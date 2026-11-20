import 'dart:isolate';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:focus_guard/splash_screen/splashscreen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Navigation/Focus_Wigest/Daily_Timer/app_cache.dart';
import 'app/theme/app_theme.dart';
import 'app/theme/theme_provaider.dart';
import 'files/setup_screen.dart';
import 'firebase_options.dart';
import 'screens/LoginScreen.dart';

// --- Background এ চলবে এই Function টা ---
@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(MyTaskHandler());
}

// --- FINAL FIX: এই Version এ সব Future<void> async হবে ---
class MyTaskHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {}

  @override
  void onRepeatEvent(DateTime timestamp) {
    // প্রতি ৫ সেকেন্ডে চেক করবে - কোন App খোলা, কতক্ষণ চলছে
    // এখানেই তোমার ২ মিনিটের হিসাব হবে
    FlutterForegroundTask.updateService(
      notificationTitle: 'Focus Guard পাহারা দিচ্ছে',
      notificationText: 'Block Service চলতেছে...',
    );
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {}

  @override
  Future<void> onNotificationButtonPressed(String id) async {}

  @override
  Future<void> onNotificationPressed() async {}
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseAppCheck.instance.activate();

  // --- Service Init - এইটা না থাকলে Xiaomi মেরে ফেলবে ---
  FlutterForegroundTask.init(
    androidNotificationOptions: AndroidNotificationOptions(
      channelId: 'focus_guard_block',
      channelName: 'Focus Guard Block',
      channelDescription: 'App Block করার জন্য চলতেছে',
      channelImportance: NotificationChannelImportance.LOW,
      priority: NotificationPriority.LOW,
    ),
    iosNotificationOptions: const IOSNotificationOptions(),
    foregroundTaskOptions: ForegroundTaskOptions(
      eventAction: ForegroundTaskEventAction.repeat(5000),
      autoRunOnBoot: true,
      allowWakeLock: true,
      allowWifiLock: true,
    ),
  );

  final themeProvider = ThemeProvider();
  await themeProvider.load();

  runApp(
    ChangeNotifierProvider.value(
      value: themeProvider,
      child: const App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeProvider.themeMode,
      home: const AppFlow(),
    );
  }
}

class AppFlow extends StatefulWidget {
  const AppFlow({super.key});
  @override
  State<AppFlow> createState() => _AppFlowState();
}

class _AppFlowState extends State<AppFlow> {
  bool _showSplash = true;
  bool _setupDone = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initFlow();
    _startBlockService(); // App খুললেই Service চালু
  }

  // --- এইটা সবচেয়ে জরুরি ---
  Future<void> _startBlockService() async {
    if (await FlutterForegroundTask.isRunningService) return;
    await FlutterForegroundTask.startService(
      notificationTitle: 'Focus Guard চলতেছে',
      notificationText: '২ মিনিট শেষ হলে Block হবে',
      callback: startCallback,
    );
  }

  Future<void> _initFlow() async {
    await Future.wait([
      Future.delayed(const Duration(seconds: 2)),
      AppCache.preload(),
    ]);
    final prefs = await SharedPreferences.getInstance();
    final done = prefs.getBool('setup_done') ?? false;
    if (!mounted) return;
    setState(() {
      _setupDone = done;
      _showSplash = false;
      _isLoading = false;
    });
  }

  Future<void> _onSetupDone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('setup_done', true);
    if (!mounted) return;
    setState(() {
      _setupDone = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _showSplash) {
      return SplashScreen();
    }
    if (!_setupDone) {
      return SetupScreen(onSetupDone: _onSetupDone);
    }
    return Loginscreen();
  }
}