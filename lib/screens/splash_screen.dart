
import 'package:flutter/material.dart';
import 'calculator_screen.dart';

const Color lightPurple = Color(0xFFB99AE8);
const Color pink = Color(0xFFFFB8D2);
const Color darkText = Color(0xFF655477);

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const CalculatorScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightPurple,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 120,
              width: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
              ),
              child: const Icon(
                Icons.calculate_rounded,
                size: 72,
                color: lightPurple,
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'Calculator',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Simple • Smart • Beautiful',
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFFFFE4F0),
              ),
            ),
            const SizedBox(height: 30),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _LoadingDot(color: Colors.white),
                SizedBox(width: 8),
                _LoadingDot(color: pink),
                SizedBox(width: 8),
                _LoadingDot(color: Colors.white),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingDot extends StatelessWidget {
  final Color color;

  const _LoadingDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 9,
      width: 9,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
