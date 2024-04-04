import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:news_app/firebase_options.dart';
import 'package:news_app/network/Authentication_Service/authentication_service.dart';
import 'package:news_app/screens/Authentication/login_page.dart';
import 'package:news_app/screens/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'News App',
      debugShowCheckedModeBanner: false,
      home: StreamBuilder(
          stream: Authentication.getAuthInstance.authStateChanges(),
          builder: (context, snapshot) {
            if(snapshot.hasData){
              log('Here : ${snapshot.data}');
              return HomePage();
            }else if(snapshot.connectionState == ConnectionState.waiting){
              return Center(child: CircularProgressIndicator(),);
            }else{
              return LoginPage();
            }
          },
      ),
    );
  }
}
