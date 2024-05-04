import 'dart:convert';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:news_app/controllers/article_controllers.dart';
import 'package:news_app/main.dart';
import 'package:news_app/models/custom_error.dart';
import 'package:news_app/models/user.dart';
import 'package:news_app/network/authentication.dart';
import 'package:news_app/network/remote_config_service.dart';
import 'package:news_app/screens/Error_Page/error_page.dart';
import 'package:news_app/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/article.dart';

class HomeProvider extends ChangeNotifier{

  bool _apiCallComplete = false;
  bool get getApiCallComplete => _apiCallComplete;
  setApiCallComplete(bool isComplete){
    _apiCallComplete = isComplete;
    notifyListeners();
  }

  bool _showProfile = false;
  bool get getShowProfile => _showProfile;
  setShowProfile(){
    _showProfile = !_showProfile;
    notifyListeners();
  }
  setShowProfileFalse(){
    _showProfile = false;
    notifyListeners();
  }

  late AppUser _user;
  AppUser get getUser => _user;
  setUser() async {
    final prefs = await SharedPreferences.getInstance();
    _user = AppUser.fromJson(jsonDecode(prefs.getString(Constants.userKey)!));
    notifyListeners();
  }
  removeUser() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(Constants.userKey, "");
    _showProfile = false;
    await Authentication.getInstance.signOut(_user);
  }

  String _country = "";
  String get getCountry => _country;
  setCountry() async {
    await FirebaseRemoteConfigService.getInstance.fetchAndActivate();
    _country = FirebaseRemoteConfigService.getInstance.getCountry;
    notifyListeners();
  }

  List<Article> _articles = [];
  List<Article> get getArticles => _articles;
  setArticles(List<Article> responseArticles) async {
    _articles = responseArticles;
    notifyListeners();
  }

  Future<void> fetchArticles(BuildContext context) async {
    try{
      await setCountry();
      await setUser();
      await FirebaseCrashlytics.instance.setUserIdentifier(_user.uid);
      final response = await ArticleController.getInstance.getArticles(_country);
      await setArticles(response);
      setApiCallComplete(true);
    }on CustomError catch(error){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ErrorPage(),));
    }
  }

  Future<void> refreshPage(BuildContext context) async {
    setApiCallComplete(false);
    _articles.clear();
    notifyListeners();
    fetchArticles(context);
  }
}