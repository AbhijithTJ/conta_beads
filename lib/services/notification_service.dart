import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("Handling a background message: ${message.messageId}");
  
  // If it's a data-only message and you want to show a notification manually in the background:
  if (message.notification == null && message.data.isNotEmpty) {
     // You could initialize flutter_local_notifications here and show it,
     // but usually, it's better to send 'notification' payload from the server.
  }
}

class NotificationService {
  static final NotificationService instance = NotificationService._internal();
  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    try {
      // Request permissions
      await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      // 1. Set foreground notification presentation options for iOS
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true, 
        badge: true, 
        sound: true,
      );

      // 2. Listen to Token Refreshes
      _messaging.onTokenRefresh.listen((fcmToken) {
        debugPrint("FCM Token Refreshed: $fcmToken");
      }).onError((err) {
        debugPrint("Error listening to token refresh: $err");
      });

      // 3. Listen to Foreground Messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('Received foreground message: ${message.messageId}');
        
        if (message.notification != null) {
          // Show local notification for foreground messages
          _localNotifications.show(
            message.notification.hashCode,
            message.notification!.title,
            message.notification!.body,
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'high_importance_channel',
                'High Importance Notifications',
                importance: Importance.max,
                priority: Priority.high,
              ),
              iOS: DarwinNotificationDetails(
                presentAlert: true,
                presentBadge: true,
                presentSound: true,
              ),
            ),
          );
        }
      });

      // Configure Local Notifications
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@drawable/ic_stat_notification');
      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings();
      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      await _localNotifications.initialize(
        initializationSettings,
      );

      // Create Android Notification Channel
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'high_importance_channel', // id
        'High Importance Notifications', // title
        description: 'This channel is used for important notifications.',
        importance: Importance.max,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      // Set background handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Handle background message tap
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('A new onMessageOpenedApp event was published!');
      });

      // Handle terminated state message tap
      _messaging.getInitialMessage().then((initialMessage) {
        if (initialMessage != null) {
          debugPrint('App opened from terminated state via notification');
        }
      });
    } catch (e) {
      debugPrint("NotificationService initialization error: $e");
    }
  }
  Future<String?> getToken() async {
    try {
      // 1. Check Authorization Status explicitly
      NotificationSettings settings = await _messaging.getNotificationSettings();
      debugPrint("📱 Dart: Current Auth Status: ${settings.authorizationStatus}");

      if (defaultTargetPlatform == TargetPlatform.iOS) {
        debugPrint("📱 Dart: Requesting APNs token from iOS...");
        String? apnsToken = await _messaging.getAPNSToken();
        
        if (apnsToken == null) {
          debugPrint("📱 Dart: APNs Token is null. Waiting 3 seconds...");
          await Future.delayed(const Duration(seconds: 3));
          apnsToken = await _messaging.getAPNSToken();
        }
        
        if (apnsToken != null) {
          debugPrint("📱 Dart: SUCCESS - APNs Token received: $apnsToken");
        } else {
          debugPrint("📱 Dart: FATAL - APNs Token is STILL null after wait. Check Xcode native logs for 'FAILED to register'.");
          return null; // Don't even try FCM if APNs failed natively
        }
      }
      
      debugPrint("📱 Dart: Requesting FCM token...");
      String? fcmToken = await _messaging.getToken();
      debugPrint("📱 Dart: SUCCESS - FCM Token: $fcmToken");
      
      return fcmToken;
    } catch (e) {
      debugPrint("📱 Dart: Error fetching token: $e");
      return null;
    }
  }

  /// Request notification permission explicitly
  Future<void> requestNotificationPermission() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted notification permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      debugPrint('User granted provisional notification permission');
    } else {
      debugPrint('User declined notification permission');
    }
  }
}
