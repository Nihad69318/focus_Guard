import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:focus_guard/utils/Utils.dart';
import 'package:installed_apps/app_info.dart';

import 'Daily_Timer/Daily_Timer.dart';

class Saftey extends StatefulWidget {
  final List<AppInfo> apps;

  const Saftey({super.key, required this.apps});

  @override
  State<Saftey> createState() => _SafteyState();
}

class _SafteyState extends State<Saftey> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController timerController = TextEditingController();

  int selectedHour = 0;
  int selectedMin = 0;
  int selectedSec = 0;

  // --- ১. আগে ১টা ছিলো, এখন লিস্ট করে দিলাম ---
  // ১টা না, অনেকগুলা App রাখা যাবে
  List<String> selectedPackages = [];
  List<String> selectedAppNames = [];

  Future<void> _pickDuration() async {
    await DurationPicker.show(
      context,
      initHour: selectedHour,
      initMin: selectedMin,
      initSec: selectedSec,
      onPicked: (h, m, s) {
        setState(() {
          selectedHour = h;
          selectedMin = m;
          selectedSec = s;
          timerController.text =
              "$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
        });
      },
    );
  }

  @override
  void dispose() {
    timerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Limit Timer",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 30,
            color: Colors.black,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        toolbarHeight: 50,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: timerController,
                  readOnly: true,
                  onTap: _pickDuration,
                  decoration: InputDecoration(
                    hintText: "Daily Timer - 0:00:00",
                    prefixIcon: const Icon(Icons.lock, color: Colors.red),
                    suffixIcon: const Icon(Icons.timer, color: Colors.green),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return;
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    // --- ২. উপরে কয়টা Select হইছে দেখাবে ---
                    selectedPackages.isEmpty
                        ? "App Select"
                        : "${selectedPackages.length} টা App Selected: ${selectedAppNames.join(', ')}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: selectedPackages.isEmpty
                          ? Colors.black
                          : Colors.deepPurple,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: widget.apps.isEmpty
                      ? const Center(child: Text(""))
                      : ListView.builder(
                          itemCount: widget.apps.length,
                          itemBuilder: (context, index) {
                            AppInfo app = widget.apps[index];
                            // --- ৩. এই App টা লিস্টে আছে কিনা চেক ---
                            bool isSelected = selectedPackages.contains(
                              app.packageName,
                            );
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.deepPurple.withOpacity(0.1)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.deepPurple
                                      : Colors.grey.shade300,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: ListTile(
                                leading: app.icon != null
                                    ? Image.memory(
                                        app.icon!,
                                        width: 40,
                                        height: 40,
                                      )
                                    : const Icon(Icons.android),
                                title: Text(
                                  app.name,
                                  style: TextStyle(
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                                subtitle: Text(app.packageName),
                                trailing: Icon(
                                  isSelected
                                      ? Icons.check_circle
                                      : Icons.circle_outlined,
                                  color: isSelected
                                      ? Colors.deepPurple
                                      : Colors.grey,
                                ),
                                onTap: () {
                                  setState(() {
                                    if (isSelected) {
                                      // আবার ক্লিক করলে এইটা বাদ যাবে, বাকিগুলা থাকবে
                                      selectedPackages.remove(app.packageName);
                                      selectedAppNames.remove(app.name);
                                    } else {
                                      // নতুনটা যোগ হবে, আগেরটা বাদ যাবে না
                                      selectedPackages.add(app.packageName);
                                      selectedAppNames.add(app.name);
                                    }
                                  });
                                },
                              ),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () {
                      if (!_formKey.currentState!.validate()) return;

                      if (selectedPackages.isEmpty) {
                        Utels.failToset(" Select App");
                        return; // এখানেই আটকে যাবে, নিচে যাবে না
                      }

                      // --- Save সফল হইছে ---
                      Utels.SuccessToset(
                        "${selectedPackages.length}-${timerController.text}",
                      );

                      // --- ১ সেকেন্ড পরে এই Page থেকে বের করে দিবে ---
                      Future.delayed(const Duration(milliseconds: 800), () {
                        if (!context.mounted) return;
                        Navigator.pop(context, {
                          'packages': selectedPackages,
                          'names': selectedAppNames,
                          'time': timerController.text,
                        });
                      });
                    },
                    child: Text(
                      selectedPackages.isEmpty
                          ? "Safety"
                          : "Safety (${selectedPackages.length})",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
