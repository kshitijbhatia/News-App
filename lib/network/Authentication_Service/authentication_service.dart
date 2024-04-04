import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';

class Authentication{
  Authentication._privateConstructor();
  static final Authentication _instance = Authentication._privateConstructor();
  static Authentication get getInstance => _instance;

  static final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  static FirebaseAuth get getAuthInstance => _firebaseAuth;

  Future<void> signUp(String name,String email,String password) async {
    try{
      final currentUser = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);

    }catch(err){
      log(err.toString());
    }
  }
}

