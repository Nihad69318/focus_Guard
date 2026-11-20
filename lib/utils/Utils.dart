import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Utels {

  static void SuccessToset(String meassage){
    Fluttertoast.showToast(
        msg: meassage,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }
  static void failToset(String meassage){
    Fluttertoast.showToast(
        msg: meassage,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }

}