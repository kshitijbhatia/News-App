import 'dart:developer';
import 'package:news_app/models/article.dart';
import 'package:news_app/models/custom_error.dart';
import 'package:news_app/network/api_service.dart';

class ArticleController{

  ArticleController._();
  static final ArticleController _instance = ArticleController._();
  static ArticleController get getInstance => _instance;

  final ApiService _api = ApiService.getInstance;

  Future<List<Article>> getArticles() async{
    try{
      final response = await _api.getArticles();
      final List<Map<String, dynamic>> resListJson = List<Map<String, dynamic>>.from(response["articles"]);
      List<Article> articles = resListJson.map((json) {
        return Article.fromJson(json);
      }).toList();
      return articles;
    } on CustomError catch(error){
      log('Controller : ${error.toString()}');
      rethrow;
    }catch(error){
      CustomError customError = CustomError(
        message: "Json Parsing Error",
        description : "Error while parsing JSON response"
      );
      log('Controller : ${error.toString()}');
      throw(customError);
    }
  }
}