import 'package:flutter/material.dart';
import 'package:news_app/utils/constants.dart';

SnackBar getCustomSnackBar(BuildContext context,String text) {
  return SnackBar(
    content: Text(text, style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500, fontSize: 18),),
    action: SnackBarAction(
      label: 'Close',
      textColor: Colors.white,
      onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
    ),
    elevation: 5,
    backgroundColor: Colors.blue,
    duration: const Duration(seconds : 3600),
    behavior: SnackBarBehavior.fixed,
  );
}
