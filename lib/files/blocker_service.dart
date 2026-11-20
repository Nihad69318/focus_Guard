import 'package:flutter/services.dart';

class BlockerSession {
  const BlockerSession({
    this.packages = const [],
    this.startAt,
    this.endAt,
    this.serviceConnected = false,
    this.lastPackage = '',
  });

  final List<String> packages;
  final DateTime? startAt;
  final DateTime? endAt;
  final bool serviceConnected;
  final String lastPackage;

  bool get isLockedNow {
    final s = startAt;
    final e = endAt;
    if (s == null || e == null) return false;
    final now = DateTime.now();
    return !now.isBefore(s) && now.isBefore(e);
  }

  Duration get remaining {
    final e = endAt;
    if (e == null) return Duration.zero;
    final d = e.difference(DateTime.now());
    return d.isNegative ? Duration.zero : d;
  }
}

class BlockerService {
  BlockerService._();

  static const MethodChannel _channel = MethodChannel('com.focusguard/blocker');

  static Future<bool> isAccessibilityEnabled() async {
    try {
      return await _channel.invokeMethod<bool>('isAccessibilityEnabled') ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<void> openAccessibilitySettings() async {
    try {
      await _channel.invokeMethod('openAccessibilitySettings');
    } catch (_) {}
  }

  static Future<bool> isBatteryOptimizationIgnored() async {
    try {
      return await _channel.invokeMethod<bool>('isBatteryOptimizationIgnored') ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<void> requestBatteryOptimization() async {
    try {
      await _channel.invokeMethod('requestBatteryOptimization');
    } catch (_) {}
  }

  static Future<void> openAutostartSettings() async {
    try {
      await _channel.invokeMethod('openAutostartSettings');
    } catch (_) {}
  }

  static Future<BlockerSession> getSession() async {
    try {
      final map = await _channel.invokeMapMethod<String, dynamic>('getSession');
      if (map == null) return const BlockerSession();

      DateTime? ms(Object? v) {
        final n = (v as num?)?.toInt() ?? 0;
        return n <= 0 ? null : DateTime.fromMillisecondsSinceEpoch(n);
      }

      return BlockerSession(
        packages: List<String>.from(map['packages'] as List? ?? const []),
        startAt: ms(map['startAt']),
        endAt: ms(map['endAt']),
        serviceConnected: map['serviceConnected'] as bool? ?? false,
        lastPackage: map['lastPackage'] as String? ?? '',
      );
    } catch (_) {
      return const BlockerSession();
    }
  }

  static Future<bool> setBlockedPackages(List<String> packages) async {
    try {
      final res = await _channel.invokeMethod<bool>(
        'setBlockedPackages',
        {'packages': packages},
      );
      return res ?? true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> setBlockedFeatures(List<String> features) async {
    try {
      final res = await _channel.invokeMethod<bool>(
        'setBlockedFeatures',
        {'features': features},
      );
      return res ?? true;
    } catch (e) {
      return false;
    }
  }

  static Future<String?> setSession({
    required List<String> packages,
    required DateTime startAt,
    required DateTime endAt,
  }) async {
    try {
      // ঠিক করা - আগে 'setSession' ছিল, যেটা packages ফেলে দিতো
      // এখন 'setBlockedApps' দিলাম, যেটা packages + time ২টাই একসাথে Save করে
      await _channel.invokeMethod('setBlockedApps', {
        'packages': packages,
        'startAt': startAt.millisecondsSinceEpoch,
        'endAt': endAt.millisecondsSinceEpoch,
      });
      return null;
    } on PlatformException catch (e) {
      return '${e.code}: ${e.message}';
    } on MissingPluginException {
      return 'MissingPlugin: App Rebuild করো';
    } catch (e) {
      return e.toString();
    }
  }

  static Future<void> clearSession() async {
    try {
      await _channel.invokeMethod('clearSession');
    } catch (_) {}
  }
}