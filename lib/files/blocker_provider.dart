// import 'package:flutter/foundation.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import 'block_item.dart';
// import 'blocker_service.dart';
//
// enum ToggleResult { done, needsPermission, notSupported }
//
// class BlockerProvider extends ChangeNotifier {
//   static const _prefsKey = 'enabled_block_ids';
//
//   final Set<String> _enabled = {};
//
//   bool isEnabled(String id) => _enabled.contains(id);
//
//   Future<void> load() async {
//     final prefs = await SharedPreferences.getInstance();
//     _enabled
//       ..clear()
//       ..addAll(prefs.getStringList(_prefsKey) ?? const []);
//     await _syncNative();
//     notifyListeners();
//   }
//
//   Future<ToggleResult> toggle(BlockItem item, bool value) async {
//     if (!item.isSupported) return ToggleResult.notSupported;
//
//     // Turning ON needs the Accessibility Service permission first.
//     if (value && !await BlockerService.isAccessibilityEnabled()) {
//       await BlockerService.openAccessibilitySettings();
//       return ToggleResult.needsPermission;
//     }
//
//     value ? _enabled.add(item.id) : _enabled.remove(item.id);
//     notifyListeners();
//
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setStringList(_prefsKey, _enabled.toList());
//     await _syncNative();
//     return ToggleResult.done;
//   }
//
//   Future<void> _syncNative() async {
//     final active = blockItems
//         .where((i) => _enabled.contains(i.id) && i.isSupported)
//         .toList();
//
//     await BlockerService.setBlockedPackages([
//       for (final item in active) ...item.packages,
//     ]);
//
//     await BlockerService.setBlockedFeatures(
//       active.map((i) => i.featureKey).whereType<String>().toList(),
//     );
//   }
// }


import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'block_item.dart';
import 'blocker_service.dart';

enum ToggleResult { done, needsPermission, notSupported }

class BlockerProvider extends ChangeNotifier {
  static const _prefsKey = 'enabled_block_ids';

  final Set<String> _enabled = {};

  bool isEnabled(String id) => _enabled.contains(id);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _enabled
      ..clear()
      ..addAll(prefs.getStringList(_prefsKey) ?? const []);
    await _syncNative();
    notifyListeners();
  }

  Future<ToggleResult> toggle(BlockItem item, bool value) async {
    if (!item.isSupported) return ToggleResult.notSupported;

    // Turning ON needs the Accessibility Service permission first.
    if (value && !await BlockerService.isAccessibilityEnabled()) {
      await BlockerService.openAccessibilitySettings();
      return ToggleResult.needsPermission;
    }

    value ? _enabled.add(item.id) : _enabled.remove(item.id);
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKey, _enabled.toList());
    await _syncNative();
    return ToggleResult.done;
  }

  Future<void> _syncNative() async {
    try {
      final active = blockItems
          .where((i) => _enabled.contains(i.id) && i.isSupported)
          .toList();

      await BlockerService.setBlockedPackages([
        for (final item in active) ...item.packages,
      ]);

      await BlockerService.setBlockedFeatures(
        active.map((i) => i.featureKey).whereType<String>().toList(),
      );
    } catch (e) {
      debugPrint('Sync Native Error: $e');
    }
  }
}