import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:news_app/controllers/user_controller.dart';
import 'package:news_app/models/custom_error.dart';
import 'package:news_app/models/form_data.dart';
import 'package:news_app/screens/Authentication/register_page.dart';
import 'package:news_app/screens/Home_Page/home_page.dart';
import 'package:news_app/utils/constants.dart';
import 'package:news_app/widgets/snackbar.dart';
import 'package:news_app/widgets/submit_button.dart';
import 'package:news_app/widgets/text_input.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum LoginState { initial, loading }

final loginStateProvider = StateProvider<LoginState>((ref) {
  return LoginState.initial;
},);

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {

  late final TextEditingController _emailController;
  late final TextEditingController _passController;

  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passController = TextEditingController();
  }

  _navigateToRegisterPage(){
    ref.read(emailFieldNotifierProvider.notifier).updateError(null);
    ref.read(passwordFieldNotifierProvider.notifier).updateError(null);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const RegisterPage(),),);
  }

  _loginUser() async {
    String email = _emailController.text;
    String password = _passController.text;
    try{
      ref.read(loginStateProvider.notifier).state = LoginState.loading;
      final userController = ref.read(userControllerProvider);
      await userController.signIn(email, password);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage(),));
    } on CustomError catch(error){
      if(error.errorType == "email"){
        ref.read(emailFieldNotifierProvider.notifier).updateError(error.description);
      }else if(error.errorType == "password"){
        ref.read(passwordFieldNotifierProvider.notifier).updateError(error.description);
      }else if(error.errorType == "snackbar"){
        ScaffoldMessenger.of(context).showSnackBar(getCustomSnackBar(context ,error.description));
      }
    } finally{
      ref.read(loginStateProvider.notifier).state = LoginState.initial;
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
            child: Consumer(
              builder: (context, ref, child) {
                final loginState = ref.watch(loginStateProvider);
                if(loginState == LoginState.initial){
                  return Column(
                    children: [_header(), _loginForm(), _loginSubmit()],
                  );
                }else{
                  return Column(
                    children: [_header(), _loginInProgress()],
                  );
                }
              },
            )
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
    final emailField = ref.watch(emailFieldNotifierProvider);
    final passwordField = ref.watch(passwordFieldNotifierProvider);
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
              error: emailField.error,
              removeError: () => ref.read(emailFieldNotifierProvider.notifier).updateError(null),
              focusNode: _emailFocus,
            ),
            20.h,
            TextInput(
              text: 'Password',
              controller: _passController,
              error: passwordField.error,
              removeError: () => ref.read(passwordFieldNotifierProvider.notifier).updateError(null),
              focusNode: _passwordFocus,
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
            onClick: () async {
              final emailError = ref.read(emailFieldNotifierProvider.notifier).validate(_emailController.text);
              final passwordError = ref.read(passwordFieldNotifierProvider.notifier).validate(_passController.text);
              if(!emailError || !passwordError){_loginUser();}
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
