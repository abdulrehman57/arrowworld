import 'package:flutter/material.dart';
import 'package:orbit_escape/Screens/game_screen.dart';

void main() {
  runApp(const OrbitEscapeApp());
}

class OrbitEscapeApp extends StatelessWidget {
  const OrbitEscapeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Orbit Escape',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const GameScreen(),
    );
  }
}
