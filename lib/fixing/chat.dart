import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

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
  int _secondsRemaining = 10 ;//* 60;
  late Timer _timer;
  bool _messageSent = false;
  final ValueNotifier<int> _timerNotifier = ValueNotifier<int>(10 * 60);

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

  Future<void> _sendMessage(String message) async {
    try {
      await _firestore
          .collection('chat_rooms')
          .doc(chatRoomId)
          .collection('messages')
          .add({
        'senderId': currentUserId,
        'senderName': currentUserName,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
      });
      if (!_messageSent) {
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

                    return ListView.builder(
                      reverse: true,
                      padding: const EdgeInsets.all(8.0),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index].data() as Map<String, dynamic>?;
                        if (message == null) {
                          return const SizedBox.shrink();
                        }
                        final isMe = message['senderId'] == currentUserId;
                        final timestamp = (message['timestamp'] as Timestamp?)?.toDate();
                        final formattedTime = timestamp != null
                            ? DateFormat('HH:mm').format(timestamp)
                            : '';

                        return Align(
                          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment:
                            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                                padding: const EdgeInsets.all(30.0),
                                decoration: BoxDecoration(
                                  color: isMe ? const Color(0xFF62CD9C) : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: Text(
                                  message['message'] ?? '',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    color: isMe ? Colors.white : Colors.black,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                                child: Text(
                                  formattedTime,
                                  style: const TextStyle(
                                    fontSize: 10.0,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
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
                      onPressed: () {
                        // Your file sending logic here
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
                    _sendMessage(message);
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
///
// import 'dart:async';
//
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:intl/intl.dart';
//
// class ChatScreen extends StatefulWidget {
//   final bool isDoctor;
//
//   const ChatScreen({super.key, required this.isDoctor});
//
//   @override
//   _ChatScreenState createState() => _ChatScreenState();
// }
//
// class _ChatScreenState extends State<ChatScreen> {
//   final TextEditingController _messageController = TextEditingController();
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   static const String doctorId = 'DOCTOR_12345';
//   static const String doctorName = 'Dr. Smith';
//   static const String patientId = 'PATIENT_67890';
//   static const String patientName = 'John Doe';
//
//   late String chatRoomId;
//   late String currentUserId;
//   late String currentUserName;
//   late String otherUserId;
//   late String otherUserName;
//   bool _showTimerDialog = true;
//   bool _timerEnded = false;
//   int _secondsRemaining = 10 * 60;
//   late Timer _timer;
//
//   @override
//   void initState() {
//     super.initState();
//     if (widget.isDoctor) {
//       currentUserId = doctorId;
//       currentUserName = doctorName;
//       otherUserId = patientId;
//       otherUserName = patientName;
//     } else {
//       currentUserId = patientId;
//       currentUserName = patientName;
//       otherUserId = doctorId;
//       otherUserName = doctorName;
//     }
//
//     final ids = [currentUserId, otherUserId]..sort();
//     chatRoomId = '${ids[0]}_${ids[1]}';
//
//     _initializeChatRoom();
//     _startTimer();
//   }
//
//   Future<void> _initializeChatRoom() async {
//     try {
//       final chatRoomRef = _firestore.collection('chat_rooms').doc(chatRoomId);
//       final chatRoomSnapshot = await chatRoomRef.get();
//       if (!chatRoomSnapshot.exists) {
//         await chatRoomRef.set({
//           'createdAt': FieldValue.serverTimestamp(),
//           'participants': [doctorId, patientId],
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error initializing chat room: $e')),
//         );
//       }
//     }
//   }
//
//   Future<void> _sendMessage(String message) async {
//     try {
//       await _firestore
//           .collection('chat_rooms')
//           .doc(chatRoomId)
//           .collection('messages')
//           .add({
//         'senderId': currentUserId,
//         'senderName': currentUserName,
//         'message': message,
//         'timestamp': FieldValue.serverTimestamp(),
//       });
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error sending message: $e')),
//         );
//       }
//     }
//   }
//
//   void _startTimer() {
//     _timer = Timer.periodic(Duration(seconds: 1), (timer) {
//       if (mounted && _secondsRemaining > 0 && !_timerEnded) {
//         setState(() {
//           _secondsRemaining--;
//         });
//       } else {
//         timer.cancel();
//         if (mounted) {
//           setState(() {
//             _timerEnded = true;
//             _showTimerDialog = false;
//           });
//         }
//       }
//     });
//     if (mounted) {
//       setState(() {
//         _showTimerDialog = true;
//       });
//     }
//   }
//
//   void _showTimerDialogg() {
//     if (!_timerEnded) {
//       setState(() {
//         _showTimerDialog = true;
//       });
//     }
//   }
//
//   String _formatTime(int seconds) {
//     final minutes = seconds ~/ 60;
//     final remaining = seconds % 60;
//     return '${minutes.toString().padLeft(2, '0')}:${remaining.toString().padLeft(2, '0')}';
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Center(
//           child: Text(
//             otherUserName,
//             style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//           ),
//         ),
//         backgroundColor: Color(0xFF62CD9C),
//       ),
//       body: Stack(
//         children: [
//           Column(
//             children: [
//               Expanded(
//                 child: StreamBuilder<QuerySnapshot>(
//                   stream: _firestore
//                       .collection('chat_rooms')
//                       .doc(chatRoomId)
//                       .collection('messages')
//                       .orderBy('timestamp', descending: true)
//                       .snapshots(),
//                   builder: (context, snapshot) {
//                     if (snapshot.hasError) {
//                       return Center(child: Text('Error: ${snapshot.error}'));
//                     }
//                     if (snapshot.connectionState == ConnectionState.waiting) {
//                       return Center(child: CircularProgressIndicator());
//                     }
//
//                     final messages = snapshot.data?.docs ?? [];
//
//                     if (messages.isEmpty) {
//                       return Center(child: Text('No messages yet.'));
//                     }
//
//                     return ListView.builder(
//                       reverse: true,
//                       padding: EdgeInsets.all(8.0),
//                       itemCount: messages.length,
//                       itemBuilder: (context, index) {
//                         final message = messages[index].data() as Map<String, dynamic>?;
//                         if (message == null) {
//                           return SizedBox.shrink();
//                         }
//                         final isMe = message['senderId'] == currentUserId;
//                         final timestamp = (message['timestamp'] as Timestamp?)?.toDate();
//                         final formattedTime = timestamp != null
//                             ? DateFormat('HH:mm').format(timestamp)
//                             : '';
//
//                         return Align(
//                           alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
//                           child: Column(
//                             crossAxisAlignment:
//                             isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
//                             children: [
//                               Container(
//                                 margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
//                                 padding: EdgeInsets.all(12.0),
//                                 decoration: BoxDecoration(
//                                   color: isMe ? Color(0xFF62CD9C) : Colors.grey[200],
//                                   borderRadius: BorderRadius.circular(12.0),
//                                 ),
//                                 child: Text(
//                                   message['message'] ?? '',
//                                   style: TextStyle(
//                                     fontSize: 16.0,
//                                     color: isMe ? Colors.white : Colors.black,
//                                   ),
//                                 ),
//                               ),
//                               Padding(
//                                 padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
//                                 child: Text(
//                                   formattedTime,
//                                   style: TextStyle(
//                                     fontSize: 10.0,
//                                     color: Colors.grey[600],
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         );
//                       },
//                     );
//                   },
//                 ),
//               ),
//               Padding(
//                 padding: EdgeInsets.all(8.0),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     if (!_timerEnded)
//                       Row(
//                         children: [
//                           Text(
//                             _formatTime(_secondsRemaining),
//                             style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
//                           ),
//                           SizedBox(width: 5),
//                           Icon(Icons.timer, color: Colors.red),
//                         ],
//                       ),
//                     if (_secondsRemaining > 0 && !_timerEnded)
//                       ElevatedButton(
//                         onPressed: _showTimerDialogg,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Color(0xFF62CD9C),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8.0),
//                           ),
//                         ),
//                         child: Text('TRIMITE ÎNTREBAREA', style: TextStyle(color: Colors.white)),
//                       ),
//                     if (_timerEnded)
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           ElevatedButton(
//                             onPressed: () {
//                               setState(() {
//                                 _timerEnded = false;
//                                 _secondsRemaining = 10 * 60; // Reset for new session
//                                 _showTimerDialog = true;
//                                 _startTimer(); // Restart timer
//                               });
//                             },
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Color(0xFF62CD9C),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(8.0),
//                               ),
//                             ),
//                             child: Text('DA\nMai dorești o întrebare', style: TextStyle(color: Colors.white)),
//                           ),
//                           SizedBox(width: 10),
//                           ElevatedButton(
//                             onPressed: () {
//                               Navigator.pop(context);
//                             },
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.grey[200],
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(8.0),
//                               ),
//                             ),
//                             child: Text('NU\nVă mulțumesc', style: TextStyle(color: Colors.grey[600])),
//                           ),
//                         ],
//                       ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           if (_showTimerDialog && !_timerEnded)
//             TimerDialog(
//               onSend: (message) {
//                 _sendMessage(message);
//                 setState(() {
//                   _showTimerDialog = false;
//                 });
//               },
//               onClose: () {
//                 setState(() {
//                   _showTimerDialog = false;
//                 });
//               },
//               secondsRemaining: _secondsRemaining,
//             ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     _timer.cancel();
//     _messageController.dispose();
//     super.dispose();
//   }
// }
//
// class TimerDialog extends StatefulWidget {
//   final Function(String) onSend;
//   final VoidCallback onClose;
//   final int secondsRemaining;
//
//   const TimerDialog({super.key, required this.onSend, required this.onClose, required this.secondsRemaining});
//
//   @override
//   _TimerDialogState createState() => _TimerDialogState();
// }
//
// class _TimerDialogState extends State<TimerDialog> {
//   final TextEditingController _controller = TextEditingController();
//
//   @override
//   void initState() {
//     super.initState();
//   }
//
//   void _sendMessage() {
//     if (_controller.text.isNotEmpty) {
//       widget.onSend(_controller.text);
//     }
//     widget.onClose();
//   }
//
//   String _formatTime(int seconds) {
//     final minutes = seconds ~/ 60;
//     final remaining = seconds % 60;
//     return '${minutes.toString().padLeft(2, '0')}:${remaining.toString().padLeft(2, '0')}';
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       insetPadding: EdgeInsets.zero,
//       backgroundColor: Colors.white,
//       child: Container(
//         color: Colors.white,
//         width: double.infinity,
//         height: double.infinity,
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Row(
//                   children: [
//                     const Icon(Icons.fiber_manual_record, color: Colors.red),
//                     const SizedBox(width: 5),
//                     Text(
//                       _formatTime(widget.secondsRemaining),
//                       style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
//                     ),
//                     const SizedBox(width: 5),
//                     const Icon(Icons.timer, color: Colors.red),
//                   ],
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.close, color: Colors.grey),
//                   onPressed: widget.onClose,
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             Expanded(
//               child: Padding(
//                 padding: EdgeInsets.all(12),
//                 child: Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFF5F7FF),
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Column(
//                     children: [
//                       Expanded(
//                         child: TextField(
//                           controller: _controller,
//                           maxLength: 400,
//                           maxLines: null,
//                           minLines: 5,
//                           keyboardType: TextInputType.multiline,
//                           decoration: const InputDecoration(
//                             hintText: 'Scrie text',
//                             border: InputBorder.none,
//                           ),
//                           onChanged: (_) => setState(() {}),
//                         ),
//                       ),
//                       Text(
//                         '${_controller.text.length} de caractere',
//                         style: TextStyle(color: Colors.grey[600]),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),
//             SizedBox(
//               width: double.infinity,
//               height: 50,
//               child: ElevatedButton(
//                 onPressed: _sendMessage,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Color(0xFF06C167),
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                 ),
//                 child: const Text(
//                   'TRIMITE ÎNTREBAREA',
//                   style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

/// //////////////////////////////////////////////////////////////

// class ChatScreen extends StatefulWidget {
//   final bool isDoctor;
//
//   const ChatScreen({super.key, required this.isDoctor});
//
//   @override
//   _ChatScreenState createState() => _ChatScreenState();
// }
// class _ChatScreenState extends State<ChatScreen> {
//   final TextEditingController _messageController = TextEditingController();
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   static const String doctorId = 'DOCTOR_12345';
//   static const String doctorName = 'Dr. Smith';
//   static const String patientId = 'PATIENT_67890';
//   static const String patientName = 'John Doe';
//
//   late String chatRoomId;
//   late String currentUserId;
//   late String currentUserName;
//   late String otherUserId;
//   late String otherUserName;
//
//   @override
//   void initState() {
//     super.initState();
//     if (widget.isDoctor) {
//       currentUserId = doctorId;
//       currentUserName = doctorName;
//       otherUserId = patientId;
//       otherUserName = patientName;
//     } else {
//       currentUserId = patientId;
//       currentUserName = patientName;
//       otherUserId = doctorId;
//       otherUserName = doctorName;
//     }
//
//     final ids = [currentUserId, otherUserId]..sort();
//     chatRoomId = '${ids[0]}_${ids[1]}';
//
//     _initializeChatRoom();
//   }
//
//   Future<void> _initializeChatRoom() async {
//     try {
//       final chatRoomRef = _firestore.collection('chat_rooms').doc(chatRoomId);
//       final chatRoomSnapshot = await chatRoomRef.get();
//       if (!chatRoomSnapshot.exists) {
//         await chatRoomRef.set({
//           'createdAt': FieldValue.serverTimestamp(),
//           'participants': [doctorId, patientId],
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error initializing chat room: $e')),
//         );
//       }
//     }
//   }
//
//   Future<void> _sendMessage(String message) async {
//     try {
//       await _firestore
//           .collection('chat_rooms')
//           .doc(chatRoomId)
//           .collection('messages')
//           .add({
//         'senderId': currentUserId,
//         'senderName': currentUserName,
//         'message': message,
//         'timestamp': FieldValue.serverTimestamp(),
//       });
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error sending message: $e')),
//         );
//       }
//     }
//   }
//
//   Future<void> _showTimerDialog() async {
//     try {
//       showDialog(
//
//         context: context,
//         builder: (context) => TimerDialog(
//           onSend: (message) {
//             _sendMessage(message);
//           },
//         ),
//       ).then((value) => setState(() {}));
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error opening dialog: $e')),
//         );
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Center(
//           child: Text(
//             otherUserName,
//             style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//           ),
//         ),
//         backgroundColor: Color(0xFF62CD9C),
//       ),
//       body:
//
//       Column(
//         children: [
//           Expanded(
//             child: StreamBuilder<QuerySnapshot>(
//               stream: _firestore
//                   .collection('chat_rooms')
//                   .doc(chatRoomId)
//                   .collection('messages')
//                   .orderBy('timestamp', descending: true)
//                   .snapshots(),
//               builder: (context, snapshot) {
//                 if (snapshot.hasError) {
//                   return Center(child: Text('Error: ${snapshot.error}'));
//                 }
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return Center(child: CircularProgressIndicator());
//                 }
//
//                 final messages = snapshot.data?.docs ?? [];
//
//                 if (messages.isEmpty) {
//                   return Center(child: Text('No messages yet.'));
//                 }
//
//                 return ListView.builder(
//                   reverse: true,
//                   padding: EdgeInsets.all(8.0),
//                   itemCount: messages.length,
//                   itemBuilder: (context, index) {
//                     final message = messages[index].data() as Map<String, dynamic>?;
//                     if (message == null) {
//                       return SizedBox.shrink();
//                     }
//                     final isMe = message['senderId'] == currentUserId;
//                     final timestamp = (message['timestamp'] as Timestamp?)?.toDate();
//                     final formattedTime = timestamp != null
//                         ? DateFormat('HH:mm').format(timestamp)
//                         : '';
//
//                     return Align(
//                       alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
//                       child: Column(
//                         crossAxisAlignment:
//                         isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
//                         children: [
//                           Container(
//                             margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
//                             padding: EdgeInsets.all(12.0),
//                             decoration: BoxDecoration(
//                               color: isMe ? Color(0xFF62CD9C) : Colors.grey[200],
//                               borderRadius: BorderRadius.circular(12.0),
//                             ),
//                             child: Text(
//                               message['message'] ?? '',
//                               style: TextStyle(
//                                 fontSize: 16.0,
//                                 color: isMe ? Colors.white : Colors.black,
//                               ),
//                             ),
//                           ),
//                           Padding(
//                             padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
//                             child: Text(
//                               formattedTime,
//                               style: TextStyle(
//                                 fontSize: 10.0,
//                                 color: Colors.grey[600],
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//           Padding(
//             padding: EdgeInsets.all(8.0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 ElevatedButton(
//                   onPressed: _showTimerDialog,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Color(0xFF62CD9C),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8.0),
//                     ),
//                   ),
//                   child: Text('TRIMITE ÎNTREBAREA', style: TextStyle(color: Colors.white)),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//
//
//
//     );
//   }
//
//   @override
//   void dispose() {
//     _messageController.dispose();
//     super.dispose();
//   }
// }
//
//
// class TimerDialog extends StatefulWidget {
//   final Function(String) onSend;
//
//   const TimerDialog({super.key, required this.onSend});
//
//   @override
//   _TimerDialogState createState() => _TimerDialogState();
// }
// class _TimerDialogState extends State<TimerDialog> {
//   final TextEditingController _controller = TextEditingController();
//   int _secondsRemaining = 10 * 60;
//   late Timer _timer;
//
//   @override
//   void initState() {
//     super.initState();
//     _startTimer();
//   }
//
//   void _startTimer() {
//     _timer = Timer.periodic(Duration(seconds: 1), (timer) {
//       if (!mounted) return;
//       setState(() {
//         if (_secondsRemaining > 0) {
//           _secondsRemaining--;
//         } else {
//           _timer.cancel();
//           _autoSend();
//         }
//       });
//     });
//   }
//
//   void _autoSend() {
//     if (_controller.text.isNotEmpty) {
//       widget.onSend(_controller.text);
//     }
//     Navigator.pop(context);
//   }
//
//   void _sendMessage() {
//     if (_controller.text.isNotEmpty) {
//       widget.onSend(_controller.text);
//     }
//     _timer.cancel();
//     Navigator.pop(context);
//   }
//
//   String _formatTime(int seconds) {
//     final minutes = seconds ~/ 60;
//     final remaining = seconds % 60;
//     return '${minutes.toString().padLeft(2, '0')}:${remaining.toString().padLeft(2, '0')}';
//   }
//
//   @override
//   void dispose() {
//     _timer.cancel();
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       insetPadding: EdgeInsets.zero,
//       backgroundColor: Colors.white,
//       child: Container(
//         color: Colors.white,
//         width: double.infinity,
//         height: double.infinity,
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           children: [
//             // Header with timer and close
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Row(
//                   children: [
//                     const Icon(Icons.fiber_manual_record, color: Colors.red),
//                     const SizedBox(width: 5),
//                     Text(
//                       _formatTime(_secondsRemaining),
//                       style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
//                     ),
//                     const SizedBox(width: 5),
//                     const Icon(Icons.timer, color: Colors.red),
//                   ],
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.close, color: Colors.grey),
//                   onPressed: () => Navigator.pop(context),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             // Text field
//             Expanded(
//               child: Padding(
//                 padding: EdgeInsets.all(12),
//                 child: Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFF5F7FF),
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Column(
//                     children: [
//                       Expanded(
//                         child: TextField(
//                           controller: _controller,
//                           maxLength: 400,
//                           maxLines: null,
//                           minLines: 5,
//                           keyboardType: TextInputType.multiline,
//                           decoration: const InputDecoration(
//                             hintText: 'Scrie text',
//                             border: InputBorder.none,
//                           ),
//                           onChanged: (_) => setState(() {}),
//                         ),
//                       ),
//                       Text(
//                         '${_controller.text.length} de caractere',
//                         style: TextStyle(color: Colors.grey[600]),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),
//             // Button
//             SizedBox(
//               width: double.infinity,
//               height: 50,
//               child: ElevatedButton(
//                 onPressed: _sendMessage,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Color(0xFF06C167),
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                 ),
//                 child: const Text(
//                   'TRIMITE ÎNTREBAREA',
//                   style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }




