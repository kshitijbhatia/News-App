import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:news_app/controllers/user_controller.dart';
import 'package:news_app/models/user.dart';
import 'package:news_app/screens/Authentication/login_page.dart';
import 'package:news_app/screens/Home_Page/home_page.dart';
import 'package:news_app/utils/constants.dart';
import 'package:news_app/utils/utils.dart';
import 'package:news_app/widgets/snackbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpdatePage extends StatefulWidget{
  const UpdatePage({super.key, required this.user});

  final AppUser user;

  @override
  State<UpdatePage> createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {

  XFile? file;

  final _formKey = GlobalKey<FormState>();

  bool _nameChanged = false;
  bool _emailChanged = false;
  bool _passwordChanged = false;

  late final TextEditingController _emailController;
  late final TextEditingController _nameController;
  late final TextEditingController _passController;


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
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage(),),);
    } on FirebaseAuthException catch(err){
      if(err.code == "requires-recent-login"){
        ScaffoldMessenger.of(context).showSnackBar(getCustomSnackBar(context, "Please Login Again to Update Details"));
      }else if(err.code == "invalid-email"){
        ScaffoldMessenger.of(context).showSnackBar(getCustomSnackBar(context, "Please Enter a valid Email"));
      }else if(err.code == "email-already-in-use"){
        ScaffoldMessenger.of(context).showSnackBar(getCustomSnackBar(context, "Email Already In Use"));
      }else if(err.code == "weak-password"){
        ScaffoldMessenger.of(context).showSnackBar(getCustomSnackBar(context, "Password is too weak"));
      }else if(err.code == "network-request-failed"){
        ScaffoldMessenger.of(context).showSnackBar(getCustomSnackBar(context, "No Internet Connection"));
      }else{
        ScaffoldMessenger.of(context).showSnackBar(getCustomSnackBar(context, "Unknown Error Occurred"));
      }
    }catch(err){
      log('UI : $err');
      ScaffoldMessenger.of(context).showSnackBar(getCustomSnackBar(context, "Error Occurred while Deleting Account"));
    }
  }

  _updateImage() async {
    try{
      ImagePicker imagePicker = ImagePicker();
      file = await imagePicker.pickImage(source: ImageSource.gallery);
      final response = await UserController.updateImage(widget.user, file);
      log(response);
      setState(() => widget.user.imageUrl = response);
    }catch(err){
      log('Update Image Error : $err');
      ScaffoldMessenger.of(context).showSnackBar(getCustomSnackBar(context, "Error occurred"));
    }
  }

  _deleteAccount() async {
    try{
      await UserController.deleteAccount(widget.user);
      Navigator.pop(context, MaterialPageRoute(builder: (context) => const LoginPage(),));
    }on FirebaseAuthException catch(err){
      if(err.code == "network-request-failed" || err.code == "too-many-requests"){
        ScaffoldMessenger.of(context).showSnackBar(getCustomSnackBar(context, "No Internet Connection"));
      }else if(err.code == "user-deleted"){
        ScaffoldMessenger.of(context).showSnackBar(getCustomSnackBar(context, "Account Already Deleted"));
      }else if(err.code == "requires-recent-login"){
        ScaffoldMessenger.of(context).showSnackBar(getCustomSnackBar(context, "Please Login Again to Delete Account"));
      }else{
        ScaffoldMessenger.of(context).showSnackBar(getCustomSnackBar(context, "Unknown Error Occurred"));
      }
    } catch(err){
      log('$err');
      ScaffoldMessenger.of(context).showSnackBar(getCustomSnackBar(context, "Error Occurred while Deleting Account"));
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
            child:
            widget.user.imageUrl == ""
                ? const Image(image: AssetImage('assets/user.webp'),)
                : Image(image: NetworkImage(widget.user.imageUrl))
          ),
          10.h,
          Container(
            child: Text("User joined on ${Utils.getDate(widget.user.createdOn)}", style: const TextStyle(fontFamily: "Poppins", fontSize: 18, fontWeight: FontWeight.w500),),
          ),
          10.h,
          Form(
            key: _formKey,
            child : Column(
              children: [
                _field(
                    prefixText: "Name",
                    controller: _nameController,
                    changeField: (){setState(() => _nameChanged = !_nameChanged);},
                    fieldChanged: _nameChanged
                ),
                _field(
                    prefixText: "Email",
                    controller: _emailController,
                    changeField: (){setState(() => _emailChanged = !_emailChanged);},
                    fieldChanged: _emailChanged
                ),
                _field(
                    prefixText: "Password",
                    controller: _passController,
                    changeField: () => setState(() => _passwordChanged = !_passwordChanged),
                    fieldChanged: _passwordChanged
                ),
              ],
            )
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

  Widget _field({
    required String prefixText,
    required TextEditingController controller,
    required Function changeField,
    required bool fieldChanged
  }) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Container(
      width: width,
      height: height / 12,
      margin: const EdgeInsets.only(left: 10, right: 10, top: 20),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                child: Text('$prefixText : ', style: AppTheme.getStyle(color: Colors.black, fs: 18, fw: FontWeight.w500),),
              ),
              Container(
                width: width / 2,
                child: fieldChanged
                  ? TextFormField(
                  validator: (value) {
                    if(value == null || value.trim().isEmpty){
                      return "Please enter some text";
                    }
                    return null;
                  },
                  autofocus: true,
                  obscureText: prefixText == "Password" ? true : false,
                  controller: controller,
                  style: AppTheme.getStyle(color: Colors.black, fs: 18, fw: FontWeight.w400),
                  decoration: const InputDecoration(
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                  ),
                  onFieldSubmitted: (value) {
                    changeField();
                  },
                )
                : Container(
                  child: Text(prefixText == "Password" ? "******" : controller.text, style: AppTheme.getStyle(color: Colors.black, fs: 18, fw: FontWeight.w400),),
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: ()=>{changeField()},
            icon: fieldChanged ? const Icon(Icons.close) : const Icon(Icons.edit),
          )
        ],
      ),
    );
  }

}