import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:roberto/core/services/local_storage_service.dart';
import 'package:roberto/features/notification/data/repositories/notification_repository.dart';
import 'package:roberto/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Only import flutter_local_notifications on non-web platforms
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    if (dart.library.html) 'package:roberto/core/services/_stub_local_notifications.dart';

// Global key for navigation without context
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Background message handler — must be a top-level function.
/// Only registered on mobile (web uses service worker).
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (kDebugMode) {
    print('[FCM] Background message received: ${message.messageId}');
  }
}

class FirebaseMessagingService {
  static final FirebaseMessagingService _instance =
      FirebaseMessagingService._internal();
  factory FirebaseMessagingService() => _instance;
  FirebaseMessagingService._internal();

  // _fcm is a lazy getter — only accessed AFTER Firebase.initializeApp()
  FirebaseMessaging get _fcm => FirebaseMessaging.instance;

  FlutterLocalNotificationsPlugin? _localNotifications;

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      // 1. Initialize Firebase
      await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform);

      // 2. Register background handler only on mobile
      if (!kIsWeb) {
        FirebaseMessaging.onBackgroundMessage(
            _firebaseMessagingBackgroundHandler);
      }

      // 3. Request permissions
      await _requestPermissions();

      // 4. Setup local notifications (mobile only)
      if (!kIsWeb) {
        await _initLocalNotifications();
      }

      // 5. Setup message listeners
      _setupMessageHandlers();

      _isInitialized = true;

      if (kDebugMode) {
        print('[FCM] FirebaseMessagingService initialized successfully.');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[FCM] Error initializing FirebaseMessagingService: $e');
      }
    }
  }

  Future<void> _requestPermissions() async {
    try {
      final NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      if (kDebugMode) {
        print(
            '[FCM] Notification permission: ${settings.authorizationStatus}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[FCM] Permission request failed: $e');
      }
    }
  }

  Future<void> _initLocalNotifications() async {
    _localNotifications = FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications!.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (kDebugMode) {
          print('[FCM] Notification tapped: ${response.payload}');
        }
        _handleNotificationClick(response.payload);
      },
    );

    // Create Android high-importance channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'Used for important push notifications.',
      importance: Importance.high,
    );

    await _localNotifications!
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  void _setupMessageHandlers() {
    // --- Foreground messages ---
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print(
            '[FCM] Foreground message: ${message.notification?.title}');
      }

      // Show local notification on mobile only
      if (!kIsWeb && _localNotifications != null) {
        final notification = message.notification;
        if (notification != null) {
          _localNotifications!.show(
            id: notification.hashCode,
            title: notification.title,
            body: notification.body,
            notificationDetails: const NotificationDetails(
              android: AndroidNotificationDetails(
                'high_importance_channel',
                'High Importance Notifications',
                icon: '@mipmap/ic_launcher',
                importance: Importance.high,
                priority: Priority.high,
              ),
              iOS: DarwinNotificationDetails(),
            ),
            payload: jsonEncode(message.data),
          );
        }
      }
    });

    // --- App opened from background tap ---
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('[FCM] App opened from background tap: ${message.messageId}');
      }
      _handleNotificationClick(jsonEncode(message.data));
    });

    // --- App opened from terminated state ---
    _fcm.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        if (kDebugMode) {
          print(
              '[FCM] App opened from terminated state: ${message.messageId}');
        }
        // Delay to ensure navigator is fully mounted
        Future.delayed(const Duration(milliseconds: 500), () {
          _handleNotificationClick(jsonEncode(message.data));
        });
      }
    });

    // --- Token refresh ---
    _fcm.onTokenRefresh.listen((newToken) {
      if (kDebugMode) {
        print('[FCM] Token refreshed.');
      }
      if (navigatorKey.currentContext != null) {
        final repository =
            navigatorKey.currentContext!.read<NotificationRepository>();
        _registerTokenWithBackend(newToken, repository);
      }
    });
  }

  /// Call this after a successful login or when the dashboard loads.
  Future<void> registerCurrentToken(NotificationRepository repository) async {
    try {
      String? token;
      if (kIsWeb) {
        // Web requires a VAPID key from Firebase Console → Project Settings → Cloud Messaging
        // Replace 'YOUR_WEB_VAPID_KEY_HERE' with the actual key.
        token = await _fcm.getToken(vapidKey: 'BA_d-hjgny9aAoJCuWuNgRzpMf53AhoCpaRx34pp9DiUpFeFcrNy8pONC2rasIZdNNViMLcmWZHCJ0c_iBROSdU');
      } else {
        token = await _fcm.getToken();
      }

      if (token != null) {
        if (kDebugMode) {
          print('[FCM] Token generated: $token');
        }
        await _registerTokenWithBackend(token, repository);
      }
    } catch (e) {
      if (kDebugMode) {
        print('[FCM] Token generation error: $e');
      }
    }
  }

  Future<void> _registerTokenWithBackend(
      String token, NotificationRepository repository) async {
    // Skip if user is not logged in
    final accessToken = LocalStorageService.accessToken;
    if (accessToken == null || accessToken.isEmpty) return;

    // Skip if token hasn't changed
    final lastToken = LocalStorageService.fcmToken;
    if (lastToken == token) {
      if (kDebugMode) {
        print('[FCM] Token unchanged. Skipping backend registration.');
      }
      return;
    }

    try {
      final String deviceType = kIsWeb
          ? 'WEB'
          : (defaultTargetPlatform == TargetPlatform.iOS ? 'IOS' : 'ANDROID');

      await repository.registerFCMToken(token, deviceType);

      if (kDebugMode) {
        print('[FCM] Token registered successfully. Device: $deviceType');
      }
      await LocalStorageService.saveFcmToken(token);
    } catch (e) {
      if (kDebugMode) {
        print('[FCM] Token backend registration failed: $e');
      }
    }
  }

  /// Navigate to the correct screen based on notification type.
  void _handleNotificationClick(String? payloadString) {
    if (payloadString == null || payloadString.isEmpty) return;

    try {
      final Map<String, dynamic> payload = jsonDecode(payloadString);
      final String? type = payload['type'] as String?;

      if (navigatorKey.currentState == null) return;

      // Ensure user is logged in before navigating
      final accessToken = LocalStorageService.accessToken;
      if (accessToken == null || accessToken.isEmpty) return;

      if (kDebugMode) {
        print('[FCM] Notification clicked. type=$type');
      }

      // Centralized notification-type → route mapping
      switch (type) {
        case 'NEW_MESSAGE':
          navigatorKey.currentState!.pushNamed('/inbox');
          break;
        case 'PARCEL_DELIVERY':
        case 'BRANCH_CREATE':
        default:
          navigatorKey.currentState!.pushNamed('/notifications');
          break;
      }
    } catch (e) {
      if (kDebugMode) {
        print('[FCM] Error handling notification click: $e');
      }
    }
  }
}
