import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:math' as math;
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:news_app/controllers/article_controllers.dart';
import 'package:news_app/main.dart';
import 'package:news_app/models/article.dart';
import 'package:news_app/models/custom_error.dart';
import 'package:news_app/models/user.dart';
import 'package:news_app/network/authentication.dart';
import 'package:news_app/network/messaging_service.dart';
import 'package:news_app/network/remote_config_service.dart';
import 'package:news_app/screens/Authentication/login_page.dart';
import 'package:news_app/screens/Error_Page/error_page.dart';
import 'package:news_app/screens/Update_Page/update_page.dart';
import 'package:news_app/utils/constants.dart';
import 'package:news_app/screens/Home_Page/article_card.dart';
import 'package:news_app/screens/Loading_Page/loading_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final showProfileSectionProvider = StateProvider<bool>((ref) {
  return false;
},);

final showProfilePictureProvider = StateProvider<bool>((ref) {
  return false;
},);

final countryProvider = StateProvider<String>((ref) {
  return "";
},);

final getArticlesFutureProvider = FutureProvider.autoDispose.family<List<Article>, BuildContext>((ref, context) async {
  try{
    // Get the country from Remote Config
    await FirebaseRemoteConfigService.getInstance.fetchAndActivate();
    final country = FirebaseRemoteConfigService.getInstance.getCountry;
    ref.read(countryProvider.notifier).state = country;

    final user = ref.read(currentUserNotifierProvider);

    // Set the user uid in crashlytics
    await FirebaseCrashlytics.instance.setUserIdentifier(user.uid);

    // Get Articles
    final articleController = ref.read(articleControllerProvider);
    final response = await articleController.getArticles(country);

    // Set articles list and show Profile picture in app bar
    ref.read(articleListNotifierProvider.notifier).setArticleList(response);
    ref.read(showProfilePictureProvider.notifier).state = true;
    return response;
  }catch(error){
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ErrorPage(),));
    rethrow;
  }
},);

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {

  Future<void> _refreshPage() async {
    ref.read(articleListNotifierProvider.notifier).setArticleList([]);
    ref.read(getArticlesFutureProvider(context));
  }

  Future<void> initializeNotification() async {
    final prefs = ref.read(sharedPreferencesProvider);
    final _user = AppUser.fromJson(jsonDecode(prefs.getString(Constants.userKey)!));
    await FirebaseMessagingApi.getInstance.initNotifications();
    await FirebaseMessagingApi.getInstance.subscribeToTopic(_user.uid);
    await FirebaseMessagingApi.getInstance.subscribeToTopic(Constants.allSignedInUsers);
  }

  @override
  void initState() {
    super.initState();
    initializeNotification();
  }

  @override
  void dispose() {
    final user = ref.read(currentUserNotifierProvider);
    FirebaseMessagingApi.getInstance.unsubscribeFromTopic(user.uid);
    FirebaseMessagingApi.getInstance.unsubscribeFromTopic(Constants.allSignedInUsers);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Scaffold(
          appBar: _appBar(),
          body: Consumer(
            builder: (context, ref, child) {
              return ref.watch(getArticlesFutureProvider(context)).when(
                  data: (data) {
                    return _articleList();
                  },
                  error: (error, stackTrace) {
                    return Container();
                  },
                  loading: () => const LoadingScreen(),
              );
            },
          )
      ),
    );
  }



  _appBar(){
    final AppUser user = ref.watch(currentUserNotifierProvider);
    final showProfilePicture = ref.watch(showProfilePictureProvider);
    final showProfileSection = ref.watch(showProfileSectionProvider);

    double width = ScreenSize.getWidth(context);
    double height = ScreenSize.getHeight(context);
    return AppBar(
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            child: Row(
              children: [
                GestureDetector(
                  onTap : () => ref.read(showProfileSectionProvider.notifier).state = !showProfileSection,
                  child: showProfilePicture
                    ? CircleAvatar(
                        maxRadius: 16,
                        backgroundColor: Colors.white,
                        backgroundImage: NetworkImage(user.imageUrl),
                      )
                    : Container(
                        width: width/20,
                        height: height/38,
                        child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                  )
                ),
                10.w,
                Text(
                  Constants.appName,
                  style: AppTheme.getStyle(color: Colors.white, fs: 20, fw: FontWeight.w600),
                ),
              ],
            ),
          ),
          Container(
            child: Row(
              children: [
                Container(
                  margin : const EdgeInsets.only(bottom: 5),
                  child: Transform.rotate(
                      angle : math.pi/4,
                      child: const Icon(Icons.navigation),
                  ),
                ),
                Consumer(
                    builder: (context, ref, child) {
                      final country = ref.watch(countryProvider);
                      return Text(country, style: AppTheme.getStyle(color: Colors.white, fs: 16, fw: FontWeight.bold),);
                    },
                )
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
    final showProfileSection = ref.watch(showProfileSectionProvider);
    return Container(
      width: width,
      height: height,
      color: AppTheme.pageBackground,
      child: RefreshIndicator(
        onRefresh: _refreshPage,
        color: AppTheme.highlightedTheme,
        child: Stack(
          children: [
            Consumer(
              builder: (context, ref, child) {
                final articles = ref.watch(articleListNotifierProvider);
                return GestureDetector(
                  onTap: () => ref.read(showProfileSectionProvider.notifier).state = false,
                  child: ListView.builder(
                    itemCount: articles.length + 1,
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
                      if (index < articles.length) {
                        Article currentArticle = articles[index - 1];
                        return ArticleCard(
                          article: currentArticle,
                        );
                      }else {
                        return Container();
                      }
                    },
                  ),
                );
              },
            ),
            showProfileSection
                ? _profileSection()
                : 0.h,
        ],
        ),
      ),
    );
  }

  Widget _profileSection(){
    double width = ScreenSize.getWidth(context);
    double height = ScreenSize.getHeight(context);
    final AppUser user = ref.watch(currentUserNotifierProvider);
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.grey,
                        backgroundImage: NetworkImage(user.imageUrl)
                      ),
                      20.w,
                      Text(
                        user.name.toUpperCase(),
                        style: AppTheme.getStyle(color: Colors.black, fs: 25, fw: FontWeight.w500),
                      ),
                    ],
                  ),
                ),



                GestureDetector(
                  onTap: (){
                    ref.read(showProfileSectionProvider.notifier).state = false;
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const UpdatePage(),)).then((value){
                      if(value != null){_refreshPage();}
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
              ],
            ),
          ),
          GestureDetector(
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              prefs.setString(Constants.userKey, "");
              Authentication.getInstance.signOut(user);
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