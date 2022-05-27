import 'package:documents_module/src/ui/medical_records/maternity_widget/add_maternity_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swarapp/shared/app_colors.dart';
import 'package:swarapp/shared/app_static_bar.dart';
import 'package:swarapp/shared/screen_size.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:jiffy/jiffy.dart';
import 'package:swarapp/ui/startup/terms_view.dart';

class ShowMaternityView extends StatefulWidget {
  dynamic maternityinfo;
  dynamic documentModelid;
  ShowMaternityView({Key? key, this.maternityinfo, this.documentModelid}) : super(key: key);

  @override
  _ShowMaternityViewState createState() => _ShowMaternityViewState();
}

class _ShowMaternityViewState extends State<ShowMaternityView> {
  // get maternityinfo => null;

  Widget additionalInfoWidget(BuildContext context, String title, String value, Widget icon) {
    return Row(
      children: [
        icon,
        UIHelper.horizontalSpaceSmall,
        SizedBox(
          child: Text(title).fontSize(13),
          width: Screen.width(context) / 2,
        ),
        Expanded(
          child: Text(value).fontSize(13).textAlignment(TextAlign.end).fontWeight(FontWeight.w600),
        ),
        UIHelper.horizontalSpaceSmall,
      ],
    );
  }

  Widget iconItem(IconData icon) {
    return Icon(
      icon,
      color: activeColor,
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
                    // Get.to(() => VaccineMaternityListView(cat_Type:"Maternity"));
                    Get.back(result: {'refresh': true});
                  },
                  child: Icon(
                    Icons.arrow_back_ios,
                    size: 20,
                  ),
                )
              : SizedBox(),
          Text('Maternity').bold().fontSize(16),
          Expanded(child: SizedBox()),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print(widget.maternityinfo.toString());
    String checkupDate = "";
    String lastCheckupDate = "";
    String nextCheckupDate = "";
    String expectedDueDate = "";
    String pregnancyDate = preferencesService.dropdown_user_pragnancy_date;
    String getDob = '';
    String getAge = '';
    String attachFileName = "";

//  if ( preferencesService.userInfo['dateofbirth'] != null) {
//       Jiffy dob_chk = Jiffy(  preferencesService.memberInfo['date_of_birth'] );
//       get_dob = dob_chk.format('dd/MM/yyyy');
//     }

    if (widget.maternityinfo['attach_record'] != null && widget.maternityinfo['attach_record'] != "") {
      attachFileName = widget.maternityinfo['attach_record'].contains('/') ? widget.maternityinfo['attach_record'].split('/').last : widget.maternityinfo['attach_record'];
    } else {
      attachFileName = "";
    }

    if (preferencesService.dropdown_user_dob == null || preferencesService.dropdown_user_dob == "") {
      getAge = "";
      getDob = "";
    } else {
      getAge = preferencesService.dropdown_user_age;
      getDob = preferencesService.dropdown_user_dob;
    }

    if (widget.maternityinfo['checkup_date'] != null) {
      Jiffy chck = Jiffy(widget.maternityinfo['checkup_date']);
      checkupDate = chck.format('dd/MM/yyyy');
    }

    if (widget.maternityinfo['last_checkup_date'] != null) {
      Jiffy laChck = Jiffy(widget.maternityinfo['last_checkup_date']);
      lastCheckupDate = laChck.format('dd/MM/yyyy');
    }

    if (widget.maternityinfo['next_checkup_date'] != null) {
      Jiffy nxtChck = Jiffy(widget.maternityinfo['next_checkup_date']);
      nextCheckupDate = nxtChck.format('dd/MM/yyyy');
    }

    if (widget.maternityinfo['expected_due_date'] != null) {
      Jiffy dueDate = Jiffy(widget.maternityinfo['expected_due_date']);
      expectedDueDate = dueDate.format('dd/MM/yyyy');
    }

    return Scaffold(
        backgroundColor: Colors.white,
        // appBar: SwarAppBar(),
        appBar: SwarAppStaticBar(),
        // appBar: SwarAppBar(),
        body: Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            width: Screen.width(context),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              //  UIHelper.verticalSpaceMedium,
              //  UIHelper.verticalSpaceSmall,
              UIHelper.verticalSpaceSmall,
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 8),
              //   child: addHeader(context, true),
              // ),
              UIHelper.addHeader(context, "Maternity", true),
              UIHelper.verticalSpaceSmall,
              UIHelper.verticalSpaceSmall,
              Expanded(
                  child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 10),
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
                              await Get.to(() {
                                var maternityDocId = widget.documentModelid;
                                return AddMaternityView(
                                  isEditMode: true,
                                  editmaternity: widget.maternityinfo,
                                  mainDocId: maternityDocId,
                                );
                              });

                              setState(() {});
                              print(widget.maternityinfo.toString());
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
                      UIHelper.verticalSpaceSmall,
                      // additionalInfoWidget(
                      //     context,
                      //     'Member Medical ID',
                      //     widget.maternityinfo['member_medical_id'] ?? '',

                      //     imageItem('assets/mem1.png')),
                      //     // UIHelper.verticalSpaceSmall,
                      //      UIHelper.verticalSpaceMedium,
                      additionalInfoWidget(context, 'Date Of Birth', getDob, imageItem('assets/ch_up.png')),
                      //  UIHelper.verticalSpaceSmall,
                      //  UIHelper.verticalSpaceSmall,
                      UIHelper.verticalSpaceMedium,
                      additionalInfoWidget(context, 'Age', getAge, imageItem('assets/ch_up.png')),
                      //UIHelper.verticalSpaceSmall,
                      UIHelper.verticalSpaceMedium,
                      // UIHelper.verticalSpaceSmall,
                      // additionalInfoWidget(
                      //     context,
                      //     'Check up Date',
                      //    checkup_date,
                      //     imageItem('assets/ch_up.png')),
                      // UIHelper.verticalSpaceSmall,
                      // additionalInfoWidget(
                      //     context,
                      //     'Pregnancy Week',
                      //     widget.maternityinfo['pregnancy_week'] ?? '',
                      //     imageItem('assets/cil_pregnant.png')),
                      // UIHelper.verticalSpaceSmall,
                      additionalInfoWidget(context, 'Member Medical ID', widget.maternityinfo['member_medical_id'] ?? '', imageItem('assets/apgr_rec_icon.png')),
                      UIHelper.verticalSpaceMedium,
                      additionalInfoWidget(context, 'Checkup Date', checkupDate, imageItem('assets/ch_up.png')),
                      //UIHelper.verticalSpaceSmall,
                      UIHelper.verticalSpaceMedium,
                      additionalInfoWidget(context, 'Pregnancy Week', widget.maternityinfo['pregnancy_week'] ?? '', imageItem('assets/cil_pregnant.png')),
                      //UIHelper.verticalSpaceSmall,
                      UIHelper.verticalSpaceMedium,

                      (widget.maternityinfo['mother_weight'] == null) || (widget.maternityinfo['mother_weight'] == '')
                          ? additionalInfoWidget(context, 'Mother Weight', '', imageItem('assets/bweight.png'))
                          : additionalInfoWidget(context, 'Mother Weight', widget.maternityinfo['mother_weight'] + " Kg", imageItem('assets/bweight.png')),
                      //UIHelper.verticalSpaceSmall,
                      UIHelper.verticalSpaceMedium,
                      // additionalInfoWidget(
                      //     context,
                      //     'Baby Weight',
                      //     widget.maternityinfo['baby_weight'] ?? '',
                      //     imageItem('assets/bweight.png')),
                      // UIHelper.verticalSpaceSmall,
                      // additionalInfoWidget(
                      //     context,
                      //     'Baby BPM ',
                      //     widget.maternityinfo['baby_BPM'] ?? '',
                      //     imageItem('assets/bpm.png')),
                      // UIHelper.verticalSpaceSmall,
                      // additionalInfoWidget(
                      //     context,
                      //     'Baby HCG Level',
                      //     widget.maternityinfo['baby_HCG_level'] ?? '',
                      //     imageItem('assets/apgr_rec_icon.png')),
                      // UIHelper.verticalSpaceSmall,
                      // additionalInfoWidget(
                      //     context,
                      //     'Baby Head Circumference',
                      //     widget.maternityinfo['baby_head_circumference'] ?? '',
                      //     imageItem('assets/head_cir.png')),
                      // UIHelper.verticalSpaceSmall,
                      (widget.maternityinfo['mother_BP'] == null) || (widget.maternityinfo['mother_BP'] == '')
                          ? additionalInfoWidget(context, ' Mother BP', '', imageItem('assets/bbgroup.png'))
                          : additionalInfoWidget(context, ' Mother BP', widget.maternityinfo['mother_BP'] + " mmHg", imageItem('assets/bbgroup.png')),
                      //UIHelper.verticalSpaceSmall,
                      UIHelper.verticalSpaceMedium,

                      (widget.maternityinfo['baby_blood_group'] == null) || (widget.maternityinfo['baby_blood_group'] == '')
                          ? additionalInfoWidget(context, ' Mother Blood Group ', '', imageItem('assets/bbgroup.png'))
                          : additionalInfoWidget(context, ' Mother Blood Group', widget.maternityinfo['baby_blood_group'], imageItem('assets/bbgroup.png')),
                      //UIHelper.verticalSpaceSmall,
                      UIHelper.verticalSpaceMedium,
                      // additionalInfoWidget(
                      //     context,
                      //     'Last Checkup Date ',
                      //     last_checkup_date,
                      //     imageItem('assets/ch_up.png')),
                      // UIHelper.verticalSpaceSmall,
                      (widget.maternityinfo['glucose_level'] == null) || (widget.maternityinfo['glucose_level'] == '')
                          ? additionalInfoWidget(context, ' Glucose level ', '', imageItem('assets/bp.png'))
                          : additionalInfoWidget(context, ' Glucose level ', widget.maternityinfo['glucose_level'] + " mg/dl", imageItem('assets/bp.png')),
                      //UIHelper.verticalSpaceSmall,
                      UIHelper.verticalSpaceMedium,
                      (widget.maternityinfo['blood_sugar'] == null) || (widget.maternityinfo['blood_sugar'] == '')
                          ? additionalInfoWidget(context, ' Blood Sugar Fast', '', imageItem('assets/bbgroup.png'))
                          : additionalInfoWidget(context, ' Blood Sugar Fast', widget.maternityinfo['blood_sugar'] + " mg/dl", imageItem('assets/bbgroup.png')),
                      //UIHelper.verticalSpaceSmall,
                      UIHelper.verticalSpaceMedium,
                      (widget.maternityinfo['mother_blood_group'] == null) || (widget.maternityinfo['mother_blood_group'] == '')
                          ? additionalInfoWidget(context, ' Blood Sugar Random', '', imageItem('assets/bbgroup.png'))
                          : additionalInfoWidget(context, ' Blood Sugar Random', widget.maternityinfo['mother_blood_group'] + " mg/dl", imageItem('assets/bbgroup.png')),
                      //UIHelper.verticalSpaceSmall,
                      UIHelper.verticalSpaceMedium,
                      (widget.maternityinfo['temperature'] == null) || (widget.maternityinfo['temperature'] == '')
                          ? additionalInfoWidget(context, ' Temperature', '', imageItem('assets/bp.png'))
                          : additionalInfoWidget(context, ' Temperature', widget.maternityinfo['temperature'] + " °C", imageItem('assets/bp.png')),
                      //UIHelper.verticalSpaceSmall,
                      UIHelper.verticalSpaceMedium,
                      (widget.maternityinfo['spo2'] == null) || (widget.maternityinfo['spo2'] == '')
                          ? additionalInfoWidget(context, ' SpO2', '', imageItem('assets/bbgroup.png'))
                          : additionalInfoWidget(context, ' SpO2', widget.maternityinfo['spo2'] + " %", imageItem('assets/bbgroup.png')),
                      //UIHelper.verticalSpaceSmall,
                      UIHelper.verticalSpaceMedium,
                      additionalInfoWidget(
                        context,
                        'Doctor Name',
                        widget.maternityinfo['doctor_name'] ?? '',
                        Icon(
                          Icons.person_outlined,
                          color: activeColor,
                        ),
                      ),
                      //UIHelper.verticalSpaceSmall,
                      UIHelper.verticalSpaceMedium,
                      additionalInfoWidget(context, ' Clinic Name', widget.maternityinfo['clinic_name'] ?? '', imageItem('assets/clinic_name.png')),
                      //UIHelper.verticalSpaceSmall,
                      UIHelper.verticalSpaceMedium,
                      additionalInfoWidget(context, ' Note', widget.maternityinfo['note'] ?? '', imageItem('assets/apgr_rec_icon.png')),
                      UIHelper.verticalSpaceMedium,
                      additionalInfoWidget(context, ' File', attachFileName, imageItem('assets/attach_member.png')),
                    ],
                  ),
                ),
              )),
              UIHelper.verticalSpaceMedium,
            ])));
  }
}
