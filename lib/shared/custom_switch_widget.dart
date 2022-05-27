import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:styled_widget/styled_widget.dart';

class CustomSwitchWidget extends StatefulWidget {
 Function(bool) onChanged;
  bool value;
  CustomSwitchWidget({Key? key, required this.onChanged, required this.value}) : super(key: key);

  @override
  _CustomSwitchWidgetState createState() => _CustomSwitchWidgetState();
}

class _CustomSwitchWidgetState extends State<CustomSwitchWidget> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 24,
          child: Transform.scale(
            alignment: Alignment.centerLeft,
            scale: 0.5,
            transformHitTests: false,
            child: CupertinoSwitch(
              activeColor: Colors.green,
              value: widget.value,
              onChanged: widget.onChanged,
            ),
          ),
        ),
        Text('Private').fontSize(12).fontWeight(FontWeight.w600),
      ],
    );
  }
}
