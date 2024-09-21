import 'dart:async';
import 'dart:developer';
import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:news_app/firebase_options.dart';
import 'package:news_app/logger.dart';
import 'package:news_app/network/messaging_service.dart';
import 'package:news_app/network/remote_config_service.dart';
import 'package:news_app/screens/Authentication/login_page.dart';
import 'package:news_app/screens/Home_Page/home_page.dart';
import 'package:news_app/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/services.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform
  );

  await LoggerClass.initLogger();
  await LoggerClass.saveLog("app_startup");

  Future.delayed(const Duration(milliseconds: 50), () {
    Timer.periodic(const Duration(milliseconds: 50), (Timer timer) async {
      log("saveLog method called: ${timer.tick}");
      await LoggerClass.saveLog("Log_Saved_Flutter");
    });
  },);

  await NativeCommunication.callNativeMethod('appStartup');

  await FirebaseMessagingApi.getInstance.initNotifications();
  FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);

  await FirebaseRemoteConfigService.getInstance.initialize();

  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(FlutterErrorDetails(exception: error));
    return true;
  };

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  String _user = "";

  _loadPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() => _user = prefs.getString(Constants.userKey) ?? "");
    log(_user);
  }

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'News App',
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      home: (_user != "")
          ? const HomePage()
          : const LoginPage()
    );
  }
}

class NativeCommunication {
  static const platform = MethodChannel('my_news');

  static Future<String?> callNativeMethod(String methodName) async {
    try {
      final String result = await platform.invokeMethod(methodName);
      return result;
    } on PlatformException catch (e) {
      log("Failed to call native method: '${e.message}'.");
      return null;
    }
  }
}