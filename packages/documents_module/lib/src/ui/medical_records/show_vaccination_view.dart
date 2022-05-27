import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:swarapp/shared/app_colors.dart';
import 'package:swarapp/shared/app_static_bar.dart';
import 'package:swarapp/shared/screen_size.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:get/get.dart';
import 'package:swarapp/ui/startup/terms_view.dart';
import 'add_vaccination_view.dart';
import 'edit_vaccination_view.dart';

class ShowVaccinationView extends StatefulWidget {
  // dynamic vaccineData;
  dynamic vaccineData;
  dynamic userVaccineData;
  String docId;
  bool date_is_empty;

  ShowVaccinationView({Key? key, this.vaccineData, this.userVaccineData, required this.docId, required this.date_is_empty}) : super(key: key);

  @override
  _ShowVaccinationViewState createState() => _ShowVaccinationViewState();
}

class _ShowVaccinationViewState extends State<ShowVaccinationView> {
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
                    Get.back(result: {'refresh': true});
                  },
                  // child: Icon(
                  //   Icons.arrow_back_ios,
                  //   size: 20,
                  // ),
                  child: Image.asset('assets/arrow_back_chat.png'),
                )
              : SizedBox(),
          Text(' Vaccination').bold().fontSize(16),
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
    String attachFileName = '';
    //String age = preferencesService.dropdown_userInfo['age'].toString();
    // String age= preferencesService.dropdown_userInfo['age'].toString();
    String age = preferencesService.dropdown_user_age;

    // if (widget.vaccineData['attach_record'] != null && widget.vaccineData['attach_record'] != "") {
    //   attach_file_name = widget.vaccineData['attach_record'].contains('/') ? widget.vaccineData['attach_record'].split('/').last : widget.vaccineData['attach_record'];
    // } else {
    //   attach_file_name = "";
    // }

    if (widget.vaccineData['vaccine_date'] == null) {
      nextDate = "";
    } else if (widget.vaccineData['vaccine_date'] != "") {
      Jiffy nextdate = Jiffy(widget.vaccineData['vaccine_date']);

      nextDate = nextdate.format('dd/MM/yyyy');
    }

    if (widget.vaccineData['date'] == null) {
      givenDateStr = "";
    } else if (widget.vaccineData['date'] != "") {
      Jiffy givendate = Jiffy(widget.vaccineData['date']);
      givenDateStr = givendate.format('dd/MM/yyyy');
    }

    if (preferencesService.dropdown_user_dob != "") {
      // Jiffy date_birth = Jiffy( preferencesService.dropdown_user_dob);
      // dob = date_birth.format('dd/MM/yyyy');
      dob = preferencesService.dropdown_user_dob;
    } else if (preferencesService.dropdown_user_dob == null || preferencesService.dropdown_user_dob == "") {
      dob = "";
    }
    String vaccineStatus = '';

    widget.vaccineData['status'] == true ? vaccineStatus = "Yes" : vaccineStatus = "No";

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
                  UIHelper.addHeader(context, "Vaccination", true),
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
                                  await Get.to(() => AddVaccinationView(
                                        vaccineData: widget.vaccineData,
                                        userVaccineData: widget.userVaccineData,
                                        docId: widget.docId,
                                        date_is_empty: false,
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

                          // additionalInfoWidget(context, 'Age', age , imageItem('assets/age_icon.png')),
                          // UIHelper.verticalSpaceSmall,
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
                          additionalInfoWidget(context, 'Vaccine date', givenDateStr, imageItem('assets/vacdate.png')),
                          UIHelper.verticalSpaceMedium,
                          (widget.vaccineData['height'] == null) || (widget.vaccineData['height'] == '')
                              ? additionalInfoWidget(context, 'Height', '', imageItem('assets/apgr_rec_icon.png'))
                              : additionalInfoWidget(context, 'Height', widget.vaccineData['height'] + ' Cm' ?? '', imageItem('assets/apgr_rec_icon.png')),
                          UIHelper.verticalSpaceMedium,
                          (widget.vaccineData['weight'] == null) || (widget.vaccineData['weight'] == '')
                              ? additionalInfoWidget(context, 'Weight', '', imageItem('assets/bweight.png'))
                              : additionalInfoWidget(context, 'Weight', widget.vaccineData['weight'] + ' Kg' ?? '', imageItem('assets/bweight.png')),
                          UIHelper.verticalSpaceMedium,
                          (widget.vaccineData['temperature'] == null) || (widget.vaccineData['temperature'] == '')
                              ? additionalInfoWidget(context, ' Temperature', '', imageItem('assets/apgr_rec_icon.png'))
                              : additionalInfoWidget(context, ' Temperature', widget.vaccineData['temperature'] + ' °C' ?? '', imageItem('assets/apgr_rec_icon.png')),
                          UIHelper.verticalSpaceMedium,
                          (widget.vaccineData['spo2'] == null) || (widget.vaccineData['spo2'] == '')
                              ? additionalInfoWidget(context, '   SpO2', '', imageItem('assets/mbgroup.png'))
                              : additionalInfoWidget(context, '   SpO2', widget.vaccineData['spo2'] + ' %' ?? '', imageItem('assets/mbgroup.png')),
                          UIHelper.verticalSpaceMedium,
                          (widget.vaccineData['blood_pressure'] == null) || (widget.vaccineData['blood_pressure'] == '')
                              ? additionalInfoWidget(context, '   Blood pressure', '', imageItem('assets/mbgroup.png'))
                              : additionalInfoWidget(context, '   Blood pressure', widget.vaccineData['blood_pressure'] + ' mmHg' ?? '', imageItem('assets/mbgroup.png')),
                          UIHelper.verticalSpaceMedium,
                          additionalInfoWidget(context, '   Notes', widget.vaccineData['notes'] ?? '', imageItem('assets/mr_icon.png')),
                          UIHelper.verticalSpaceMedium,
                         // additionalInfoWidget(context, '   File', attach_file_name, imageItem('assets/attach_member.png')),
                         // UIHelper.verticalSpaceMedium,
                        ],
                      ),
                    ),
                  )),
                  UIHelper.verticalSpaceMedium,
                ]))));
  }
}
