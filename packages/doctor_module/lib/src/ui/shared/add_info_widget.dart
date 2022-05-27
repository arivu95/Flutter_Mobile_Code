import 'package:flutter/material.dart';
import 'package:swarapp/shared/ui_helpers.dart';

class AddInfoWidget extends StatelessWidget {
  String title;
  AddInfoWidget({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Icon(Icons.add_circle_outline, color: Color(0xFFDE2128)),
        Padding(
          padding: const EdgeInsets.only(left: 18, top: 2),
          child: UIHelper.tagWidget(title, Color(0xFFDE2128), fontSize: 11),
        )
      ],
    );
  }
}
