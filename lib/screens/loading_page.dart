import 'package:flutter/material.dart';
import 'package:news_app/utils/constants.dart';
import 'package:shimmer/shimmer.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {

    double width = ScreenSize.getWidth(context);
    double height = ScreenSize.getHeight(context);

    return Container(
        width: width,
        height: height,
        child: Shimmer.fromColors(
            baseColor: Colors.grey.shade400,
            highlightColor: Colors.grey.shade100,
            child: ListView.builder(
                itemCount: 4,
                itemBuilder: (context, index) {
                  return Container(
                    width: width,
                    height: height/2,
                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black45,
                              blurRadius: 5,
                              offset: Offset(10, 10)
                          )
                        ]
                    ),
                  );
                },
            )
        ),
    );
  }
}
