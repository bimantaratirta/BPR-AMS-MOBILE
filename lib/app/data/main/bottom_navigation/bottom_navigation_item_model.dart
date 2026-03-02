import 'package:flutter/material.dart';

class BottomNavigationItemModel {
  final VoidCallback onTap;
  final String iconPath;
  final Color iconColor;
  final String label;
  final TextStyle labelStyle;
  final int index;

  BottomNavigationItemModel({
    required this.onTap,
    required this.iconPath,
    required this.label,
    required this.iconColor,
    required this.labelStyle,
    required this.index,
  });
}
