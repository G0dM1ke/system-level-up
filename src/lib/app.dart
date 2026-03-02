import 'package:flutter/material.dart';
import 'screens/decoy/decoy_home.dart';

class SystemApp extends StatelessWidget {
  const SystemApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SYSTEM',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF58A6FF),
      ),
      home: const DecoyHome(),
    );
  }
}
