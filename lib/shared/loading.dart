import 'package:flutter/material.dart';
import 'app_colors.dart';

class Loading extends StatelessWidget {
  const Loading();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(activeColor),
        ),
      ),
      color: Colors.white.withOpacity(0.8),
    );
  }
}
