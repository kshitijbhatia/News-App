// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'article.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Article _$ArticleFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const [
      'id',
      'title',
      'url',
      'image_url',
      'news_site',
      'summary',
      'published_at',
      'updated_at'
    ],
  );
  return Article(
    id: json['id'] as int,
    title: json['title'] as String,
    summary: json['summary'] as String,
    image: json['image_url'] as String,
    newsSite: json['news_site'] as String,
    url: json['url'] as String,
    publishedAt: json['published_at'] as String,
    updatedAt: json['updated_at'] as String,
  );
}

Map<String, dynamic> _$ArticleToJson(Article instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'url': instance.url,
      'image_url': instance.image,
      'news_site': instance.newsSite,
      'summary': instance.summary,
      'published_at': instance.publishedAt,
      'updated_at': instance.updatedAt,
    };
