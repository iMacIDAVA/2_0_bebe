import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {
  // Flag to indicate if this is the doctor or patient app
  final bool isDoctor;

  const ChatScreen({Key? key, required this.isDoctor}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Static IDs and names for doctor and patient (replace with your own)
  static const String doctorId = 'DOCTOR_12345';
  static const String doctorName = 'Dr. Smith';
  static const String patientId = 'PATIENT_67890';
  static const String patientName = 'John Doe';

  late String chatRoomId;
  late String currentUserId;
  late String currentUserName;
  late String otherUserId;
  late String otherUserName;

  @override
  void initState() {
    super.initState();
    // Set current and other user based on isDoctor flag
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

    // Create a unique chat room ID by sorting UIDs
    final ids = [currentUserId, otherUserId]..sort();
    chatRoomId = '${ids[0]}_${ids[1]}';

    // Initialize chat room in Firestore if it doesn't exist
    _initializeChatRoom();
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

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final message = {
      'senderId': currentUserId,
      'senderName': currentUserName,
      'message': _messageController.text.trim(),
      'timestamp': FieldValue.serverTimestamp(),
    };

    try {
      await _firestore
          .collection('chat_rooms')
          .doc(chatRoomId)
          .collection('messages')
          .add(message);
      _messageController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending message: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with $otherUserName'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
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
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data?.docs ?? [];

                if (messages.isEmpty) {
                  return Center(child: Text('No messages yet.'));
                }

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

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                        padding: EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blue[100] : Colors.grey[200],
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Column(
                          crossAxisAlignment: isMe
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Text(
                              message['senderName'] ?? 'Unknown',
                              style: TextStyle(
                                fontSize: 12.0,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 4.0),
                            Text(
                              message['message'] ?? '',
                              style: TextStyle(fontSize: 16.0),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 10.0,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                SizedBox(width: 8.0),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.blueAccent),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}