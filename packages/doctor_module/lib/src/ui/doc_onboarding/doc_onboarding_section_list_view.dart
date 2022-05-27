import 'package:doctor_module/src/ui/doc_onboarding/doc_onboarding_section_a_view.dart';
import 'package:doctor_module/src/ui/doc_onboarding/doc_onboarding_section_b_view.dart';
import 'package:doctor_module/src/ui/doc_onboarding/doc_onboarding_section_c_view.dart';
import 'package:flutter/material.dart';
import 'package:swarapp/shared/app_bar.dart';
import 'package:swarapp/shared/app_colors.dart';
import 'package:swarapp/shared/app_profile_bar.dart';
import 'package:swarapp/shared/dotted_line.dart';
import 'package:swarapp/shared/screen_size.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:get/get.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:swarapp/ui/dashboard/dashboard_view.dart';
import 'package:swarapp/ui/dashboard/doctor_dashboard_view.dart';

class DocOnboardingSectionListView extends StatefulWidget {
  DocOnboardingSectionListView({Key? key}) : super(key: key);

  @override
  _DocOnboardingSectionListViewState createState() => _DocOnboardingSectionListViewState();
}

class _DocOnboardingSectionListViewState extends State<DocOnboardingSectionListView> {
  Widget getSectionItem(String title, String description, bool isadded, bool isTop, bool isBottom, Function() onSelect) {
    return SizedBox(
      height: 100,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              DottedLine(
                direction: Axis.vertical,
                lineLength: 8,
                dashColor: isTop ? activeColor : Colors.transparent,
              ),
              Container(
                width: 34,
                height: 34,
                decoration: UIHelper.roundedLineBorderWithColor(17, Colors.white, 2, borderColor: activeColor),
              ),
              DottedLine(
                direction: Axis.vertical,
                lineLength: 58,
                dashColor: isBottom ? activeColor : Colors.transparent,
              )
            ],
          ),
          UIHelper.horizontalSpaceSmall,
          Expanded(
            child: SizedBox(
              height: 100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  UIHelper.verticalSpaceTiny,
                  Text(title).fontSize(12).textColor(Color(0xFF626262)),
                  Text(description).fontSize(13),
                  UIHelper.verticalSpaceSmall,
                  GestureDetector(
                    onTap: onSelect,
                    child: Container(
                      alignment: Alignment.center,
                      width: 88,
                      height: 24,
                      decoration: UIHelper.roundedBorderWithColor(4, activeColor),
                      child: Text(isadded ? 'Edit' : 'Add').textColor(Colors.white).fontSize(12),
                    ),
                  ),
                  // UIHelper.verticalSpaceTiny,
                  Expanded(child: SizedBox()),
                  UIHelper.hairLineWidget()
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Color(0xFFFAF9F9),
      appBar: SwarProfileAppBar(),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UIHelper.verticalSpaceSmall,
            Text('Your profile is just few steps away form going live.').fontSize(12),
            UIHelper.verticalSpaceSmall,
            UIHelper.verticalSpaceSmall,
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  children: [Icon(Icons.check_box_outlined), Text('Video Consultation')],
                ),
                UIHelper.horizontalSpaceSmall,
                Row(
                  children: [Icon(Icons.check_box_outline_blank), Text('In clinic')],
                )
              ],
            ),
            UIHelper.verticalSpaceSmall,
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  children: [Icon(Icons.check_box_outline_blank), Text('Home visit Nurse')],
                ),
                UIHelper.horizontalSpaceSmall,
                UIHelper.horizontalSpaceSmall,
                Row(
                  children: [Icon(Icons.check_box_outline_blank), Text('Home visit Doctor')],
                )
              ],
            ),
            Expanded(
                child: Container(
              width: Screen.width(context),
              decoration: UIHelper.roundedBorderWithColor(8, Colors.white),
              padding: EdgeInsets.all(12),
              child: Column(
                children: [
                  Expanded(
                      child: ListView(
                    children: [
                      getSectionItem('Section A : Profile Details', 'Medical registration, educational qualification, establishment details.', false, false, true, () {
                        Get.to(() => DocOnboardingSectionAView());
                      }),
                      getSectionItem('Section B : Clinic', 'Manage fees, timing', false, true, true, () {
                        Get.to(() => DocOnboardingSectionBView());
                      }),
                      getSectionItem('Section C: Upload Documents', 'Upload the documents to verify your profile', false, true, false, () {
                        Get.to(() => DocOnboardingSectionCView());
                      }),
                    ],
                  )),
                  ElevatedButton(
                      onPressed: () async {
                        await Get.to(() => DoctorDashboardView());
                      },
                      child: Text('Review and submit').bold(),
                      style: ButtonStyle(
                          minimumSize: MaterialStateProperty.all(Size(70, 30)),
                          backgroundColor: MaterialStateProperty.all(activeColor),
                          shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))))),
                ],
              ),
            )),
            UIHelper.verticalSpaceMedium,
          ],
        ),
      ),
    );
  }
}
