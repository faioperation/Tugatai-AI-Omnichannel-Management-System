import 'package:flutter/material.dart';

class PricingRuleMod {
  final String id;
  final String name;
  final String type;
  final String value;
  final bool isActive;

  PricingRuleMod({
    required this.id,
    required this.name,
    required this.type,
    required this.value,
    this.isActive = true,
  });

  PricingRuleMod copyWith({
    String? id,
    String? name,
    String? type,
    String? value,
    bool? isActive,
  }) {
    return PricingRuleMod(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      value: value ?? this.value,
      isActive: isActive ?? this.isActive,
    );
  }
}
