import 'package:flutter/material.dart';

class JournalScreen extends StatelessWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log — Journal')),
      body: const Padding(
        padding: EdgeInsets.all(12),
        child: Text(
          'V1 placeholder (next upgrade):\n'
          '- mood 1–5\n'
          '- anxiety 0–10\n'
          '- win of the day\n'
          '- plan tomorrow\n\n'
          'We’ll wire this into local storage next.',
        ),
      ),
    );
  }
}
