import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:news_app/models/article.dart';
import 'package:news_app/providers/home_provider.dart';
import 'package:news_app/screens/Authentication/login_page.dart';
import 'package:news_app/screens/Update_Page/update_page.dart';
import 'package:news_app/utils/constants.dart';
import 'package:news_app/screens/Home_Page/article_card.dart';
import 'package:news_app/screens/Loading_Page/loading_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  void initState() {
    super.initState();
    Provider.of<HomeProvider>(context, listen: false).fetchArticles(context);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Scaffold(
          appBar: _appBar(),
            body: Consumer<HomeProvider>(
            builder : (context, provider, child) =>  provider.getApiCallComplete
                ? _articleList()
                : const LoadingScreen()
            )
      ),
    );
  }

  _appBar(){
    double width = ScreenSize.getWidth(context);
    double height = ScreenSize.getHeight(context);
    final provider = Provider.of<HomeProvider>(context, listen: false);
    return AppBar(
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            child: Row(
              children: [
                Consumer<HomeProvider>(
                  builder: (context, providerModel, child) => GestureDetector(
                    onTap: () => providerModel.setShowProfile(),
                    child: providerModel.getApiCallComplete ? CircleAvatar(
                      maxRadius: 16,
                      backgroundColor: Colors.white,
                      backgroundImage: NetworkImage(providerModel.getUser.imageUrl),
                    ) : Container(
                      width: width/20,
                      height: height/38,
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                ),
                10.w,
                Text(
                  Constants.appName,
                  style: AppTheme.getStyle(color: Colors.white, fs: 20, fw: FontWeight.w600),
                ),
              ],
            ),
          ),
          Consumer<HomeProvider>(
            builder : (context, providerModel, child) => Container(
              child: Row(
                children: [
                  Container(
                    margin : const EdgeInsets.only(bottom: 5),
                    child: Transform.rotate(
                        angle : math.pi/4,
                        child: const Icon(Icons.navigation),
                    ),
                  ),
                  Text(providerModel.getCountry, style: AppTheme.getStyle(color: Colors.white, fs: 16, fw: FontWeight.bold),)
                ],
              ),
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
      child: Consumer<HomeProvider>(
        builder: (context, provider, child) => RefreshIndicator(
          onRefresh: () => provider.refreshPage(context),
          color: AppTheme.highlightedTheme,
          child: Stack(
            children: [
              GestureDetector(
                onTap: () => provider.setShowProfileFalse(),
                child: ListView.builder(
                  itemCount: provider.getArticles.length + 1,
                  itemBuilder: (context, index) {
                    if(index == 0){
                      return Container(
                        width: width,
                        height: height/16,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(left: 15),
                        child: Text("Top Headlines", style: AppTheme.getStyle(color: Colors.black, fs: 18, fw: FontWeight.w600),),
                      );
                    }
                    if (index < provider.getArticles.length) {
                      Article currentArticle = provider.getArticles[index - 1];
                      return ArticleCard(
                        article: currentArticle,
                      );
                    }else {
                      return Container();
                    }
                  },
                ),
              ),
              provider.getShowProfile
                  ? _profileSection()
                  : 0.h,
          ],
          ),
        ),
      ),
    );
  }

  Widget _profileSection(){
    double width = ScreenSize.getWidth(context);
    double height = ScreenSize.getHeight(context);
    final provider = Provider.of<HomeProvider>(context, listen: false);
    return Container(
      width: width/1.5,
      height: height,
      padding: const EdgeInsets.only(top: 15),
      margin: const EdgeInsets.only(top: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            blurRadius: 7,
            offset: Offset(0, 3)
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: width/1.8,
                  height: height/11,
                  padding: const EdgeInsets.only(bottom: 10),
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                            color: Colors.grey,
                          )
                      )
                  ),
                  child: Consumer<HomeProvider>(
                    builder: (context, providerModel, child) => Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.grey,
                          backgroundImage: NetworkImage(providerModel.getUser.imageUrl)
                        ),
                        20.w,
                        Text(
                          providerModel.getUser.name.toUpperCase(),
                          style: AppTheme.getStyle(color: Colors.black, fs: 25, fw: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),



                Consumer<HomeProvider>(
                  builder : (context, providerModel, child) => GestureDetector(
                    onTap: (){
                      providerModel.setShowProfileFalse();
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => UpdatePage(user: providerModel.getUser,),)
                      ).then((value){
                        if(value != null){
                          providerModel.refreshPage(context);
                        }
                      });
                    },
                    child: Container(
                      width: width/1.8,
                      height: height/12,
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Icon(
                              Icons.settings,
                            size: 30,
                          ),
                          10.w,
                          Text(
                            "Settings",
                            style: AppTheme.getStyle(color: Colors.black, fs: 18, fw: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              prefs.setString(Constants.userKey, "");
              provider.setShowProfileFalse();
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage(),));
            },
            child: Container(
              width: width/1.8,
              height: height/12,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Icon(Icons.logout, size: 22,color: Colors.red,),
                  5.w,
                  Text("Log Out", style: AppTheme.getStyle(color: Colors.red, fs: 16, fw: FontWeight.w600),),
                  10.w
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}