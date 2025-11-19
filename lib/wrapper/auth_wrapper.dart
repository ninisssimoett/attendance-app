import 'package:attendance_app/screen/auth/widgets/login_screen.dart';
import 'package:attendance_app/screen/auth/widgets/register_screen.dart';
import 'package:attendance_app/screen/home/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

// auth wrapper = dia yang muncul login or register dulu
class _AuthWrapperState extends State<AuthWrapper> {
  bool _showLogin = true; // ini login dulu berarti

  void _toggleView() { // agar bisa pindah" antara login n register
    setState(() {
    _showLogin = !_showLogin; 
    });
  } 


  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) { // mengecek ui sudah bisa connect atau blm => jika menunggu
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

         if (snapshot.hasData) {
          return HomeScreen();
        }

        return _showLogin ? LoginScreen(onRegisterTap: _toggleView) : RegisterScreen(onLoginTap: _toggleView);
      },
    );
  }
}