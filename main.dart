import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const InteriorDesignApp());
}

class InteriorDesignApp extends StatelessWidget {
  const InteriorDesignApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AI Interior Designer',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      home: const HomeScreen(),
    );
  }
}