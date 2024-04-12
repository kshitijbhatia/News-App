import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:news_app/controllers/article_controllers.dart';
import 'package:news_app/models/article.dart';
import 'package:news_app/models/custom_error.dart';
import 'package:news_app/screens/Authentication/login_page.dart';
import 'package:news_app/screens/Error_Page/error_page.dart';
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
  late Map<String, dynamic> user;
  List<Article> _articles = [];

  Future<void> _getArticles() async {
    try {
      final response = await ArticleController.getInstance.getArticles();
      setState(() {
        _isComplete = true;
        _articles = response;
      });
      final prefs = await SharedPreferences.getInstance();
      user = jsonDecode(prefs.getString("user")!);
    } on CustomError catch (error) {
      log(error.toString());
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ErrorPage(refreshPage: _refreshPage),));
    }
  }

  Future<void> _refreshPage() async {
    setState(() {
      _isComplete = false;
      _articles.clear();
    });
    await _getArticles();
    return Future.value();
  }

  @override
  void initState() {
    super.initState();
    _getArticles();
  }

  @override
  Widget build(BuildContext context) {
    double width = ScreenSize.getWidth(context);
    double height = ScreenSize.getHeight(context);

    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: SafeArea(
        child: Scaffold(
          appBar: _appBar(),
            body:
            _isComplete
                ? _articleList()
                : const LoadingScreen()
          ),
        ),
    );
  }



  _appBar(){
    return AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            child: Row(
              children: [
                IconButton(
                    onPressed:(){setState(() => _showProfile = !_showProfile);},
                    icon: const Icon(Icons.person)
                ),
                10.w,
                const Text(Constants.appName, style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 20),),
              ],
            ),
          ),
          Container(
            child: const Row(
              children: [
                Icon(Icons.navigation),
                Text(Constants.country, style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 18),)
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
        child: Stack(
          children: [
            ListView.builder(
              itemCount: _articles.length + 1,
              itemBuilder: (context, index) {
                if(index == 0){
                  return Container(
                    width: width,
                    height: height/16,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 15),
                    child: const Text("Top Headlines", style: TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.w600, fontSize: 18),),
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
      width: width/2.5,
      height: height/6,
      margin: const EdgeInsets.only(left: 5, top: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.grey,
            blurRadius: 7,
            offset: Offset(0, 3)
          )
        ],
      ),
      child: Column(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              width: width/2.5,
              alignment: Alignment.center,
              child: Text("Hi ${user["name"]}", style: const TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.w500, fontSize: 16),),
            ),
          ),
          Expanded(
            flex: 1,
            child: GestureDetector(
              onTap: (){
                log("Update Profile Button Pressed");
              },
              child: Container(
                width: width/2.5,
                alignment: Alignment.center,
                child: const Text("Update Profile", style: TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.w500, fontSize: 16),),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: GestureDetector(
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                prefs.setString("user", "");
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage(),));
              },
              child: Container(
                width: width/2.5,
                alignment: Alignment.center,
                child: const Text("Log Out", style: TextStyle(color : Colors.red,fontFamily: "Poppins", fontWeight: FontWeight.w500, fontSize: 16),),
              ),
            ),
          )
        ],
      ),
    );
  }
}