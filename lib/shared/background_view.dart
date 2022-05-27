import 'package:flutter/material.dart';

class BackgroundView extends StatelessWidget {
  final Widget child;
  const BackgroundView({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return Material(
      color: Colors.white,
      child: Stack(
        children: [
          Image.asset(
            'assets/background_img.png',
            width: screenSize.width,
            height: screenSize.height,
            fit: BoxFit.fill,
          ),
          child
        ],
      ),
    );
  }
}
