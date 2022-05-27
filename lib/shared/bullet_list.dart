import 'package:flutter/material.dart';
import 'package:swarapp/shared/ui_helpers.dart';

class BulletList extends StatelessWidget {
  final List<String> strings;

  BulletList(this.strings);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.fromLTRB(16, 5, 16, 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: strings.map((str) {
          return Padding(
              padding: const EdgeInsets.only(top: 5, bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  UIHelper.horizontalSpaceMedium,
                  Text(
                    '\u2022',
                    style: TextStyle(
                      fontSize: 25,
                      height: 0.8,
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Expanded(
                    child: Container(
                      child: Text(
                        str,
                        textAlign: TextAlign.left,
                        softWrap: true,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black.withOpacity(0.6),
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ));
        }).toList(),
      ),
    );
  }
}
