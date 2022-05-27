import 'package:doctor_module/src/ui/doc_onboarding/doc_onboarding_section_b_view.dart';
import 'package:doctor_module/src/ui/doc_onboarding/widgets/doc_nav_back_widget.dart';
import 'package:doctor_module/src/ui/doc_onboarding/widgets/doc_section_progress_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get/get.dart';
import 'package:swarapp/shared/app_bar.dart';
import 'package:swarapp/shared/text_styles.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:styled_widget/styled_widget.dart';

class DocOnboardingSectionAView extends StatefulWidget {
  const DocOnboardingSectionAView({Key? key}) : super(key: key);

  @override
  _DocOnboardingSectionAViewState createState() => _DocOnboardingSectionAViewState();
}

class _DocOnboardingSectionAViewState extends State<DocOnboardingSectionAView> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();

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
         hintText: hintText,
          hintStyle: loginInputHintTitleStyle,
          filled: true,
          fillColor: Colors.white,
          enabledBorder: UIHelper.getInputBorder(1),
          focusedBorder: UIHelper.getInputBorder(1),
          focusedErrorBorder: UIHelper.getInputBorder(1),
          errorBorder: UIHelper.getInputBorder(1),
        ));
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
              DocNavBackWidget(title: 'Profile Details '),
              UIHelper.verticalSpaceSmall,
              DocSectionProgressWidget(
                title: 'Section A',
                value: 0.5,
              ),
              UIHelper.verticalSpaceSmall,
              Expanded(
                  child: FormBuilder(
                key: _fbKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [Text('Personal Info ').fontSize(14)],
                      ),
                      UIHelper.verticalSpaceSmall,
                      addInputFormControl('address', 'Address'),
                      UIHelper.verticalSpaceSmall,
                      FormBuilderDropdown(
                        decoration: InputDecoration(
                          hintStyle: loginInputHintTitleStyle,
                          contentPadding: EdgeInsets.only(left: 10),
                          filled: true,
                          fillColor: Colors.white,
                          enabledBorder: UIHelper.getInputBorder(1),
                          focusedBorder: UIHelper.getInputBorder(1),
                          focusedErrorBorder: UIHelper.getInputBorder(1),
                          errorBorder: UIHelper.getInputBorder(1),
                        ),
                        name: "languages_known",
                        hint: Text('Languages Known').fontSize(14),

                        //key: UniqueKey(),
                        items: ['English', 'Arabic', 'Tamil', 'Hindi']
                            .map((cat) => DropdownMenuItem(
                                  value: cat,
                                  child: Text("$cat").textColor(Colors.black).fontSize(14),
                                ))
                            .toList(),
                      ),
                      UIHelper.verticalSpaceMedium,
                      Row(
                        children: [Text('Medical Registration ').fontSize(14)],
                      ),
                      UIHelper.verticalSpaceSmall,
                      addInputFormControl('reg_number', 'Registartion Number'),
                      UIHelper.verticalSpaceSmall,
                      addInputFormControl('reg_council', 'Registration Council'),
                      UIHelper.verticalSpaceSmall,
                      addInputFormControl('reg_year', 'Registration Year'),
                      UIHelper.verticalSpaceMedium,
                      Row(
                        children: [Text('Educational Qualification').fontSize(14)],
                      ),
                      UIHelper.verticalSpaceSmall,
                      FormBuilderDropdown(
                        decoration: InputDecoration(
                          hintStyle: loginInputHintTitleStyle,
                          contentPadding: EdgeInsets.only(left: 10),
                          filled: true,
                          fillColor: Colors.white,
                          enabledBorder: UIHelper.getInputBorder(1),
                          focusedBorder: UIHelper.getInputBorder(1),
                          focusedErrorBorder: UIHelper.getInputBorder(1),
                          errorBorder: UIHelper.getInputBorder(1),
                        ),
                        name: "select_degree",
                        hint: Text('Type or Select degree').fontSize(14),

                        //key: UniqueKey(),
                        items: ['MBBS', 'MD']
                            .map((cat) => DropdownMenuItem(
                                  value: cat,
                                  child: Text("$cat").textColor(Colors.black).fontSize(14),
                                ))
                            .toList(),
                      ),
                      UIHelper.verticalSpaceSmall,
                      FormBuilderDropdown(
                        decoration: InputDecoration(
                          hintStyle: loginInputHintTitleStyle,
                          contentPadding: EdgeInsets.only(left: 10),
                          filled: true,
                          fillColor: Colors.white,
                          enabledBorder: UIHelper.getInputBorder(1),
                          focusedBorder: UIHelper.getInputBorder(1),
                          focusedErrorBorder: UIHelper.getInputBorder(1),
                          errorBorder: UIHelper.getInputBorder(1),
                        ),
                        name: "select_institute",
                        hint: Text('Type or Select college/institute').fontSize(14),

                        //key: UniqueKey(),
                        items: ['MBBS', 'MD']
                            .map((cat) => DropdownMenuItem(
                                  value: cat,
                                  child: Text("$cat").textColor(Colors.black).fontSize(14),
                                ))
                            .toList(),
                      ),
                      UIHelper.verticalSpaceSmall,
                      addInputFormControl('deg_year', 'Type year of completion '),
                      UIHelper.verticalSpaceSmall,
                      addInputFormControl('exp', 'Type year of Experience '),
                      UIHelper.verticalSpaceMedium,
                    ],
                  ),
                ),
              )),
              ElevatedButton(
                onPressed: () {
                  Get.to(() => DocOnboardingSectionBView());
                },
                child: Text('Save and Next').bold(),
                style: UIHelper.elevatedButtonStyle(),
              ),
              UIHelper.verticalSpaceSmall,
            ])));
  }
}
