import 'package:documents_module/src/ui/medical_records/vaccination_widget/Add_Birthdetails_view.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:swarapp/shared/app_colors.dart';
import 'package:swarapp/shared/app_static_bar.dart';
import 'package:swarapp/shared/screen_size.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:get/get.dart';
import 'package:swarapp/ui/startup/terms_view.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class BirthDetailsView extends StatefulWidget {
  // dynamic vaccineData;
  dynamic vaccineData;
  dynamic userVaccineData;
  dynamic userBirthData;
  String docId;
  BirthDetailsView({Key? key, this.vaccineData, this.userVaccineData, required this.docId}) : super(key: key);

  @override
  _BirthDetailsViewState createState() => _BirthDetailsViewState();
}

class _BirthDetailsViewState extends State<BirthDetailsView> {
  // final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  Widget additionalInfoWidget(BuildContext context, String title, String value, Widget icon) {
    return Row(
      children: [
        icon,
        UIHelper.horizontalSpaceSmall,
        SizedBox(
          child: Text(title).fontSize(13),
          width: Screen.width(context) / 2.5,
        ),
        Expanded(
          child: Text(value).fontSize(13).textAlignment(TextAlign.end).fontWeight(FontWeight.w600),
        ),
        UIHelper.horizontalSpaceSmall,
      ],
    );
  }

  Widget iconItem(IconData icon) {
    return SizedBox(
      width: 20,
      child: Icon(
        icon,
        color: activeColor,
      ),
    );
  }

  Widget imageItem(String asset) {
    return Image.asset(
      asset,
      height: 20,
    );
  }

  Widget addHeader(BuildContext context, bool isBackBtnVisible) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
      child: Row(
        children: [
          isBackBtnVisible
              ? GestureDetector(
                  onTap: () {
                    // Get.to(() => VaccineMaternityListView(cat_Type:"Vaccination"));
                    Get.back();
                  },
                  // child: Icon(
                  //   Icons.arrow_back_ios,
                  //   size: 20,
                  // ),
                  child: Image.asset('assets/arrow_back_chat.png'),
                )
              : SizedBox(),
          Text('  Vaccination').bold().fontSize(16),
          Expanded(child: SizedBox()),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String givenDateStr = '';
    String nextDate = '';
    String dob = '';
    String age = '';
   
    if (preferencesService.dropdown_user_dob != null || preferencesService.dropdown_user_dob != "") {
      dob = preferencesService.dropdown_user_dob;
    }

    if (preferencesService.dropdown_user_age != "null" && preferencesService.dropdown_user_age != null && preferencesService.dropdown_user_age != "") {
      age = preferencesService.dropdown_user_age;
    }
    
    String vaccineStatus = '';

    // widget.vaccineData['status'] == true ? vaccine_status = "Yes" : vaccine_status = "No";

    return Scaffold(
        // backgroundColor: fieldBgColor,
        backgroundColor: Colors.white,
        // appBar: SwarAppBar(),
        appBar: SwarAppStaticBar(),
        body: SafeArea(
            top: false,
            child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12),
                width: Screen.width(context),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  //UIHelper.verticalSpaceMedium,
                  //  UIHelper.verticalSpaceSmall,
                  UIHelper.verticalSpaceSmall,
                  UIHelper.addHeader(context, "Birth Details", true),
                  // Padding(
                  //   padding: const EdgeInsets.symmetric(horizontal: 8),
                  //   child: addHeader(context,true),
                  // ),
                  UIHelper.verticalSpaceSmall,
                  UIHelper.verticalSpaceSmall,
                  Expanded(
                      child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: UIHelper.roundedBorderWithColorWithShadow(8, fieldBgColor),
                      width: Screen.width(context),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  await Get.to(() => AddBirthDetailsView(
                                        vaccineData: widget.vaccineData,
                                        userVaccineData: widget.userVaccineData,
                                        docId: widget.docId,
                                      ));

                                  setState(() {});
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Icon(
                                      Icons.edit,
                                      size: 16,
                                      color: activeColor,
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text('Edit').fontSize(13)
                                  ],
                                ),
                              ),
                            ],
                          ),
                          // UIHelper.verticalSpaceSmall,
                          UIHelper.verticalSpaceMedium,
                          additionalInfoWidget(
                              context,
                              'Child Name',
                              //widget.vaccineData['name'] ?? '',
                              preferencesService.dropdown_user_name ?? '',
                              imageItem('assets/user_portrait.png')),
                          //UIHelper.verticalSpaceSmall,
                          // additionalInfoWidget(context, 'Medical Record No', widget.vaccineData['medical_record_no'] ?? '', imageItem('assets/mem1.png')),
                          //UIHelper.verticalSpaceSmall,
                          UIHelper.verticalSpaceMedium,
                          additionalInfoWidget(context, 'Date of Birth', dob, imageItem('assets/ch_up.png')),
                          UIHelper.verticalSpaceMedium,
                          additionalInfoWidget(context, 'Age', age, imageItem('assets/age_icon.png')),
                          UIHelper.verticalSpaceMedium,
                          // UIHelper.verticalSpaceSmall,
                          // additionalInfoWidget(
                          //     context,
                          //     'Vaccine',
                          //     widget.vaccineData['vaccine_name'] ?? '',
                          //     imageItem('assets/vaccine.png')),
                          // UIHelper.verticalSpaceSmall,
                          // additionalInfoWidget(
                          //   context,
                          //   'Vaccine status',
                          //   vaccine_status,
                          //   imageItem('assets/vacstatus.png'),
                          // ),
                          // UIHelper.verticalSpaceSmall,
                          // additionalInfoWidget(context, 'Vaccine given date',
                          //     given_dateStr, imageItem('assets/vacdate.png')),

                          // additionalInfoWidget(context, 'Next vaccine date', next_date, imageItem('assets/vacdate.png')),
                          additionalInfoWidget(context, 'Medical Record No', widget.userVaccineData['medical_record_no'] ?? '', imageItem('assets/ch_up.png')),
                          UIHelper.verticalSpaceMedium,
                          additionalInfoWidget(context, 'Gestational Age ', widget.userVaccineData['gestational_Age'] ?? '', imageItem('assets/age_icon.png')),
                          UIHelper.verticalSpaceMedium,
                          additionalInfoWidget(context, ' Mode of delivery ', widget.userVaccineData['mode_of_delivery'] ?? '', imageItem('assets/cil_pregnant.png')),
                          UIHelper.verticalSpaceMedium,
                          additionalInfoWidget(context, 'Birth Weight', widget.userVaccineData['birth_weight'] ?? '', imageItem('assets/bweight.png')),
                          UIHelper.verticalSpaceMedium,
                          additionalInfoWidget(context, ' APGAR Score', widget.userVaccineData['apgar_score'] ?? '', imageItem('assets/apgr_rec_icon.png')),
                          UIHelper.verticalSpaceMedium,
                          additionalInfoWidget(context, ' Length at birth ', widget.userVaccineData['length_at_birth'] ?? '', imageItem('assets/lb.png')),
                          UIHelper.verticalSpaceMedium,
                          additionalInfoWidget(context, ' Head Circumference ', widget.userVaccineData['head_circumference'] ?? '', imageItem('assets/head_cir.png')),
                          UIHelper.verticalSpaceMedium,
                          (widget.userVaccineData['TSH'] == null) || (widget.userVaccineData['TSH'] == '')
                              ? additionalInfoWidget(context, ' TSH', '', imageItem('assets/tsh.png'))
                              : additionalInfoWidget(context, ' TSH', widget.userVaccineData['TSH'] + ' mIU/L' ?? '', imageItem('assets/tsh.png')),
                          UIHelper.verticalSpaceMedium,
                          (widget.userVaccineData['G6PD'] == null) || (widget.userVaccineData['G6PD'] == '')
                              ? additionalInfoWidget(context, ' G6PD', '', imageItem('assets/g6pd.png'))
                              : additionalInfoWidget(context, ' G6PD', widget.userVaccineData['G6PD'] + ' U/g Hb' ?? '', imageItem('assets/g6pd.png')),
                          UIHelper.verticalSpaceMedium,
                          additionalInfoWidget(context, '   Baby Blood Group', widget.userVaccineData['baby_blood_group'] ?? '', imageItem('assets/mbgroup.png')),
                          UIHelper.verticalSpaceMedium,
                          additionalInfoWidget(context, '   Mother’s Blood Group', widget.userVaccineData['mother_Blood_group'] ?? '', imageItem('assets/mbgroup.png')),
                        ],
                      ),
                    ),
                  )),
                  UIHelper.verticalSpaceMedium,
                ]))));
  }
}
