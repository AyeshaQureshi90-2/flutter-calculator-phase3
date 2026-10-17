
import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calculator',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFFF8F3FF),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFB99AE8),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
