import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:news_app/models/article.dart';
import 'package:news_app/screens/Web_View_Page/web_view_page.dart';
import 'package:news_app/utils/constants.dart';
import 'package:news_app/utils/utils.dart';

class ArticleCard extends StatefulWidget{
  const ArticleCard({
    super.key,
    required this.article
  });

  final Article article;

  @override
  State<ArticleCard> createState() => _ArticleCardState();
}

class _ArticleCardState extends State<ArticleCard>{

  bool _seeMore = false;
  _changeSeeMore() => setState(()=> _seeMore = !_seeMore);

  @override
  Widget build(BuildContext context) {

    double width = ScreenSize.getWidth(context);
    double height = ScreenSize.getHeight(context);

    return Container(
      width: width,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: GestureDetector(
        onTap: (){
          Navigator.push(context, MaterialPageRoute(builder: (context) => WebViewPage(url: widget.article.url),));
        },
        child: Row(
          crossAxisAlignment: _seeMore ? CrossAxisAlignment.start : CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _articleSource(),
                  _articleSummary(),
                  _articleDate()
                ],
              ),
            ),
            _articleImage()
          ],
        )
      ),
    );
  }

  // Source for the Article

  Widget _articleSource(){
    double width = ScreenSize.getWidth(context);
    double height = ScreenSize.getHeight(context);
    return Container(
      width: width,
      padding: const EdgeInsets.all(10),
      child: Text(
        widget.article.source,
        style: const TextStyle(
          fontFamily: "Poppins",
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Image for the Article

  Widget _articleImage(){
    double width = ScreenSize.getWidth(context);
    double height = ScreenSize.getHeight(context);
    return CachedNetworkImage(
      imageUrl: widget.article.image,
      imageBuilder: (context, imageProvider) {
        return Container(
            width: width/2.6,
            height: height/6.5,
            margin: _seeMore ? const EdgeInsets.only(top : 15) : null,
            decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.fill
                )
            )
        );
      },
      progressIndicatorBuilder: (context, url, progress) {
        return Container(
          width: width/2.6,
          height: height/6.5,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.grey
          ),
          child: Center(
            child: SizedBox(
              width: width/8,
              height: height/16,
              child: const CircularProgressIndicator(color: AppTheme.highlightedTheme,),
            ),
          ),
        );
      },
      errorWidget: (context, url, error) {
        return Container(
            width: width/2.6,
            height: height/6.5,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image : const DecorationImage(
                    image: AssetImage('assets/breaking_news.jpg'),
                    fit: BoxFit.fill
                )
            )
        );
      },
    );
  }

  // Summary of the Article

  Widget _articleSummary(){

    String summary = widget.article.summary;
    if(summary == ""){
      summary = widget.article.title;
    }

    return Container(
        padding: const EdgeInsets.only(left: 10, right: 5),
        child: RichText(
            text: TextSpan(
              style: const TextStyle(fontFamily: "Poppins",fontSize: 16,fontWeight: FontWeight.w400 , color: Colors.black),
              children: <TextSpan>[
                TextSpan(
                  text: _seeMore ? summary : Utils.getHalfSummary(widget.article),
                ),
                widget.article.summary != ""
                    ? TextSpan(
                      text: _seeMore ? '' : '...',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => setState(() => _changeSeeMore())
                    )
                    : const TextSpan()
              ]
            )
        )
    );
  }

  // Date on the Article

  Widget _articleDate(){
    double width = ScreenSize.getWidth(context);
    double height = ScreenSize.getHeight(context);
    return Container(
      height: height/22,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 10),
      child: Text(Utils.getDaysAgo(widget.article.publishedAt), style: const TextStyle(fontFamily: "Poppins",fontSize: 16),),
    );
  }

}
