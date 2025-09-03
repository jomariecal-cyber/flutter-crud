// main.dart
import 'package:flutter/material.dart';
import 'screens/personal_info_screen.dart'; // Import our main screen

void main() {
  runApp(const MyApp());
}

// Root widget of the app
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Hide the debug banner
      title: "Personal Info App",
      theme: ThemeData(
        primarySwatch: Colors.deepPurple, // Theme color
      ),
      home: const PersonalInfoScreen(), // Starting screen
    );
  }
}
