import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../app/color/app_colors.dart';

class timer extends StatelessWidget {
  const timer({
    super.key,
    required this.cardColor,
  });

  final Color cardColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
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
    );
  }
}
