import 'package:flutter/material.dart';
import 'package:focus_guard/files/blocker_service.dart';

class SetupScreen extends StatefulWidget {
  final VoidCallback onSetupDone;
  const SetupScreen({super.key, required this.onSetupDone});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  bool _accessibilityOn = false;
  bool _batteryOk = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAll();
  }

  Future<void> _checkAll() async {
    setState(() => _isLoading = true);

    // ১. Settings এ ON কিনা
    final acc = await BlockerService.isAccessibilityEnabled();
    // ২. Battery OK কিনা
    final bat = await BlockerService.isBatteryOptimizationIgnored();
    // ৩. NEW: Service আসলেই বেঁচে আছে কিনা - এইটাই আসল চেক
    final session = await BlockerService.getSession();
    final reallyRunning = session.serviceConnected;

    if (!mounted) return;
    setState(() {
      // ২টা মিললেই সবুজ দেখাবে, শুধু Settings দেখলে হবে না
      _accessibilityOn = acc && reallyRunning;
      _batteryOk = bat;
      _isLoading = false;
    });

    // যদি Settings ON কিন্তু Service মরা থাকে, তাহলে ইউজারকে বলো
    if (acc && !reallyRunning) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Accessibility ON আছে কিন্তু Service মরে গেছে। OFF করে আবার ON করো।'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  bool get _allDone => _accessibilityOn && _batteryOk;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Center(
                child: Icon(Icons.shield, size: 80, color: Colors.blue),
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  'Focus Guard Setup',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'Block চালু রাখার জন্য ৩টা Permission লাগবে।\nতুমি শুধু বাটনে চাপ দাও, অ্যাপ নিজেই পেজ খুলে দিবে।',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 15),
                ),
              ),
              const SizedBox(height: 30),

              // STEP 1
              _buildStep(
                number: '1',
                title: 'Accessibility Service',
                subtitle: 'App Block করার জন্য এইটা লাগবেই',
                isDone: _accessibilityOn,
                buttonText: _accessibilityOn ? 'ON আছে ✓' : 'ON করো',
                onTap: () async {
                  await BlockerService.openAccessibilitySettings();
                  await Future.delayed(const Duration(seconds: 1));
                  _checkAll();
                },
              ),

              const SizedBox(height: 16),

              // STEP 2
              _buildStep(
                number: '2',
                title: 'Battery - No Restriction',
                subtitle: 'Recent থেকে কাটলেও যাতে Block বন্ধ না হয়',
                isDone: _batteryOk,
                buttonText: _batteryOk ? 'Done আছে ✓' : 'Allow করো',
                onTap: () async {
                  await BlockerService.requestBatteryOptimization();
                  await Future.delayed(const Duration(seconds: 1));
                  _checkAll();
                },
              ),

              const SizedBox(height: 16),

              // STEP 3
              _buildStep(
                number: '3',
                title: 'Autostart',
                subtitle: 'ফোন Restart দিলেও যাতে Block চালু থাকে',
                isDone: true, // Autostart চেক করা যায় না, তাই সবসময় Done দেখাবে
                buttonText: 'Autostart পেজ খুলো',
                onTap: () async {
                  await BlockerService.openAutostartSettings();
                },
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _allDone ? widget.onSetupDone : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                    _allDone ? 'চলো শুরু করি →' : 'উপরের ২টা শেষ করো',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: TextButton(
                  onPressed: _checkAll,
                  child: const Text('আবার চেক করো (Refresh)'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep({
    required String number,
    required String title,
    required String subtitle,
    required bool isDone,
    required String buttonText,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDone ? Colors.green.withOpacity(0.08) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDone ? Colors.green : Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: isDone ? Colors.green : Colors.blue,
            child: Text(number, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: isDone ? Colors.green : Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: Text(buttonText, style: const TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}