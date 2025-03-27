import 'package:flutter/material.dart';

class AppStyles {
  static final inputDecoration = InputDecoration(
    filled: true,
    fillColor: Colors.white,
    labelStyle: TextStyle(color: Colors.green),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: Colors.green),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: Colors.green[800]!),
    ),
  );

  static final greenButton = ElevatedButton.styleFrom(
    backgroundColor: Colors.green[700],
    foregroundColor: Colors.white,
    padding: EdgeInsets.symmetric(vertical: 14),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  );

  static final outlinedGreenButton = OutlinedButton.styleFrom(
    foregroundColor: Colors.green[700],
    side: BorderSide(color: Colors.green),
    padding: EdgeInsets.symmetric(vertical: 14),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  );
}
