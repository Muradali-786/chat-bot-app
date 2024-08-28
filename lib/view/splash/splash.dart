import 'dart:async';
import 'package:chat_bot_app/main.dart';
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
      const Duration(seconds: 3),
      () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.blueGrey,
      body: SafeArea(
        child: Center(
          child: ClipOval(
            child: Image(
                height: 200,
                width: 200,
                fit: BoxFit.contain,
                image: AssetImage(logoUrl)),
          ),
        ),
      ),
    );
  }
}


