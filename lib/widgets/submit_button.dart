import 'package:flutter/material.dart';
import 'package:news_app/utils/constants.dart';

class SubmitButton extends StatelessWidget {
  const SubmitButton({super.key, required this.text, required this.formKey, required this.onClick});

  final String text;
  final GlobalKey<FormState> formKey;
  final Function onClick;

  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: () {
          if(formKey.currentState!.validate()){
            onClick();
          }
        },
        style: ButtonStyle(
          padding: const MaterialStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 100, vertical: 12),
          ),
          shape: MaterialStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          backgroundColor: const MaterialStatePropertyAll(AppTheme.highlightedTheme),
          foregroundColor: const MaterialStatePropertyAll(Colors.white),
          textStyle: const MaterialStatePropertyAll(
            TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                fontSize: 20),
          ),
        ),
        child: Text(text));
  }
}
