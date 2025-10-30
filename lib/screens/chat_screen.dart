import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(
        title: Text('FlutterChat'),
        actions: [
          DropdownButton(
            icon: Icon(
              Icons.more_vert,
              color: Theme.of(context).primaryIconTheme.color,
            ),
            items: [
              DropdownMenuItem(
               value: 'logout',
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.exit_to_app),
                      SizedBox(width: 8),
                      Text('Logout'),
                    ],
                  ),
                
                
              ),
            ],
            onChanged: (itemIdentifier) {
              if (itemIdentifier == 'logout') {
                FirebaseAuth.instance.signOut();
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chat')
            .doc('SrErmN1ut0ycP2BmAzJ2')
            .collection('messages')
            .snapshots(),
        builder: (context, streamSnapshot) {
          if (streamSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final documents = streamSnapshot.data?.docs ?? [];

          if (documents.isEmpty) {
            return const Center(child: Text('No messages yet...'));
          }

          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (ctx, index) {
              final messageData = documents[index].data() as Map<String, dynamic>;
              return Container(
                padding: const EdgeInsets.all(8),
                child: Text(messageData['text'] ?? ''),
              );
            },
          );
        },
      ),
    );
  }
}
