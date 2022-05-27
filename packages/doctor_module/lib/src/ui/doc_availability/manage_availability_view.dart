import 'dart:ui';
import 'package:doctor_module/src/ui/doc_availability/availability_calender_view.dart';
import 'package:doctor_module/src/ui/doc_availability/calendar.dart';
import 'package:doctor_module/src/ui/doc_availability/manage_calender_availability_model.dart';
import 'package:doctor_module/src/ui/doc_availability/edit_calender_availabilityview.dart';
import 'package:doctor_module/src/ui/doc_availability/viewall_availability.dart';
import 'package:doctor_module/src/ui/doc_onboarding/doc_onboarding_section_b_sess_list_view.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stacked/stacked.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/frideos/extended_asyncwidgets.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/services/preferences_service.dart';
import 'package:swarapp/shared/app_colors.dart';
import 'package:swarapp/shared/app_doctorprofile_bar.dart';
import 'package:swarapp/shared/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:swarapp/shared/flutter_overlay_loader.dart';
import 'package:swarapp/shared/screen_size.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:swarapp/ui/startup/terms_view.dart';
import 'package:swarapp/ui/subscription/subscription_view.dart';
import 'package:member_module/src/ui/members/members_viewmodel.dart';
import 'package:user_module/src/ui/appoinments/book_appointment_view.dart';
import 'package:jiffy/jiffy.dart';

class ManageAvailableWidget extends StatefulWidget {
  final bool isContainer;
  final dynamic service_Type;
  const ManageAvailableWidget({Key? key, required this.isContainer, required this.service_Type}) : super(key: key);

  get boolValue => null;

  get isDelete => "yes";

  @override
  _ManageAvailableWidgetState createState() => _ManageAvailableWidgetState();
}

class _ManageAvailableWidgetState extends State<ManageAvailableWidget> {
  bool isremove = false;
  SharedPreferences? prefs;
  String gt = "";
  int index = 1;
  dynamic levelStates = ['Entry', 'Enhanced', 'Verified', 'SWAR Dr.'];
  set boolValue(String boolValue) {
    this.isremove = boolValue as bool;
  }

  bool isViewWidget = false;
//SharedPreferences prefs = await SharedPreferences.getInstance();
  TextEditingController mailController = TextEditingController();
  bool get isDelete {
    return isremove;
  }

  String startDt = Jiffy().format('MM-dd-yyyy');
  String getLimit = Jiffy(DateTime.now()).add(months: 3).format('MM-dd-yyyy').toString();
  List<dynamic> manage_type_bar = [];
  void initState() {
    //manage_type_bar = [
    for (var getSeparate in preferencesService.usersServiceListStream!.value!) {
      if (getSeparate != "Chat") {
        manage_type_bar.add({
          "containertype": getSeparate == "In clinic" ? "1" : "2",
          "container_name": getSeparate.toString().toLowerCase(),
          "stagetitle": getSeparate,
          "barImage": getSeparate == "In clinic"
              ? "assets/clinic.png"
              : getSeparate == "Online"
                  ? "assets/online_img.png"
                  : "assets/home_visit_img.png"
        });
      }
    }
    //];
  }

  // List<dynamic> manage_type_bar = [
  //   {"containertype": "1", "container_name": "clinic", "stagetitle": "Clinic", "barImage": "assets/clinic.png"},
  //   {"containertype": "2", "container_name": "online", "stagetitle": "Online", "barImage": "assets/online_img.png"},
  //   {"containertype": "2", "container_name": "homevisit", "stagetitle": "Home Visit", "barImage": "assets/home_visit_img.png"},
  // ];
//service_Type
  Widget showTitle(BuildContext context, String title) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              title,
              overflow: TextOverflow.clip,
              textAlign: TextAlign.center,
            ).fontSize(15).fontWeight(FontWeight.w600).textColor(title == "Manage Subscriptions & contract\n with SWAR Doctor LLC" ? Colors.white : Colors.black),
          ],
        ),
      ],
    );
  }

  Widget showIcon(BuildContext context, String imgUrl, double width, double height) {
    if (imgUrl == "assets/swar_logo.png") {
      width = 40;
      height:
      40;
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [Image.asset(imgUrl, width: width, height: height)],
    );
  }

  Widget manage_bar(ManageCalenderWidgetmodel model) {
    return StreamedWidget<List<dynamic>?>(
        stream: preferencesService.usersServiceListStream!.outStream!,
        builder: (context, snapshot) {
          // ListView.builder(
          //         // itemCount: friends_stream.length,
          //         itemCount: isSearch ? model.recentFriends.length : snapshot.data!.length,
          //         scrollDirection: Axis.horizontal,
          //         itemBuilder: (
          //           context,
          //           index,
          //         ) {

          return Container(
            // padding: EdgeInsets.all(10),
            // decoration: BoxDecoration(
            //     color: Colors.blueAccent, //remove color to make it transpatent
            //     border: Border.all(style: BorderStyle.solid, color: Colors.white)),
            // width: Screen.width(context) / 2,

            child: Column(
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                UIHelper.verticalSpaceMedium,
                UIHelper.verticalSpaceMedium,
                for (var manageBar in manage_type_bar)
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          print(preferencesService.clinicListStream!.length);
                          if (preferencesService.clinicListStream!.length == 0 && manageBar['containertype'] == "1") {
                            Fluttertoast.showToast(
                              msg: "Please Update Clinic from your profile",
                              backgroundColor: Colors.grey.shade400,
                              gravity: ToastGravity.BOTTOM,
                              textColor: Colors.black,
                            );
                          } else {
                            //print(preferencesService.clinicListStream!.value![0]['information_Id'].toString());
                            Loader.show(context);
                            manageBar['containertype'] == "1"
                                ? await model.viewSessionByclinic(startDt, getLimit, preferencesService.clinicListStream!.value![0]['information_Id'])
                                : await model.viewSession(startDt, getLimit, manageBar['stagetitle'].toString());
                            Loader.hide();
                            //manage_bar['stagetitle'].toString().toLowerCase()
                            //update  calendar screen
                            Get.to(() => ManageCalenderWidget(
                                isContainer: manageBar['stagetitle'].toString(),
                                dataView: model.calender_date_view,
                                available_dates: model.convert_dates,
                                clinic_name: manageBar['containertype'] == "1" ? preferencesService.clinicListStream!.value![0]['clinic_name'] : '',
                                clinicId: manageBar['containertype'] == "1" ? preferencesService.clinicListStream!.value![0]['information_Id'] : '',
                                sessionTime: model.setSessionTime.toList()));
                            // Get.to(() => ManageCalenderWidget(isContainer: manage_bar['stagetitle'].toString()));
                          }
                        },
                        child: Container(
                            decoration:
                                //  preferencesService.stage_level_count! == 2 || preferencesService.stage_level_count! > 2
                                UIHelper.rightcornerRadiuswithColorDoctor(4, 20, Colors.white),
                            // : UIHelper.rightcornerRadiuswithColorDoctor(4, 20, bgContainerShadowColor[manage_bar['containertype']] != null ? bgContainerShadowColor[manage_bar['containertype']]! : Colors.yellow),
                            width: Screen.width(context),
                            padding: EdgeInsets.all(10),
                            child: Row(
                              // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              // mainAxisSize: MainAxisSize.max,
                              //  padding: EdgeInsets.all(10),
                              children: [
                                // Text(manage_bar.toString()),
                                showIcon(context, manageBar['barImage'], 50, 50),
                                UIHelper.horizontalSpaceSmall,
                                showTitle(context, manageBar['stagetitle']),
                              ],
                            )),
                      ),

                      //}

                      UIHelper.verticalSpaceMedium,
                    ],
                  )
              ],
            ),
          );
        });
  }

  Widget view_all_button(ManageCalenderWidgetmodel model) {
    return Row(mainAxisAlignment: MainAxisAlignment.end,
        // mainAxisSize: MainAxisSize.max,
        //  padding: EdgeInsets.all(10),
        children: [
          GestureDetector(
              onTap: () async {
                // await model.viewSession('02-24-2022', '02-26-2022');
                // Get.to(() => AvailabilityCalenderView(dateView: model.get_session_view));
                Loader.show(context);
                await model.viewSession(startDt, getLimit, '');
                Loader.hide();
                Get.to(() => ViewallAvailabilityCalenderView(dataView: model.calender_date_view, available_dates: model.convert_dates, sessionTime: model.setSessionTime.toList()));
              },
              child: Container(
                  // decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), boxShadow: [
                  //   BoxShadow(
                  //     color: Colors.grey.shade300,
                  //     spreadRadius: 0.5,
                  //     blurRadius: 0.5,
                  //     offset: Offset(
                  //       2.0, // Move to right 10  horizontally
                  //       2.0, // Move to bottom 10 Vertically
                  //     ), //edited
                  //   ),
                  // ]),
                  decoration: UIHelper.roundedBorderWithColorWithShadow(6, Colors.white),
                  // : UIHelper.rightcornerRadiuswithColorDoctor(4, 20, bgContainerShadowColor[manage_bar['containertype']] != null ? bgContainerShadowColor[manage_bar['containertype']]! : Colors.yellow),
                  width: Screen.width(context) / 4,
                  padding: EdgeInsets.all(6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text('View all').fontSize(12).fontWeight(FontWeight.w600),
                      Icon(Icons.date_range, size: 20, color: activeColor),
                    ],
                  )))
        ]);
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
              child: ViewModelBuilder<ManageCalenderWidgetmodel>.reactive(
                  onModelReady: (model) async {
                    // await model.viewSession('sadf', 'asdfdf');
                    await model.init();
                  },
                  builder: (context, model, child) {
                    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      UIHelper.verticalSpaceSmall,
                      GestureDetector(
                        onTap: () {
                          Get.back(result: {'refresh': true});
                        },
                        child: Row(
                          children: [
                            Icon(
                              Icons.arrow_back_outlined,
                              size: 20,
                            ),
                            Text(' Manage Availability').fontSize(16).bold(),
                          ],
                        ),
                      ),
                      UIHelper.verticalSpaceMedium,
                      UIHelper.verticalSpaceMedium,
                      view_all_button(model),
                      UIHelper.verticalSpaceMedium,
                      manage_type_bar.length > 0
                          ? manage_bar(model)
                          : Container(
                              width: Screen.width(context),
                              height: Screen.height(context) / 2,
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "No more services available. \n please choose your service type",
                                    textAlign: TextAlign.center,
                                  ).bold(),
                                ],
                              )),
                      // Text(model.setSessionTime[0]['start_time'].toString())
                    ]);
                  },
                  viewModelBuilder: () => ManageCalenderWidgetmodel()),
            )));
  }
}
