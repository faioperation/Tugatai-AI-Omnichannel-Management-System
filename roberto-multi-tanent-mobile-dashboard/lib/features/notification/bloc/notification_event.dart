import 'package:flutter/foundation.dart';

@immutable
abstract class NotificationEvent {}

class FetchNotificationsRequested extends NotificationEvent {}

class MarkAllNotificationsAsRead extends NotificationEvent {}

class MarkNotificationAsRead extends NotificationEvent {
  final String notificationId;

  MarkNotificationAsRead({required this.notificationId});
}
