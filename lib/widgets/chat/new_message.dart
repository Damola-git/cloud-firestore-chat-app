import 'package:flutter/material.dart';
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

    final userImage = userData.data()?['imageData'] ?? '';

    

    await FirebaseFirestore.instance.collection('chat').add({
      'text': _enteredMessage.trim(),
      'createdAt': Timestamp.now(),
      'userId': user.uid,
      'username': userData.data()?['username'] ?? 'Unknown',
      'userImageData': userImage,
    });

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
