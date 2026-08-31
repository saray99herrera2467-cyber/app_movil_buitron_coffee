import 'package:flutter/material.dart';
import 'screens/Login_screen.dart';

void main() {
  runApp(const BuitronCoffeeApp());
}

class BuitronCoffeeApp extends StatelessWidget {
  const BuitronCoffeeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Buitron Coffee',
      home: const LoginPage(),
    );
  }
}