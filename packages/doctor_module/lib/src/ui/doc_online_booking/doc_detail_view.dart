import 'package:doctor_module/src/ui/doc_online_booking/doc_detail_view_model.dart';
import 'package:doctor_module/src/ui/doc_signup/doc_terms_view.dart';
import 'package:doctor_module/src/ui/doc_online_booking/top_specalities_view_model.dart';
import 'package:doctor_module/src/ui/doctor_profile/doctor_profile_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:stacked/stacked.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/services/preferences_service.dart';
import 'package:swarapp/shared/app_colors.dart';
import 'package:swarapp/shared/app_doctorprofile_bar.dart';
import 'package:swarapp/shared/app_static_bar.dart';
import 'package:swarapp/shared/custom_dialog_box.dart';
import 'package:swarapp/shared/dotted_line.dart';
import 'package:swarapp/shared/flutter_overlay_loader.dart';
import 'package:swarapp/shared/screen_size.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:swarapp/ui/startup/language_select_view.dart';
import 'package:swarapp/ui/startup/role_select_viewmodel.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:doctor_module/src/ui/doc_signup/role_select_view.dart';
import 'package:doctor_module/src/ui/doc_online_booking/doc_list_view.dart';
import 'package:doctor_module/src/ui/doc_online_booking/bookings_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pinch_zoom/pinch_zoom.dart';

class DoctorDetailView extends StatefulWidget {
  final String DoctorDetail;
  final String servicetype;
  DoctorDetailView({Key? key, required this.DoctorDetail, required this.servicetype}) : super(key: key);

  @override
  _DoctorDetailViewState createState() => _DoctorDetailViewState();
}

class _DoctorDetailViewState extends State<DoctorDetailView> {
  PreferencesService preferencesService = locator<PreferencesService>();
  TextEditingController searchController = TextEditingController();
  PageController sliderController = PageController(initialPage: 0, keepPage: false);

  void initState() {
    //await _prefs!.setString(prefUserLogin, cubeUser.login!);
    getStateLevel();
  }

  String selectedTab = '';
  int Tab_id = 3;
  bool select_personal = false;
  bool select_doc = false;
  int index = 1;
  String selectedDoc = '';
  dynamic levelStates = ['Entry', 'Enhanced', 'Verified', 'SWAR Dr.'];
  SharedPreferences? prefs;
  String gt = "";
  String start_year = '';
  String end_year = '';
  String workExperience = '';
  String network_img_url = '';
  List imageUrls = [];
  String medical_record = '';
  String Insurance = '';
  String Fees = '';
  String Discount = '';
  String final_amount = '';

  Widget ImageDialog(BuildContext context, String getImg) {
    String setImg = getImg;
    return Dialog(
        backgroundColor: Color.fromRGBO(105, 105, 105, 0.5),
        insetPadding: EdgeInsets.all(15),
        child: Container(
          child: Stack(
            // child: SingleChildScrollView(
            children: [
              PinchZoom(
                // image:DecorationImage(),
                image: Image.network(setImg),
                zoomedBackgroundColor: Colors.black.withOpacity(0.5),
                resetDuration: const Duration(milliseconds: 100),
                maxScale: 2.5,
                onZoomStart: () {
                  print('Start zooming');
                },
                onZoomEnd: () {
                  print('Stop zooming');
                },
              ),
              Positioned(
                right: 0.0,
                top: 0.5,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Align(
                    alignment: Alignment.topRight,
                    child: CircleAvatar(
                      radius: 14.0,
                      backgroundColor: Colors.red,
                      child: Icon(Icons.close, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  getStateLevel() async {
    String userId = '621c79e30c49b30033f5c649';
    // String chk = preferencesService.doctorInfo['_id'];
    await locator<ApiService>().getStageProfile(userId);
    prefs = await SharedPreferences.getInstance();
    gt = preferencesService.doctorStageValue.toString();
    //gt = prefs!.getString('profile_level') != null && prefs!.getString('profile_level')!.isNotEmpty ? prefs!.getString('profile_level')! : '';
    //levelStates
    // index = levelStates.indexWhere((item) => item.toLowerCase() == gt.toLowerCase());
    // preferencesService.stage_level_count = gt.isNotEmpty ? index + 1 : 0;
  }

  @override
  Widget addHeader(BuildContext context, bool isBackBtnVisible) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  Get.back();
                },
                child: Icon(
                  Icons.arrow_back,
                  size: 20,
                ),
              ),
              Text('Doctor Profile').fontSize(16).fontWeight(FontWeight.w600),
            ],
          ),
        ],
      ),
    );
  }

  Widget showSearchField(BuildContext context) {
    return SizedBox(
      height: 54,
      child: Container(
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 38,
                child: TextField(
                  controller: searchController,
                  onChanged: (value) {},
                  style: TextStyle(fontSize: 14),
                  decoration: new InputDecoration(
                    prefixIcon: Icon(
                      Icons.search,
                      color: activeColor,
                      size: 20,
                    ),
                    suffixIcon: searchController.text.isEmpty
                        ? SizedBox()
                        : IconButton(
                            icon: Icon(
                              Icons.cancel,
                              color: Colors.black38,
                            ),
                            onPressed: () {}),
                    contentPadding: EdgeInsets.only(left: 20),
                    enabledBorder: UIHelper.getInputBorder(0, radius: 8, borderColor: Color(0x00CCCCCC)),
                    focusedBorder: UIHelper.getInputBorder(0, radius: 8, borderColor: Color(0xFFCCCCCC)),
                    focusedErrorBorder: UIHelper.getInputBorder(0, radius: 8, borderColor: Color(0xFFCCCCCC)),
                    errorBorder: UIHelper.getInputBorder(0, radius: 8, borderColor: Color(0xFFCCCCCC)),
                    filled: true,
                    hintStyle: new TextStyle(color: Colors.grey[800]),
                    hintText: "Search a doctor by Specialty,City,Hospital name",
                  ),
                ),
              ),
            ),
            Icon(
              Icons.filter_alt_rounded,
            ),
          ],
        ),
      ),
    );
  }

  Widget aboutme(BuildContext context, DocDetailmodel model) {
    String startDate = '';
    String renewalDate = '';
    String expTitle = '';
    String expOrg = '';
    String arrClinicName = '';
    String arrClinicCity = '';
    String arrClinicId = '';
    String achieveName = '';
    String achieveOrg = '';
    String achieveIssueDate = '';
    String achieveRenewDate = '';
    String workExp = '';
    Jiffy endDate = Jiffy();
    String servisesStr = '';
    String medicalStr = '';
    String stateStr = '';
    String countryStr = '';
    String workStr = '';
    String clinicName = '';
    String clinicAddressName = '';
    String organization = '';
    String email = '';
    String phone = '';
    List<dynamic> morningDateList = [];
    List<dynamic> experienceList = [];
    List<dynamic> clinicList = [];
    List<dynamic> achievementInformation = [];
    List<dynamic> dateList = [];
    List<dynamic> stateList = [];
    String medicalRegister = '';

    if (model.doctor_details['doctor_services'] != null) {
      List al = model.doctor_details['doctor_services'];
      servisesStr = al.join('|');
    }
    // if (model.doctor_Info['medical_registaration'].isNotEmpty) {
    //   if (model.doctor_Info['medical_registaration'][0]['renewal_date'] != null) {
    //     end_date = Jiffy(model.doctor_Info['medical_registaration'][0]['renewal_date']);
    //   }
    // }

    if (model.doctor_Info['medical_registaration'].isNotEmpty) {
      if (model.doctor_Info['medical_registaration'][0]['organization'] != null) {
        String ml = model.doctor_Info['medical_registaration'][0]['organization'];
        medicalStr = ml;
      }
    }
    for (var i = 0; i < model.doctor_Info.length; i++) {
      for (var j = 0; j < model.doctor_Info['medical_registaration'].length; j++) {
        morningDateList.add(model.doctor_Info['medical_registaration'][j]);

        // if ((model.doctor_Info['medical_registaration'][j]['issue_date'] != null) || (model.doctor_Info['medical_registaration'][j]['issue_date'] != "")) {
        //   Jiffy start_ = Jiffy(model.doctor_Info['medical_registaration'][j]['issue_date']);
        //   date_list.add(start_.format('MMM.yyyy'));
        // }
      }

      break;
    }

    // for (var i = 0; i < morning_date_list.length; i++) {
    //   if (morning_date_list[i] != null) {
    //     medical_register = morning_date_list[i]['certificate'][0];
    //   }
    // }

    // if (morning_date_list[0]['certificate'][0] != null) {
    //   imageUrls = 'm${ApiService.fileStorageEndPoint}${morning_date_list[0]['certificate'][0]}';
    // }
    if (model.doctor_Info['medical_registaration'].isNotEmpty) {
      if (model.doctor_Info['medical_registaration'][0]['country'] != null) {
        String cl = model.doctor_Info['medical_registaration'][0]['country'];
        countryStr = cl;
      }
    }
    for (var i = 0; i < model.doctor_Info.length; i++) {
      for (var j = 0; j < model.doctor_Info['experience'].length; j++) {
        experienceList.add(model.doctor_Info['experience'][j]);

        if (model.doctor_Info['experience'][j]['startyear'] != null && model.doctor_Info['experience'][j]['startyear'] != "") {
          Jiffy dt = Jiffy(model.doctor_Info['experience'][j]['startyear']);
          start_year = dt.format('yyyy');
        }

        // if ((model.doctor_Info['medical_registaration'][j]['issue_date'] != null) || (model.doctor_Info['medical_registaration'][j]['issue_date'] != "")) {
        //   Jiffy start_ = Jiffy(model.doctor_Info['medical_registaration'][j]['issue_date']);
        //   date_list.add(start_.format('MMM.yyyy'));
        // }
      }

      break;
    }

    for (var i = 0; i < model.doctor_Info.length; i++) {
      for (var j = 0; j < model.doctor_Info['clinic_details'].length; j++) {
        clinicList.add(model.doctor_Info['clinic_details'][j]);
      }
      break;
    }

    for (var i = 0; i < model.doctor_Info['services'].length; i++) {
      if (model.doctor_Info['services'][i]['services_type'] == widget.servicetype) {
        Fees = model.doctor_Info['services'][i]['fees'];
        print('feesss' + Fees.toString());
      }
      if (model.doctor_Info['services'][i]['services_type'] == widget.servicetype) {
        Discount = model.doctor_Info['services'][i]['discount'];
        print('feesss' + Discount.toString());
      }
      if (model.doctor_Info['services'][i]['services_type'] == widget.servicetype) {
        final_amount = model.doctor_Info['services'][i]['final_amount'];
        preferencesService.Final_amount = model.doctor_Info['services'][i]['final_amount'];
        print('feesss' + final_amount.toString());
      }
    }

    for (var i = 0; i < model.doctor_Info.length; i++) {
      for (var j = 0; j < model.doctor_Info['achievement_information'].length; j++) {
        achievementInformation.add(model.doctor_Info['achievement_information'][j]);
      }
      break;
    }
    if (model.doctor_Info['experience'].isNotEmpty) {
      if (model.doctor_Info['experience'][0]['title'] != null) {
        String expl = model.doctor_Info['experience'][0]['title'];
        workStr = expl;
      }
    }
    if (model.doctor_Info['clinic_details'].isNotEmpty) {
      if (model.doctor_Info['clinic_details'][0]['clinic_name'] != null) {
        String clinic = model.doctor_Info['clinic_details'][0]['clinic_name'];
        clinicName = clinic;
      }
      if (model.doctor_Info['clinic_details'][0]['address'] != null) {
        String clinicAddress = model.doctor_Info['clinic_details'][0]['address'];
        clinicAddressName = clinicAddress;
      }
    }
    if (model.doctor_Info['achievement_information'].isNotEmpty) {
      if (model.doctor_Info['achievement_information'][0]['organization'] != null) {
        String doctAchievement = model.doctor_Info['achievement_information'][0]['organization'];
        organization = doctAchievement;
      }
    }

    if (model.doctor_details['email'] != null) {
      String docEmail = model.doctor_details['email'];
      email = docEmail;
    }

    if (model.doctor_details['mobilenumber'] != null) {
      String docPhone = model.doctor_details['mobilenumber'];
      phone = docPhone;
    }
    if (model.doctor_Info['experience'].isNotEmpty) {
      if (model.doctor_Info['experience'][0]['endyear'] != null && model.doctor_Info['experience'][0]['endyear'] != "") {
        Jiffy dt = Jiffy(model.doctor_Info['experience'][0]['endyear']);
        end_year = dt.format('yyyy');
      }
      if (model.doctor_Info['experience'][0]['work_experience'] != null && model.doctor_Info['experience'][0]['work_experience'] != "") {
        int experInt = int.parse(model.doctor_Info['experience'][0]['work_experience']);
        if (experInt < 12) {
          workExperience = '$experInt  month';
        } else {
          double exper = experInt / 12;
          String workExperience = exper.toStringAsFixed(2).toString();
          workExperience = '$workExperience year';
        }
      }
    }

    if ((model.doctor_Info['medical_registaration'][0]['issue_date'] != "")) {
      Jiffy start_ = Jiffy(model.doctor_Info['medical_registaration'][0]['issue_date']);
      startDate = start_.format('MMM.yyyy');
    }
    if ((model.doctor_Info['medical_registaration'][0]['renewal_date'] != "")) {
      Jiffy start_ = Jiffy(model.doctor_Info['medical_registaration'][0]['renewal_date']);
      renewalDate = start_.format('MMM.yyyy');
    }

    if (model.doctor_Info['experience'].length > 0) {
      if (model.doctor_Info['experience'][0]['title'] != "") {
        expTitle = model.doctor_Info['experience'][0]['title'];
      }

      if (model.doctor_Info['experience'][0]['organization'] != "") {
        expOrg = model.doctor_Info['experience'][0]['organization'];
      }
    }

    if (model.doctor_Info['clinic_details'].length > 0) {
      if (model.doctor_Info['clinic_details'][0]['clinic_name'] != "") {
        arrClinicName = model.doctor_Info['clinic_details'][0]['clinic_name'];
      }

      if (model.doctor_Info['clinic_details'][0]['address'] != "") {
        arrClinicCity = model.doctor_Info['clinic_details'][0]['address'];
      }

      if (model.doctor_Info['clinic_details'][0]['Information_Id'] != "") {
        arrClinicId = model.doctor_Info['clinic_details'][0]['Information_Id'];
      }
    }

    if (model.doctor_Info['achievement_information'].length > 0) {
      if (model.doctor_Info['achievement_information'][0]['name'] != "") {
        achieveName = model.doctor_Info['achievement_information'][0]['name'];
      }

      if (model.doctor_Info['achievement_information'][0]['organization'] != "") {
        achieveOrg = model.doctor_Info['achievement_information'][0]['organization'];
      }

      if (model.doctor_Info['achievement_information'][0]['issue_date'] != "") {
        Jiffy firstDate = Jiffy(model.doctor_Info['achievement_information'][0]['issue_date']);
        achieveIssueDate = firstDate.format('MMM.yyyy');
      }

      if (model.doctor_Info['achievement_information'][0]['renewal_date'] != "") {
        Jiffy renewDate = Jiffy(model.doctor_Info['achievement_information'][0]['renewal_date']);
        achieveRenewDate = renewDate.format('MMM.yyyy');
      }
    }

    return Container(
      padding: EdgeInsets.all(4),
      width: Screen.width(context) - 32,
      decoration: UIHelper.allcornerRadiuswithbottomShadow(12, 12, 12, 12, Colors.white),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Services').bold().fontSize(15),
            UIHelper.verticalSpaceTiny,
            Text(servisesStr).fontSize(13),
            // Row(children: [
            //   Text(model.doctor_details['doctor_services'][0] != null ? model.doctor_details['doctor_services'][0] + '|' : "").fontSize(13),
            //   Text(model.doctor_details['doctor_services'][1] != null ? model.doctor_details['doctor_services'][1] + '|' : "").fontSize(13),
            //   Text(model.doctor_details['doctor_services'][2] != null ? model.doctor_details['doctor_services'][2] + '|' : "").fontSize(13),
            //   Text(model.doctor_details['doctor_services'][3] != null || model.doctor_details['doctor_services'][3] != "" ? model.doctor_details['doctor_services'][3] + '|' : "").fontSize(13),
            //   // Text(model.doctor_details['doctor_services'][3] != null || model.doctor_details['doctor_services'][3] != "" ? model.doctor_details['doctor_services'][3] + '|' : "").fontSize(13),
            // ]),

            // Text(model.getUserdetail['doctor_services'][0]),
            // Text(model.doctor_Info['educational_information'][0]['specializations'][0] != null ? model.doctor_Info['educational_information'][0]['specializations'][0] : "")
            // Text('Home visit | Video consultation | In clinic').fontSize(13),
            Row(
              children: [
                // Text(model.getUserdetail)
              ],
            ),
            UIHelper.hairLineWidget(),
            Text('About me').bold().fontSize(15),
            UIHelper.verticalSpaceTiny,
            Text(model.doctor_details['aboutme'] != null ? model.doctor_details['aboutme'] : "").fontSize(13),
            UIHelper.hairLineWidget(),
            Row(
              children: [
                Text('Medical Registration / License').bold().fontSize(15),
                UIHelper.horizontalSpaceSmall,
              ],
            ),
            Column(
              children: [
                Row(children: [
                  Text(medicalStr + '' + stateStr + '' + countryStr).fontSize(13),
                ]),
              ],
            ),
            // GestureDetector(
            //   // onTap: () async {
            //   //   await showDialog(
            //   //       context: context,
            //   //       //https://swarstage.blob.core.windows.net/swardoctor/scaled_image_picker8539268485450644726_1621533729545.jpg
            //   //       builder: (_) => ImageDialog(context, medical_register));
            //   // },

            // ),

            Column(children: [
              ListView.builder(
                  itemCount: morningDateList.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        Row(
                          children: [
                            Text(morningDateList[index]['organization'] != null ? morningDateList[index]['organization'] : ""),
                            Text(morningDateList[index]['organization'] != "" ? ' ' + morningDateList[index]['state'] : morningDateList[index]['state']),
                            Text(morningDateList[index]['organization'] != "" ? ' ' + morningDateList[index]['country'] : morningDateList[index]['country']),
                            UIHelper.horizontalSpaceMedium,
                            Container(
                              height: 40,
                              width: 40,
                              decoration: UIHelper.allcornerRadiuswithbottomShadow(0, 0, 6, 6, fieldBgColor),
                              child: Icon(
                                Icons.description_outlined,
                                color: Colors.black38,
                              ),
                            ),
                            // Text(morning_date_list[index]['issue_date'] != "" ? morning_date_list[index]['issue_date'] : ""),
                          ],
                        ),
                        Row(
                          children: [
                            Text(startDate != '' ? startDate : ''),
                            UIHelper.horizontalSpaceTiny,
                            Text(renewalDate != '' ? ' To  ' + renewalDate : ''),
                          ],
                        )
                      ],
                    );
                  }),
            ]),

            UIHelper.hairLineWidget(),
            Text('Work experience').bold().fontSize(15),
            UIHelper.verticalSpaceTiny,
            Column(children: [
              ListView.builder(
                  itemCount: experienceList.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        Row(
                          children: [
                            Text(expTitle != '' ? expTitle : ''),
                            Text(expOrg != '' && expOrg != null ? ' | ' + expOrg : '')
                            // Text(morning_date_list[index]['issue_date'] != "" ? morning_date_list[index]['issue_date'] : ""),
                          ],
                        )
                      ],
                    );
                  }),
            ]),
            // Text(model.)
            UIHelper.hairLineWidget(),
            Text('Clinic ').bold().fontSize(15),
            UIHelper.verticalSpaceTiny,
            Column(children: [
              ListView.builder(
                  itemCount: clinicList.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        Row(
                          children: [Text(arrClinicName != '' ? arrClinicName : ''), Text(arrClinicCity != '' ? ' | ' + arrClinicCity : ''), Text(arrClinicId != '' ? ' | ' + arrClinicId.toString() : '')],
                        )
                      ],
                    );
                  }),
            ]),
            UIHelper.hairLineWidget(),
            Text('Achievement').bold().fontSize(15),
            UIHelper.verticalSpaceTiny,
            Column(children: [
              ListView.builder(
                  itemCount: achievementInformation.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        Row(
                          //                        if ((model.doctor_Info['medical_registaration'][0]['issue_date'] != null) || (model.doctor_Info['medical_registaration'][0]['issue_date'] != "")) {
                          //   Jiffy start_ = Jiffy(model.doctor_Info['medical_registaration'][0]['issue_date']);
                          //   start_date = start_.format('MMM.yyyy');
                          // }String achieve_name = '';
                          // String achieve_org = '';
                          // String achieve_issue_date = '';
                          // String achieve_renew_date = '';
                          children: [
                            Text(achieveName != '' ? achieveName : ''),
                            Text(achieveIssueDate != '' ? achieveIssueDate : ''),
                            Text(achieveRenewDate != '' ? ' To ' + achieveIssueDate : ''),
                            Text(achieveOrg != '' ? ' | ' + achieveOrg : ''),
                          ],
                        )
                      ],
                    );
                  }),
            ]),
            // Text('SWAR | Mar.2021 To Mar.2022 | we.').fontSize(13),
            Text(organization).fontSize(13),
            UIHelper.hairLineWidget(),
            Text('Contact info').bold().fontSize(15),
            UIHelper.verticalSpaceTiny,
            Text(email + '   ' + phone).fontSize(13),
            // ext('Sam@gmail.com | 9034234234234 |').fontSize(13),
            UIHelper.verticalSpaceTiny,
          ],
        ),
      ),
    );
  }

  Widget nurseList(BuildContext context, DocDetailmodel model) {
    if (model.doctor_details['azureBlobStorageLink'] != null) {
      network_img_url = '${ApiService.fileStorageEndPoint}${model.doctor_details['azureBlobStorageLink']}';
    }
    if ((model.doctor_Info['insurance'] != null) && (model.doctor_Info['insurance'].length > 0)) {
      if (model.doctor_Info['insurance'][0] != "") {
        Insurance = model.doctor_Info['insurance'][0];
      }
    }

    String Qualification = '';
    if (model.doctor_Info['educational_information'].length > 0) {
      for (int i = 0; model.doctor_Info['educational_information'].length > i; i++) {
        var qua = model.doctor_Info['educational_information'][i]['qualification'];
        if (qua != "" && qua != null) {
          Qualification != '' ? Qualification = Qualification + ',' + qua.toString() : Qualification = qua.toString();
        }
      }
    }

    return GestureDetector(
      onTap: () {
        DoctorProfileView();
      },
      child: Container(
          padding: EdgeInsets.all(4),
          width: Screen.width(context) - 30,
          decoration: UIHelper.allcornerRadiuswithbottomShadow(12, 12, 12, 12, Colors.white),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(children: [
                network_img_url == ''
                    ? Container(
                        height: 90,
                        width: 70,
                        decoration: UIHelper.allcornerRadiuswithbottomShadow(2, 2, 2, 2, fieldBgColor),
                        child: Icon(
                          Icons.account_circle,
                          color: Colors.black38,
                        ),
                      )
                    : UIHelper.getImage(network_img_url, 70, 90),
                model.doctor_Info['stage'] == "verified"
                    ? Container(
                        height: 20,
                        width: 70,
                        decoration: UIHelper.allcornerRadiuswithbottomShadow(0, 0, 6, 6, img_badgeColor),
                        child: Text('Verified').fontSize(13.8).bold().textColor(Colors.white).textAlignment(TextAlign.center))
                    : model.doctor_Info['stage'] == "Enhanced"
                        ? Container(
                            height: 20,
                            width: 70,
                            decoration: UIHelper.allcornerRadiuswithbottomShadow(0, 0, 6, 6, img_badgeColor),
                            child: Text('Enhanced').fontSize(12.8).bold().textColor(Colors.white).textAlignment(TextAlign.center))
                        : Container(
                            height: 30,
                            width: 70,
                            decoration: UIHelper.allcornerRadiuswithbottomShadow(0, 0, 6, 6, activeColor),
                            child: Text('SWAR Doctor').fontSize(12.8).bold().textColor(Colors.white).textAlignment(TextAlign.center))
                // model.doctor_Info['stage'] == "verified"
                //     ? Container(height: 20, width: 70, decoration: UIHelper.allcornerRadiuswithbottomShadow(0, 0, 6, 6, img_badgeColor), child: Text('  Verified ').fontSize(15.8).bold().textColor(Colors.white))
                //     : Container(child: Text(""))
              ]),
              UIHelper.horizontalSpaceSmall,
              UIHelper.verticalSpaceSmall,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(model.doctor_details['name'] != null ? model.doctor_details['name'] : "").fontSize(12).fontWeight(FontWeight.w600),
                  UIHelper.verticalSpaceTiny,
                  // Text(
                  //'General physician, 5 years exp').fontSize(12).fontWeight(FontWeight.w600).textColor(Colors.black38),
                  Row(
                    children: [
                      Row(
                        children: [
                          model.doctor_details['specialization'].isNotEmpty
                              ? Text(model.doctor_details['specialization'][0] != null ? model.doctor_details['specialization'][0] : "").fontSize(12).fontWeight(FontWeight.w600).textColor(Colors.black38)
                              : Text('').fontSize(12).fontWeight(FontWeight.w600).textColor(Colors.black38)
                        ],
                      ),
                      Row(
                        children: [Text(workExperience != null ? ' ' + workExperience + ' exp' : "").fontSize(12).fontWeight(FontWeight.w600).textColor(Colors.black38)],
                      ),
                    ],
                  ),

                  UIHelper.horizontalSpaceSmall,
                  UIHelper.verticalSpaceSmall,
                  // Text('M.B.B.S, Diploma - Family Medicine').fontSize(9).fontWeight(FontWeight.w300).bold(),

                  Text(Qualification).fontSize(9).fontWeight(FontWeight.w300).bold(),
                  Container(
                    width: 170,
                    decoration: UIHelper.allcornerRadiuswithbottomShadow(6, 6, 6, 6, Colors.white),
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Container(
                          child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20, left: 15, right: 0, top: 10),
                            child: DottedLine(
                              dashColor: Colors.red,
                              lineThickness: 2,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                children: [
                                  model.doctor_Info['stage'] == 'verified'
                                      ? Row(children: [
                                          Container(
                                              width: 21, height: 21, decoration: UIHelper.roundedLineBorderWithColor(16, Colors.green, 1, borderColor: Colors.red), child: Icon(Icons.done, size: 12, color: Colors.white)),
                                          UIHelper.horizontalSpaceMedium,
                                          Container(
                                              width: 21, height: 21, decoration: UIHelper.roundedLineBorderWithColor(16, Colors.green, 1, borderColor: Colors.red), child: Icon(Icons.done, size: 12, color: Colors.white)),
                                          UIHelper.horizontalSpaceMedium,
                                          Container(
                                              width: 21, height: 21, decoration: UIHelper.roundedLineBorderWithColor(16, Colors.green, 1, borderColor: Colors.red), child: Icon(Icons.done, size: 12, color: Colors.white)),
                                          UIHelper.horizontalSpaceMedium,
                                          Container(width: 21, height: 21, decoration: UIHelper.roundedLineBorderWithColor(16, subtleColor, 1, borderColor: Colors.red)),
                                        ])
                                      : Row(children: [
                                          Container(
                                              width: 21, height: 21, decoration: UIHelper.roundedLineBorderWithColor(16, Colors.green, 1, borderColor: Colors.red), child: Icon(Icons.done, size: 12, color: Colors.white)),
                                          UIHelper.horizontalSpaceMedium,
                                          Container(
                                              width: 21, height: 21, decoration: UIHelper.roundedLineBorderWithColor(16, Colors.green, 1, borderColor: Colors.red), child: Icon(Icons.done, size: 12, color: Colors.white)),
                                          UIHelper.horizontalSpaceMedium,
                                          Container(width: 21, height: 21, decoration: UIHelper.roundedLineBorderWithColor(16, subtleColor, 1, borderColor: Colors.red)),
                                          UIHelper.horizontalSpaceMedium,
                                          Container(width: 21, height: 21, decoration: UIHelper.roundedLineBorderWithColor(16, subtleColor, 1, borderColor: Colors.red)),
                                        ]),

                                  //Container(width: 32, height: 32, decoration: UIHelper.roundedLineBorderWithColor(16, subtleColor, 1, borderColor: Colors.red)), Text(state).fontWeight(FontWeight.w600)
                                  //state == gt
                                  // preferencesService.stage_level_count! == i || preferencesService.stage_level_count! > i
                                  //     ? Container(
                                  //         width: 21, height: 21, decoration: UIHelper.roundedLineBorderWithColor(16, Colors.green, 1, borderColor: Colors.red), child: Icon(Icons.done, size: 12, color: Colors.white))
                                  //     : Container(width: 21, height: 21, decoration: UIHelper.roundedLineBorderWithColor(16, subtleColor, 1, borderColor: Colors.red)),
                                  //levelStates  dynamic levelStates = ['Entry', 'Enhanced', 'Verified', 'SWAR Dr.'];
                                  Row(
                                    children: [
                                      Text('Entry').fontWeight(FontWeight.w600).fontSize(10),
                                      Text('Enhanced').fontWeight(FontWeight.w600).fontSize(10),
                                      Text('Verified').fontWeight(FontWeight.w600).fontSize(10),
                                      Text('SWAR Dr.').fontWeight(FontWeight.w600).fontSize(10)
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      )),
                    ),
                  ),
//                   UIHelper.verticalSpaceVeryLarge,

//                   Container(
//                     width: 150,
//                     height: 30,
//                     decoration: UIHelper.allcornerRadiuswithbottomShadow(6, 6, 6, 6, Colors.white),
//                     child: StreamBuilder<String?>(
//                         stream: locator<PreferencesService>().doctorStageValue!.outStream,
//                         builder: (context, snapshot) {
//                           if (snapshot.data != null && snapshot.data != "") {
//                             index = levelStates.indexWhere((item) => item.toLowerCase() == snapshot!.data!.toLowerCase());
//                             preferencesService.stage_level_count = index + 1;
//                             return Container(
//                                 decoration: UIHelper.roundedBorderWithColorWithShadow(6, Colors.white),
//                                 child: Column(children: [
//                                   UIHelper.verticalSpaceSmall,
//                                   Row(
//                                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                     children: [
//                                       Padding(
//                                         padding: const EdgeInsets.all(5.0),
//                                         child: Expanded(
//                                             child: Stack(
//                                           children: [
//                                             Padding(
//                                               padding: const EdgeInsets.only(bottom: 20, left: 15, right: 0, top: 10),
//                                               child: DottedLine(
//                                                 dashColor: Colors.red,
//                                                 lineThickness: 2,
//                                               ),
//                                             ),
//                                             Row(
//                                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                               children: [
//                                                 for (int i = 1; i <= 4; i++)
//                                                   Column(
//                                                     children: [
//                                                       //Container(width: 32, height: 32, decoration: UIHelper.roundedLineBorderWithColor(16, subtleColor, 1, borderColor: Colors.red)), Text(state).fontWeight(FontWeight.w600)
//                                                       //state == gt
//                                                       preferencesService.stage_level_count! == i || preferencesService.stage_level_count! > i
//                                                           ? Container(
//                                                               width: 12,
//                                                               height: 12,
//                                                               decoration: UIHelper.roundedLineBorderWithColor(16, Colors.green, 1, borderColor: Colors.red),
//                                                               child: Icon(Icons.done, size: 12, color: Colors.white))
//                                                           : Container(width: 12, height: 12, decoration: UIHelper.roundedLineBorderWithColor(16, subtleColor, 1, borderColor: Colors.red)),
//                                                       //levelStates
//                                                       Text(levelStates[i - 1]).fontWeight(FontWeight.w600).fontSize(12)
//                                                     ],
//                                                   ),
//                                               ],
//                                             ),
//                                           ],
//                                         )),
//                                       ),
//                                       SizedBox(
//                                         width: 9,
//                                       ),
//                                     ],
//                                   )
//                                 ]));
//                           } else {
//                             return Container(
//                                 decoration: UIHelper.roundedBorderWithColorWithShadow(6, Colors.white),
//                                 padding: EdgeInsets.all(12),
//                                 child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                                   Row(
//                                     crossAxisAlignment: CrossAxisAlignment.center,
//                                     children: [
//                                       SizedBox(
//                                         width: 15,
//                                       ),
//                                       Expanded(
//                                           child: Stack(
//                                         children: [
//                                           Padding(
//                                             padding: const EdgeInsets.only(bottom: 15, left: 15, right: 25, top: 15),
//                                             child: DottedLine(
//                                               dashColor: Colors.red,
//                                               lineThickness: 2,
//                                             ),
//                                           ),
//                                           Row(
//                                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                             children: [
// //                      for (var state in levelStates)
//                                               for (int i = 1; i <= 4; i++)
//                                                 Column(
//                                                   children: [
//                                                     //Container(width: 32, height: 32, decoration: UIHelper.roundedLineBorderWithColor(16, subtleColor, 1, borderColor: Colors.red)), Text(state).fontWeight(FontWeight.w600)
//                                                     //state == gt

//                                                     Container(width: 32, height: 32, decoration: UIHelper.roundedLineBorderWithColor(16, subtleColor, 1, borderColor: Colors.red)),
//                                                     //levelStates
//                                                     Text(levelStates[i - 1]).fontWeight(FontWeight.w600).fontSize(12)
//                                                   ],
//                                                 ),
//                                             ],
//                                           ),
//                                         ],
//                                       )),
//                                       SizedBox(
//                                         width: 30,
//                                       ),
//                                     ],
//                                   )
//                                 ]));
//                           }
//                         }),
//                   ),
                ],
              ),
              UIHelper.horizontalSpaceSmall,
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Patients visit').fontSize(10),
                      UIHelper.horizontalSpaceSmall,
                      Text('1.5K').fontSize(12).fontWeight(FontWeight.w500).textColor(activeColor),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      UIHelper.horizontalSpaceMedium,
                      Icon(
                        Icons.star_purple500_sharp,
                        color: goldenColor,
                        size: 20,
                      ),
                      Text(' 4.0').fontSize(12).fontWeight(FontWeight.w500).textColor(activeColor),
                    ],
                  ),
                  UIHelper.verticalSpaceSmall,
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: UIHelper.allcornerRadiuswithbottomShadow(6, 6, 6, 6, Colors.white),
                      child: Column(
                        children: [
                          Text('Languages').fontSize(10),
                          UIHelper.verticalSpaceTiny,
                          // Text('English, Tamil, \n      Telugu').fontSize(9).fontWeight(FontWeight.w800),
                          Column(children: [
                            for (var lang in model.doctor_details['language_known'])
                              Text(
                                lang != null ? lang : '',
                                maxLines: 1,
                                softWrap: false,
                                overflow: TextOverflow.fade,
                              ).fontSize(12).fontWeight(FontWeight.w600).textColor(Colors.black38),
                          ]),
                        ],
                      ),
                    ),
                  ),
                  // UIHelper.verticalSpaceSmall,
                  // Text(final_amount != "" ? 'Discount %' : ''),
                  // final_amount != ""
                  //     ? Row(
                  //         children: [
                  //           Text(Fees,
                  //               style: TextStyle(
                  //                 decoration: TextDecoration.lineThrough,
                  //               )).textColor(Colors.black38),
                  //           UIHelper.horizontalSpaceTiny,
                  //           Text('₹' + final_amount).textColor(activeColor),
                  //         ],
                  //       )
                  //     : Text(''),
                ],
              ),
            ],
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SwarAppStaticBar(),
      backgroundColor: Colors.white,
      body: Container(
        padding: EdgeInsets.all(12),
        child: ViewModelBuilder<DocDetailmodel>.reactive(
            onModelReady: (model) async {
              await model.getUserProfile();
              await model.getUserdetail();
            },
            builder: (context, model, child) {
              return model.isBusy
                  ? Center(
                      child: UIHelper.swarPreloader(),
                    )
                  : SingleChildScrollView(
                      child: Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            addHeader(context, true),
                            UIHelper.verticalSpaceSmall,
                            nurseList(context, model),
                            UIHelper.verticalSpaceSmall,
                            aboutme(context, model),
                            UIHelper.verticalSpaceMedium,
                            ElevatedButton(
                                onPressed: () async {
                                  selectedDoc = preferencesService.selected_doctor_id;
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => BookAppointmentView(BookingInfo: selectedDoc, servicetype: widget.servicetype)),
                                  );
                                },
                                child: Text('Book  Appointment').fontSize(15).textColor(Colors.white),
                                style: ButtonStyle(
                                    minimumSize: MaterialStateProperty.all(Size(65, 40)),
                                    backgroundColor: MaterialStateProperty.all(activeColor),
                                    shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))))),
                          ],
                        ),
                      ),
                    );
            },
            viewModelBuilder: () => DocDetailmodel()),
      ),
    );
  }
}
