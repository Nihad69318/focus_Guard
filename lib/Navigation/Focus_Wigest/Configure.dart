import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:focus_guard/app/color/app_colors.dart';
import 'package:focus_guard/files/blocker_service.dart';

import '../schedule_blocker_widgest/Select App.dart';

class Configure extends StatefulWidget {
  const Configure({super.key});

  @override
  State<Configure> createState() => _ConfigureState();
}

class _ConfigureState extends State<Configure> {
  BlockerSession _session = const BlockerSession();

  Timer? _ticker;

  bool _isBlocking = false;
  bool _isLoading = true;
  bool _isRefreshing = false;

  List<String> _selectedApps = [];

  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _startTimeController =
  TextEditingController();

  final TextEditingController _endTimeController =
  TextEditingController();

  bool get _isLocked => _session.isLockedNow;

  @override
  void initState() {
    super.initState();
    _loadSession();
    _ticker = Timer.periodic(
      const Duration(seconds: 1),
          (_) => _refreshStatus(),
    );
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }

  // ------------------------------------------
  // LOAD SAVED SESSION
  // ------------------------------------------

  Future<void> _loadSession() async {
    try {
      final session = await BlockerService.getSession();
      if (!mounted) return;
      setState(() {
        _session = session;
        _selectedApps = List<String>.from(session.packages);
        if (session.startAt != null) {
          _startTime = TimeOfDay.fromDateTime(session.startAt!);
          _startTimeController.text = _startTime!.format(context);
        }
        if (session.endAt != null) {
          _endTime = TimeOfDay.fromDateTime(session.endAt!);
          _endTimeController.text = _endTime!.format(context);
        }
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Load Session Error: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      _showMessage('Failed to load saved session: $e');
    }
  }

  // ------------------------------------------
  // REFRESH SERVICE STATUS
  // ------------------------------------------

  Future<void> _refreshStatus() async {
    if (_isRefreshing || !mounted) return;
    _isRefreshing = true;
    try {
      final session = await BlockerService.getSession();
      if (!mounted) return;
      setState(() {
        _session = session;
      });
    } catch (e) {
      debugPrint('Refresh Status Error: $e');
    } finally {
      _isRefreshing = false;
    }
  }

  // ------------------------------------------
  // SNACKBAR
  // ------------------------------------------

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  void _showLockedMessage() {
    _showMessage(
      "Locked! You can't change apps or time until the session ends.",
    );
  }

  // ------------------------------------------
  // FORMAT REMAINING TIME
  // ------------------------------------------

  String _fmtDuration(Duration duration) {
    if (duration.isNegative) return '0s';
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    if (hours > 0) return '${hours}h ${minutes}m ${seconds}s';
    if (minutes > 0) return '${minutes}m ${seconds}s';
    return '${seconds}s';
  }

  // ------------------------------------------
  // BUILD START AND END DATETIME - FULL FIXED
  // ------------------------------------------
  (DateTime, DateTime) _buildWindow() {
    final now = DateTime.now();

    DateTime atToday(TimeOfDay time) {
      return DateTime(
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );
    }

    // FIX: Block চাপলেই এখন থেকে শুরু হবে।
    // Start Time ভবিষ্যতে দিলেও এখন থেকে ব্লক হবে।
    final DateTime start = now;

    // End Time
    DateTime end = atToday(_endTime!);

    // FIX: End Time যদি Start / Now এর আগে হয়, মানে রাত ১০টা -> সকাল ৬টা
    // তাহলে End কে আগামীকাল ধরো
    if (!end.isAfter(start)) {
      end = end.add(const Duration(days: 1));
    }

    return (start, end);
  }

  // ------------------------------------------
  // STATUS BANNER
  // ------------------------------------------

  Widget _buildStatusBanner() {
    final session = _session;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                session.serviceConnected ? Icons.check_circle : Icons.error,
                color: session.serviceConnected ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  session.serviceConnected
                      ? 'Blocker Service: Running'
                      : 'Blocker Service: Not Running',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: session.serviceConnected ? Colors.green : Colors.red,
                  ),
                ),
              ),
            ],
          ),
          if (!session.serviceConnected) ...[
            const SizedBox(height: 8),
            const Text(
              'Settings → Accessibility → Downloaded apps → Focus Guard → ON',
              style: TextStyle(fontSize: 12, color: Colors.black87),
            ),
          ],
          if (_isLocked) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.lock, color: Colors.red, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Session Locked: ${_fmtDuration(session.remaining)} left',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.red),
                  ),
                ),
              ],
            ),
          ],
          if (session.lastPackage.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Last app seen: ${session.lastPackage}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ],
      ),
    );
  }

  // ------------------------------------------
  // SELECT START / END TIME
  // ------------------------------------------

  Future<void> _selectTime(
      BuildContext context,
      bool isStartTime,
      ) async {
    if (_isLocked) {
      _showLockedMessage();
      return;
    }
    final picked = await showTimePicker(
      context: context,
      initialTime: isStartTime
          ? (_startTime ?? TimeOfDay.now())
          : (_endTime ?? TimeOfDay.now()),
    );
    if (picked == null || !mounted) return;
    setState(() {
      if (isStartTime) {
        _startTime = picked;
        _startTimeController.text = picked.format(context);
      } else {
        _endTime = picked;
        _endTimeController.text = picked.format(context);
      }
    });
  }

  // ------------------------------------------
  // SELECT APPS
  // ------------------------------------------

  Future<void> _selectApps() async {
    if (_isLocked) {
      _showLockedMessage();
      return;
    }
    final result = await Navigator.push<List<String>>(
      context,
      MaterialPageRoute(
        builder: (context) => SelectApp(
          initiallySelected: _selectedApps,
        ),
      ),
    );
    if (result != null && mounted) {
      setState(() {
        _selectedApps = List<String>.from(result);
      });
    }
  }

  // ------------------------------------------
  // BLOCK SELECTED APPS - FULL FIXED
  // ------------------------------------------

  Future<void> _blockSelectedApps() async {
    if (_isLocked) {
      _showLockedMessage();
      return;
    }
    if (_selectedApps.isEmpty) {
      _showMessage('Please select at least one app!');
      return;
    }
    if (_endTime == null) {
      _showMessage('Please select an End Time!');
      return;
    }
    if (_startTime != null && _startTime == _endTime) {
      _showMessage('Start and End time cannot be the same.');
      return;
    }

    setState(() {
      _isBlocking = true;
    });

    try {
      // Check Accessibility Permission
      final isEnabled = await BlockerService.isAccessibilityEnabled();
      if (!isEnabled) {
        await BlockerService.openAccessibilitySettings();
        if (!mounted) return;
        _showMessage('Please enable Focus Guard Accessibility Service.');
        return;
      }

      // Build schedule - এখন থেকে শুরু হবে
      final (start, end) = _buildWindow();

      // FIX 1: পুরানো আটকে থাকা Session Clear করো, নাহলে LOCKED আসবে
      await BlockerService.clearSession();
      await Future.delayed(const Duration(milliseconds: 100));

      // FIX 2: এখন setSession - Error String ফেরত দিবে
      final String? error = await BlockerService.setSession(
        packages: _selectedApps,
        startAt: start,
        endAt: end,
      );

      if (!mounted) return;

      if (error != null) {
        _showMessage('Failed: $error');
        return;
      }

      await _refreshStatus();
      if (!mounted) return;
      _showMessage('${_selectedApps.length} Apps Blocking Started!');
    } catch (e) {
      debugPrint('Blocking Error: $e');
      if (!mounted) return;
      _showMessage('Blocking Failed: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isBlocking = false;
        });
      }
    }
  }

  // ------------------------------------------
  // TIME CARD
  // ------------------------------------------

  Widget _buildTimeCard() {
    final startText = _startTime?.format(context) ?? '--:--';
    final endText = _endTime?.format(context) ?? '--:--';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          TextFormField(
            controller: _startTimeController,
            readOnly: true,
            onTap: () => _selectTime(context, true),
            decoration: InputDecoration(
              labelText: 'Start Time',
              hintText: 'Tap to set start time',
              prefixIcon: const Icon(Icons.play_arrow,
                  color: Colors.blueAccent, size: 30),
              suffixIcon: const Icon(Icons.arrow_forward_ios, size: 16),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _endTimeController,
            readOnly: true,
            onTap: () => _selectTime(context, false),
            decoration: InputDecoration(
              labelText: 'End Time',
              hintText: 'Tap to set end time',
              prefixIcon: const Icon(Icons.stop_circle_outlined,
                  color: Colors.red, size: 30),
              suffixIcon: const Icon(Icons.arrow_forward_ios, size: 16),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                const Icon(Icons.alarm, color: Colors.red, size: 30),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'BLOCKING SCHEDULE',
                        style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '$startText - $endText',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------
  // APP SELECTION CARDS
  // ------------------------------------------

  Widget _buildAppSelection() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 160,
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const FaIcon(FontAwesomeIcons.mobileScreenButton,
                        color: Colors.blue, size: 30),
                    const SizedBox(height: 8),
                    const Text('Choose App',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _isLocked ? null : _selectApps,
                      child: const Text('Select App'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SizedBox(
            height: 160,
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const FaIcon(FontAwesomeIcons.ban,
                        color: Colors.red, size: 30),
                    const SizedBox(height: 8),
                    const Text('Block Now',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: (_isBlocking || _isLocked)
                          ? null
                          : _blockSelectedApps,
                      child: _isBlocking
                          ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Block'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ------------------------------------------
  // MAIN UI
  // ------------------------------------------

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle,
                        color: AppColors.info, size: 30),
                    const SizedBox(width: 8),
                    const Text(
                      'Schedule Block',
                      style: TextStyle(
                          fontSize: 28,
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _buildStatusBanner(),
                const SizedBox(height: 18),
                _buildTimeCard(),
                const SizedBox(height: 22),
                const Text(
                  'App Selection',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                ),
                const SizedBox(height: 10),
                _buildAppSelection(),
                const SizedBox(height: 16),
                if (_selectedApps.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.apps, color: Colors.blue),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${_selectedApps.length} Apps Selected',
                            style: const TextStyle(
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 25),
              ],
            ),
          ),
        ),
      ),
    );
  }
}