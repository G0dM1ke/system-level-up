import 'package:flutter/material.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stats — Character Sheet')),
      body: const Padding(
        padding: EdgeInsets.all(12),
        child: Text(
          'V1 placeholder (next upgrade):\n'
          '- weight history\n'
          '- waist / neck\n'
          '- steps / sleep\n'
          '- knee pain slider\n\n'
          'For now, use Dashboard quick logs.',
        ),
      ),
    );
  }
}
