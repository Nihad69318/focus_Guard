import 'package:flutter/material.dart';

class Activate extends StatefulWidget {
  const Activate({super.key});

  @override
  State<Activate> createState() => _ActivateState();
}

class _ActivateState extends State<Activate> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Activate"),),
    );
  }
}
