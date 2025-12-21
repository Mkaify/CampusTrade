import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/chat_service.dart';

class ChatScreen extends StatefulWidget {
  final String receiverEmail;

  const ChatScreen({super.key, required this.receiverEmail});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(widget.receiverEmail, _messageController.text);
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.receiverEmail.split('@')[0])), // Show name only
      body: Column(
        children: [
          // 1. Messages List
          Expanded(
            child: StreamBuilder(
              stream: _chatService.getMessages(widget.receiverEmail),
              builder: (context, snapshot) {
                if (snapshot.hasError) return const Text("Error loading messages");
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                return ListView(
                  children: snapshot.data!.docs.map((doc) => _buildMessageItem(doc)).toList(),
                );
              },
            ),
          ),

          // 2. Input Area
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Enter message...",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: sendMessage,
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  // Helper to build a single message bubble
  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    bool isCurrentUser = data['senderEmail'] == _auth.currentUser!.email;

    return Container(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        // Reverse row if current user, so avatar is on right
        textDirection: isCurrentUser ? TextDirection.rtl : TextDirection.ltr,
        children: [
          // 1. Avatar
          if (!isCurrentUser) ...[
            CircleAvatar(
              radius: 14,
              backgroundImage: (data['senderPhoto'] != null && data['senderPhoto'] != "")
                  ? NetworkImage(data['senderPhoto'])
                  : null,
              child: (data['senderPhoto'] == null || data['senderPhoto'] == "")
                  ? const Icon(Icons.person, size: 16) : null,
            ),
            const SizedBox(width: 8),
          ],

          // 2. Message Bubble
          Flexible(
            child: Column(
              crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                // Show Name in small text for other user
                if (!isCurrentUser)
                  Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 2),
                    child: Text(
                      data['senderName'] ?? "Student",
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isCurrentUser ? Colors.blue : Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    data['message'],
                    style: TextStyle(color: isCurrentUser ? Colors.white : Colors.black87),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}