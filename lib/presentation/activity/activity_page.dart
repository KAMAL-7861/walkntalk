// activity_screen.dart
import 'package:flutter/material.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity'),
      ),
      body: const Center(
        child: Text(
          'Activity Screen',
          style: TextStyle(fontSize: 24.0),
        ),
      ),
    );
  }
}
