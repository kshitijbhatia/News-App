import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:math' as math;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:news_app/controllers/article_controllers.dart';
import 'package:news_app/models/article.dart';
import 'package:news_app/models/custom_error.dart';
import 'package:news_app/models/user.dart';
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

  Future<void> _getArticles() async {
    try {
      final response = await ArticleController.getInstance.getArticles();
      setState(() {
        _isComplete = true;
        _articles = response;
      });
      final prefs = await SharedPreferences.getInstance();
      user = AppUser.fromJson(jsonDecode(prefs.getString("user")!));
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
                IconButton(
                    onPressed: (){setState(() {_showProfile = !_showProfile;});},
                    icon: _showProfile ? const Icon(Icons.close) : const Icon(Icons.menu),
                ),
                // _isComplete ? GestureDetector(
                //   onTap: (){setState(() => _showProfile = !_showProfile);},
                //   child: CachedNetworkImage(
                //     imageUrl: user.imageUrl,
                //     errorWidget: (context, url, error) {
                //       return const CircleAvatar(
                //           radius: 16,
                //           backgroundImage: AssetImage('assets/user.webp')
                //         );
                //     },
                //     imageBuilder: (context, imageProvider) {
                //       return CircleAvatar(
                //         radius: 16,
                //         backgroundImage: imageProvider,
                //       );
                //     },
                //     placeholder: (context, url) {
                //       return const CircleAvatar(
                //         radius: 10,
                //         backgroundColor: AppTheme.highlightedTheme,
                //         child: CircularProgressIndicator(
                //           color: Colors.white,
                //           strokeWidth: 3,
                //         ),
                //       );
                //     },
                //   )
                // ) : 0.h,
                10.w,
                const Text(Constants.appName, style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 20),),
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
                const Text(Constants.country, style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 16),)
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
            ListView.builder(
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
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey,

                )
              )
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  width: width/1.8,
                  height: height/12,
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.grey,
                        backgroundImage: NetworkImage(user.imageUrl),
                      ),
                      20.w,
                      Text(
                        user.name.toUpperCase(),
                        style: AppTheme.getStyle(color: Colors.black, fs: 18, fw: FontWeight.w500),
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
                      _refreshPage();
                    });
                  },
                  child: Container(
                    width: width/1.8,
                    height: height/12,
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
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
              prefs.setString("user", "");
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage(),));
            },
            child: Container(
              width: width/1.8,
              height: height/12,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Icon(Icons.logout, size: 26,color: Colors.red,),
                  10.w,
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