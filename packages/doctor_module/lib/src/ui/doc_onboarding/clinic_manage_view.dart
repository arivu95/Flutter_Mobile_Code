import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:swarapp/shared/app_bar.dart';
import 'package:swarapp/shared/app_doctorprofile_bar.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:doctor_module/src/ui/doc_onboarding/widgets/doc_nav_back_widget.dart';
import 'package:get/get_core/src/get_main.dart';

class DocOnboardingClinicManageView extends StatefulWidget {
  DocOnboardingClinicManageView({Key? key}) : super(key: key);

  @override
  _DocOnboardingClinicManageViewState createState() => _DocOnboardingClinicManageViewState();
}

class _DocOnboardingClinicManageViewState extends State<DocOnboardingClinicManageView> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFFFAF9F9),
        appBar: SwarAppDoctorBar(isProfileBar: false),
        body: Container(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
              UIHelper.verticalSpaceSmall,
              GestureDetector(
                onTap: () {
                  // Get.back(result: {'refresh': true});
                },
                child: Row(
                  children: [
                    // Icon(
                    //   Icons.arrow_back_outlined,
                    //   size: 20,
                    // ),
                    Text(' Chat').bold(),
                  ],
                ),
              ),
              // DocNavBackWidget(title: 'Chat '),
              // UIHelper.verticalSpaceSmall,
              // UIHelper.verticalSpaceSmall,
              // Expanded(
              //     child: FormBuilder(
              //         key: _fbKey,
              //         child: SingleChildScrollView(
              //             child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              //           UIHelper.verticalSpaceSmall,
              //           GestureDetector(
              //             onTap: () {},
              //             child: Container(
              //               height: 72,
              //               decoration: UIHelper.roundedBorderWithColor(8, Colors.white),
              //               child: Row(
              //                 children: [
              //                   UIHelper.horizontalSpaceSmall,
              //                   Expanded(
              //                       child: Column(
              //                     crossAxisAlignment: CrossAxisAlignment.start,
              //                     children: [
              //                       UIHelper.verticalSpaceSmall,
              //                       Text('Clinic 1'),
              //                       UIHelper.verticalSpaceTiny,
              //                       Text('MON,TUE,WED,THU,FRI,SAT,SUN '),
              //                     ],
              //                   )),
              //                   Icon(Icons.arrow_right_sharp)
              //                 ],
              //               ),
              //             ),
              //           ),
              //           UIHelper.verticalSpaceSmall,
              //           GestureDetector(
              //             onTap: () {},
              //             child: Container(
              //               height: 72,
              //               decoration: UIHelper.roundedBorderWithColor(8, Colors.white),
              //               child: Row(
              //                 children: [
              //                   UIHelper.horizontalSpaceSmall,
              //                   Expanded(
              //                       child: Column(
              //                     crossAxisAlignment: CrossAxisAlignment.start,
              //                     children: [
              //                       UIHelper.verticalSpaceSmall,
              //                       Text('Clinic 2'),
              //                       UIHelper.verticalSpaceTiny,
              //                       Text('MON,TUE,WED,THU,FRI,SAT,SUN '),
              //                     ],
              //                   )),
              //                   Icon(Icons.arrow_right_sharp)
              //                 ],
              //               ),
              //             ),
              //           ),
              //         ])))),
            ])));
  }
}
