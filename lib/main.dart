import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart'; 

import '../screens/auth_screen.dart';
import '../screens/chat_screen.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
// Handle background message (log, analytics, local DB, etc)
debugPrint('BG message: \\${message.messageId} data=\\${message.data}');
}
Future <void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  runApp(const MyApp());
}

Future<void> checkInitialMessage() async {
final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
if (initialMessage != null) {
// Navigate based on payload
}
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const reddishBrown = Color(0xFF8B2E24); 
    const pinkAppBar = Colors.pink; 

    return MaterialApp(
      title: 'Chat App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: reddishBrown,
          primary: reddishBrown,
          secondary: Colors.brown.shade300,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: pinkAppBar,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        scaffoldBackgroundColor: reddishBrown, 
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: pinkAppBar,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: pinkAppBar,
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          hintStyle: TextStyle(color: Colors.grey),
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.all(Radius.circular(25)),
          ),
        ),
        useMaterial3: true,
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (ctx, userSnapshot) {
          if (userSnapshot.hasData) {
            return const ChatScreen();
          }
          return const AuthScreen();
        },
      ),
    );
  }
}
