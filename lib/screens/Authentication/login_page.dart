import 'dart:developer';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:news_app/screens/Authentication/register_page.dart';
import 'package:news_app/utils/constants.dart';
import 'package:news_app/widgets/submit_button.dart';
import 'package:news_app/widgets/text_input.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  late final TextEditingController _emailController;
  late final TextEditingController _passController;
  String? _emailError;
  String? _passError;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passController = TextEditingController();
  }

  _navigateToRegisterPage(){
    setState(() {
      _formKey.currentState?.reset();
      _emailController.clear();
      _passController.clear();
    });
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RegisterPage(),
      ),
    );
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
            color: AppTheme.authPageBackground,
            child: Column(
              children: [
                _header(),
                _loginForm(),
                _loginSubmit(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _header() {
    double width = ScreenSize.getWidth(context);
    double height = ScreenSize.getHeight(context);
    return Container(
      width: width,
      height: height / 10,
      color: AppTheme.authPageBackground,
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

  Widget _loginForm() {
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
              text: 'Email',
              controller: _emailController,
              error: _emailError,
              removeError: () => setState(() => _emailError = null),
            ),
            20.h,
            TextInput(
              text: 'Password',
              controller: _passController,
              error: _passError,
              removeError: () => setState(() => _passError = null),
            )
          ],
        ),
      ),
    );
  }

  Widget _loginSubmit() {
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
            text: 'Login',
            formKey: _formKey,
            onClick: (){
              log(_emailController.text);
              log(_passController.text);
            },
          ),
          20.h,
          RichText(
            text: TextSpan(
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
              ),
              children: <TextSpan>[
                const TextSpan(
                  text: "New here? ",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                TextSpan(
                  text: "Signup",
                  style: const TextStyle(
                    color: AppTheme.highlightedTheme,
                    fontWeight: FontWeight.bold,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = _navigateToRegisterPage
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
