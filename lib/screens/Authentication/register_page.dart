import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:news_app/controllers/user_controller.dart';
import 'package:news_app/models/custom_error.dart';
import 'package:news_app/models/user.dart';
import 'package:news_app/network/authentication.dart';
import 'package:news_app/screens/Home_Page/home_page.dart';
import 'package:news_app/utils/constants.dart';
import 'package:news_app/widgets/snackbar.dart';
import 'package:news_app/widgets/submit_button.dart';
import 'package:news_app/widgets/text_input.dart';

class RegisterPage extends StatefulWidget{
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passController;

  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  String? _nameError;
  String? _emailError;
  String? _passError;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passController = TextEditingController();
    _nameController = TextEditingController();
  }

  _navigateToLoginPage(){
    Navigator.pop(context);
  }

  _registerUser() async {
    String name = _nameController.text;
    String email = _emailController.text;
    String pass = _passController.text;
    try{
      await UserController.signUp(name, email, pass);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage(),));
    } on CustomError catch(error){
      if(error.errorType == "email"){
        setState(() => _emailError = error.description);
      }else if(error.errorType == "password"){
        setState(() => _passError = error.description);
      }else if(error.errorType == "snackbar"){
        ScaffoldMessenger.of(context).showSnackBar(getCustomSnackBar(context ,error.description));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = ScreenSize.getWidth(context);
    double height = ScreenSize.getHeight(context);

    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            width: width,
            height: height,
            color: AppTheme.pageBackground,
            child: Column(
              children: [
                _header(),
                _registerForm(),
                _registerSubmit(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _header(){
    double width = ScreenSize.getWidth(context);
    double height = ScreenSize.getHeight(context);
    return Container(
      width: width,
      height: height / 10,
      color: AppTheme.pageBackground,
      padding: const EdgeInsets.only(left: 15,),
      alignment: Alignment.centerLeft,
      child: const Text(
        Constants.appName,
        style: TextStyle(
          color: AppTheme.highlightedTheme,
          fontFamily: 'Poppins',
          fontSize: 26,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _registerForm(){
    double width = ScreenSize.getWidth(context);
    double height = ScreenSize.getHeight(context);
    return Form(
      key: _formKey,
      child: Container(
        width: width,
        height: height / 2.5,
        padding: const EdgeInsets.only(left: 30, right: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextInput(
              text: 'Name',
              controller: _nameController,
              error: _nameError,
              removeError: () => setState(() => _nameError = null),
              focusNode: _nameFocus,
            ),
            20.h,
            TextInput(
              text: 'Email',
              controller: _emailController,
              error: _emailError,
              removeError: () => setState(() => _emailError = null),
              focusNode: _emailFocus,
            ),
            20.h,
            TextInput(
              text: 'Password',
              controller: _passController,
              error: _passError,
              removeError: () => setState(() => _passError = null),
              focusNode: _passwordFocus,
            )
          ],
        ),
      ),
    );
  }

  Widget _registerSubmit() {
    double width = ScreenSize.getWidth(context);
    double height = ScreenSize.getHeight(context);
    return Container(
      width: width,
      height: height / 2,
      padding: const EdgeInsets.only(bottom: 50),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SubmitButton(
            text: 'Register',
            formKey: _formKey,
            onClick: () async {
              await _registerUser();
            },
          ),
          10.h,
          RichText(
            text: TextSpan(
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
              ),
              children: <TextSpan>[
                const TextSpan(
                  text: "Already have an account? ",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                TextSpan(
                    text: "Login",
                    style: const TextStyle(
                      color: AppTheme.highlightedTheme,
                      fontWeight: FontWeight.bold,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = _navigateToLoginPage
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

}