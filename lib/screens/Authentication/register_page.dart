import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:news_app/controllers/user_controller.dart';
import 'package:news_app/models/custom_error.dart';
import 'package:news_app/models/form_data.dart';
import 'package:news_app/screens/Authentication/login_page.dart';
import 'package:news_app/screens/Home_Page/home_page.dart';
import 'package:news_app/utils/constants.dart';
import 'package:news_app/widgets/snackbar.dart';
import 'package:news_app/widgets/submit_button.dart';
import 'package:news_app/widgets/text_input.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum RegisterState { initial, loading }

final registerStateProvider = StateProvider<RegisterState>((ref) {
  return RegisterState.initial;
},);

class RegisterPage extends ConsumerStatefulWidget{
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passController;

  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passController = TextEditingController();
    _nameController = TextEditingController();
  }

  _navigateToLoginPage(){
    ref.read(emailFieldNotifierProvider.notifier).updateError(null);
    ref.read(passwordFieldNotifierProvider.notifier).updateError(null);
    ref.read(nameFieldNotifierProvider.notifier).updateError(null);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage(),));
  }

  _registerUser() async {
    String name = _nameController.text;
    String email = _emailController.text;
    String pass = _passController.text;
    try{
      ref.read(registerStateProvider.notifier).state = RegisterState.loading;
      final userController = ref.read(userControllerProvider);
      await userController.signUp(name, email, pass);
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
      ref.read(registerStateProvider.notifier).state = RegisterState.initial;
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
                final registerState = ref.watch(registerStateProvider);
                if(registerState == RegisterState.initial){
                  return Column(
                    children: [_header(), _registerForm(), _registerSubmit()],
                  );
                }else{
                  return Column(
                    children: [_header(), _registerInProgress()],
                  );
                }
              },
            )
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
    
    final nameField = ref.watch(nameFieldNotifierProvider);
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
              text: 'Name',
              controller: _nameController,
              error: nameField.error,
              removeError: () => ref.read(nameFieldNotifierProvider.notifier).updateError(null),
              focusNode: _nameFocus,
            ),
            20.h,
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
              final nameError = ref.read(nameFieldNotifierProvider.notifier).validate(_nameController.text);
              final emailError = ref.read(emailFieldNotifierProvider.notifier).validate(_emailController.text);
              final passwordError = ref.read(passwordFieldNotifierProvider.notifier).validate(_passController.text);
              if(!nameError || !emailError || !passwordError){_registerUser();}
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