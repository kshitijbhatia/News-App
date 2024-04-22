import 'package:flutter/cupertino.dart';

class Constants{
  Constants._();

  static const defaultImageUrl = "https://firebasestorage.googleapis.com/v0/b/news-app-e526e.appspot.com/o/images%2Fuser.webp?alt=media&token=e614f270-7ca6-4782-8037-c585c2bce7f8";
  static const userKey = "user";
  static const newsCategory = "business";
  static const apiKey = "fd32f8ae57794159b0719d981ba2988a";
  static const baseUrl = 'https://newsapi.org';
  static const getArticlesEndpoint = '/v2/top-headlines';
  static const String appName = "MyNews";
}

class AppTheme{
  static const Color pageBackground = Color(0xFFF5F9FD);
  static const Color highlightedTheme = Color(0xFF0C54BE);

  static TextStyle getStyle({required Color color,required double fs, required FontWeight fw}){
    return TextStyle(
      color: color,
      fontFamily: "Poppins",
      fontSize: fs,
      fontWeight: fw,
    );
  }
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
