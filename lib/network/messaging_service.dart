import 'dart:async';
import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  log('Title : ${message.notification?.title}');
  log('Body : ${message.notification?.body}');
  log('Payload : ${message.data}');
}

class FirebaseMessagingApi{
  FirebaseMessagingApi._();
  static final FirebaseMessagingApi _instance = FirebaseMessagingApi._();
  static FirebaseMessagingApi get getInstance => _instance;

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> initNotifications() async {
    // Initialize Notifications
    initPushNotification();

    // Subscribing to onMessage stream for Foreground notifications
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
          message.notification!.body.toString(),
          htmlFormatBigText: true,
          contentTitle: message.notification!.body.toString(),
          htmlFormatContentTitle: true
      );

      AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
          "breaking_news_MyNews",
          "Breaking News Alerts",
          importance: Importance.high,
          styleInformation: bigTextStyleInformation,
          priority: Priority.high,
          playSound: true,
          icon: '@mipmap/ic_launcher'
      );

      NotificationDetails platformChannelSpecifics = NotificationDetails(
          android: androidPlatformChannelSpecifics,
          iOS: const DarwinNotificationDetails()
      );

      await _flutterLocalNotificationsPlugin.show(
        message.notification.hashCode,
        message.notification?.title,
        message.notification?.body,
        platformChannelSpecifics,
      );
    },
    );

    // For Background and Terminated notifications
    final RemoteMessage? backgroundMessage = await _firebaseMessaging.getInitialMessage();
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
  }

  Future<void> initPushNotification() async {
    final NotificationSettings settings = await _firebaseMessaging.requestPermission();
    final String? fCMToken = await _firebaseMessaging.getToken();
    log('Firebase Cloud Messaging Token : $fCMToken');

    const androidInitialize = AndroidInitializationSettings("@mipmap/ic_launcher");
    const iOSInitialize = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initializationSettings = InitializationSettings(
        android: androidInitialize,
        iOS: iOSInitialize
    );

    _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
    log('Subscribed To Topic : $topic');
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
    log('Unsubscribed From Topic : $topic');
  }
}