import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

class Article{
  String id;
  String title;
  String author;
  String url;
  String image;
  String source;
  String summary;
  String publishedAt;

  Article({
    required this.id,
    required this.title,
    required this.author,
    required this.summary,
    required this.image,
    required this.source,
    required this.url,
    required this.publishedAt,
  });

  factory Article.fromJson(Map<String, dynamic> json){
    const uuid = Uuid();
    return Article(
        id: uuid.v4(),
        title: json["title"] ?? "",
        author: json["author"] ?? "",
        summary: json["description"] ?? "",
        image: json["urlToImage"] ?? "",
        source: json["source"]["name"] ?? "",
        url: json["url"] ?? "",
        publishedAt: json["publishedAt"]
    );
  }

  Map<String, dynamic> toJson(){
   return {
     "id" : id,
     "title" : title,
     "author" : author,
     "summary" : summary,
     "image" : image,
     "source" : source,
     "url" : url,
     "publishedAt" : publishedAt
   };
  }
}

class ArticleNotifier extends StateNotifier<List<Article>>{
  ArticleNotifier() : super([]);

  setArticleList(List<Article> list){
    state = list;
  }
}

final articleListNotifierProvider = StateNotifierProvider<ArticleNotifier, List<Article>>((ref) {
  return ArticleNotifier();
},);