import 'package:attendance_app/wrapper/auth_wrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyCn6BPXNwN8vsUlHgnNGhSW3mRIDYjDBkk",
      appId: "1:261263919822:android:86a8dfe8dd6ddae8e1de9f",
      messagingSenderId: "261263919822",
      projectId: "attendance-app-975c1",
    ),
  );
  runApp(attendance_app());
}


class attendance_app extends StatelessWidget {
  const attendance_app({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Attendance App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          centerTitle: true,
          elevation: 0,
        )
      ),
      home: AuthWrapper(),
    );
  }
}