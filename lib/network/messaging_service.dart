import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  log('Title : ${message.notification?.title}');
  log('Body : ${message.notification?.body}');
  log('Payload : ${message.data}');
}

class FirebaseMessagingApi{
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> initNotifications() async {
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

    flutterLocalNotificationsPlugin.initialize(initializationSettings);

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
        playSound: true
      );

      NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: const DarwinNotificationDetails()
      );

      await flutterLocalNotificationsPlugin.show(
          message.notification.hashCode,
          message.notification?.title,
          message.notification?.body,
          platformChannelSpecifics,
      );
    },
    );

    await FirebaseMessaging.instance.getInitialMessage();
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
  }
}