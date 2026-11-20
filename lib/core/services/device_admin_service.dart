
import 'package:flutter/services.dart';

class DeviceAdminService {
  DeviceAdminService._();

  static const MethodChannel _channel =
  MethodChannel('com.focusguard/device_owner');

  /// Check whether app is Device Owner
  static Future<bool> isDeviceOwner() async {
    try {
      final result = await _channel.invokeMethod<bool>(
        'isDeviceOwner',
      );

      return result ?? false;
    } on PlatformException catch (e) {
      throw Exception('Device Owner check failed: ${e.message}');
    }
  }

  /// Check whether Device Admin is active
  static Future<bool> isAdminActive() async {
    try {
      final result = await _channel.invokeMethod<bool>(
        'isAdminActive',
      );

      return result ?? false;
    } on PlatformException catch (e) {
      throw Exception('Device Admin check failed: ${e.message}');
    }
  }
}
