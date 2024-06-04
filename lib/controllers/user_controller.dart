import 'dart:convert';
import 'dart:io';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:news_app/models/custom_error.dart';
import 'package:news_app/models/user.dart';
import 'package:news_app/network/authentication.dart';
import 'package:news_app/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

final userControllerProvider = Provider((ref) {
  return UserController(ref);
},);

class UserController{
  final Ref ref;

  UserController(this.ref);

  static final _authService = Authentication.getInstance;

  signUp(String name, String email, String password) async {
    try{
      final response = await _authService.signUp(name, email, password);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(Constants.userKey, jsonEncode(response));
      final currentUser = AppUser.fromJson(response);
      ref.read(currentUserNotifierProvider.notifier).setUser(currentUser: currentUser);
    } on CustomError catch(error){
      await FirebaseCrashlytics.instance.setUserIdentifier("not-signed-in");
      await FirebaseCrashlytics.instance.recordFlutterFatalError(FlutterErrorDetails(exception: error));
      rethrow;
    }
  }

  signIn(String email, String password) async {
    try{
      final response = await _authService.signIn(email, password);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(Constants.userKey, jsonEncode(response));
      final currentUser = AppUser.fromJson(response);
      ref.read(currentUserNotifierProvider.notifier).setUser(currentUser: currentUser);
    }on CustomError catch(error){
      await FirebaseCrashlytics.instance.setUserIdentifier("not-signed-in");
      await FirebaseCrashlytics.instance.recordFlutterFatalError(FlutterErrorDetails(exception: error));
      rethrow;
    }
  }

  deleteAccount(AppUser user) async {
    try{
      await Authentication.getInstance.deleteAccount(user);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("user", "");
    } on CustomError catch(error){
      await FirebaseCrashlytics.instance.recordFlutterFatalError(FlutterErrorDetails(exception: error));
      rethrow;
    }
  }
  
  updateDetails(AppUser user, String newName, String newEmail, String newPassword,WidgetRef ref) async {
    try{
      final response = await Authentication.getInstance.updateDetails(user, newName, newEmail, newPassword);
      if(newName.isNotEmpty)ref.read(currentUserNotifierProvider.notifier).updateName(newName);
      if(newEmail.isNotEmpty)ref.read(currentUserNotifierProvider.notifier).updateEmail(newEmail);
      if(newPassword.isNotEmpty)ref.read(currentUserNotifierProvider.notifier).updatePassword(newPassword);
      final prefs = await SharedPreferences.getInstance();
      prefs.setString("user", jsonEncode(response));
    } on CustomError catch(error){
      await FirebaseCrashlytics.instance.recordFlutterFatalError(FlutterErrorDetails(exception: error));
      rethrow;
    }
  }

  Future<String> updateImage(AppUser user, XFile file) async {
    try{
      Reference referenceRoot = FirebaseStorage.instance.ref();
      Reference referenceDirImages = referenceRoot.child('images');
      Reference referenceImageToUpload = referenceDirImages.child('image-${user.uid}');
      await referenceImageToUpload.putFile(File(file.path));
      String imageUrl = await referenceImageToUpload.getDownloadURL();
      final response = await Authentication.getInstance.updateImage(user, imageUrl);

      final prefs = await SharedPreferences.getInstance();
      prefs.setString("user", jsonEncode(response));

      return imageUrl;
    }on CustomError catch(error){
      await FirebaseCrashlytics.instance.recordFlutterFatalError(FlutterErrorDetails(exception: error));
      rethrow;
    }
  }
}