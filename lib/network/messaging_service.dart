import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:news_app/main.dart';
import 'package:news_app/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  print('Title : ${message.notification?.title}');
  print('Body : ${message.notification?.body}');
  print('Payload : ${message.data}');
}

class FirebaseApi{
  final _firebaseMessaging = FirebaseMessaging.instance;

  void handleMessage(RemoteMessage? message) async {
    if(message == null)return;

    final prefs = await SharedPreferences.getInstance();
    if(prefs.getString(Constants.userKey)!.isNotEmpty){
      navigatorKey.currentState?.pushNamed('/home', arguments: message);
    }
    navigatorKey.currentState?.pushNamed('/login', arguments: message);
  }

  Future<void> initNotifications() async {
    final _permission = await _firebaseMessaging.requestPermission();
    log('${_permission.authorizationStatus}');
    final fCMToken = await _firebaseMessaging.getToken();
    log('Here is the token : $fCMToken');
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
  }

  Future<void> initPushNotification() async {
    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
  }
}