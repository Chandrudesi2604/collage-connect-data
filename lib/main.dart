import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const CollegeConnectApp());
}

class CollegeConnectApp extends StatelessWidget {
  const CollegeConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'College Connect',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        scaffoldBackgroundColor: const Color(0xFFF7F8FC),
      ),
      home: const HomeScreen(),
    );
  }
}
