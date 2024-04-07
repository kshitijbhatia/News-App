import 'package:flutter/material.dart';
import 'package:news_app/utils/constants.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewPage extends StatelessWidget{
  const WebViewPage({super.key, required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {

    double width = ScreenSize.getWidth(context);
    double height = ScreenSize.getHeight(context);

    return WillPopScope(
        onWillPop: () {
          return Future.value(false);
        },
        child: SafeArea(
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Space News'),
              backgroundColor: AppTheme.highlightedTheme,
              foregroundColor: Colors.white,
              leading: IconButton(
                onPressed: (){
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back),
              ),
            ),
            body: Container(
              width: width,
              height: height,
              child: _WebViewComponent(url: url,)
            ),
          ),
        )
    );
  }
}


class _WebViewComponent extends StatefulWidget{
  const _WebViewComponent({super.key, required this.url});

  final String url;

  @override
  State<_WebViewComponent> createState() => _WebViewComponentState();
}

class _WebViewComponentState extends State<_WebViewComponent> {
  late final WebViewController controller;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..enableZoom(true)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url){
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (url) {
            setState(() {
              _isLoading = false;
            });
          },
        )
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    double width = ScreenSize.getWidth(context);
    return Container(
      width: width,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator( color: AppTheme.highlightedTheme,),)
          : WebViewWidget(controller: controller,)
    );
  }
}