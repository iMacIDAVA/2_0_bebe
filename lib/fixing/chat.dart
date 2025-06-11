import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sos_bebe_app/utils_api/shared_pref_keys.dart' as pref_keys;
import '../datefacturare/date_facturare_completare_rapida.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;

class ChatScreen extends StatefulWidget {
  final bool isDoctor;

  const ChatScreen({super.key, required this.isDoctor});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String doctorId = 'DOCTOR_12345';
  static const String doctorName = 'Dr. Smith';
  static const String patientId = 'PATIENT_67890';
  static const String patientName = 'John Doe';

  late String chatRoomId;
  late String currentUserId;
  late String currentUserName;
  late String otherUserId;
  late String otherUserName;
  bool _showTimerDialog = true;
  bool _timerEnded = false;
  int _secondsRemaining = 10 * 60;
  late Timer _timer;
  bool _messageSent = false;
  final ValueNotifier<int> _timerNotifier = ValueNotifier<int>(10 * 60);

  String? _fileName;
  String? _fileExtension;
  String? _fileBase64;
  String? _uploadedFileUrl;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.isDoctor) {
      currentUserId = doctorId;
      currentUserName = doctorName;
      otherUserId = patientId;
      otherUserName = patientName;
    } else {
      currentUserId = patientId;
      currentUserName = patientName;
      otherUserId = doctorId;
      otherUserName = doctorName;
    }

    final ids = [currentUserId, otherUserId]..sort();
    chatRoomId = '${ids[0]}_${ids[1]}';

    _initializeChatRoom();
    _startTimer();
  }

  Future<void> _initializeChatRoom() async {
    try {
      final chatRoomRef = _firestore.collection('chat_rooms').doc(chatRoomId);
      final chatRoomSnapshot = await chatRoomRef.get();
      if (!chatRoomSnapshot.exists) {
        await chatRoomRef.set({
          'createdAt': FieldValue.serverTimestamp(),
          'participants': [doctorId, patientId],
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error initializing chat room: $e')),
        );
      }
    }
  }

  void _sendMessage({String? fileUrl, String? fileName}) async {
    if (_messageController.text.trim().isEmpty && fileUrl == null) return;

    final message = {
      'senderId': currentUserId,
      'senderName': currentUserName,
      'type': fileUrl != null ? 'file' : 'text',
      'message': fileUrl != null ? (fileName ?? '') : _messageController.text.trim(),
      'fileUrl': fileUrl,
      'fileName': fileName,
      'timestamp': FieldValue.serverTimestamp(),
    };

    try {
      await _firestore
          .collection('chat_rooms')
          .doc(chatRoomId)
          .collection('messages')
          .add(message);
      _messageController.clear();
      setState(() {
        _uploadedFileUrl = null;
        _fileName = null;
        _fileExtension = null;
        _fileBase64 = null;
      });
      if(fileUrl != null)
        return ;
          if (!_messageSent  ) {
            _messageSent = true;
            _timer.cancel();
            setState(() {
              _timerEnded = true;
              _showTimerDialog = false;
              _secondsRemaining = 0;
              _timerNotifier.value = 0;
            });
          }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending message: $e')),
        );
      }
    }
  }
  // Future<void> _sendMessage(String message) async {
  //   try {
  //     await _firestore
  //         .collection('chat_rooms')
  //         .doc(chatRoomId)
  //         .collection('messages')
  //         .add({
  //       'senderId': currentUserId,
  //       'senderName': currentUserName,
  //       'message': message,
  //       'timestamp': FieldValue.serverTimestamp(),
  //     });
  //     if (!_messageSent) {
  //       _messageSent = true;
  //       _timer.cancel();
  //       setState(() {
  //         _timerEnded = true;
  //         _showTimerDialog = false;
  //         _secondsRemaining = 0;
  //         _timerNotifier.value = 0;
  //       });
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Error sending message: $e')),
  //       );
  //     }
  //   }
  // }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted && _secondsRemaining > 0 && !_timerEnded) {
        _secondsRemaining--;
        _timerNotifier.value = _secondsRemaining;
      } else {
        timer.cancel();
        if (mounted) {
          setState(() {
            _timerEnded = true;
            _showTimerDialog = false;
          });
        }
      }
    });
    if (mounted) {
      setState(() {
        _showTimerDialog = true;
      });
    }
  }

  void _showTimerDialogg() {
    if (!_timerEnded) {
      setState(() {
        _showTimerDialog = true;
      });
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remaining = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remaining.toString().padLeft(2, '0')}';
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result != null && result.files.single.path != null) {
        File file = File(result.files.single.path!);
        _fileName = path.basenameWithoutExtension(file.path);
        _fileExtension = path.extension(file.path);

        List<int> fileBytes = await file.readAsBytes();
        _fileBase64 = base64Encode(fileBytes);

        setState(() {
          _errorMessage = null;
        });
      } else {
        setState(() {
          _errorMessage = 'No file selected';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error picking file: $e';
      });
    }
  }

  Future<void> _uploadFile() async {
    if (_fileBase64 == null || _fileName == null || _fileExtension == null) {
      setState(() {
        _errorMessage = 'Please select a file first';
      });
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      // Get actual user credentials
      String user =  'dr@d.com';
      String userPassMD5 = 'e10adc3949ba59abbe56e057f20f883e';
      String pIdMedic = '9'; // Your hardcoded doctor ID

      // Debug prints for all parameters
      print("=== Upload Debug Info ===");
      print("User: $user");
      print("Password MD5: $userPassMD5");
      print("Doctor ID: $pIdMedic");
      print("File Name: $_fileName");
      print("File Extension: $_fileExtension");
      print("File Base64 Length: ${_fileBase64?.length}");
      print("API Key: 6nDjtwV4kPUsIuBtgLhV4bTZNerrxzThPGImSsFa");

      String? fileUrl = await apiCallFunctions.adaugaMesajCuAtasamentDinContMedic(
        pCheie: '6nDjtwV4kPUsIuBtgLhV4bTZNerrxzThPGImSsFa',
        pUser: user,
        pParolaMD5: userPassMD5,
        pIdMedic: pIdMedic,
        pMesaj: "File Attachment: $_fileName$_fileExtension",
        pDenumireFisier: _fileName!,
        pExtensie: _fileExtension!,
        pSirBitiDocument: _fileBase64!,
      );

      print("=== Upload Response ===");
      print("File URL: $fileUrl");

      setState(() {
        _isLoading = false;
        if (fileUrl != null) {
          fileUrl = fileUrl?.trim();
          fileUrl = Uri.encodeFull(fileUrl!);
          _uploadedFileUrl = fileUrl;
          _errorMessage = null;
          print("Upload successful! URL: $fileUrl");
          _sendMessage(fileUrl: fileUrl, fileName: '$_fileName$_fileExtension' ,);
        } else {
          _errorMessage = 'Upload failed - no URL returned';
          print("Upload failed - no URL returned");
        }
      });
    } catch (e) {
      print("=== Upload Error ===");
      print("Error details: $e");
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error uploading file: $e';
      });
    }
  }

  Future<void> _openFile(String url, String fileName, BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(

        backgroundColor: Colors.white,
        title: Text('File: $fileName'),
        content: const Text('Would you like to view or download the file?'),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              // Ensure URL is trimmed and valid
              final cleanUrl = url.trim();
              final uri = Uri.parse(cleanUrl);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Could not open file')),
                );
              }
            },
            child: const Text('View'),
          ),
          TextButton(
            onPressed: () async {

              _downloadFile(url, "filename", context);

            },
            child: const Text('Download'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  AppBar(
        title: Center(
          child: Text(
            doctorName,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        backgroundColor: Color(0xFF62CD9C),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('chat_rooms')
                      .doc(chatRoomId)
                      .collection('messages')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Center(child: Text('Error: '));
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final messages = snapshot.data?.docs ?? [];

                    if (messages.isEmpty) {
                      return const Center(child: Text('No messages yet.'));
                    }

                    // return ListView.builder(
                    //   reverse: true,
                    //   padding: const EdgeInsets.all(8.0),
                    //   itemCount: messages.length,
                    //   itemBuilder: (context, index) {
                    //     final message = messages[index].data() as Map<String, dynamic>?;
                    //     if (message == null) {
                    //       return const SizedBox.shrink();
                    //     }
                    //     final isMe = message['senderId'] == currentUserId;
                    //     final timestamp = (message['timestamp'] as Timestamp?)?.toDate();
                    //     final formattedTime = timestamp != null
                    //         ? DateFormat('HH:mm').format(timestamp)
                    //         : '';
                    //
                    //     return Align(
                    //       alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                    //       child: Column(
                    //         crossAxisAlignment:
                    //         isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    //         children: [
                    //           Container(
                    //             margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                    //             padding: const EdgeInsets.all(30.0),
                    //             decoration: BoxDecoration(
                    //               color: isMe ? const Color(0xFF62CD9C) : Colors.grey[200],
                    //               borderRadius: BorderRadius.circular(12.0),
                    //             ),
                    //             child: Text(
                    //               message['message'] ?? '',
                    //               style: TextStyle(
                    //                 fontSize: 16.0,
                    //                 color: isMe ? Colors.white : Colors.black,
                    //               ),
                    //             ),
                    //           ),
                    //           Padding(
                    //             padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                    //             child: Text(
                    //               formattedTime,
                    //               style: const TextStyle(
                    //                 fontSize: 10.0,
                    //                 color: Colors.grey,
                    //               ),
                    //             ),
                    //           ),
                    //         ],
                    //       ),
                    //     );
                    //   },
                    // );

                    return ListView.builder(
                      reverse: true,
                      padding: EdgeInsets.all(8.0),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index].data() as Map<String, dynamic>?;
                        if (message == null) {
                          return SizedBox.shrink();
                        }
                        final isMe = message['senderId'] == currentUserId;
                        return _buildMessage(message, isMe);
                      },
                      //physics: NeverScrollableScrollPhysics(),
                    );


                  },
                ),
              ),
              if (!_timerEnded)
                Row(mainAxisAlignment:MainAxisAlignment.center,
                  children: [
                  ValueListenableBuilder<int>(
                    valueListenable: _timerNotifier,
                    builder: (context, seconds, child) {
                      return Row(
                        children: [
                          Text(
                            _formatTime(seconds),
                            style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 5),
                          const Icon(Icons.timer, color: Colors.red),
                        ],
                      );
                    },
                  ),
                ],),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [

                    if (_secondsRemaining > 0 && !_timerEnded)
                      ElevatedButton(

                        onPressed: _showTimerDialogg,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),

                          backgroundColor: const Color(0xFF62CD9C),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: const Text('TRIMITE ÎNTREBAREA', style: TextStyle(color: Colors.white  ,fontWeight:  FontWeight.w500)),
                      ),
                    if (_secondsRemaining > 0 && !_timerEnded)
                      ElevatedButton.icon(
                      onPressed:  () async {
                                await _pickFile();
                                if (_fileBase64 != null) {
                                await _uploadFile();
                                }
                                },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF62CD9C), // Green background
                        foregroundColor: Colors.white,      // White icon/text
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      ),
                      icon: Icon(Icons.attach_file), // Paperclip icon
                      label: Text(
                        'Trimite fișier',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ),

                    if (_timerEnded)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 70,
                            child: ElevatedButton(
                              onPressed: () {
                               // Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  side: const BorderSide(color: Color(0xFF697191)
                                      , width: 1), // Add black border
                                ),
                              ),
                              child: const Text('NU\nVă mulțumesc', style: TextStyle(color: Color(0xFF697191)
                              )),
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            height: 70,
                            child: ElevatedButton(
                              onPressed: () {
                                // setState(() {
                                //   _timerEnded = false;
                                //   _secondsRemaining = 10 * 60;
                                //   _showTimerDialog = true;
                                //   _timerNotifier.value = _secondsRemaining;
                                //   _startTimer();
                                // });
                              },
                              style: ElevatedButton.styleFrom(

                                backgroundColor: const Color(0xFF62CD9C),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              child: const Text('DA\nMai dorești o întrebare', style: TextStyle(color: Colors.white)),
                            ),
                          ),


                        ],
                      ),
                  ],
                ),
              ),


            ],
          ),
          if (_showTimerDialog && !_timerEnded)
            ValueListenableBuilder<int>(
              valueListenable: _timerNotifier,
              builder: (context, seconds, child) {
                return TimerDialog(
                  onSend: (message) {
                    _messageController.text = message ;
                    _sendMessage();
                    setState(() {
                      _showTimerDialog = false;
                    });
                  },
                  onClose: () {
                    setState(() {
                      _showTimerDialog = false;
                    });
                  },
                  secondsRemaining: seconds,
                );
              },
            ),

        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    _timerNotifier.dispose();
    _messageController.dispose();
    super.dispose();
  }


  Future<File?> _downloadFile(String? url, String? filename, BuildContext context) async {
    if (url == null || url.trim().isEmpty || filename == null || filename.trim().isEmpty) {
      print('Invalid download parameters: url=$url, filename=$filename');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid file data')),
      );
      return null;
    }
    try {
      // Check storage permission
      final permissionStatus = await Permission.storage.request();
      if (!permissionStatus.isGranted) {
        if (permissionStatus.isPermanentlyDenied) {
          print('Storage permission permanently denied');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Storage permission permanently denied. Please enable in settings.')),
          );
          await openAppSettings(); // Prompt user to enable in settings
        } else {
          print('Storage permission denied');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Storage permission denied')),
          );
        }
        return null;
      }

      final cleanUrl = url.trim(); // Handle URL spaces
      final response = await http.get(Uri.parse(cleanUrl));
      if (response.statusCode != 200) {
        print('Download failed: HTTP ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to download file')),
        );
        return null;
      }

      // Try external storage first, fall back to temporary directory
      Directory? dir;
      try {
        dir = await getExternalStorageDirectory();
      } catch (e) {
        print('Failed to get external storage: $e');
      }
      if (dir == null) {
        dir = await getTemporaryDirectory();
        print('Falling back to temporary directory: ${dir.path}');
      }

      final file = File('${dir.path}/$filename');
      await file.writeAsBytes(response.bodyBytes);
      print('Downloaded file path: ${file.path}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('File downloaded to ${file.path}')),
      );
      return file;
    } catch (e) {
      print('Download error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error downloading file')),
      );
      return null;
    }
  }

  Widget _buildMessage(Map<String, dynamic> message, bool isMe) {
    final timestamp = (message['timestamp'] as Timestamp?)?.toDate();
    final formattedTime = timestamp != null ? DateFormat('HH:mm').format(timestamp) : '';
    final isFile = message['type'] == 'file';

    return Column(
      crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          padding: EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: isMe ? Color(0xFF62CD9C) : Colors.grey[200],
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: isFile
              ? GestureDetector(
            onTap: () async {
              {
                String url = message['fileUrl'] ;
                final cleanUrl = url.trim();
                final uri = Uri.parse(cleanUrl);
                if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
                else {
              ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Could not open file')),
              );
              }
            }
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
               // _getFileIcon(message['fileName'] ?? 'file'),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    message['fileName'] ?? 'File',
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.blue,
                   //   decoration: TextDecoration.underline,
                      fontSize: 16.0,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          )
              : Text(
            message['message'] ?? '',
            style: TextStyle(
              fontSize: 16.0,
              color: isMe ? Colors.white : Colors.black,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            formattedTime,
            style: TextStyle(
              fontSize: 10.0,
              color: Colors.grey[600],
            ),
          ),
        ),
      ],
    );
  }
}

class TimerDialog extends StatefulWidget {
  final Function(String) onSend;
  final VoidCallback onClose;
  final int secondsRemaining;

  const TimerDialog({super.key, required this.onSend, required this.onClose, required this.secondsRemaining});

  @override
  _TimerDialogState createState() => _TimerDialogState();
}

class _TimerDialogState extends State<TimerDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      widget.onSend(_controller.text);
    }
    widget.onClose();
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remaining = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remaining.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.zero,
      backgroundColor: Colors.white,
      child: Container(
        color: Colors.white,
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    const Icon(Icons.fiber_manual_record, color: Colors.red),
                    const SizedBox(width: 5),
                    Text(
                      _formatTime(widget.secondsRemaining),
                      style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 5),
                    const Icon(Icons.timer, color: Colors.red),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: widget.onClose,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF5F7FF),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          maxLength: 400,
                          maxLines: null,
                          minLines: 5,
                          keyboardType: TextInputType.multiline,
                          decoration: const InputDecoration(
                            hintText: 'Scrie text',
                            border: InputBorder.none,
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      Text(
                        '${_controller.text.length} de caractere',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _sendMessage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF06C167),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'TRIMITE ÎNTREBAREA',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}




