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

  factory PricingRuleMod.fromJson(Map<String, dynamic> json) {
    String parsedValue = '';
    final config = json['configuration'];
    if (config != null) {
      if (config is Map) {
        parsedValue = config.entries.map((e) => '${e.key}: ${e.value}').join(', ');
      } else {
        parsedValue = config.toString();
      }
    }

    return PricingRuleMod(
      id: json['id']?.toString() ?? '',
      name: json['ruleName'] ?? 'Unknown',
      type: json['type'] ?? 'Unknown',
      value: parsedValue,
      isActive: json['status'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ruleName': name,
      'type': type,
      'configuration': {'value': value}, // Basic mapping back to config
      'status': isActive,
    };
  }
}
