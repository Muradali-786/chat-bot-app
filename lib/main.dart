import 'package:chat_bot_app/view/splash/splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';


const String googleAPIKey = 'PLACE-YOUR-API-KEY HERE';
const logoUrl = 'assets/log.jpg';

void main() {
  Gemini.init(apiKey: googleAPIKey);
  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    imageLoading(context);
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: false,
      ),
      home: const Splash(),
    );
  }
}

void imageLoading(BuildContext context) async {
  ImageProvider logo = const AssetImage(logoUrl);
  await precacheImage(logo, context);
}

