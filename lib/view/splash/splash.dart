import 'dart:async';
import 'package:flutter/material.dart';
import '../home/home.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    Timer(
      const Duration(seconds: 2),
          () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        body: Center(
          child: Text(
            'CHAT BOT',
            style: TextStyle(
              fontSize: 24,
              color: Colors.black,
            ),
          ),
        )
    );
  }
}
