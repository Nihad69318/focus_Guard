import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../files/block_item.dart';
import '../files/blockable_tile.dart';
import '../files/blocker_provider.dart';

class AppBlocker extends StatelessWidget {
  const AppBlocker({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BlockerProvider()..load(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'AppBlock',
            style: TextStyle(
               fontWeight: FontWeight.bold,
               color: Theme.of(context).colorScheme.onSurface,

            ),
          ),
          toolbarHeight: 50,
          backgroundColor: Colors.blueGrey,
        ),
        body: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 6),
          itemCount: blockItems.length,
          itemBuilder: (_, i) => BlockableTile(item: blockItems[i]),
        ),
      ),
    );
  }
}