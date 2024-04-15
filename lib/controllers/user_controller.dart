import 'dart:convert';
import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:news_app/models/user.dart';
import 'package:news_app/network/authentication.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserController{
  UserController._();
  final UserController _instance = UserController._();
  UserController get getInstance => _instance;

  static final _authService = Authentication.getInstance;

  static signUp(String name, String email, String password) async {
    try{
      final response = await _authService.signUp(name, email, password);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("user", jsonEncode(response));

    } on FirebaseAuthException catch(err){
      rethrow;
    }catch(err){
      log(err.toString());
      rethrow;
    }
  }

  static signIn(String email, String password) async {
    try{
      final response = await _authService.signIn(email, password);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("user", jsonEncode(response));

    }on FirebaseAuthException catch(err){
      rethrow;
    }catch(err){
      log(err.toString());
      rethrow;
    }
  }

  static deleteAccount(AppUser user) async {
    try{
      await Authentication.getInstance.deleteAccount(user);
    } on FirebaseAuthException catch(err){
      log('$err');
      rethrow;
    } catch(err){
      log('Controller : $err');
      rethrow;
    }
  }
  
  static updateDetails(AppUser user, String newName, String newEmail, String newPassword) async {
    try{
      final response = await Authentication.getInstance.updateDetails(user, newName, newEmail, newPassword);
      final prefs = await SharedPreferences.getInstance();
      prefs.setString("user", jsonEncode(response));
    } on FirebaseAuthException catch(err){
      rethrow;
    } catch(err){
      rethrow;
    }
  }
}