import 'package:flutter/foundation.dart';
import 'package:roberto/features/notification/data/models/notification_model.dart';

@immutable
abstract class NotificationState {
  final List<NotificationModel> notifications;
  final int unreadCount;

  const NotificationState({this.notifications = const [], this.unreadCount = 0});
}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {
  const NotificationLoading({super.notifications, super.unreadCount});
}

class NotificationLoaded extends NotificationState {
  const NotificationLoaded({required super.notifications, required super.unreadCount});
}

class NotificationError extends NotificationState {
  final String message;

  const NotificationError({required this.message, super.notifications, super.unreadCount});
}
