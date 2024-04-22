import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:math' as math;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:news_app/controllers/article_controllers.dart';
import 'package:news_app/models/article.dart';
import 'package:news_app/models/custom_error.dart';
import 'package:news_app/models/user.dart';
import 'package:news_app/network/remote_config_service.dart';
import 'package:news_app/screens/Authentication/login_page.dart';
import 'package:news_app/screens/Error_Page/error_page.dart';
import 'package:news_app/screens/Update_Page/update_page.dart';
import 'package:news_app/utils/constants.dart';
import 'package:news_app/screens/Home_Page/article_card.dart';
import 'package:news_app/screens/Loading_Page/loading_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  bool _isComplete = false;

  bool _showProfile = false;

  late AppUser user;
  List<Article> _articles = [];

  String country = "";

  Future<void> _getArticles() async {
    try {
      // Get the country from Remote Config
      await FirebaseRemoteConfigService.getInstance.fetchAndActivate();
      country = FirebaseRemoteConfigService.getInstance.getCountry;

      // Get the user from Shared Preferences
      final prefs = await SharedPreferences.getInstance();
      user = AppUser.fromJson(jsonDecode(prefs.getString(Constants.userKey)!));

      // Set the user uid in crashlytics
      await FirebaseCrashlytics.instance.setUserIdentifier(user.uid);

      // Get Articles
      final response = await ArticleController.getInstance.getArticles(country);

      setState(() {
        _isComplete = true;
        _articles = response;
      });
    } on CustomError catch (error) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ErrorPage(refreshPage: _refreshPage),));
    }
  }

  Future<void> _refreshPage() async {
    setState(() {
      _isComplete = false;
      _articles.clear();
    });
    await _getArticles();
  }

  @override
  void initState() {
    super.initState();
    _getArticles();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Scaffold(
        appBar: _appBar(),
          body:
          _isComplete
              ? _articleList()
              : const LoadingScreen()
        ),
    );
  }



  _appBar(){
    double width = ScreenSize.getWidth(context);
    double height = ScreenSize.getHeight(context);
    return AppBar(
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            child: Row(
              children: [
                GestureDetector(
                  onTap : () => setState(() => _showProfile = !_showProfile),
                  child:
                  _isComplete ? CircleAvatar(
                    maxRadius: 16,
                    backgroundColor: Colors.white,
                    backgroundImage: NetworkImage(user.imageUrl),
                  ) : Container(
                    width: width/20,
                    height: height/38,
                    child: const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                ),
                10.w,
                Text(
                  Constants.appName,
                  style: AppTheme.getStyle(color: Colors.white, fs: 20, fw: FontWeight.w600),
                ),
              ],
            ),
          ),
          Container(
            child: Row(
              children: [
                Container(
                  margin : const EdgeInsets.only(bottom: 5),
                  child: Transform.rotate(
                      angle : math.pi/4,
                      child: const Icon(Icons.navigation),
                  ),
                ),
                Text(country, style: AppTheme.getStyle(color: Colors.white, fs: 16, fw: FontWeight.bold),)
              ],
            ),
          )
        ],
      ),
      backgroundColor: AppTheme.highlightedTheme,
      foregroundColor: Colors.white,
    );
  }

  Widget _articleList(){
    double width = ScreenSize.getWidth(context);
    double height = ScreenSize.getHeight(context);
    return Container(
      width: width,
      height: height,
      color: AppTheme.pageBackground,
      child: RefreshIndicator(
        onRefresh: _refreshPage,
        color: AppTheme.highlightedTheme,
        child: Stack(
          children: [
            GestureDetector(
              onTap: () => setState(() => _showProfile = false),
              child: ListView.builder(
                itemCount: _articles.length + 1,
                itemBuilder: (context, index) {
                  if(index == 0){
                    return Container(
                      width: width,
                      height: height/16,
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(left: 15),
                      child: Text("Top Headlines", style: AppTheme.getStyle(color: Colors.black, fs: 18, fw: FontWeight.w600),),
                    );
                  }
                  if (index < _articles.length) {
                    Article currentArticle = _articles[index - 1];
                    return ArticleCard(
                      article: currentArticle,
                    );
                  }else {
                    return Container();
                  }
                },
              ),
            ),
            _showProfile
                ? _profileSection()
                : 0.h,
        ],
        ),
      ),
    );
  }

  Widget _profileSection(){
    double width = ScreenSize.getWidth(context);
    double height = ScreenSize.getHeight(context);
    return Container(
      width: width/1.5,
      height: height,
      padding: const EdgeInsets.only(top: 25),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            blurRadius: 7,
            offset: Offset(0, 3)
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [


                Container(
                  width: width/1.8,
                  height: height/11,
                  padding: const EdgeInsets.only(bottom: 10),
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                            color: Colors.grey,
                          )
                      )
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.grey,
                        backgroundImage: NetworkImage(user.imageUrl)
                      ),
                      20.w,
                      Text(
                        user.name.toUpperCase(),
                        style: AppTheme.getStyle(color: Colors.black, fs: 25, fw: FontWeight.w500),
                      ),
                    ],
                  ),
                ),



                GestureDetector(
                  onTap: (){
                    setState(() => _showProfile = false);
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => UpdatePage(user: user,),)
                    ).then((value){
                      if(value != null){
                        _refreshPage();
                      }
                    });
                  },
                  child: Container(
                    width: width/1.8,
                    height: height/12,
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Icon(
                            Icons.settings,
                          size: 30,
                        ),
                        10.w,
                        Text(
                          "Settings",
                          style: AppTheme.getStyle(color: Colors.black, fs: 18, fw: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              prefs.setString(Constants.userKey, "");
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage(),));
            },
            child: Container(
              width: width/1.8,
              height: height/12,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Icon(Icons.logout, size: 22,color: Colors.red,),
                  5.w,
                  Text("Log Out", style: AppTheme.getStyle(color: Colors.red, fs: 16, fw: FontWeight.w600),),
                  10.w
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}