import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:news_app/controllers/article_controllers.dart';
import 'package:news_app/models/article.dart';
import 'package:news_app/models/custom_error.dart';
import 'package:news_app/screens/Error_Page/error_page.dart';
import 'package:news_app/utils/constants.dart';
import 'package:news_app/screens/Home_Page/article_card.dart';
import 'package:news_app/screens/Loading_Page/loading_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Article> _articles = [];

  Future<List<Article>> _getArticles() async {
    try {
      final response = await ArticleController.getInstance.getArticles();
      return response;
    } on CustomError catch (error) {
      log('Home Page : ${error.toString()}');
      rethrow;
    }
  }

  Future<void> _refreshPage() async {
    setState(() {
      _articles.clear();
    });
    await _getArticles();
    return Future.value();
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
            body: FutureBuilder<List<Article>>(
              future: _getArticles(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingScreen();
                } else if (snapshot.hasError) {
                  return ErrorPage(refreshPage: _refreshPage,);
                } else {
                  _articles = snapshot.data!;
                  return _articleList();
                }
              },
            )
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
                    onPressed:(){},
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
        child: ListView.builder(
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
      ),
    );
  }
}
