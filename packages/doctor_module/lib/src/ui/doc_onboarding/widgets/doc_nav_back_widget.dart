import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:styled_widget/styled_widget.dart';

class DocNavBackWidget extends StatelessWidget {
  final String title;
  const DocNavBackWidget({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.back();
      },
      child: Container(
        color: Colors.transparent,
        child: Row(
          children: [
            Icon(
              Icons.arrow_back_ios_new,
              size: 18,
            ),
            Text(title).fontSize(16),
          ],
        ),
      ),
    );
  }
}
