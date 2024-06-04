import 'package:flutter/material.dart';
import 'package:news_app/screens/Home_Page/home_page.dart';
import 'package:news_app/utils/constants.dart';

class ErrorPage extends StatefulWidget{
  const ErrorPage({super.key});

  @override
  State<ErrorPage> createState() => _ErrorPageState();
}

class _ErrorPageState extends State<ErrorPage> {
  @override
  Widget build(BuildContext context) {

    double width = ScreenSize.getWidth(context);
    double height = ScreenSize.getHeight(context);

    return WillPopScope(
      onWillPop: (){
        return Future.value(false);
      },
      child: Scaffold(
        appBar: _appBar(),
        body: Container(
          width: width,
          height: height,
          color: AppTheme.pageBackground,
          child: _errorMessage(),
        ),
      ),
    );
  }

  _appBar(){
    return AppBar(
      title: Container(
        child: const Text(Constants.appName, style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 20),),
      ),
      backgroundColor: AppTheme.highlightedTheme,
      foregroundColor: Colors.white,
    );
  }

  Widget _errorMessage(){
    double width = ScreenSize.getWidth(context);
    double height = ScreenSize.getHeight(context);
    return Center(
        child: Container(
          width: width/1.2,
          height: height/3,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text('Something went wrong. Please try again', style: TextStyle(fontSize: 40,color: AppTheme.highlightedTheme, fontWeight: FontWeight.w300),),
              30.h,
              TextButton(
                  style: const ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(AppTheme.highlightedTheme),
                      padding: MaterialStatePropertyAll(EdgeInsets.symmetric(vertical: 10, horizontal: 30))
                  ),
                  onPressed: (){
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage(),));
                  },
                  child: const Text('Retry', textAlign: TextAlign.center,style: TextStyle(color: Colors.white,fontSize: 18),)
              )
            ],
          ),
        )
    );
  }
}
