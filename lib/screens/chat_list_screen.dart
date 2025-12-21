import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/chat_service.dart';
import '../services/database_service.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ChatService chatService = ChatService();
    final String myEmail = FirebaseAuth.instance.currentUser!.email!;

    return Scaffold(
      appBar: AppBar(title: const Text("Messages")),
      body: StreamBuilder(
        stream: chatService.getUserChats(),
        builder: (context, snapshot) {
          // 1. Error & Loading States
          if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Empty State (FIXED LOGIC HERE)
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 60, color: Colors.grey[300]),
                  const SizedBox(height: 10),
                  const Text("No messages yet.", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          // 3. Build the List
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

              // Safety check: Ensure 'users' exists (handles old data)
              List<dynamic> users = data['users'] ?? [];

              if (users.isEmpty) return const SizedBox(); // Skip broken chats

              // Identify the "Other" person
              String otherEmail = users.firstWhere(
                      (email) => email != myEmail,
                  orElse: () => "Unknown"
              );

              return _ChatTile(
                otherEmail: otherEmail,
                lastMessage: data['lastMessage'] ?? "",
                lastTime: data['lastTime'] as Timestamp?,
              );
            },
          );
        },
      ),
    );
  }
}

// --- SMART TILE WIDGET (Unchanged) ---
class _ChatTile extends StatelessWidget {
  final String otherEmail;
  final String lastMessage;
  final Timestamp? lastTime;

  const _ChatTile({
    required this.otherEmail,
    required this.lastMessage,
    this.lastTime,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: DatabaseService().getUserProfile(otherEmail),
      builder: (context, snapshot) {

        String displayName = otherEmail.split('@')[0];
        String? photoUrl;

        if (snapshot.hasData && snapshot.data != null) {
          var userProfile = snapshot.data!;
          displayName = userProfile['name'] ?? displayName;
          photoUrl = userProfile['photoUrl'];
        }

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: CircleAvatar(
            radius: 28,
            backgroundColor: Colors.blue.shade100,
            backgroundImage: (photoUrl != null && photoUrl.isNotEmpty)
                ? NetworkImage(photoUrl)
                : null,
            child: (photoUrl == null || photoUrl.isEmpty)
                ? Text(displayName[0].toUpperCase(),
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue))
                : null,
          ),
          title: Text(
            displayName,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Text(
            lastMessage,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.grey[600]),
          ),
          trailing: lastTime != null
              ? Text(
            _formatTime(lastTime!),
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          )
              : null,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatScreen(receiverEmail: otherEmail),
              ),
            );
          },
        );
      },
    );
  }

  String _formatTime(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
    return "${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }
}