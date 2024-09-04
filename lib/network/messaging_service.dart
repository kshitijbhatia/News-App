import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:news_app/main.dart';
import 'package:news_app/models/user.dart';
import 'package:news_app/screens/Update_Page/update_page.dart';


@pragma('vm:entry-point')
Future<void> handleBackgroundMessage(RemoteMessage message) async {
  log('''
    Background Message
    Title: ${message.data["title"]}
    Body: ${message.data["body"]}
    Data: ${message.data["data"]}
  ''');

  if(message.data["data"] == "1"){

    final AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
        FirebaseMessagingApi.theftAlertNotificationChannel.id,
        FirebaseMessagingApi.theftAlertNotificationChannel.name,
        icon: "@drawable/tvs_notification_toolbar",
        color: Colors.yellowAccent,
        importance: Importance.max,
        sound: const RawResourceAndroidNotificationSound('custom_sound'),
        priority: Priority.max,
        colorized: true,
    );

    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidNotificationDetails,
    );

    await FirebaseMessagingApi._flutterLocalNotificationsPlugin.show(
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

@pragma('vm:entry-point')
void handleBackgroundNotificationTap(NotificationResponse message) {
  log("Background_Message_Payload : ${message.payload}");
}





class FirebaseMessagingApi{
  FirebaseMessagingApi._();
  static final FirebaseMessagingApi _instance = FirebaseMessagingApi._();
  static FirebaseMessagingApi get getInstance => _instance;

  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final  FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel theftAlertNotificationChannel = AndroidNotificationChannel(
      'theft_alert',
      'Theft Alerts',
      importance: Importance.max,
      sound: RawResourceAndroidNotificationSound('alarm_sound'),
      enableLights: true,
      ledColor: Colors.white
  );

  Future<void> initNotifications() async {
    try{
      final settings = await _firebaseMessaging.requestPermission();
      log("Notification_Auth_Status: ${settings.authorizationStatus}");

      getFCMToken();

      checkFCMToken();

      const androidInitialization = AndroidInitializationSettings("@drawable/tvs_notification_toolbar");
      const iOSInitialisation = DarwinInitializationSettings();
      const initializationSettings = InitializationSettings(android: androidInitialization, iOS: iOSInitialisation);
      await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (details) {
          log('User tapped on notification. Inside onDidReceiveNotificationResponse');
          log("Payload : ${details.payload}");
        },
        onDidReceiveBackgroundNotificationResponse: handleBackgroundNotificationTap,
      );
      _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(theftAlertNotificationChannel);

      _showForegroundNotification();
    }catch(error){
      log("Error occurred when initialising notification plugin: $error");
    }
  }



  void _showForegroundNotification() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {

      // BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
      //   message.data["body"].toString(),
      //   htmlFormatBigText: false,
      //   contentTitle: message.data["title"].toString(),
      //   htmlFormatContentTitle: false,
      //   htmlFormatContent: false,
      // );

      // ToDo: TVS Blue Color, add vibration Patterns, add enableLights
      final AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
          theftAlertNotificationChannel.id,
          theftAlertNotificationChannel.name,
          icon: "@drawable/tvs_notification_toolbar",
          // styleInformation: bigTextStyleInformation,
          importance: Importance.max,
          priority: Priority.max,
          // Not Working
          enableVibration: true,
          vibrationPattern: Int64List.fromList([0, 1000, 500, 1000, 500, 1000]),
          ledColor: Colors.white,
          ledOnMs: 1000,
          ledOffMs: 1000,
          
          color: Colors.lightBlue,
      );

      NotificationDetails platformChannelSpecifics = NotificationDetails(
          android: androidNotificationDetails,
          iOS: const DarwinNotificationDetails()
      );

      await _flutterLocalNotificationsPlugin.show(
        message.notification.hashCode,
        message.data["title"].toString(),
        message.data["body"].toString(),
        platformChannelSpecifics,
        payload: "123456"
      );
    });
  }



  Future<String?> getFCMToken() async {
    String? fcmToken;
    try{
      fcmToken = await FirebaseMessaging.instance.getToken() ?? 'null';
    }catch(error){
      fcmToken = 'error';
      log("Error occurred when fetching the FCM Token; $error");
    }
    log("FCM_Token: $fcmToken");
    return fcmToken;
  }

  void removeToken() async {
    await FirebaseMessaging.instance.deleteToken();
  }

  void checkFCMToken(){
    _firebaseMessaging.onTokenRefresh
        .listen((String newToken){
          log("New_Token: $newToken");
        })
        .onError((error){
          log('Error: $error');
        });
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

