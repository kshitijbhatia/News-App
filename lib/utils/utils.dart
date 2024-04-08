import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:news_app/models/article.dart';

class Utils{

  static String getHalfSummary(Article article){

    String summary = article.summary;
    if(summary == "")return article.title;

    List<String> wordList = summary.split(' ');
    if(wordList.length <= 10) return summary;
    wordList = wordList.sublist(0, 10);

    String halfSummary = "";
    for (var element in wordList) {
      halfSummary += element;
      halfSummary += " ";
    }
    return halfSummary;
  }

  static String getDaysAgo(String updatedAt){
    DateTime updatedAtDate = DateTime.parse(updatedAt);
    DateTime now = DateTime.now();
    Duration difference = now.difference(updatedAtDate);
    int days = difference.inDays;
    if(days == 0){
      int hours = difference.inHours;
      if(hours == 0){
        int minutes = difference.inMinutes;
        return minutes == 1 ? '1 minute ago' : '$minutes minutes ago';
      }
      return hours == 1 ? '1 hour ago' : '$hours hours ago';
    }else if(days >= 7 && days < 31){
      int weeks = days~/7;
      return weeks == 1 ? '1 week ago' : '$weeks weeks ago';
    }else if(days >= 31 && days<365){
      int months = days~/31;
      return months == 1 ? '1 months ago' : '$months months ago';
    }else if(days >= 365){
      int years = days~/365;
      return years == 1 ? '1 year ago' : '$years years ago';
    }
    return days == 1 ? '1 day ago' : '$days days ago';
  }
}