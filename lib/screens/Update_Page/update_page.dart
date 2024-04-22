import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:news_app/controllers/user_controller.dart';
import 'package:news_app/models/custom_error.dart';
import 'package:news_app/models/user.dart';
import 'package:news_app/screens/Authentication/login_page.dart';
import 'package:news_app/utils/constants.dart';
import 'package:news_app/utils/utils.dart';
import 'package:news_app/widgets/snackbar.dart';
import 'package:news_app/widgets/text_input.dart';

class UpdatePage extends StatefulWidget{
  const UpdatePage({super.key, required this.user});

  final AppUser user;

  @override
  State<UpdatePage> createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {

  XFile? file;
  bool _updateImageIsComplete = true;

  final _formKey = GlobalKey<FormState>();

  String? _nameError;
  String? _emailError;
  String? _passwordError;

  late final TextEditingController _emailController;
  late final TextEditingController _nameController;
  late final TextEditingController _passController;

  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.user.email);
    _nameController = TextEditingController(text: widget.user.name);
    _passController = TextEditingController(text: widget.user.password);
  }

  _updateDetails() async {
    try{
      String newName = _nameController.text == widget.user.name ? "" : _nameController.text;
      String newEmail = _emailController.text == widget.user.email ? "" : _emailController.text;
      String newPassword = _passController.text == widget.user.password ? "" : _passController.text;
      if(newName != "" || newEmail != "" || newPassword != ""){
        await UserController.updateDetails(widget.user, newName, newEmail, newPassword);
      }
      Navigator.pop(context, "Success");
    } on CustomError catch(error){
      if(error.errorType == "email"){
        setState(() => _emailError = error.description);
      }else if(error.errorType == "password"){
        setState(() => _passwordError = error.description);
      }else if(error.errorType == "snackbar"){
        ScaffoldMessenger.of(context).showSnackBar(getCustomSnackBar(context ,error.description));
      }
    }
  }

  _updateImage() async {
    try{
      ImagePicker imagePicker = ImagePicker();
      file = await imagePicker.pickImage(source: ImageSource.gallery);
      if(file == null)return;
      setState(() => _updateImageIsComplete = false);
      final response = await UserController.updateImage(widget.user, file!);
      setState((){
        widget.user.imageUrl = response;
        _updateImageIsComplete = true;
      });
    }on CustomError catch(error){
      if(error.errorType == "email"){
        setState(() => _emailError = error.description);
      }else if(error.errorType == "password"){
        setState(() => _passwordError = error.description);
      }else if(error.errorType == "snackbar"){
        ScaffoldMessenger.of(context).showSnackBar(getCustomSnackBar(context ,error.description));
      }
    }
  }

  _deleteAccount() async {
    try{
      await UserController.deleteAccount(widget.user);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage(),));
    }on CustomError catch(error){
      if(error.errorType == "email"){
        setState(() => _emailError = error.description);
      }else if(error.errorType == "password"){
        setState(() => _passwordError = error.description);
      }else if(error.errorType == "snackbar"){
        ScaffoldMessenger.of(context).showSnackBar(getCustomSnackBar(context ,error.description));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          appBar: _appBar(),
          body: _updateForm()
        )
    );
  }

  _appBar(){
    return AppBar(
      title: Container(
        child: const Text(Constants.appName, style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 20),),
      ),
      backgroundColor: AppTheme.highlightedTheme,
      foregroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pop(context, "Back");
        },
      ),
    );
  }

  Widget _updateForm(){
    double width = ScreenSize.getWidth(context);
    double height = ScreenSize.getHeight(context);
    return SingleChildScrollView(
      child: Container(
        color: AppTheme.pageBackground,
        width: width,
        height: height/1.1,
        child: Column(
        children: [
          10.h,
          GestureDetector(
            onTap: () {
              _updateImage();
            },
            child: Stack(
              children: [
                _userProfilePicture(),
                Center(
                  child: Container(
                    width: width/2,
                    height: height/4,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(120)
                    ),
                    alignment: Alignment.bottomRight,
                    padding: const EdgeInsets.only(bottom: 15,right: 5),
                    child: const CircleAvatar(
                      maxRadius: 20,
                      backgroundColor: Colors.black,
                      child: Icon(Icons.edit, color: Colors.white,),
                    ),
                  ),
                ),
              ],
            )
          ),
          20.h,
          Container(
            child: Text("User joined on ${Utils.getDate(widget.user.createdOn)}", style: const TextStyle(fontFamily: "Poppins", fontSize: 18, fontWeight: FontWeight.w500),),
          ),
          15.h,
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            child: Form(
              key: _formKey,
              child : Column(
                children: [
                  TextInput(
                      text: "Name",
                      controller: _nameController,
                      removeError: (){},
                      error: _nameError,
                      focusNode: _nameFocus,
                  ),
                  20.h,
                  TextInput(
                    text: "Email",
                    controller: _emailController,
                    removeError: (){},
                    error: _emailError,
                    focusNode: _emailFocus,
                  ),
                  20.h,
                  TextInput(
                    text: "Password",
                    controller: _passController,
                    removeError: (){},
                    error: _passwordError,
                    focusNode: _passwordFocus,
                  )
                ],
              )
            ),
          ),
          40.h,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: (){
                  _deleteAccount();
                },
                style: ButtonStyle(
                    backgroundColor: const MaterialStatePropertyAll(Colors.red),
                    foregroundColor: const MaterialStatePropertyAll(Colors.white),
                    elevation: const MaterialStatePropertyAll(10),
                    fixedSize: MaterialStatePropertyAll(Size(width/2.5, height/18))
                ),
                child: Text("Delete Account", style: AppTheme.getStyle(color: Colors.white, fs: 16, fw: FontWeight.w500),),
              ),
              TextButton(
                  onPressed: (){
                    if(_formKey.currentState!.validate()){
                      _updateDetails();
                    }
                  },
                  style: ButtonStyle(
                      backgroundColor: const MaterialStatePropertyAll(AppTheme.highlightedTheme),
                      foregroundColor: const MaterialStatePropertyAll(Colors.white),
                      elevation: const MaterialStatePropertyAll(10),
                      fixedSize: MaterialStatePropertyAll(Size(width/2.5, height/18))
                  ),
                  child: Text("Update", style: AppTheme.getStyle(color: Colors.white, fs: 16, fw: FontWeight.w500),),
              ),
            ],
          )
        ],
        ),
      ),
    );
  }

  _userProfilePicture(){
    double width = ScreenSize.getWidth(context);
    double height = ScreenSize.getHeight(context);

    if(_updateImageIsComplete) {
      return Center(
        child: Container(
          width: width/2,
          height: height/4,
          decoration: BoxDecoration(
            // border: Border.all(color: Colors.black, width: 2),
            borderRadius: BorderRadius.circular(100),
            image: DecorationImage(
              image: NetworkImage(widget.user.imageUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
    }else{
      return Container(
        width: width,
        height: height/4.5,
        child: const Center(
          child: CircularProgressIndicator(
            color: AppTheme.highlightedTheme,
          ),
        ),
      );
    }
  }
}