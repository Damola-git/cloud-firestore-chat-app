import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({super.key});

  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  final _controller = TextEditingController();
  String _enteredMessage = '';

  Future<void> _sendMessage() async {
    FocusScope.of(context).unfocus();

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final username = userData.data()?['username'] ?? 'Unknown';
    final userImage = userData.data()?['imageData'] ?? '';

    // 🟢 1. Save message to Firestore
    await FirebaseFirestore.instance.collection('chat').add({
      'text': _enteredMessage.trim(),
      'createdAt': Timestamp.now(),
      'userId': user.uid,
      'username': username,
      'userImageData': userImage,
    });

    
    final usersSnapshot = await FirebaseFirestore.instance.collection('users').get();

    // Just pick the first user that isn't the current one (for testing)
    final recipientDoc = usersSnapshot.docs.firstWhere(
      (doc) => doc.id != user.uid,
      orElse: () => throw Exception('No recipient found!'),
    );

    final recipientToken = recipientDoc['fcmToken'];

    // 🟣 3. Send push notification via your Node.js server
    try {
      const serverUrl = 'http://10.0.2.2:3000/sendNotification'; 
 

      final response = await http.post(
        Uri.parse(serverUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'token': recipientToken,
          'title': username,
          'body': _enteredMessage.trim(),
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('✅ Notification sent successfully!');
      } else {
        debugPrint('❌ Failed to send notification: ${response.body}');
      }
    } catch (error) {
      debugPrint('⚠️ Error sending notification: $error');
    }

    // 🟠 4. Clear input
    _controller.clear();
    setState(() => _enteredMessage = '');
  }

  @override
  Widget build(BuildContext context) {
    final isTyping = _enteredMessage.trim().isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Send a message...',
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.send,
              onChanged: (value) {
                setState(() => _enteredMessage = value);
              },
              onSubmitted: (_) {
                if (isTyping) _sendMessage();
              },
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.send),
            color: isTyping ? Colors.greenAccent[400] : Colors.grey,
            onPressed: isTyping ? _sendMessage : null,
          ),
        ],
      ),
    );
  }
}
