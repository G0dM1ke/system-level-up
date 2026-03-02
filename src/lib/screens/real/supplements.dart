import 'package:flutter/material.dart';

class SupplementsScreen extends StatelessWidget {
  const SupplementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Arsenal — Supplements')),
      body: const Padding(
        padding: EdgeInsets.all(12),
        child: Text(
          'V1 placeholder (next upgrade):\n'
          '- add supplements\n'
          '- taken today toggles\n'
          '- reminders\n\n'
          'Secret Mode is already live.',
        ),
      ),
    );
  }
}
