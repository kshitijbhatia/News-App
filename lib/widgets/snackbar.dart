import 'package:flutter/material.dart';
import 'package:news_app/utils/constants.dart';

SnackBar getCustomSnackBar(String text) {
  return SnackBar(
    duration: const Duration(seconds: 3),
    content: Text(text, style: const TextStyle(fontSize: 20),),
    elevation: 5,
    backgroundColor: Colors.blue,
  );
}
