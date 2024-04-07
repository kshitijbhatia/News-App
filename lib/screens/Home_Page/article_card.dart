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
        boxShadow: [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 10,
            offset: Offset(-10, 5)
          ),
          BoxShadow(
              color: Colors.black45,
              blurRadius: 10,
              offset: Offset(10, 5)
          )
        ]
      ),
      child: GestureDetector(
        onTap: (){
          Navigator.push(context, MaterialPageRoute(builder: (context) => WebViewPage(url: widget.article.url),));
        },
        child: Column(
          children: [
              _articleImage(),
              _articleTitle(),
              _articleSummary(),
              _articleDate()
          ],
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
            width: width,
            height : height/4,
            decoration: BoxDecoration(
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
          width: width,
          height: height/4,
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
            width: width,
            height : height/4,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image : const DecorationImage(
                    image: AssetImage('assets/Rocket.jpg'),
                    fit: BoxFit.fill
                )
            )
        );
      },
    );
  }

  // Title for the Article

  Widget _articleTitle(){
    double width = ScreenSize.getWidth(context);
    double height = ScreenSize.getHeight(context);
    return Container(
      width: width,
      padding: const EdgeInsets.all(10),
      child: Text(
        widget.article.title,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 22,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // Summary of the Article

  Widget _articleSummary(){
    double width = ScreenSize.getWidth(context);
    double height = ScreenSize.getHeight(context);

    return Container(
        width: width,
        padding: const EdgeInsets.all(10),
        child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 18, color: Colors.black),
              children: <TextSpan>[
                TextSpan(
                  text: _seeMore ? widget.article.summary : Utils.getHalfSummary(widget.article.summary),
                ),
                widget.article.summary != ""
                    ? TextSpan(
                      text: _seeMore ? ' show less' : '  ...show more',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.highlightedTheme,
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
      width: width,
      height: height/22,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 10),
      child: Text(Utils.getDaysAgo(widget.article.publishedAt), style: const TextStyle(fontSize: 16),),
    );
  }

}
