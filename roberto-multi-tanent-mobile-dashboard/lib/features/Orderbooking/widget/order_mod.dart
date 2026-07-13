import 'package:flutter/material.dart';

enum OrderStatus {
  pending,
  confirmed,
  completed,
  delivered,
  cancelled,
}

class OrderMod {
  final String orderId; // Maps to "id"
  final String customerName;
  final String phone; // Maps to "customerNumber"
  final String? email;
  final String price;
  final String? note;
  final OrderStatus status;
  final DateTime? createdAt;
  final String? conversationId;
  
  // Payment Details
  final String? paymentMethod;
  final String? paymentStatus;
  final String? transactionId;

  // Additional Details
  final String? companyName;
  final String? industry;
  final String? meetingPurpose;
  final String? employeeCount;
  final String? source;
  final String? consultantName;
  final String? timezone;
  final String? meetingLink;
  final String? preferredLanguage;
  final bool? followUpRequired;
  
  final String? appointmentDate;
  final String? appointmentTime;
  final String? platform;
  final String? duration;

  final String? bookingType;
  final String? pickupAddress;
  final String? pickupDate;
  final String? pickupTime;
  final String? deliveryDate;
  final String? deliveryTime;
  final String? deliveryAddress;
  final String? productType;
  final String? productHeight;
  final String? productWeight;
  final String? receiverPhone;
  final String? productName;
  final String? customRequirement;
  final String? country;
  final Map<String, dynamic> rawAdditionalDetails;

  // UI Helpers
  final String avatarInitials;
  final Color avatarColor;

  OrderMod({
    required this.orderId,
    required this.customerName,
    required this.phone,
    this.email,
    required this.price,
    this.note,
    required this.status,
    this.createdAt,
    this.conversationId,
    this.paymentMethod,
    this.paymentStatus,
    this.transactionId,
    this.companyName,
    this.industry,
    this.meetingPurpose,
    this.employeeCount,
    this.source,
    this.consultantName,
    this.timezone,
    this.meetingLink,
    this.preferredLanguage,
    this.followUpRequired,
    this.appointmentDate,
    this.appointmentTime,
    this.platform,
    this.duration,
    this.bookingType,
    this.pickupAddress,
    this.pickupDate,
    this.pickupTime,
    this.deliveryDate,
    this.deliveryTime,
    this.deliveryAddress,
    this.productType,
    this.productHeight,
    this.productWeight,
    this.receiverPhone,
    this.productName,
    this.customRequirement,
    this.country,
    this.rawAdditionalDetails = const {},
  })  : avatarInitials = customerName.isNotEmpty ? customerName.substring(0, 1).toUpperCase() : 'U',
        avatarColor = _generateColor(customerName);

  static Color _generateColor(String name) {
    if (name.isEmpty) return Colors.grey;
    final hash = name.hashCode;
    final r = (hash & 0xFF0000) >> 16;
    final g = (hash & 0x00FF00) >> 8;
    final b = (hash & 0x0000FF);
    return Color.fromARGB(255, 100 + (r % 155), 100 + (g % 155), 100 + (b % 155));
  }

  factory OrderMod.fromJson(Map<String, dynamic> json) {
    OrderStatus parsedStatus;
    switch (json['status']?.toString().toUpperCase()) {
      case 'PENDING':
        parsedStatus = OrderStatus.pending;
        break;
      case 'CONFIRMED':
        parsedStatus = OrderStatus.confirmed;
        break;
      case 'COMPLETED':
        parsedStatus = OrderStatus.completed;
        break;
      case 'DELIVERED':
        parsedStatus = OrderStatus.delivered;
        break;
      case 'CANCELLED':
        parsedStatus = OrderStatus.cancelled;
        break;
      default:
        parsedStatus = OrderStatus.pending;
    }

    final payment = json['paymentDetails'] as Map<String, dynamic>?;
    
    final detailsList = json['additionalDetails'] as List<dynamic>? ?? [];
    final detailsMap = <String, dynamic>{};
    for (var detail in detailsList) {
      if (detail is Map<String, dynamic> && detail['key'] != null) {
        detailsMap[detail['key']] = detail['value'];
      }
    }
    
    // Also include parcelDetails if available
    final parcelDetails = json['parcelDetails'] as Map<String, dynamic>?;
    if (parcelDetails != null) {
      detailsMap.addAll(parcelDetails);
    }
    
    // Also include appointmentDetails if available
    final appointmentDetails = json['appointmentDetails'] as Map<String, dynamic>?;
    if (appointmentDetails != null) {
      detailsMap.addAll(appointmentDetails);
    }

    return OrderMod(
      orderId: json['id'] ?? '',
      customerName: json['customerName'] ?? 'Unknown',
      phone: json['customerNumber'] ?? '',
      email: json['email'],
      price: json['price']?.toString() ?? '0',
      note: json['note'],
      status: parsedStatus,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      conversationId: json['conversationId'],
      
      paymentMethod: payment?['paymentMethod'],
      paymentStatus: payment?['paymentStatus'],
      transactionId: payment?['transactionId'],

      companyName: detailsMap['companyName'],
      industry: detailsMap['industry'],
      meetingPurpose: detailsMap['meetingPurpose'],
      employeeCount: detailsMap['employeeCount']?.toString(),
      source: detailsMap['source'],
      consultantName: detailsMap['consultantName'],
      timezone: detailsMap['timezone'],
      meetingLink: detailsMap['meetingLink'],
      preferredLanguage: detailsMap['preferredLanguage'],
      followUpRequired: detailsMap['followUpRequired']?.toString().toLowerCase() == 'true',
      
      appointmentDate: detailsMap['appointmentDate'],
      appointmentTime: detailsMap['appointmentTime'],
      platform: detailsMap['platform'],
      duration: detailsMap['duration'],

      bookingType: detailsMap['bookingType'] ?? (detailsMap['appointmentDate'] != null ? 'Appointment Booking' : (detailsMap['pickupAddress'] != null ? 'Parcel Delivery' : 'Order Booking')),
      pickupAddress: detailsMap['pickupAddress'],
      pickupDate: detailsMap['pickupDate'],
      pickupTime: detailsMap['pickupTime'],
      deliveryDate: detailsMap['deliveryDate'],
      deliveryTime: detailsMap['deliveryTime'],
      deliveryAddress: detailsMap['deliveryAddress'],
      productType: detailsMap['productType'] ?? json['productType'],
      productHeight: detailsMap['productHeight']?.toString(),
      productWeight: detailsMap['productWeight']?.toString(),
      receiverPhone: detailsMap['receiverPhone'],
      productName: detailsMap['productName'] ?? json['productName'],
      customRequirement: detailsMap['customRequirement'],
      country: detailsMap['country'] ?? json['country'],
      rawAdditionalDetails: detailsMap,
    );
  }
}
