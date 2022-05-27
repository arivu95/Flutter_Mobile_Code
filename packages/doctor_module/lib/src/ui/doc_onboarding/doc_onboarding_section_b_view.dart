import 'package:doctor_module/src/ui/doc_onboarding/doc_onboarding_section_b_sess_list_view.dart';
import 'package:doctor_module/src/ui/doc_onboarding/widgets/doc_nav_back_widget.dart';
import 'package:doctor_module/src/ui/doc_onboarding/widgets/doc_section_progress_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get/get.dart';
import 'package:swarapp/shared/app_bar.dart';
import 'package:swarapp/shared/app_colors.dart';
import 'package:swarapp/shared/text_styles.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:styled_widget/styled_widget.dart';

class DocOnboardingSectionBView extends StatefulWidget {
  DocOnboardingSectionBView({Key? key}) : super(key: key);

  @override
  _DocOnboardingSectionBViewState createState() => _DocOnboardingSectionBViewState();
}

class _DocOnboardingSectionBViewState extends State<DocOnboardingSectionBView> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  int number=1;

  Widget addInputFormControl(String nameField, String hintText) {
    bool isEnabled = true;
    return FormBuilderTextField(
        style: loginInputTitleStyle,
        name: nameField,
        autocorrect: false,
        onChanged: (value) {
          print(value);
        },
        decoration: InputDecoration(
          contentPadding: nameField == 'attach' ? const EdgeInsets.symmetric(vertical: 10.0) : EdgeInsets.only(left: 10),
          // prefixIcon: icon,
          hintText: hintText,
          hintStyle: loginInputHintTitleStyle,
          filled: true,
          fillColor: Colors.white,
          enabledBorder: UIHelper.getInputBorder(1),
          focusedBorder: UIHelper.getInputBorder(1),
          focusedErrorBorder: UIHelper.getInputBorder(1),
          errorBorder: UIHelper.getInputBorder(1),
          //contentPadding: const EdgeInsets.symmetric(vertical: 40.0),
        ));
  }

  Widget inputwidget(BuildContext context) {
    return FormBuilder(
       // key: _fbKey,
        child: SingleChildScrollView(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          UIHelper.verticalSpaceSmall,
          addInputFormControl('clinic_name', 'Clinic Name'),
          UIHelper.verticalSpaceSmall,
          addInputFormControl('location', 'Location'),
          UIHelper.verticalSpaceSmall,
          addInputFormControl('clinic_number', 'Clinic Number '),
          UIHelper.verticalSpaceSmall,
          addInputFormControl('fee', 'Fees'),
          UIHelper.verticalSpaceSmall,
          GestureDetector(
            onTap: () {
              Get.to(() => DocOnboardingSectionBSessionListView());
            },
            child: Container(
              height: 72,
              decoration: UIHelper.roundedBorderWithColor(8, Colors.white),
              child: Row(
                children: [
                  UIHelper.horizontalSpaceSmall,
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      UIHelper.verticalSpaceSmall,
                      Text('Add your timings at the clinic'),
                      UIHelper.verticalSpaceTiny,
                      Text('MON,TUE,WED,THU,FRI,SAT,SUN '),
                    ],
                  )),
                  Icon(Icons.arrow_right_sharp)
                ],
              ),
            ),
          ),
        ])));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFFFAF9F9),
        appBar: SwarAppBar(2),
        body: SingleChildScrollView(
      child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
              UIHelper.verticalSpaceSmall,
              DocNavBackWidget(title: 'Clinic Details'),
              UIHelper.verticalSpaceSmall,
              DocSectionProgressWidget(
                title: 'Section B',
                value: 0.2,
              ),
              UIHelper.verticalSpaceSmall,
            Column(
                children: [
                   inputwidget(context),
                  number==2?
                  Column(
                    children: [
                     UIHelper.verticalSpaceSmall, 
                     UIHelper.hairLineWidget(borderColor: Colors.black12), 
                     inputwidget(context),
                     Text(''),
                  ],)
                 
                  :Text(''),
                 Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                             number=2;
                          });
                       },
                        child: Container(
                          alignment: Alignment.center,
                          width: 88,
                          height: 24,
                          decoration: UIHelper.roundedBorderWithColor(4, activeColor),
                          child: Text('Add').textColor(Colors.white).fontSize(12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
                 UIHelper.verticalSpaceLarge,
              ElevatedButton(
                onPressed: () {
                  Get.to(() => DocOnboardingSectionBView());
                },
                child: Text('Save').bold(),
                style: UIHelper.elevatedButtonStyle(),
              ),
              UIHelper.verticalSpaceSmall,
            ]))));
  }
}
