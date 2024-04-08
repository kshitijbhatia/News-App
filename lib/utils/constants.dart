import 'package:flutter/cupertino.dart';

class Constants{
  Constants._();

  static const country = "IN";
  static const newsCategory = "business";
  static const apiKey = "fd32f8ae57794159b0719d981ba2988a";
  static const baseUrl = 'https://newsapi.org';
  static const getArticlesEndpoint = '/v2/top-headlines';
  static const String appName = "MyNews";
}

class AppTheme{
  static const Color pageBackground = Color(0xFFF5F9FD);
  static const Color highlightedTheme = Color(0xFF0C54BE);
}

class ScreenSize{
  static getWidth(BuildContext context){
    return MediaQuery.of(context).size.width;
  }

  static getHeight(BuildContext context){
    return MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top;
  }
}

extension SizedBoxedExtension on num{
  SizedBox get h => SizedBox(height: toDouble(),);
  SizedBox get w => SizedBox(width: toDouble(),);
}
