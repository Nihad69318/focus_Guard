
import 'package:flutter/material.dart';

import '../app/color/app_colors.dart';
import 'homepage_Wigest/GreetingSection.dart';
import 'homepage_Wigest/facebook_Supprot.dart';


class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.shield_rounded, size: 30, color: AppColors.primary),
            SizedBox(width: 8),
            Text(
              'Focus Guard',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        toolbarHeight: 50,
        backgroundColor: Colors.blueGrey,

      ),
      body: SafeArea(
          child:
          Column(children: [
        const GreetingSection(),
            SizedBox(height: 10,),
            facebook_Supprot()

      ],)),
    );
  }
}

