import 'package:flutter/material.dart';

class CRMLead {
  final String name;
  final String email;
  final String phone;
  final String socialText;
  final String socialIcon;
  final String tagText;
  final Color tagColor;
  final String time;
  final String? notes;

  CRMLead({
    required this.name,
    required this.email,
    required this.phone,
    required this.socialText,
    required this.socialIcon,
    required this.tagText,
    required this.tagColor,
    required this.time,
    this.notes,
  });
}
