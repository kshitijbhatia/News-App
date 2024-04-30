import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:news_app/controllers/user_controller.dart';
import 'package:news_app/models/custom_error.dart';
import 'package:news_app/models/user.dart';
import 'package:news_app/network/authentication.dart';
import 'package:news_app/providers/register_provider.dart';
import 'package:news_app/screens/Home_Page/home_page.dart';
import 'package:news_app/utils/constants.dart';
import 'package:news_app/widgets/snackbar.dart';
import 'package:news_app/widgets/submit_button.dart';
import 'package:news_app/widgets/text_input.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatefulWidget{
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

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
            child: Consumer<RegisterProvider>(
              builder: (context, provider, child) => Column(
                children: [
                  _header(),
                  provider.getRegisterComplete
                      ? Column(
                    children: [
                      _registerForm(),
                      _registerSubmit(),
                    ],
                  ) : _registerInProgress()
                ],
              ),
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
    return Consumer<RegisterProvider>(
      builder : (context, provider, child) => Form(
        key: provider.registerFormKey,
        child: Container(
          width: width,
          height: height / 2.5,
          padding: const EdgeInsets.only(left: 30, right: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextInput(
                text: 'Name',
                controller: provider.nameController,
                error: provider.getNameError,
                removeError: () => provider.setNameError(null)
              ),
              20.h,
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
                removeError: () => provider.setPasswordError(null),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _registerSubmit() {
    double width = ScreenSize.getWidth(context);
    double height = ScreenSize.getHeight(context);
    final registerProvider = Provider.of<RegisterProvider>(context);
    return Container(
      width: width,
      height: height / 2,
      padding: const EdgeInsets.only(bottom: 50),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SubmitButton(
            text: 'Register',
            formKey: registerProvider.registerFormKey,
            onClick: () => registerProvider.registerUser(context)
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
                      ..onTap = () => Navigator.pop(context)
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _registerInProgress(){
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