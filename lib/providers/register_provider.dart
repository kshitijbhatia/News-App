import 'package:flutter/material.dart';
import 'package:news_app/controllers/user_controller.dart';
import 'package:news_app/models/custom_error.dart';
import 'package:news_app/screens/Home_Page/home_page.dart';
import 'package:news_app/widgets/snackbar.dart';

class RegisterProvider extends ChangeNotifier{
  bool _registerApiCallComplete = true;
  bool get getRegisterComplete => _registerApiCallComplete;
  setRegisterStatus(){
    _registerApiCallComplete = !_registerApiCallComplete;
    notifyListeners();
  }

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  GlobalKey<FormState> registerFormKey = GlobalKey<FormState>();

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

  clearForm(){
   registerFormKey.currentState?.reset();
   nameController.clear();
   emailController.clear();
   passwordController.clear();
   notifyListeners();
  }

  Future<void> registerUser(BuildContext context) async {
    try{
      String name = nameController.text;
      String email = emailController.text;
      String password = passwordController.text;
      setRegisterStatus();
      await UserController.signUp(name, email, password);
      clearForm();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage(),));
    } on CustomError catch(error){
      if(error.errorType == "email"){
        setEmailError(error.description);
      }else if(error.errorType == "password"){
        setPasswordError(error.description);
      }else if(error.errorType == "snackbar"){
        ScaffoldMessenger.of(context).showSnackBar(getCustomSnackBar(context ,error.description));
      }
    } finally {
      setRegisterStatus();
    }
  }
}