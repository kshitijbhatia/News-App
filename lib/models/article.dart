import 'package:json_annotation/json_annotation.dart';
part 'article.g.dart';

@JsonSerializable()
class Article{
  @JsonKey(name : "id", required: true)
  int id;

  @JsonKey(name : "title", required: true)
  String title;

  @JsonKey(name : "url", required: true)
  String url;

  @JsonKey(name : "image_url", required: true)
  String image;

  @JsonKey(name : "news_site", required: true)
  String newsSite;

  @JsonKey(name : "summary", required: true)
  String summary;

  @JsonKey(name : "published_at", required: true)
  String publishedAt;

  @JsonKey(name : "updated_at", required: true)
  String updatedAt;

  Article({
    required this.id,
    required this.title,
    required this.summary,
    required this.image,
    required this.newsSite,
    required this.url,
    required this.publishedAt,
    required this.updatedAt
  });

  factory Article.fromJson(Map<String, dynamic> json) => _$ArticleFromJson(json);

  Map<String, dynamic> toJson() => _$ArticleToJson(this);
}