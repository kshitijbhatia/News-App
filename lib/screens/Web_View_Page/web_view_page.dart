import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_app/utils/constants.dart';
import 'package:webview_flutter/webview_flutter.dart';

final webViewPageProvider = StateProvider((ref) {
  return WebViewPageState.initial;
},);

enum WebViewPageState { initial, loading }

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
              title: const Text(Constants.appName, style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 20),),
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


class _WebViewComponent extends ConsumerStatefulWidget{
  const _WebViewComponent({super.key, required this.url});

  final String url;

  @override
  ConsumerState<_WebViewComponent> createState() => _WebViewComponentState();
}

class _WebViewComponentState extends ConsumerState<_WebViewComponent> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..enableZoom(true)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url){
            ref.read(webViewPageProvider.notifier).state = WebViewPageState.loading;
          },
          onPageFinished: (url) {
            ref.read(webViewPageProvider.notifier).state = WebViewPageState.initial;
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
      child: Consumer(
        builder: (context, ref, child) {
          final webViewState = ref.watch(webViewPageProvider);
          switch(webViewState){
            case WebViewPageState.loading :
              return const Center(child: CircularProgressIndicator( color: AppTheme.highlightedTheme,),);
            case WebViewPageState.initial :
              return WebViewWidget(controller: controller,);
          }
        },
      )
    );
  }
}