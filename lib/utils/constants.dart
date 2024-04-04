import 'package:flutter/cupertino.dart';

class Constants{
  Constants._();

  static const baseUrl = 'https://api.spaceflightnewsapi.net/';
  static const getArticlesEndpoint = 'v4/articles/';
  static const String appName = "MyNews";
}

class AppTheme{
  static const Color primaryColor = Color.fromRGBO(24, 56, 131, 1);
  static const Color authPageBackground = Color(0xFFF5F9FD);
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