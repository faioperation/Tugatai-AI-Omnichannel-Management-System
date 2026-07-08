// Stub file for flutter_local_notifications on web.
// flutter_local_notifications does not support Flutter Web.
// This stub provides empty implementations so the code compiles on web.

class FlutterLocalNotificationsPlugin {
  Future<bool?> initialize({
    required dynamic settings,
    dynamic onDidReceiveNotificationResponse,
    dynamic onDidReceiveBackgroundNotificationResponse,
  }) async =>
      null;

  Future<void> show({
    required int id,
    required String? title,
    required String? body,
    required dynamic notificationDetails,
    String? payload,
  }) async {}

  T? resolvePlatformSpecificImplementation<T>() => null;
}

class AndroidFlutterLocalNotificationsPlugin {
  Future<void> createNotificationChannel(dynamic channel) async {}
}

class InitializationSettings {
  const InitializationSettings({dynamic android, dynamic iOS, dynamic macOS, dynamic linux});
}

class AndroidInitializationSettings {
  const AndroidInitializationSettings(String defaultIcon);
}

class DarwinInitializationSettings {
  const DarwinInitializationSettings({
    bool? requestAlertPermission,
    bool? requestBadgePermission,
    bool? requestSoundPermission,
  });
}

class NotificationResponse {
  final String? payload;
  const NotificationResponse({this.payload});
}

class NotificationDetails {
  const NotificationDetails({dynamic android, dynamic iOS, dynamic macOS});
}

class AndroidNotificationDetails {
  const AndroidNotificationDetails(
    String channelId,
    String channelName, {
    String? icon,
    dynamic importance,
    dynamic priority,
  });
}

class DarwinNotificationDetails {
  const DarwinNotificationDetails();
}

class AndroidNotificationChannel {
  const AndroidNotificationChannel(
    String id,
    String name, {
    String? description,
    dynamic importance,
  });
}

enum Importance { high, defaultImportance, low, max, min, none, unspecified }
enum Priority { high, defaultPriority, low, max, min }
