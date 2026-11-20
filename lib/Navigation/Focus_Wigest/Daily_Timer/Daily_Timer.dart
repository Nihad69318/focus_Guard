import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// এইটাই তোর Widget
class DurationPicker {
  static Future<void> show(
      BuildContext context, {
        required Function(int hour, int min, int sec) onPicked,
        int initHour = 0,
        int initMin = 0,
        int initSec = 0,
      }) async {
    int tempH = initHour;
    int tempM = initMin;
    int tempS = initSec;

    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Container(
          height: 320,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text("Setup daily timer", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text("Hours", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text("Minute", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text("Second", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: CupertinoPicker(
                        itemExtent: 40,
                        scrollController: FixedExtentScrollController(initialItem: tempH),
                        onSelectedItemChanged: (v) => tempH = v,
                        children: List.generate(13, (i) => Center(child: Text("$i", style: const TextStyle(fontSize: 22)))),
                      ),
                    ),
                    const Text(":", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    Expanded(
                      child: CupertinoPicker(
                        itemExtent: 40,
                        scrollController: FixedExtentScrollController(initialItem: tempM),
                        onSelectedItemChanged: (v) => tempM = v,
                        children: List.generate(60, (i) => Center(child: Text(i.toString().padLeft(2, '0'), style: const TextStyle(fontSize: 22)))),
                      ),
                    ),
                    const Text(":", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    Expanded(
                      child: CupertinoPicker(
                        itemExtent: 40,
                        scrollController: FixedExtentScrollController(initialItem: tempS),
                        onSelectedItemChanged: (v) => tempS = v,
                        children: List.generate(60, (i) => Center(child: Text(i.toString().padLeft(2, '0'), style: const TextStyle(fontSize: 22)))),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                  onPressed: () {
                    onPicked(tempH, tempM, tempS);
                    Navigator.pop(context);
                  },
                  child: const Text("Set Timer", style: TextStyle(color: Colors.white, fontSize: 18)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}