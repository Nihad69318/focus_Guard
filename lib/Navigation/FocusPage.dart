
import 'package:flutter/material.dart';
import 'package:focus_guard/Navigation/Focus_Wigest/Saftey.dart';
import 'package:focus_guard/app/color/app_colors.dart';
import 'package:installed_apps/installed_apps.dart';

import 'Focus_Wigest/Activate.dart';
import 'Focus_Wigest/Configure.dart';
import 'Focus_Wigest/Daily_Timer/app_cache.dart';
import 'Focus_Wigest/View Stats.dart';
import 'Focus_Wigest/contact.dart';

class Focuspage extends StatefulWidget {
  const Focuspage({super.key});

  @override
  State<Focuspage> createState() => _FocuspageState();
}

class _FocuspageState extends State<Focuspage> {
  @override
  Widget build(BuildContext context) {
    // Current Theme Colors
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final backgroundColor = theme.scaffoldBackgroundColor;
    final cardColor = theme.colorScheme.primary;
    final buttonColor = theme.colorScheme.surface;
    final textColor = theme.colorScheme.onPrimary;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Contact(
                backgroundColor: backgroundColor,
                cardColor: cardColor,
                textColor: textColor,
                buttonColor: buttonColor,
              ),
              SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Safe area",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                    color: AppColors.primary,
                  ),
                ),
              ),
              SizedBox(height: 10),
              SizedBox(
                height: 60,
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cardColor,
                    foregroundColor: Colors.white,
                  ),
                  icon: Icon(
                    Icons.security,
                    color: Colors.lightGreenAccent,
                    size: 30,
                  ),
                  label: Text(
                    "Account Protection",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Features",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                    color: AppColors.primary,
                  ),
                ),
              ),
              SizedBox(height: 5),
              //
              // timer(cardColor: cardColor),
              Expanded(
                child: Container(

                  width: double.infinity,
                  height: 335,

                  child: Card(
                    margin: EdgeInsets.zero,
                    color: cardColor,
                    elevation: 4,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),

                    child: Padding(
                      padding: const EdgeInsets.all(12),

                      child: Column(
                        children: [
                          Row(
                            children: [
                              // First Card
                              Expanded(
                                child: SizedBox(
                                  height: 185,
                                  child: Card(
                                    margin: EdgeInsets.zero,
                                    color: AppColors.lightBackground,
                                    elevation: 4,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center, // সব উপাদান মাঝে সেন্টারে রাখবে
                                        children: [
                                          // ঘড়ির আইকনযুক্ত ছোট কার্ড
                                          Card(
                                            elevation: 0,
                                            color: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(50),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Icon(
                                                Icons.watch_later,
                                                color: AppColors.error,
                                                size: 40, // সাইজ ১০০ থেকে কমিয়ে 40 করা হয়েছে যাতে হাইটের মধ্যে ফিট হয়
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          const Text(
                                            "Daily Limit",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                color: Colors.cyan
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          SizedBox(
                                            height: 30, // বাটন ছোট করার জন্য
                                            child: ElevatedButton(
                                              onPressed: () async {
                                                // যদি কোনো কারণে এখনো Load শেষ না হয়ে থাকে, তাহলে এইটুকুই Wait করবে
                                                // আর যদি Load হয়ে থাকে, তাহলে ০ সেকেন্ডে খুলবে
                                                if (AppCache.apps == null) {
                                                  showDialog(
                                                    context: context,
                                                    barrierDismissible: false,
                                                    builder: (context) => const Center(child: CircularProgressIndicator()),
                                                  );
                                                  await AppCache.preload();
                                                  if (!context.mounted) return;
                                                  Navigator.pop(context);
                                                }

                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(builder: (context) => Saftey(apps: AppCache.apps!)),
                                                );
                                              },

                                              child: const Text("Safety", style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color:Colors.cyan)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 10),

                              // Second Card
                              Expanded(
                                child: SizedBox(
                                  height: 185,

                                  child: Card(
                                    margin: EdgeInsets.zero,
                                    color: AppColors.lightBackground,
                                    elevation: 4,

                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center, // সব উপাদান মাঝে সেন্টারে রাখবে
                                        children: [
                                          // ঘড়ির আইকনযুক্ত ছোট কার্ড
                                          Card(
                                            elevation: 0,
                                            color: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(50),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Icon(
                                                Icons.timer,
                                                color: AppColors.error,
                                                size: 40, // সাইজ ১০০ থেকে কমিয়ে 40 করা হয়েছে যাতে হাইটের মধ্যে ফিট হয়
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          const Text(
                                            "Schedule Blocker",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                color: Colors.cyan
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          SizedBox(
                                            height: 30, // বাটন ছোট করার জন্য
                                            child: ElevatedButton(
                                              onPressed: () {
                                                Navigator.push(context, MaterialPageRoute(builder: (context)=>Configure()));
                                              },
                                              child: const Text("Configure", style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color:Colors.cyan)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              // First Card
                              Expanded(
                                child: SizedBox(
                                  height: 185,

                                  child: Card(
                                    margin: EdgeInsets.zero,
                                    color: AppColors.lightBackground,
                                    elevation: 4,

                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center, // সব উপাদান মাঝে সেন্টারে রাখবে
                                        children: [
                                          // ঘড়ির আইকনযুক্ত ছোট কার্ড
                                          Card(
                                            elevation: 0,
                                            color: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(50),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Icon(
                                                Icons.bar_chart,
                                                color: AppColors.error,
                                                size: 40, // সাইজ ১০০ থেকে কমিয়ে 40 করা হয়েছে যাতে হাইটের মধ্যে ফিট হয়
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          const Text(
                                            "Activity Dashboard",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                color: Colors.cyan
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          SizedBox(
                                            height: 30, // বাটন ছোট করার জন্য
                                            child: ElevatedButton(
                                              onPressed: () {
                                                Navigator.push(context, MaterialPageRoute(builder: (context)=>Viewstats()));
                                              },
                                              child: const Text("View Stats", style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color:Colors.cyan)),
                                            ),
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
                                  height: 185,

                                  child: Card(
                                    margin: EdgeInsets.zero,
                                    color: AppColors.lightBackground,
                                    elevation: 4,

                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center, // সব উপাদান মাঝে সেন্টারে রাখবে
                                        children: [
                                          // ঘড়ির আইকনযুক্ত ছোট কার্ড
                                          Card(
                                            elevation: 0,
                                            color: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(50),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Icon(
                                                Icons.lock,
                                                color: AppColors.error,
                                                size: 40, // সাইজ ১০০ থেকে কমিয়ে 40 করা হয়েছে যাতে হাইটের মধ্যে ফিট হয়
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          const Text(
                                            "Focus Lock",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                color: Colors.cyan
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          SizedBox(
                                            height: 30, // বাটন ছোট করার জন্য
                                            child: ElevatedButton(
                                              onPressed: () {
                                                Navigator.push(context, MaterialPageRoute(builder: (context)=>Activate()));
                                              },
                                              child: const Text("Activate", style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color:Colors.cyan)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

