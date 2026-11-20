import 'package:flutter/material.dart';

class Viewstats extends StatefulWidget {
  const Viewstats({super.key});

  @override
  State<Viewstats> createState() => _ViewstatsState();
}

class _ViewstatsState extends State<Viewstats> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Viewstats"),
      ),
    );
  }
}
