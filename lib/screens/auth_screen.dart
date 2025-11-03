import 'dart:io';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/auth/auth_form.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _auth = FirebaseAuth.instance;
  var _isLoading = false;

  // ✅ Handles token saving & refreshing automatically
  Future<void> _saveUserToken(String userId) async {
    try {
      final fcm = FirebaseMessaging.instance;
      final token = await fcm.getToken();

      if (token != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({'fcmToken': token});
      }

      // 🔁 Keep token updated if it ever refreshes
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({'fcmToken': newToken});
      });
    } catch (e) {
      debugPrint('⚠️ Error saving FCM token: $e');
    }
  }

  Future<void> _submitAuthForm(
    String email,
    String password,
    String username,
    File? image,
    bool isLogin,
    BuildContext ctx,
  ) async {
    UserCredential authResult;

    try {
      setState(() {
        _isLoading = true;
      });

      if (isLogin) {
        // 🔹 Sign in
        authResult = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        // ✅ Save/update FCM token for existing user
        await _saveUserToken(authResult.user!.uid);
      } else {
        // 🔹 Sign up
        authResult = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Convert image to base64 string
        final bytes = await image!.readAsBytes();
        final base64Image = base64Encode(bytes);

        // Save user data in Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(authResult.user!.uid)
            .set({
          'username': username,
          'email': email,
          'imageData': base64Image,
        });

        // ✅ Save FCM token for new user
        await _saveUserToken(authResult.user!.uid);
      }
    } on FirebaseAuthException catch (err) {
      var message = 'An error occurred, please check your credentials.';
      if (err.message != null) message = err.message!;

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } catch (err) {
      debugPrint('❌ Auth error: $err');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: AuthForm(_submitAuthForm, _isLoading),
    );
  }
}
