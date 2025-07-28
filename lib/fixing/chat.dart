import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sos_bebe_app/fixing/screens/rev.dart';
import 'package:sos_bebe_app/fixing/services/consultation_service.dart';
import 'package:sos_bebe_app/fixing/services/showPaymentModalBottomSheet.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sos_bebe_app/utils_api/shared_pref_keys.dart' as pref_keys;
import '../datefacturare/date_facturare_completare_rapida.dart' as s;
import 'package:path/path.dart' as path;
import '../intro_screen.dart';

class ChatScreen extends StatefulWidget {
  final bool isDoctor;
  final String doctorId;
  final String patientId;
  final String doctorName;
  final String patientName;
  final String chatRoomId;
  final bool recommendation;
  final double amount;
  final String sessionId ;


  const ChatScreen({
    super.key,
    required this.isDoctor,
    required this.doctorId,
    required this.patientId,
    required this.doctorName,
    required this.patientName,
    required this.chatRoomId,
    required this.amount,
    this.recommendation = false,
    required this.sessionId
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
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
  int _completionTimerSeconds = 60;
  Timer? _completionTimer;
  ValueNotifier<int>? _completionTimerNotifier;
  final ScrollController _scrollController = ScrollController();

  final ConsultationService _consultationService = ConsultationService();

  @override
  void initState() {
    super.initState();
    if (widget.isDoctor) {
      currentUserId = widget.doctorId;
      currentUserName = widget.doctorName;
      otherUserId = widget.patientId;
      otherUserName = widget.patientName;
    } else {
      currentUserId = widget.patientId;
      currentUserName = widget.patientName;
      otherUserId = widget.doctorId;
      otherUserName = widget.doctorName;
    }

    _initializeChatRoom();
    _startTimer();
  }

  Future<void> _initializeChatRoom() async {
    try {
      final chatRoomRef = _firestore.collection('chat_rooms').doc(widget.chatRoomId);
      final chatRoomSnapshot = await chatRoomRef.get();
      if (!chatRoomSnapshot.exists) {
        await chatRoomRef.set({
          'createdAt': FieldValue.serverTimestamp(),
          'participants': [widget.doctorId, widget.patientId],
          'conversationCompleted': false,
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

  Future<void> _setConversationCompletedTrue() async {
    try {
      final chatRoomRef = _firestore.collection('chat_rooms').doc(widget.chatRoomId);
      await chatRoomRef.update({
        'conversationCompleted': true,
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error setting conversation completed: $e')),
        );
      }
    }
  }

  Future<void> _setConversationCompletedFalse() async {
    try {
      final chatRoomRef = _firestore.collection('chat_rooms').doc(widget.chatRoomId);
      await chatRoomRef.update({
        'conversationCompleted': false,
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error setting conversation not completed: $e')),
        );
      }
    }
  }

  Future<bool> _checkConversationCompleted() async {
    try {
      final chatRoomRef = _firestore.collection('chat_rooms').doc(widget.chatRoomId);
      final chatRoomSnapshot = await chatRoomRef.get();
      if (chatRoomSnapshot.exists) {
        final data = chatRoomSnapshot.data();
        bool conversationCompleted = data?['conversationCompleted'] ?? false;
        if (!conversationCompleted) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Așteaptă răspunsul medicului înainte să ieși.')),
            );
          }
          return false;
        }
        return true;
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Chat room not found.')),
          );
        }
        return false;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error checking conversation status: $e')),
        );
      }
      return false;
    }
  }

  Future<void> _sendFeedbackMessage({
    required String message,
    required String visibility,
    String senderId = 'system',
    String senderName = 'System',
    bool conversationCompleted = true,
  }) async {
    try {
      final feedbackMessage = {
        'senderId': senderId,
        'senderName': senderName,
        'type': 'text',
        'message': message,
        'fileUrl': null,
        'fileName': null,
        'timestamp': FieldValue.serverTimestamp(),
        'visibility': visibility,
      };

      await _firestore
          .collection('chat_rooms')
          .doc(widget.chatRoomId)
          .collection('messages')
          .add(feedbackMessage);

      if (conversationCompleted) {
        await _firestore.collection('chat_rooms').doc(widget.chatRoomId).update({
          'conversationCompleted': true,
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending feedback message: $e')),
        );
      }
    }
  }

  void _sendMessage({String? fileUrl, String? fileName, String visibility = 'both'}) async {
    if (_messageController.text.trim().isEmpty && fileUrl == null) return;
    if (_messageSent) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Poți trimite doar un singur mesaj pe sesiune.')
          ),
        );
      }
      return;
    }

    final message = {
      'senderId': currentUserId,
      'senderName': currentUserName,
      'type': fileUrl != null ? 'file' : 'text',
      'message': fileUrl != null ? (fileName ?? '') : _messageController.text.trim(),
      'fileUrl': fileUrl,
      'fileName': fileName,
      'timestamp': FieldValue.serverTimestamp(),
      'visibility': visibility,
    };

    try {
      await _firestore
          .collection('chat_rooms')
          .doc(widget.chatRoomId)
          .collection('messages')
          .add(message);
      if (mounted) {
        setState(() {
          _uploadedFileUrl = null;
          _fileName = null;
          _fileExtension = null;
          _fileBase64 = null;
          _messageSent = true;
          _timerEnded = true;
          _showTimerDialog = false;
          _secondsRemaining = 0;
          _timerNotifier.value = 0;
          _timer.cancel();
        });
        _messageController.clear();
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.minScrollExtent);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending message: $e')),
        );
      }
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted && _secondsRemaining > 0 && !_timerEnded && !_messageSent) {
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
    if (!_timerEnded && !_messageSent) {
      if (mounted) {
        setState(() {
          _showTimerDialog = true;
        });
      }
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remaining = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remaining.toString().padLeft(2, '0')}';
  }







// Show modal bottom sheet with picker options
  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Fă o poză'),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickFile(fromCamera: true);
                  if (mounted && _fileBase64 != null) {
                    await _uploadFile();
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Alege din galerie'),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickFile(fromCamera: false);
                  if (mounted && _fileBase64 != null) {
                    await _uploadFile();
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Pick image from camera or gallery
  Future<void> _pickFile({bool fromCamera = false}) async {
    final picker = ImagePicker();
    XFile? pickedFile;

    try {
      if (fromCamera) {
        pickedFile = await picker.pickImage(source: ImageSource.camera);
      } else {
        pickedFile = await picker.pickImage(source: ImageSource.gallery);
      }

      if (pickedFile != null && mounted) {
        final file = File(pickedFile.path);
        final fileBytes = await file.readAsBytes();
        setState(() {
          _fileBase64 = base64Encode(fileBytes);
          _fileName = pickedFile!.name.split('.').first;
          _fileExtension = '.' + (pickedFile.name.split('.').last);
          _errorMessage = null;
        });
      } else if (mounted) {
        setState(() {
          _errorMessage = 'No image selected';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error picking image: $e';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  // Upload file method (with minor improvements)
  Future<void> _uploadFile() async {
    if (_fileBase64 == null || _fileName == null || _fileExtension == null) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Please select an image first';
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String user = 'dr@d.com'; // TODO: Replace with dynamic value
      String userPassMD5 = 'e10adc3949ba59abbe56e057f20f883e'; // TODO: Replace with dynamic value
      String pIdMedic = '9'; // TODO: Replace with dynamic value

      String? fileUrl = await apiCallFunctions.adaugaMesajCuAtasamentDinContMedic(
        pCheie: '6nDjtwV4kPUsIuBtgLhV4bTZNerrxzThPGImSsFa',
        pUser: user,
        pParolaMD5: userPassMD5,
        pIdMedic: pIdMedic,
        pMesaj: 'File Attachment: $_fileName$_fileExtension',
        pDenumireFisier: _fileName!,
        pExtensie: _fileExtension!,
        pSirBitiDocument: _fileBase64!,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
          if (fileUrl != null && fileUrl!.isNotEmpty) {
            fileUrl = fileUrl!.trim();
            fileUrl = Uri.encodeFull(fileUrl!);
            _uploadedFileUrl = fileUrl;
            _errorMessage = null;
            _sendMessage(fileUrl: fileUrl, fileName: '$_fileName$_fileExtension', visibility: 'both');
          } else {
            _errorMessage = 'Upload failed - no URL returned';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error uploading file: $e';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading file: $e')),
        );
      }
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
              String url = message['fileUrl'] ?? '';
              final cleanUrl = url.trim();
              final uri = Uri.tryParse(cleanUrl);
              if (uri != null && await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Nu s-a putut deschide fișierul')
                    ),
                  );
                }
              }
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: 8),
                Image.asset('assets/img.png', height: 150),
                const SizedBox(width: 8),
                Icon(
                  Icons.download,
                  color: isMe ? Colors.white : Colors.blue,
                  size: 24.0,
                ),
                const SizedBox(width: 8),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Center(
          child: Text(
            widget.isDoctor ? widget.patientName : widget.doctorName,
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
                      .doc(widget.chatRoomId)
                      .collection('messages')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final messages = snapshot.data?.docs ?? [];

                    if (messages.isEmpty) {
                      return const Center(child: Text('No messages yet.'));
                    }

                    final filteredMessages = messages.where((doc) {
                      final message = doc.data() as Map<String, dynamic>?;
                      if (message == null) return false;
                      final visibility = message['visibility'] as String? ?? 'both';
                      if (visibility == 'both') return true;
                      if (widget.isDoctor && visibility == 'doctor') return true;
                      if (!widget.isDoctor && visibility == 'patient') return true;
                      return false;
                    }).toList();

                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (_scrollController.hasClients) {
                        _scrollController.jumpTo(_scrollController.position.minScrollExtent);
                      }
                    });

                    return ListView.builder(
                      controller: _scrollController,
                      reverse: true,
                      padding: EdgeInsets.all(8.0),
                      itemCount: filteredMessages.length,
                      itemBuilder: (context, index) {
                        final message = filteredMessages[index].data() as Map<String, dynamic>?;
                        if (message == null) {
                          return SizedBox.shrink();
                        }
                        final isMe = message['senderId'] == currentUserId;
                        return _buildMessage(message, isMe);
                      },
                    );
                  },
                ),
              ),
              if (!_timerEnded && !_messageSent)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
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
                  ],
                ),
              StreamBuilder<DocumentSnapshot>(
                stream: _firestore.collection('chat_rooms').doc(widget.chatRoomId).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting ||
                      !snapshot.hasData ||
                      !snapshot.data!.exists) {
                    _completionTimer?.cancel();
                    return const SizedBox.shrink();
                  }

                  final isCompleted = snapshot.data?.data() != null
                      ? (snapshot.data!.data() as Map<String, dynamic>)['conversationCompleted'] as bool? ?? false
                      : false;

                  if (!isCompleted) {
                    _completionTimer?.cancel();
                    return const SizedBox.shrink();
                  }

                  _completionTimerNotifier ??= ValueNotifier<int>(_completionTimerSeconds);

                  if (_completionTimer == null || !_completionTimer!.isActive) {
                    _completionTimer = Timer.periodic(const Duration(seconds: 1), (t) {
                      if (_completionTimerNotifier!.value <= 0) {
                        t.cancel();
                        _completionTimer = null;
                        _completionTimerNotifier?.dispose();
                        _completionTimerNotifier = null;
                        if (mounted) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TestimonialScreenSimple(
                                idMedic: int.parse(widget.doctorId),
                              ),
                            ),
                                (Route<dynamic> route) => false,
                          );
                        }
                      } else {
                        _completionTimerNotifier!.value--;
                        _completionTimerSeconds = _completionTimerNotifier!.value;
                      }
                    });
                  }

                  return ValueListenableBuilder<int>(
                    valueListenable: _completionTimerNotifier!,
                    builder: (context, secondsLeft, child) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Visibility(
                          visible: secondsLeft > 0,
                          child: Text(
                            secondsLeft == 0 ? 'Calculating...' : 'Time remaining: ${_formatTime(secondsLeft)}',
                            style: const TextStyle(fontSize: 16, color: Colors.red),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    if (_secondsRemaining > 0 && !_timerEnded && !_messageSent && !widget.recommendation)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _showTimerDialogg,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                            backgroundColor: const Color(0xFF62CD9C),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          child: const Text(
                            'TRIMITE ÎNTREBAREA',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    if (_secondsRemaining > 0 && !_timerEnded && !_messageSent && widget.recommendation)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {

                            _showPickerOptions();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF62CD9C),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          ),
                          icon: Icon(Icons.attach_file),
                          label: Text(
                            'Trimite fișier',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    if (_timerEnded || _messageSent)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 70,
                            width: 180,
                            child: ElevatedButton(
                              onPressed: () async {
                                bool canExit = await _checkConversationCompleted();
                                if (canExit && mounted) {
                                  await _sendFeedbackMessage(
                                    message: 'Chatul s-a încheiat din partea pacientului. Apreciem timpul acordat! 🕒',
                                    visibility: 'doctor',
                                  );
                                  await _consultationService.updateConsultationStatus(
                                   int.parse( widget.sessionId),
                                    'callEnded',
                                  );
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TestimonialScreenSimple(
                                        idMedic: int.parse(widget.doctorId),
                                      ),
                                    ),
                                        (Route<dynamic> route) => false,
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  side:  BorderSide(color:Colors.red /*Color(0xFF697191)*/, width: 1),
                                ),
                              ),
                              child: const Text(
                                'NU\nVă mulțumesc',
                                style: TextStyle(color: Colors.white  /*Color(0xFF697191)*/),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            height: 70,
                            child: ElevatedButton(
                              onPressed: () async {
                                bool canPay = await _checkConversationCompleted();
                                if (!canPay || !mounted) return;
                                await _sendFeedbackMessage(
                                  message: '🧑‍⚕️ „Pacientul dorește să mai pună o întrebare. 💬 Este în curs de efectuare a plății 💳 — te rugăm să aștepți ⏳.',
                                  visibility: 'doctor',
                                  conversationCompleted: false,
                                );
                                await _setConversationCompletedFalse();
                                showPaymentModalBottomSheet(
                                  paientId: widget.patientId,
                                  whenCompleteFunction: (paymentResults) async {
                                    if (!paymentResults) {
                                      await _sendFeedbackMessage(
                                        message: '🧑‍⚕️ „Pacientul tocmai a anulat procesul de plată ❌💳. Sesiunea se va încheia în 1 minut ⏱️ dacă nu efectuează plata sau nu iese.',
                                        visibility: 'doctor',
                                      );
                                      await _setConversationCompletedTrue();
                                    }
                                  },
                                  onClose: () async {
                                    await _sendFeedbackMessage(
                                      message: '🧑‍⚕️ „Pacientul tocmai a anulat procesul de plată ❌💳. Sesiunea se va încheia în 1 minut ⏱️ dacă nu efectuează plata sau nu iese.',
                                      visibility: 'doctor',
                                    );
                                    await _setConversationCompletedTrue();
                                  },
                                  context: context,
                                  amount: widget.amount,
                                  onSuccess: () {
                                    _sendFeedbackMessage(
                                      message: ' PLATA EFECTUATĂ. POȚI ÎNTREBA MEDICUL ✅🕒.',
                                      visibility: 'patient',
                                      conversationCompleted: false,
                                    );
                                    _sendFeedbackMessage(
                                      message: ' PLATA EFECTUATĂ ✅.',
                                      visibility: 'doctor',
                                      conversationCompleted: false,
                                    );


                                    _setConversationCompletedFalse();
                                    _timer.cancel();
                                    if (mounted) {
                                      setState(() {
                                        _timerEnded = false;
                                        _showTimerDialog = true;
                                        _secondsRemaining = 10 * 60;
                                        _timerNotifier.value = 10 * 60;
                                        _messageSent = false;
                                      });
                                      _startTimer();
                                    }
                                  },
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF62CD9C),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              child: const Text(
                                'DA\nMai doresc o întrebare',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (_showTimerDialog && !_timerEnded && !_messageSent && !widget.recommendation)
            ValueListenableBuilder<int>(
              valueListenable: _timerNotifier,
              builder: (context, seconds, child) {
                return TimerDialog(
                  onSend: (message) {
                    _messageController.text = message;
                    _sendMessage(visibility: 'both');
                    if (mounted) {
                      setState(() {
                        _showTimerDialog = false;
                      });
                    }
                  },
                  onClose: () {
                    if (mounted) {
                      setState(() {
                        _showTimerDialog = false;
                      });
                    }
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
    _completionTimer?.cancel();
    _completionTimerNotifier?.dispose();
    _scrollController.dispose();
    super.dispose();
  }




}

class TimerDialog extends StatefulWidget {
  final Function(String) onSend;
  final VoidCallback onClose;
  final int secondsRemaining;

  const TimerDialog({
    super.key,
    required this.onSend,
    required this.onClose,
    required this.secondsRemaining,
  });

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

