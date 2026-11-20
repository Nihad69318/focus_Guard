import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Contact extends StatelessWidget {
  const Contact({
    super.key,
    required this.backgroundColor,
    required this.cardColor,
    required this.textColor,
    required this.buttonColor,
  });

  final Color backgroundColor;
  final Color cardColor;
  final Color textColor;
  final Color buttonColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: backgroundColor,

      child: Card(
        margin: EdgeInsets.zero,
        color: cardColor,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),

        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              // Contact Header
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.support_agent,
                    size: 35,
                    color: textColor,
                  ),

                  const SizedBox(width: 10),

                  Text(
                    'Contact Us',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Contact Buttons
              Row(
                children: [

                  Expanded(
                    child: SizedBox(
                      height: 60,
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.phone,color: Colors.green,size: 20,),
                        label: const Text('WhatsApp',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17),),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonColor,
                          foregroundColor: Colors.green,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: SizedBox(
                      height: 60,
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.email,size: 20,color: Colors.lightGreen,),
                        label: const Text('Email',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: Colors.lightGreen),),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonColor,
                          foregroundColor: cardColor,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
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
    );
  }
}
