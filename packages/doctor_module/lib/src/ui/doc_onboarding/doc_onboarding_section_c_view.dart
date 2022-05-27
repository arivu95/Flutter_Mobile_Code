import 'package:doctor_module/src/ui/doc_onboarding/widgets/doc_nav_back_widget.dart';
import 'package:doctor_module/src/ui/doc_onboarding/widgets/doc_section_progress_widget.dart';
import 'package:flutter/material.dart';
import 'package:swarapp/shared/app_bar.dart';
import 'package:swarapp/shared/app_colors.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:styled_widget/styled_widget.dart';

class DocOnboardingSectionCView extends StatefulWidget {
  DocOnboardingSectionCView({Key? key}) : super(key: key);

  @override
  _DocOnboardingSectionCViewState createState() => _DocOnboardingSectionCViewState();
}

class _DocOnboardingSectionCViewState extends State<DocOnboardingSectionCView> {
  Widget uploadContainer(BuildContext context, String title, String description, bool isUploaded) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: UIHelper.roundedBorderWithColor(8, Colors.white),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title).fontSize(14),
                UIHelper.verticalSpaceTiny,
                Text(description).fontSize(11),
                SizedBox(
                  height: 20,
                ),
                Text(isUploaded ? '1 File Uploaded' : '').fontSize(10),
                UIHelper.verticalSpaceSmall,
              ],
            ),
          ),
          Column(
            children: [
              Container(
                padding: EdgeInsets.all(6),
                decoration: UIHelper.roundedBorderWithColor(4, isUploaded ? activeColor : Colors.black26),
                child: Text(isUploaded ? 'Uploaded' : '  Upload  ').textColor(Colors.white).fontSize(12),
              )
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFFFAF9F9),
        appBar: SwarAppBar(2),
        body: Container(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
              UIHelper.verticalSpaceSmall,
              DocNavBackWidget(title: 'Upload documents'),
              UIHelper.verticalSpaceSmall,
              DocSectionProgressWidget(
                title: 'Section C',
                value: 0.8,
              ),
              UIHelper.verticalSpaceSmall,
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      uploadContainer(context, 'Identity proof ', 'List of ldentity proof ', true),
                      UIHelper.verticalSpaceSmall,
                      uploadContainer(context, 'Medical registration proof', 'Eg. Medical council id ', false),
                      UIHelper.verticalSpaceSmall,
                      uploadContainer(context, 'Establishment proof', 'Clinic registration proof ', false),
                      UIHelper.verticalSpaceSmall,
                    ],
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {},
                child: Text('Save').bold(),
                style: UIHelper.elevatedButtonStyle(),
              ),
              UIHelper.verticalSpaceSmall,
            ])));
  }
}
