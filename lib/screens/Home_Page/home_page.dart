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
  final ScrollController _scrollController = ScrollController();
  StreamController<List<Article>> _dataStreamController = StreamController<List<Article>>();

  Stream<List<Article>> get dataStream => _dataStreamController.stream;

  final List<Article> _articles = [];

  bool _isFetchingData = false;
  bool _stopFetchingData = false;



  @override
  void initState() {
    super.initState();
    _getArticles();
    _scrollController.addListener(() {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      if (maxScroll == currentScroll && !_stopFetchingData) {
        _getArticles();
      }
    });
  }


  Future<void> _getArticles() async {
    if (_isFetchingData) {
      return;
    }
    try {
      setState(() {
        _isFetchingData = true;
      });

      final response = await ArticleController.getInstance.getArticles();

      if(response.isEmpty){
        setState(() {
          _stopFetchingData = true;
        });
        return;
      }

      _articles.addAll(response);
      _dataStreamController.add(_articles);
      _currentPage++;

    } on CustomError catch (error) {
      log('Home Page : ${error.toString()}');
      _dataStreamController.addError(error);
    } finally {
      setState(() {
        _isFetchingData = false;
      });
    }
  }

  Future<void> _refreshPage() async {
    setState(() {
      _currentPage = 0;
      _stopFetchingData = false;
      _articles.clear();
    });

    _dataStreamController.close();
    _dataStreamController = StreamController<List<Article>>();

    await _getArticles();
    return Future.value();
  }

  @override
  void dispose() {
    super.dispose();
    _dataStreamController.close();
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
            body: StreamBuilder<List<Article>>(
              stream: dataStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingScreen();
                } else if (snapshot.hasError) {
                  return ErrorPage(refreshPage: _refreshPage,);
                } else {
                  return Container(
                      child: Column(
                        children: [
                          Container(
                            width: width,
                            child: Text("Top Headlines"),
                          ),
                          _articleList(),
                        ],
                      )
                  );
                }
              },
            ),
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
      child: RefreshIndicator(
        onRefresh: _refreshPage,
        child: ListView.builder(
          controller: _scrollController,
          itemCount: _articles.length + 1,
          itemBuilder: (context, index) {
            if (index < _articles.length) {
              Article currentArticle = _articles[index];
              return ArticleCard(
                article: currentArticle,
              );
            } else if (!_stopFetchingData && index == _articles.length) {
              return Container(
                width: width,
                height: height / 12,
                child: const Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.highlightedTheme,
                  ),
                ),
              );
            } else {
              return Container();
            }
          },
        ),
      ),
    );
  }
}
