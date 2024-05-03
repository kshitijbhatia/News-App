import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:news_app/controllers/user_controller.dart';
import 'package:news_app/main.dart';
import 'package:news_app/models/custom_error.dart';
import 'package:news_app/screens/Authentication/register_page.dart';
import 'package:news_app/screens/Home_Page/home_page.dart';
import 'package:news_app/widgets/snackbar.dart';

class LoginProvider extends ChangeNotifier{
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();

  String? _emailError;
  String? _passError;

  String? get getEmailError => _emailError;
  void setEmailError(String? error){
    _emailError = error;
    notifyListeners();
  }

  String? get getPasswordError => _passError;
  void setPasswordError(String? error){
    _passError = error;
    notifyListeners();
  }

  void clearForm(){
    loginFormKey.currentState?.reset();
    emailController.clear();
    passwordController.clear();
    notifyListeners();
  }

  bool _loginApiCallComplete = true;
  bool get getLoginComplete => _loginApiCallComplete;
  setLoginStatus(){
    _loginApiCallComplete = !_loginApiCallComplete;
    notifyListeners();
  }

  Future<void> loginUser(BuildContext context) async {
    try{
      String email = emailController.text;
      String password = passwordController.text;
      setLoginStatus();
      await UserController.signIn(email, password);
      clearForm();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage(),));
    }on CustomError catch(error){
      if(error.errorType == "email"){
        setEmailError(error.description);
      }else if(error.errorType == "password"){
        setPasswordError(error.description);
      }else if(error.errorType == "snackbar"){
        ScaffoldMessenger.of(context).showSnackBar(getCustomSnackBar(context ,error.description));
      }
    } finally {
      setLoginStatus();
    }
  }

  navigateToRegisterPage(BuildContext context){
    clearForm();
    navigatorKey.currentState?.pushNamed('/register');
  }
}