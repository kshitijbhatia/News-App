import 'dart:convert';
import 'dart:developer';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:news_app/firebase_options.dart';
import 'package:news_app/models/user.dart';
import 'package:news_app/network/messaging_service.dart';
import 'package:news_app/network/remote_config_service.dart';
import 'package:news_app/riverpod_observer.dart';
import 'package:news_app/screens/Authentication/login_page.dart';
import 'package:news_app/screens/Home_Page/home_page.dart';
import 'package:news_app/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
},);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final sharedPreferences = await SharedPreferences.getInstance();

  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform
  );

  await FirebaseMessagingApi.getInstance.initNotifications();
  await FirebaseMessagingApi.getInstance.subscribeToTopic(Constants.allUsers);

  await FirebaseRemoteConfigService.getInstance.initialize();

  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(FlutterErrorDetails(exception: error));
    return true;
  };

  runApp(
      ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(sharedPreferences)],
          observers: [Logger()],
          child: const MyApp()
      ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {

  late String _user;

  _loadPreferences() async {
    final SharedPreferences prefs = ref.read(sharedPreferencesProvider);
    _user = prefs.getString(Constants.userKey) ?? "";
    log('Current User : $_user');
    if(_user.isNotEmpty){
      Future.delayed(Duration.zero, () {
        final currentUser = AppUser.fromJson(jsonDecode(_user));
        ref.read(currentUserNotifierProvider.notifier).setUser(currentUser: currentUser);
      },);
    }
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
      home: (_user != "")
          ? const HomePage()
          : const LoginPage()
    );
  }
}
