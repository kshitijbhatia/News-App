import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:news_app/controllers/user_controller.dart';
import 'package:news_app/models/custom_error.dart';
import 'package:news_app/models/user.dart';
import 'package:news_app/screens/Authentication/login_page.dart';
import 'package:news_app/widgets/snackbar.dart';

class UpdateProvider extends ChangeNotifier{

  bool _updateImageIsComplete = true;
  bool get imageUpdateComplete => _updateImageIsComplete;
  setUpdateImageStatus(){
    _updateImageIsComplete = !_updateImageIsComplete;
    notifyListeners();
  }

  String? _nameError;
  String? get getNameError => _nameError;
  setNameError(String? error){
    _nameError = error;
    notifyListeners();
  }

  String? _emailError;
  String? get getEmailError => _emailError;
  setEmailError(String? error){
    _emailError = error;
    notifyListeners();
  }

  String? _passwordError;
  String? get getPasswordError => _passwordError;
  setPasswordError(String? error){
    _passwordError = error;
    notifyListeners();
  }

  Future<void> updateDetails(AppUser user,String newName, String newEmail, String newPassword, BuildContext context) async {
    try{
      if(newName.isNotEmpty || newEmail.isNotEmpty || newPassword.isNotEmpty){
        await UserController.updateDetails(user, newName, newEmail, newPassword);
      }
      Navigator.pop(context, "Success");
    } on CustomError catch(error){
      if(error.errorType == "email"){
        setEmailError(error.description);
      }else if(error.errorType == "password"){
        setPasswordError(error.description);
      }else if(error.errorType == "snackbar"){
        ScaffoldMessenger.of(context).showSnackBar(getCustomSnackBar(context ,error.description));
      }
    }
  }

  Future<String?> updateImage(AppUser user,XFile? file, BuildContext context) async {
    try{
      setUpdateImageStatus();
      final response = await UserController.updateImage(user, file!);
      setUpdateImageStatus();
      return response;
    } on CustomError catch(error){
      if(error.errorType == "email"){
        setEmailError(error.description);
      }else if(error.errorType == "password"){
        setPasswordError(error.description);
      }else if(error.errorType == "snackbar"){
        ScaffoldMessenger.of(context).showSnackBar(getCustomSnackBar(context ,error.description));
      }
    }
  }

  Future<void> deleteAccount(AppUser user,BuildContext context) async {
    try{
      await UserController.deleteAccount(user);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage(),));
    } on CustomError catch(error){
      if(error.errorType == "email"){
        setEmailError(error.description);
      }else if(error.errorType == "password"){
        setPasswordError(error.description);
      }else if(error.errorType == "snackbar"){
        ScaffoldMessenger.of(context).showSnackBar(getCustomSnackBar(context ,error.description));
      }
    }
  }

}