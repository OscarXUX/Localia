import 'package:flutter/material.dart';

class LocaliaTheme {
  static const double kRadius = 35.0; // El estándar "Apple"
  static const Color coppelGreen = Color(0xFF008F39);
  
  static BoxDecoration glassStyle = BoxDecoration(
    color: Colors.white.withOpacity(0.9),
    borderRadius: BorderRadius.circular(kRadius),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 20,
        offset: const Offset(0, 10),
      )
    ],
  );
}