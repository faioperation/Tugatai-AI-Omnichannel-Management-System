import 'package:flutter/material.dart';

enum OrderStatus {
  pending,
  confirmed,
  delivered,
}

class OrderMod {
  final String orderId;
  final String customerName;
  final String phone;
  final String? email;
  final String? fromAddress;
  final String? toAddress;
  final String address; // Kept for backward compatibility or display
  final OrderStatus status;
  final double shippingCharge;
  final String deliveryTime;
  final String avatarInitials;
  final Color avatarColor;
  final String? productName;
  final String? productSize;
  final int quantity;
  final String? paymentMethod;
  final String? notes;
  final double? price;
  final DateTime? deliveryDate;

  OrderMod({
    required this.orderId,
    required this.customerName,
    required this.phone,
    this.email,
    this.fromAddress,
    this.toAddress,
    required this.address,
    required this.status,
    required this.shippingCharge,
    required this.deliveryTime,
    required this.avatarInitials,
    required this.avatarColor,
    this.productName,
    this.productSize,
    this.quantity = 1,
    this.paymentMethod,
    this.notes,
    this.price,
    this.deliveryDate,
  });

  OrderMod copyWith({
    String? orderId,
    String? customerName,
    String? phone,
    String? email,
    String? fromAddress,
    String? toAddress,
    String? address,
    OrderStatus? status,
    double? shippingCharge,
    String? deliveryTime,
    String? avatarInitials,
    Color? avatarColor,
    String? productName,
    String? productSize,
    int? quantity,
    String? paymentMethod,
    String? notes,
    double? price,
    DateTime? deliveryDate,
  }) {
    return OrderMod(
      orderId: orderId ?? this.orderId,
      customerName: customerName ?? this.customerName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      fromAddress: fromAddress ?? this.fromAddress,
      toAddress: toAddress ?? this.toAddress,
      address: address ?? this.address,
      status: status ?? this.status,
      shippingCharge: shippingCharge ?? this.shippingCharge,
      deliveryTime: deliveryTime ?? this.deliveryTime,
      avatarInitials: avatarInitials ?? this.avatarInitials,
      avatarColor: avatarColor ?? this.avatarColor,
      productName: productName ?? this.productName,
      productSize: productSize ?? this.productSize,
      quantity: quantity ?? this.quantity,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      notes: notes ?? this.notes,
      price: price ?? this.price,
      deliveryDate: deliveryDate ?? this.deliveryDate,
    );
  }
}
