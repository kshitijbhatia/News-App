import 'dart:developer';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:news_app/controllers/user_controller.dart';
import 'package:news_app/models/custom_error.dart';
import 'package:news_app/providers/login_provider.dart';
import 'package:news_app/providers/register_provider.dart';
import 'package:news_app/screens/Authentication/register_page.dart';
import 'package:news_app/screens/Home_Page/home_page.dart';
import 'package:news_app/utils/constants.dart';
import 'package:news_app/widgets/snackbar.dart';
import 'package:news_app/widgets/submit_button.dart';
import 'package:news_app/widgets/text_input.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

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
            child: Consumer<LoginProvider>(
              builder : (context, provider, child) => Column(
                  children: [
                    _header(),
                    provider.getLoginComplete
                        ? Column(
                      children: [
                        _loginForm(),
                        _loginSubmit(),
                      ],
                    ) : _loginInProgress()
                  ],
                ),
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

  Widget _loginForm() {
    double width = ScreenSize.getWidth(context);
    double height = ScreenSize.getHeight(context);
    return Consumer<LoginProvider>(
      builder :(context, provider, child) =>  Form(
        key: provider.loginFormKey,
        child: Container(
          width: width,
          height: height / 2.5,
          padding: const EdgeInsets.only(left: 30, right: 30),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextInput(
                  text: 'Email',
                  controller: provider.emailController,
                  error: provider.getEmailError,
                  removeError: () => provider.setEmailError(null)
                ),
                20.h,
                TextInput(
                  text: 'Password',
                  controller: provider.passwordController,
                  error: provider.getPasswordError,
                  removeError: () => provider.setPasswordError(null)
                )
              ],
            ),
          ),
      ),
    );
  }

  Widget _loginSubmit() {
    double width = ScreenSize.getWidth(context);
    double height = ScreenSize.getHeight(context);
    final loginProvider = Provider.of<LoginProvider>(context);
     return Container(
      width: width,
      height: height / 2,
      padding: const EdgeInsets.only(bottom: 50),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SubmitButton(
                text: 'Login',
                formKey: loginProvider.loginFormKey,
                onClick: () => loginProvider.loginUser(context),
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
                      ..onTap = () => loginProvider.navigateToRegisterPage(context)
                  )
                ],
              ),
            ),
          ],
        ),
    );
  }

  Widget _loginInProgress(){
    double width = ScreenSize.getWidth(context);
    double height = ScreenSize.getHeight(context);
    return Container(
      color: AppTheme.pageBackground,
      width: width,
      height: height/1.2,
      alignment: Alignment.center,
      child: Container(
        width: width/8,
        height: height/16,
        child: const CircularProgressIndicator(color: AppTheme.highlightedTheme,),
      ),
    );
  }
}
