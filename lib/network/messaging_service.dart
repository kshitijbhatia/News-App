import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';

class NotificationIconCustomizer {
  static const MethodChannel _channel = MethodChannel('com.example.news_app');

  static Future<void> showCustomNotification(RemoteMessage message) async {
    try {
      await _channel.invokeMethod('showCustomNotification',
        {
          "title" : message.data["title"],
          "body" : message.data["body"],
          "channel_id" : message.data["type"]
        },
      );
    } on PlatformException catch (e) {
      log("Failed to show notification: '${e.message}'.");
    }
  }
}


@pragma('vm:entry-point')
Future<void> handleBackgroundMessage(RemoteMessage message) async {
  log('''
    Background Message
    Title: ${message.data["title"]}
    Body: ${message.data["body"]}
    Data: ${message.data["data"]}
  ''');

  if(message.data["data"] == "1"){

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings androidInitializationSettings = AndroidInitializationSettings('@drawable/ic_stat_warning');
    const InitializationSettings initializationSettings = InitializationSettings(android: androidInitializationSettings,);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    late AndroidNotificationDetails androidNotificationDetails;
    if(message.data["type"] == "battery_alert"){
      androidNotificationDetails = AndroidNotificationDetails(
        FirebaseMessagingApi.batteryAlertChannel.id,
        FirebaseMessagingApi.batteryAlertChannel.name,
        icon: "@drawable/ic_stat_battery",
        color: Colors.red,
        importance: Importance.high,
        sound: const RawResourceAndroidNotificationSound('battery_sound'),
        priority: Priority.high,
        colorized: true
      );
    }else{
      androidNotificationDetails = AndroidNotificationDetails(
        FirebaseMessagingApi.breakingNewsChannel.id,
        FirebaseMessagingApi.breakingNewsChannel.name,
        icon: "@drawable/ic_stat_warning",
        color: Colors.yellowAccent,
        importance: Importance.high,
        sound: const RawResourceAndroidNotificationSound('custom_sound'),
        priority: Priority.high,
        colorized: true
      );
    }

    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidNotificationDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      message.notification.hashCode,
      message.data["title"],
      message.data["body"],
      platformChannelSpecifics,
    );
  }else{
    log("Invalid Data. Notification will not be shown.");
    return;
  }
}



class FirebaseMessagingApi{

  FirebaseMessagingApi._();
  static final FirebaseMessagingApi _instance = FirebaseMessagingApi._();
  static FirebaseMessagingApi get getInstance => _instance;

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel breakingNewsChannel = AndroidNotificationChannel(
    'breaking_news',
    'Breaking News Alerts',
    importance: Importance.high,
    sound: RawResourceAndroidNotificationSound('custom_sound'),
  );

  static const AndroidNotificationChannel batteryAlertChannel = AndroidNotificationChannel(
    'battery_alert',
    "Battery Alert",
    importance: Importance.high,
    sound: RawResourceAndroidNotificationSound('battery_sound'),
  );

  Future<void> initPushNotification() async {
    final settings = await _firebaseMessaging.requestPermission();
    log("Notification Auth Status: ${settings.authorizationStatus}");
    final String? fcmToken = await _firebaseMessaging.getToken();
    log("FCM Token: $fcmToken");
    refreshToken(fcmToken!);

    const androidInitialization = AndroidInitializationSettings("@drawable/ic_stat_warning");
    const iOSInitialisation = DarwinInitializationSettings();
    const initializationSettings = InitializationSettings(android: androidInitialization, iOS: iOSInitialisation);
    _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }


  checkFCMToken(){
    _firebaseMessaging.onTokenRefresh.listen((String newToken){
      log("New Token: $newToken");
      refreshToken(newToken);
    });
  }

  Future<void> initNotifications() async {
    await initPushNotification();
    checkFCMToken();

    _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(breakingNewsChannel);
    _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(batteryAlertChannel);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      log("Message Data: ${message.data}");

      await NotificationIconCustomizer.showCustomNotification(message);

      BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
          message.data["body"].toString(),
          htmlFormatBigText: true,
          contentTitle: message.data["title"].toString(),
          htmlFormatContentTitle: true,
      );

      late AndroidNotificationDetails androidNotificationDetails;
      if(message.data["type"] == 'battery_alert'){
        androidNotificationDetails = AndroidNotificationDetails(
          batteryAlertChannel.id,
          batteryAlertChannel.name,
          icon: "@drawable/ic_stat_battery",
          importance: Importance.high,
          styleInformation: bigTextStyleInformation,
          priority: Priority.high,
          playSound: true,
          color: Colors.red,
          colorized: true,
          largeIcon: const DrawableResourceAndroidBitmap('@drawable/ic_warning')
        );
      }else{
        androidNotificationDetails = AndroidNotificationDetails(
          breakingNewsChannel.id,
          breakingNewsChannel.name,
          icon: "@drawable/ic_stat_warning",
          importance: Importance.high,
          styleInformation: bigTextStyleInformation,
          priority: Priority.high,
          playSound: true,
          color: Colors.yellowAccent,
          colorized: true,
          largeIcon: const DrawableResourceAndroidBitmap('@drawable/ic_warning')
        );
      }

      NotificationDetails platformChannelSpecifics = NotificationDetails(
          android: androidNotificationDetails,
          iOS: const DarwinNotificationDetails()
      );

      // await _flutterLocalNotificationsPlugin.show(
      //   message.notification.hashCode,
      //   message.data["title"].toString(),
      //   message.data["body"].toString(),
      //   platformChannelSpecifics,
      //   payload: "123456"
      // );

    });
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

void refreshToken(String token) async {
  final CollectionReference fcmTokens = FirebaseFirestore.instance.collection('fcm');
  final timestamp = DateTime.now();
  final query = fcmTokens.where('token', isEqualTo: token);
  final QuerySnapshot querySnapshot = await query.get();
  if(querySnapshot.size == 0){
    fcmTokens.add({
      'token': token,
      'timestamp': timestamp
    });
  }else{
    final String documentId = querySnapshot.docs[0].id;
    fcmTokens.doc(documentId).update({
      'timestamp': timestamp
    });
  }
}