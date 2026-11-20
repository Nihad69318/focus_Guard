import 'package:flutter/material.dart';

class GreetingSection extends StatelessWidget {
  const GreetingSection({super.key});

  String getGreeting() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 11) {
      return 'Good Morning 🌅';
    } else if (hour >= 11 && hour < 16) {
      return 'Good Afternoon ☀️';
    } else if (hour >= 16 && hour < 21) {
      return 'Good Evening 👋';
    } else {
      return 'Good Night 🌙';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          getGreeting(),
          style:  TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
         Text(
          'Ready to take control of your time?',
          style: TextStyle(
            fontSize: 15,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}