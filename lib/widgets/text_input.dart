import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:news_app/utils/constants.dart';

class TextInput extends StatefulWidget {
  const TextInput({
    super.key,
    required this.text,
    required this.controller,
    required this.removeError,
    required this.error
  });

  final String text;
  final TextEditingController controller;
  final String? error;
  final Function removeError;

  @override
  State<TextInput> createState() => _TextInputState();
}

class _TextInputState extends State<TextInput> {

  bool _showPassword = false;

  void _changePasswordVisibility() => setState(() => _showPassword = !_showPassword);

  @override
  Widget build(BuildContext context) {
    double width = ScreenSize.getWidth(context);
    double height = ScreenSize.getHeight(context);
    return TextFormField(
      autovalidateMode: widget.controller.text.isEmpty ? AutovalidateMode.disabled : AutovalidateMode.onUserInteraction,
      controller: widget.controller,
      validator: (value) {
        if(value == null || value.trim().isEmpty){
          return 'Please enter some text';
        }
        return null;
      },
      onTapOutside: (event) {
        FocusScopeNode focusNode = FocusScope.of(context);
        if (!focusNode.hasPrimaryFocus) {
          focusNode.unfocus();
        }
      },
      obscureText: widget.text == "Password" && !_showPassword ? true : false,
      onChanged: (value) => widget.removeError(),
      decoration: InputDecoration(
        errorText: widget.error,
        labelText: widget.text,
        filled: true,
        fillColor: Colors.white,
        labelStyle: const TextStyle(
          color: Colors.black,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w500,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.only(left: 15),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        errorStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.w500,
        ),
        suffixIcon: widget.text == "Password"
            ? IconButton(
              onPressed: _changePasswordVisibility,
              icon: _showPassword
                  ? const Icon(Icons.visibility)
                  : const Icon(Icons.visibility_off),)
            : (widget.controller.text.isNotEmpty
                ? IconButton(
                  onPressed: (){
                    widget.controller.text = "";
                    widget.removeError();
                    },
                  icon: const Icon(Icons.close))
                : 0.h
        )
      )
    );
  }
}