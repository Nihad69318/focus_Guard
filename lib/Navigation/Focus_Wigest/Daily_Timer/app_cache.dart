import 'package:installed_apps/installed_apps.dart';
import 'package:installed_apps/app_info.dart';

class AppCache {
  static List<AppInfo>? _apps; // একবার Load হলে এখানে জমা থাকবে
  static bool isLoading = false;

  // App খোলার সাথে সাথে এইটা চালাবো
  static Future<void> preload() async {
    if (_apps != null) return; // আগেই Load হয়ে থাকলে আবার Load করবে না
    if (isLoading) return;
    isLoading = true;
    _apps = await InstalledApps.getInstalledApps(
      excludeSystemApps: true,
      withIcon: true,
    );
    isLoading = false;
  }

  static List<AppInfo>? get apps => _apps;
}