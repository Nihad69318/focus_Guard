import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'block_item.dart';
import 'blocker_provider.dart';

class BlockableTile extends StatelessWidget {
  const BlockableTile({super.key, required this.item});

  final BlockItem item;

  Future<void> _onChanged(BuildContext context, bool value) async {
    final result = await context.read<BlockerProvider>().toggle(item, value);
    if (!context.mounted) return;

    if (result == ToggleResult.needsPermission) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Focus Guard-এর Accessibility সার্ভিস চালু করুন, তারপর আবার সুইচ অন করুন।',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final enabled = context.select<BlockerProvider, bool>(
      (p) => p.isEnabled(item.id),
    );

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: Colors.black87,
              child: Icon(item.icon, color: item.iconColor, size: 26),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!item.isSupported)
                  const _Badge(text: 'Soon', color: Colors.orange)
                else if (item.isFree)
                  const _Badge(text: 'Free', color: Colors.green),
                const SizedBox(height: 2),
                SizedBox(
                  height: 30,
                  child: Switch(
                    value: enabled,
                    activeThumbColor: Colors.blue,
                    // null = disabled switch for not-yet-supported items
                    onChanged: item.isSupported
                        ? (v) => _onChanged(context, v)
                        : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
