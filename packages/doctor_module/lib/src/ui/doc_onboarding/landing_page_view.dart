import 'package:doctor_module/src/ui/doc_appoinment/doctor_appoinment.view.dart';
import 'package:doctor_module/src/ui/doc_availability/manage_availability_view.dart';
import 'package:doctor_module/src/ui/doc_offers/manage_offers_view.dart';
import 'package:doctor_module/src/ui/doctor_profile/doctor_declaration_view.dart';
import 'package:doctor_module/src/ui/doctor_profile/doctor_profile_view.dart';
import 'package:doctor_module/src/ui/doc_appoinment/manage_vacation_view.dart';
import 'package:doctor_module/src/ui/patient/patients_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/services/preferences_service.dart';
import 'package:swarapp/shared/app_doctorprofile_bar.dart';
import 'package:swarapp/shared/app_colors.dart';
import 'package:swarapp/shared/custom_dialog_box.dart';
import 'package:swarapp/shared/dotted_line.dart';
import 'package:swarapp/shared/profileStage_widget_view.dart';
import 'package:swarapp/shared/screen_size.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:swarapp/ui/startup/terms_view.dart';

class ProviderLandingView extends StatefulWidget {
  const ProviderLandingView({Key? key}) : super(key: key);

  @override
  _ProviderLandingViewState createState() => _ProviderLandingViewState();
}

class _ProviderLandingViewState extends State<ProviderLandingView> {
  TextEditingController searchController = TextEditingController();
  late CustomDialogBox dialogRef;
  bool isAllow = false;
  ApiService apiService = locator<ApiService>();
  List<dynamic> formtype = [
    [
      {"containertype": "1", "container_name": "patients", "stagetitle": " Your Patients\n", "assetImage": "assets/patients.png"},
      {"containertype": "2", "container_name": "manage_appointment", "stagetitle": " Manage\n Appoinments", "assetImage": "assets/appoinment.png"},
    ],
    [
      {"containertype": "3", "container_name": "profile", "stagetitle": " Profile\n", "assetImage": "assets/doctor_profile.png"},
      {"containertype": "4", "container_name": "fees_offers", "stagetitle": " Manage\n Fees and Offers", "assetImage": "assets/offer.png"},
    ]
  ];
  List<dynamic> bottom_manage_bar = [
    {"containertype": "5", "container_name": "availability", "stagetitle": "Manage Availability", "barImage": "assets/vacation.png"},
    {"containertype": "6", "container_name": "subscription", "stagetitle": "Manage Subscription & contract\n with SWAR Doctor LLC", "barImage": "assets/swar_logo.png"},
  ];
  Map<String, Color> bgContainerColor = {"1": Color(0xFFC1FF99), "2": Color(0xFFFFE8AC), "3": Color(0xFFB0D0FF), "4": Color(0xFFFDFF98), "5": Color(0XFFABF0FF), "6": Color(0XFFFF3434)};
  Map<String, Color> bgContainerShadowColor = {
    "1": Color.fromRGBO(193, 255, 153, 0.3),
    "2": Color.fromRGBO(255, 232, 172, 0.05),
    "3": Color.fromRGBO(176, 208, 255, 0.3),
    //"4": Color.fromRGBO(253, 255, 152, 0.2),
    "4": Color.fromRGBO(255, 255, 0, 0.07),
    "5": Color.fromRGBO(171, 240, 255, 0.3),
    "6": Color.fromRGBO(255, 52, 52, 0.3)
  };
  // List<dynamic> assetImage = [
  //   {"1": "assets/patients.png"},
  //   {"2": "assets/appoinment.png"},
  //   {"3": "assets/doctor_profile.png"},
  //   {"4": "assets/offer.png"}
  // ];

  void initState() {
    setState(() {
      if (preferencesService.stage_level_count != 0) {
        preferencesService.stage_level_count> 1 ? isAllow = true : false;
      }
    });
  }

  Widget docProfileTimeline(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 15,
        ),
        Expanded(
            child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 15, left: 15, right: 25, top: 15),
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
                    Container(width: 32, height: 32, decoration: UIHelper.roundedLineBorderWithColor(16, Colors.green, 1, borderColor: Colors.red), child: Icon(Icons.done, size: 20, color: Colors.white)),
                    Text('Entry').fontWeight(FontWeight.w600)
                  ],
                ),
                Column(
                  children: [Container(width: 32, height: 32, decoration: UIHelper.roundedLineBorderWithColor(16, subtleColor, 1, borderColor: Colors.red)), Text('Enhanced').fontWeight(FontWeight.w600)],
                ),
                Column(
                  children: [Container(width: 32, height: 32, decoration: UIHelper.roundedLineBorderWithColor(16, subtleColor, 1, borderColor: Colors.red)), Text('Verified').fontWeight(FontWeight.w600)],
                ),
                Column(
                  children: [Container(width: 32, height: 32, decoration: UIHelper.roundedLineBorderWithColor(16, subtleColor, 1, borderColor: Colors.red)), Text('SWAR Dr.').fontWeight(FontWeight.w600)],
                ),
              ],
            ),
          ],
        )),
        SizedBox(
          width: 15,
        ),
      ],
    );
  }

  Widget showSearchField(BuildContext context) {
    return SizedBox(
      height: 74,
      child: Container(
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 38,
                child: TextField(
                  controller: searchController,
                  onChanged: (value) {
                    //model.getMembers_search(value);
                  },
                  style: TextStyle(fontSize: 14),
                  decoration: new InputDecoration(
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.grey,
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
                      enabledBorder: UIHelper.getInputBorder(0, radius: 12, borderColor: Color(0xFFCCCCCC)),
                      focusedBorder: UIHelper.getInputBorder(0, radius: 12, borderColor: Color(0xFFCCCCCC)),
                      focusedErrorBorder: UIHelper.getInputBorder(0, radius: 12, borderColor: Color(0xFFCCCCCC)),
                      errorBorder: UIHelper.getInputBorder(0, radius: 12, borderColor: Color(0xFFCCCCCC)),
                      filled: true,
                      hintStyle: new TextStyle(color: Colors.grey[800]),
                      hintText: "Search(date, Swar id, name, phone number)",
                      fillColor: fieldBgColor),
                ),
              ),
            ),
            UIHelper.verticalSpaceLarge,
          ],
        ),
      ),
    );
  }

  Widget showTitle(BuildContext context, String title) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(title, overflow: TextOverflow.clip).fontSize(12).fontWeight(FontWeight.w600).textColor(title == "Manage Subscriptions & contract\n with SWAR Doctor LLC" ? Colors.white : Colors.black),
          ],
        ),
      ],
    );
  }

  Widget showIcon(BuildContext context, String imgUrl, double width, double height) {
    if (imgUrl == "assets/swar_logo.png") {
      width = 30;
      height:
      30;
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [Image.asset(imgUrl, width: width, height: height)],
    );
  }

  Widget showvacation(BuildContext context, String title) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(title).fontSize(12).fontWeight(FontWeight.w600).textColor(Colors.white),
        UIHelper.horizontalSpaceSmall,
        Image.asset('assets/vacation.png', width: 45, height: 45),
      ],
    );
  }

  Widget manage_bar() {
    return Container(
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (var manageBar in bottom_manage_bar)
            Column(
              children: [
                StreamBuilder<String?>(
                    stream: locator<PreferencesService>().doctorStageValue.outStream,
                    builder: (context, snapshot) {
                      // setState(() {
                      print("k");
                      if (preferencesService.stage_level_count != 0) {
                        preferencesService.stage_level_count> 1 ? isAllow = true : false;
                      }
                      return Opacity(
                          opacity: isAllow ? 0.9 : 0.3,
                          child: GestureDetector(
                              onTap: () async {
                                if (isAllow && manageBar['containertype'] == "5") {
                                  await apiService.getProfile(preferencesService.userId);
                                  setState(() {});
                                  //getProfile
                                  await Get.to(() => ManageAvailableWidget(isContainer: true, service_Type: preferencesService.servicesStream));
                                }
                              },
                              child: Container(
                                  decoration:
                                      //  preferencesService.stage_level_count! == 2 || preferencesService.stage_level_count! > 2
                                      UIHelper.rightcornerRadiuswithColorDoctor(4, 20, bgContainerColor[manageBar['containertype']] != null ? bgContainerColor[manageBar['containertype']]! : Colors.yellow),
                                  // : UIHelper.rightcornerRadiuswithColorDoctor(4, 20, bgContainerShadowColor[manage_bar['containertype']] != null ? bgContainerShadowColor[manage_bar['containertype']]! : Colors.yellow),
                                  width: Screen.width(context),
                                  padding: EdgeInsets.all(10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    // mainAxisSize: MainAxisSize.max,
                                    //  padding: EdgeInsets.all(10),
                                    children: [
                                      showTitle(context, manageBar['stagetitle']),
                                      UIHelper.verticalSpaceMedium,
                                      showIcon(context, manageBar['barImage'], 50, 50),
                                    ],
                                  ))));
                    }
                    //}
                    ),
                UIHelper.verticalSpaceMedium,
              ],
            )
        ],
      ),
    );
  }

  Widget manage_types() {
    List<dynamic> currentForm = formtype.toList();
    //double screenWidth = MediaQuery.of(context).size.width;

    // var width = (screenWidth - ((2 - 1) * 5)) / 2;
    // var height = width / 2 / 1.4;
    // int row = 2;
    // int column = 2;
    int i = 0;
    return Container(
        height: 230,
        child: StreamBuilder<String?>(
            stream: locator<PreferencesService>().doctorStageValue.outStream,
            builder: (context, snapshot) {
              // setState(() {
              print("k");
              if (preferencesService.stage_level_count != 0) {
                preferencesService.stage_level_count> 1 ? isAllow = true : false;
              }

              return Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  for (var gettype in currentForm)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        GestureDetector(
                            // onTap: null,
                            onTap: () {
                              gettype[i]['containertype'] == "3" ? Get.to(() => DoctorProfileView()) : null;
                            },
                            child: Opacity(
                              opacity: gettype[i]['containertype'] == "3" || isAllow ? 1.0 : 0.5,
                              child: Container(
                                // height: 100,
                                padding: EdgeInsets.all(5),
                                width: Screen.width(context) / 2.2,
                                decoration: UIHelper.rightcornerRadiuswithColorDoctor(4, 20, bgContainerColor[gettype[i]['containertype']] != null ? bgContainerColor[gettype[i]['containertype']]! : Colors.red),
                                child: Column(
                                  children: [
                                    showTitle(context, gettype[i]['stagetitle']),
                                    UIHelper.verticalSpaceSmall,
                                    showIcon(context, gettype[i]['assetImage'], 50, 50),
                                  ],
                                ),
                              ),
                            )),
                        UIHelper.horizontalSpaceSmall,
                        GestureDetector(
                            onTap: () {
                              if (gettype[i + 1]['containertype'] == "4") {
                                Get.to(() => ManageOffersView(
                                      newoffer: true,
                                    ));
                              } else {
                                final BottomNavigationBar navigationBar = locator<PreferencesService>().bottomTab_globalKey.currentWidget as BottomNavigationBar;
                                navigationBar.onTap!(1);
                              }
                            },
                            child: Opacity(
                              opacity: isAllow ? 1.0 : 0.5,
                              child: Container(
                                // height: 100,
                                padding: EdgeInsets.all(5),
                                width: Screen.width(context) / 2.3,
                                decoration:
                                    UIHelper.rightcornerRadiuswithColorDoctor(4, 20, bgContainerColor[gettype[i + 1]['containertype']] != null ? bgContainerColor[gettype[i + 1]['containertype']]! : Colors.yellow),
                                child: Column(
                                  children: [
                                    showTitle(context, gettype[i + 1]['stagetitle']),
                                    UIHelper.verticalSpaceSmall,
                                    showIcon(context, gettype[i + 1]['assetImage'], 50, 50),
                                  ],
                                ),
                              ),
                            )),
                      ],
                    )
                ],
              );
            }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SwarAppDoctorBar(isProfileBar: false),
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            width: Screen.width(context),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  preferencesService.stage_level_count == 4
                      ? Column(
                          children: [
                            showSearchField(context),
                            UIHelper.verticalSpaceTiny,
                          ],
                        )
                      : ProfileStageWidget(
                          isContainer: true,
                        ),
                  UIHelper.verticalSpaceMedium,
                  manage_types(),
                  UIHelper.verticalSpaceMedium,
                  manage_bar(),
                  //  preferencesService.stage_level_count != null && preferencesService.stage_level_count! == 2 || preferencesService.stage_level_count! > 2

                  //isAllow
                  StreamBuilder<String?>(
                      stream: locator<PreferencesService>().doctorStageValue.outStream,
                      builder: (context, snapshot) {
                        // setState(() {
                        print("k");
                        if (preferencesService.stage_level_count != 0) {
                          preferencesService.stage_level_count> 1 ? isAllow = true : false;
                        }
                        return isAllow && preferencesService.stage_level_count < 4
                            ? Column(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Get.to(() => DoctorDeclarationView());

                                      setState(() {});
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.5),
                                            spreadRadius: 2,
                                            blurRadius: 5,
                                            offset: Offset(0, 3), // changes position of shadow
                                          ),
                                        ],
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.all(5),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Text(
                                              '  Self Declaration',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black,
                                              ),
                                            ),
                                            Icon(
                                              Icons.arrow_forward,
                                              color: Colors.black,
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  UIHelper.verticalSpaceSmall
                                ],
                              )
                            : Container();
                      })
                ],
              ),
            )),
      ),
    );
  }
}
