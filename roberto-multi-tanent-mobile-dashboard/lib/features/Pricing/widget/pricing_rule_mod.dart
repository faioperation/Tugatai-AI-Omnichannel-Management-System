import 'package:flutter/material.dart';

class PricingRuleMod {
  final String id;
  final String name;
  final String type;
  final String value;
  final String? branchId;
  final Map<String, dynamic>? rawConfiguration;
  final bool isActive;

  PricingRuleMod({
    required this.id,
    required this.name,
    required this.type,
    required this.value,
    this.branchId,
    this.rawConfiguration,
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
      if (config is String) {
        parsedValue = config;
      } else if (config is Map) {
        // If it's just a wrapped value from old code
        if (config.containsKey('value') && config.length == 1) {
          parsedValue = config['value'].toString();
        } else {
          List<String> parts = [];
          config.forEach((key, val) {
            String formattedKey = key.toString().replaceAll(RegExp(r'([A-Z])'), r' $1');
            formattedKey = formattedKey[0].toUpperCase() + formattedKey.substring(1);
            
            if (val is Map) {
              String subVals = val.entries.map((e) => '${e.key}: ${e.value}').join(', ');
              parts.add('$formattedKey: $subVals');
            } else {
              parts.add('$formattedKey: $val');
            }
          });
          parsedValue = parts.join('\n');
        }
      } else {
        parsedValue = config.toString();
      }
    }

    return PricingRuleMod(
      id: json['id'] ?? '',
      name: json['ruleName'] ?? 'Unknown',
      type: json['type'] ?? 'SHIPPING',
      value: parsedValue,
      branchId: json['branchId'],
      rawConfiguration: config is Map ? config as Map<String, dynamic> : null,
      isActive: json['status'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ruleName': name,
      'type': type,
      'configuration': {'value': value}, // Basic mapping back to config
      'branchId': branchId,
      'status': isActive,
    };
  }
}
