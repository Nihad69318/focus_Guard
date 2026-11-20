import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class facebook_Supprot extends StatelessWidget {
  const facebook_Supprot({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () async {
            // Facebook Group open
          },
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.facebook,
                  size: 50,
                  color: Colors.blue,
                ),
                SizedBox(height: 10),
                Text(
                  'Join Our Facebook Group',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text('Connect with our community'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
