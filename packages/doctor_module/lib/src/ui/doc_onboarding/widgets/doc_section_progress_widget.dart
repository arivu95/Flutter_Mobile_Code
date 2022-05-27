import 'package:flutter/material.dart';
import 'package:swarapp/shared/app_colors.dart';
import 'package:swarapp/shared/screen_size.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:styled_widget/styled_widget.dart';

class DocSectionProgressWidget extends StatelessWidget {
  final String title;
  final double value;
  const DocSectionProgressWidget({Key? key, required this.title, required this.value}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(
        Icons.account_circle,
        size: 40,
        color: Colors.black45,
      ),
      UIHelper.horizontalSpaceSmall,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title).fontSize(11),
          UIHelper.verticalSpaceSmall,
          SizedBox(
            width: Screen.width(context) - 84,
            child: LinearProgressIndicator(
              backgroundColor: Color(0xFF919191),
              valueColor: AlwaysStoppedAnimation<Color>(
                activeColor,
              ),
              value: value,
            ),
          )
        ],
      )
    ]);
  }
}
