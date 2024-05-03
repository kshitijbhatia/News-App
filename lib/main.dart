import 'dart:developer';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:news_app/network/messaging_service.dart';
import 'package:news_app/firebase_options.dart';
import 'package:news_app/network/remote_config_service.dart';
import 'package:news_app/providers/home_provider.dart';
import 'package:news_app/providers/login_provider.dart';
import 'package:news_app/providers/register_provider.dart';
import 'package:news_app/providers/update_provider.dart';
import 'package:news_app/screens/Authentication/login_page.dart';
import 'package:news_app/screens/Authentication/register_page.dart';
import 'package:news_app/screens/Home_Page/home_page.dart';
import 'package:news_app/utils/constants.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform
  );

  await FirebaseMessagingApi().initNotifications();

  await FirebaseRemoteConfigService.getInstance.initialize();

  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(FlutterErrorDetails(exception: error));
    return true;
  };

  runApp(
    MultiProvider(
        providers: [
          ChangeNotifierProvider<LoginProvider>(create: (context) => LoginProvider(),),
          ChangeNotifierProvider<HomeProvider>(create: (context) => HomeProvider(),),
          ChangeNotifierProvider<RegisterProvider>(create: (context) => RegisterProvider(),),
          ChangeNotifierProvider<UpdateProvider>(create: (context) => UpdateProvider(),)
        ],
      child: const MyApp(),
    )
  );
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
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      routes: {
        '/home' : (context) => const HomePage(),
        '/register' : (context) => const RegisterPage()
      },
      home: (_user != "")
          ? const HomePage()
          : const LoginPage()
    );
  }
}
