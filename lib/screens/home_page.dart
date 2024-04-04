import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:news_app/controllers/article_controllers.dart';
import 'package:news_app/models/article.dart';
import 'package:news_app/models/custom_error.dart';
import 'package:news_app/screens/error_page.dart';
import 'package:news_app/utils/constants.dart';
import 'package:news_app/widgets/article_card.dart';
import 'package:news_app/screens/loading_page.dart';

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

  int _currentPage = 0;
  final int _pageSize = 4;

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

      final response = await ArticleController.getInstance.getArticles(_pageSize, _currentPage);

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
          appBar: AppBar(
            title: const Text("Space News"),
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
          ),
            body: StreamBuilder<List<Article>>(
              stream: dataStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingScreen();
                } else if (snapshot.hasError) {
                  CustomError error = snapshot.error as CustomError;
                  return ErrorPage(refreshPage: _refreshPage,);
                } else {
                  return _articleList();
                }
              },
            ),
          ),
        ),
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
                    color: AppTheme.primaryColor,
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
