import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 1. Get the Chat ID (Unique ID for any pair of users)
  String getChatRoomId(String user1, String user2) {
    // Sort emails to ensure "a_b" is always the ID, never "b_a"
    List<String> ids = [user1, user2];
    ids.sort();
    return ids.join("_");
  }

  // Update the sendMessage function
  Future<void> sendMessage(String receiverEmail, String message) async {
    final user = _auth.currentUser!;
    final String chatRoomId = getChatRoomId(user.email!, receiverEmail);
    final Timestamp timestamp = Timestamp.now();

    // Store Name/Photo in the message itself
    Map<String, dynamic> messageData = {
      "senderEmail": user.email,
      "senderName": user.displayName ?? "Student", // <--- NEW
      "senderPhoto": user.photoURL ?? "",          // <--- NEW
      "receiverEmail": receiverEmail,
      "message": message,
      "timestamp": timestamp,
    };

    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add(messageData);

    // Update the Chat List preview
    await _firestore.collection('chat_rooms').doc(chatRoomId).set({
      "participants": [user.email, receiverEmail],
      "lastMessage": message,
      "lastTime": timestamp,
      "users": [user.email, receiverEmail]
    }, SetOptions(merge: true));
  }

  // 3. Get Messages Stream (For the Chat Screen)
  Stream<QuerySnapshot> getMessages(String otherUserEmail) {
    String myEmail = _auth.currentUser!.email!;
    String chatRoomId = getChatRoomId(myEmail, otherUserEmail);

    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false) // Oldest at top
        .snapshots();
  }

  // 4. Get My Chat List Stream (For the Inbox Screen)
  Stream<QuerySnapshot> getUserChats() {
    String myEmail = _auth.currentUser!.email!;
    return _firestore
        .collection('chat_rooms')
        .where('users', arrayContains: myEmail)
        .orderBy('lastTime', descending: true)
        .snapshots();
  }
}