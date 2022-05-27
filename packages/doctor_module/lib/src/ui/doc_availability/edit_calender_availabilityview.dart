import 'dart:ui';
import 'package:doctor_module/src/ui/doc_availability/add_availability_view.dart';
import 'package:doctor_module/src/ui/doc_availability/availability_calender_view.dart';
import 'package:doctor_module/src/ui/doc_availability/calendar.dart';
import 'package:doctor_module/src/ui/doc_availability/manage_calender_availability_model.dart';
import 'package:doctor_module/src/ui/doc_availability/new.dart';
import 'package:doctor_module/src/ui/doc_onboarding/doc_onboarding_section_b_sess_list_view.dart';
import 'package:flutter/scheduler.dart';
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
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:user_module/src/ui/appoinments/book_appointment_view.dart';
import 'package:intl/src/intl/date_format.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:jiffy/jiffy.dart';
//import 'package:syncfusion_flutter_calendar/calendar.dart';

class ManageCalenderWidget extends StatefulWidget {
  final String isContainer;
  final dynamic dataView;
  final dynamic available_dates;
  final String clinic_name;
  final String clinicId;
  final dynamic sessionTime;
  const ManageCalenderWidget({Key? key, required this.isContainer, required this.dataView, required this.available_dates, required this.clinic_name, required this.clinicId, required this.sessionTime}) : super(key: key);

  get boolValue => null;

  get isDelete => "yes";

  @override
  _ManageCalenderWidgetState createState() => _ManageCalenderWidgetState();
}

class _ManageCalenderWidgetState extends State<ManageCalenderWidget> with TickerProviderStateMixin {
  bool isremove = false;
  SharedPreferences? prefs;
  String gt = "";
  int index = 1;
  dynamic levelStates = ['Entry', 'Enhanced', 'Verified', 'SWAR Dr.'];
  dynamic timing = [12, 1, 2, 3, 4, 5];
  dynamic timing_array = [12, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11];
  dynamic evg_time_array = [5, 6, 7, 8, 9, 10, 11, 12];
  bool mngDurationEnabled = true;
  bool aftDurationEnabled = true;
  bool evgDurationEnabled = true;
  bool isViewWidget = true;
  double _value = 6.0;

  SfRangeValues? _mngvalues;
  //= SfRangeValues(7.0, 9.0);
  // SfRangeValues _afternoonvalues = SfRangeValues(2.0, 4.0);
  // SfRangeValues _values = SfRangeValues(7.0, 9.0);
  //SfRangeValues _mngvalues = SfRangeValues(5.0, 6.0);
  SfRangeValues _afternoonvalues = SfRangeValues(12.0, 14.0);
  SfRangeValues _values = SfRangeValues(19.0, 21.0);

  set boolValue(String boolValue) {
    this.isremove = boolValue as bool;
  }

  dynamic selection = {};
  bool isChangedSelection = false;
  String st_date = "";
  String end_date = "";
  String range_start_date = "";
  String range_end_date = "";
  DateTime str = new DateTime.now();
  DateTime en = new DateTime.now();
  List<DateTime> days = [];
  bool editMode = false;
  bool isload = false;
  bool toupdate = false;
  bool ismngEdit = false;
  bool isaftEdit = false;
  bool isevgEdit = false;

  String mng_durations = "10 mins";
  String aft_durations = "10 mins";
  String evg_durations = "10 mins";

  String mng_durations_value = "10 mins";
  String aft_durations_value = "10 mins";
  String evg_durations_value = "10 mins";

  bool isfill = false;
//SharedPreferences prefs = await SharedPreferences.getInstance();
  TextEditingController mailController = TextEditingController();
  bool get isDelete {
    return isremove;
  }

  List ava_il = [];
  List<PickerDateRange> lst = [];
  dynamic selection_date_list = {};
  dynamic current_dataView = [];
  dynamic current_available_dates = [];
  double margin = 0;
  RangeValues intial_range_morning = RangeValues(2.0, 8.0);
  RangeValues intial_range_afternoon = RangeValues(3.0, 8.0);
  RangeValues intial_range_evg = RangeValues(2.0, 2.5);
  RangeValues init_evg_range = RangeValues(2.0, 4.0);
  List<dynamic> manage_type_bar = [
    {"containertype": "1", "container_name": "clinic", "stagetitle": "Clinic", "barImage": "assets/clinic.png"},
    {"containertype": "2", "container_name": "online", "stagetitle": "Online", "barImage": "assets/online_img.png"},
    {"containertype": "2", "container_name": "homevisit", "stagetitle": "Home Visit", "barImage": "assets/home_visit_img.png"},
  ];

  dynamic selection_dates = {};

  AnimationController? _controller;
  Animation<double>? _animation, opacityAnimation;
  String clinicName = "";
  String clinicId = "";

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller!,
      curve: Curves.fastLinearToSlowEaseIn,
      // curve: Curves.easeInOutCubicEmphasized,
    );
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    opacityAnimation = CurvedAnimation(parent: Tween<double>(begin: 1, end: 0).animate(_controller!), curve: Curves.linearToEaseOut);
    current_dataView = widget.dataView;
    current_available_dates = widget.available_dates;
  }

  _toggleContainer() {
    print(_animation!.status);
    if (_animation!.status != AnimationStatus.completed) {
      _controller!.forward();
    } else {
      _controller!.animateBack(0, duration: Duration(seconds: 1));
    }
  }

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

  Widget manage_bar() {
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
                Container(
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
                        showIcon(context, manageBar['barImage'], 50, 50),
                        UIHelper.horizontalSpaceSmall,
                        showTitle(context, manageBar['stagetitle']),
                      ],
                    )),

                //}

                UIHelper.verticalSpaceMedium,
              ],
            )
        ],
      ),
    );
  }

  Widget getMorningMode(BuildContext context, String asseturl, String title, String manageType, dynamic getslotMorning, bool isViewmode, List<dynamic> check) {
    // String g = getDefaultTime[0]['start_time'].toString();
    String mong = "";
    String mongEnd = "";
    SfRangeValues mng = SfRangeValues(0.0, 0.0);

    dynamic vaf = check.where((e) {
      return e['name'].toString().toLowerCase().contains("morning");
    }).toList();
    //double mng_srt = vaf[0]['start_time'] == 0.0 ? vaf[0]['start_time'] + 12.00 : vaf[0]['start_time'];
    double mngSrt = vaf.isNotEmpty ? vaf[0]['start_time'] : null;
    double mngEnd = vaf.isNotEmpty ? vaf[0]['end_time'] : null;
//  SearchByInfo = notificationInfo.where((e) {
//       return e['name'].toString().toLowerCase().contains(search.toLowerCase());
//     }).toList();
    //_mngvalues = SfRangeValues(getDefaultTime['start_time'] + 1.0, getDefaultTime['end_time']);
    //_mngvalues = SfRangeValues(2.0, 5.0);

    // SfRangeValues t = SfRangeValues(double.parse(mong), double.parse(mong_end));
    //SfRangeValues t = SfRangeValues(double.parse(aftr), double.parse(aftr_end));
    if (isChangedSelection && !ismngEdit && getslotMorning != "" && getslotMorning[0]['mon_start_time'] != null) {
      mong = getslotMorning[0]['mon_start_time'].replaceAll(":", ".");
      mong = mong.replaceAll(' ', '');
      mongEnd = getslotMorning[0]['mon_end_time'].replaceAll(":", ".");
      mongEnd = mongEnd.replaceAll(' ', '');
      //setState(() {
      //_mngvalues
      // double mng_srt = vaf[0]['start_time'] == 0.0 ? vaf[0]['start_time'] + 12.00 : vaf[0]['start_time'];
      // double mng_end = vaf[0]['end_time'];
      // _mngvalues = SfRangeValues(mng_srt, mng_end);
      _mngvalues = SfRangeValues(double.parse(mong), double.parse(mongEnd));
      // : SfRangeValues(mng_srt, mng_end);
      // });
      //_mngvalues = SfRangeValues(double.parse(vaf['start_time']), double.parse(vaf['end_time']));
    }
    return Container(
        padding: EdgeInsets.all(8),
        //decoration: UIHelper.roundedBorderWithColorWithShadow(6, Colors.white),
        child: Column(children: [
          isViewmode
              ? Row(
                  children: [
                    Container(
                      width: 35,
                      height: 35,
                      child: Image.asset(asseturl),
                    ),
                    UIHelper.horizontalSpaceSmall,
                    Text(title).fontSize(13).fontWeight(FontWeight.w600),
                    UIHelper.horizontalSpaceSmall,
                    Expanded(
                        child: Column(
                      children: [
                        // Text(time).fontWeight(FontWeight.w600),
                        getslotMorning != "" && getslotMorning[0]['mon_start_time'] != null
                            ? Text(_mngvalues!.start.toInt().toString() + " am   - " + " " + _mngvalues!.end.toInt().toString() + " am").fontSize(12).fontWeight(FontWeight.w600)
                            : SizedBox()
                      ],
                    ))
                  ],
                )
              : Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 35,
                        height: 35,
                        child: Image.asset(asseturl),
                      ),
                      Container(
                          // height: 55,
                          child: Column(
                              // mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Text(title).fontSize(14).fontWeight(FontWeight.w600),
                            Row(
                              children: [
                                Text('OFF   ').fontSize(12).fontWeight(FontWeight.w600),
                                SizedBox(
                                  width: 24,
                                  child: Transform.scale(
                                    alignment: Alignment.centerLeft,
                                    scale: 0.5,
                                    transformHitTests: false,
                                    child: CupertinoSwitch(
                                      activeColor: Colors.green,
                                      value: mngDurationEnabled,
                                      onChanged: (value) {
                                        // achievement_privacy = value;
                                        setState(() {
                                          mngDurationEnabled = value;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                Text('ON').fontSize(12).fontWeight(FontWeight.w600),
                              ],
                            ),
                          ]))
                    ],
                  ),
                  Row(children: [
                    Column(
                      children: [
                        isChangedSelection && !ismngEdit
                            ? Text(mong + "am   - " + " " + mongEnd + " am")
                            : Text(_mngvalues!.start.toInt().toString() + "am   - " + " " + _mngvalues!.end.toInt().toString() + " am").fontSize(12).fontWeight(FontWeight.w600),
                        Container(
                          width: 190,
                          child: SfRangeSlider(
                            min: 05.0,
                            max: 11.0,
                            // min: getDefaultTime['start_time'][0],
                            // max: getDefaultTime['end_time'][0],
                            values: _mngvalues!,
                            // interval: 1,
                            // showTicks: true,
                            // showLabels: true,
                            // dragMode: SliderDragMode.onThumb,
                            enableTooltip: true,
                            activeColor: activeColor,
                            //enableTooltip: true,
                            minorTicksPerInterval: 1,
                            onChanged: mngDurationEnabled
                                ? (SfRangeValues values) {
                                    setState(() {
                                      ismngEdit = true;

                                      _mngvalues = values;
                                    });
                                  }
                                : null,
                          ),
                        )
                      ],
                    )
                  ]),
                ]),
          // isViewmode
          //     ? Row(
          //         children: [
          //           Container(
          //             width: 35,
          //             height: 35,
          //             child: Image.asset(asseturl),
          //           ),
          //           UIHelper.horizontalSpaceSmall,
          //           Text(title).fontSize(13).fontWeight(FontWeight.w600),
          //           UIHelper.horizontalSpaceSmall,
          //           Expanded(
          //               child: Column(
          //             children: [
          //               // Text(time).fontWeight(FontWeight.w600),
          //               Text(_mngvalues.start.toInt().toString() != null ? _mngvalues.start.toInt().toString() : '')
          //             ],
          //           ))
          //         ],
          //       )
          //     : SizedBox()
        ]));
  }

  Widget getAfternoonMode(BuildContext context, String asseturl, String title, String manageType, dynamic getslotAfternoon, bool isViewmode) {
    String aftr = "";
    String aftrEnd = "";
    //SfRangeValues t = SfRangeValues(double.parse(aftr), double.parse(aftr_end));

    if (!isaftEdit && getslotAfternoon != "" && getslotAfternoon[0]['afn_start_time'] != null) {
      aftr = getslotAfternoon[0]['afn_start_time'].replaceAll(":", ".");
      aftr = aftr.replaceAll(' ', '');
      aftrEnd = getslotAfternoon[0]['afn_end_time'].replaceAll(":", ".");
      aftrEnd = aftrEnd.replaceAll(' ', '');
//setState(() {
      _afternoonvalues = SfRangeValues(double.parse(aftr), double.parse(aftrEnd));
      //  });
    }
    return Container(
        padding: EdgeInsets.all(8),
        //decoration: UIHelper.roundedBorderWithColorWithShadow(6, Colors.white),
        child: Column(children: [
          isViewmode
              ? Row(
                  children: [
                    Container(
                      width: 35,
                      height: 35,
                      child: Image.asset(asseturl),
                    ),
                    UIHelper.horizontalSpaceSmall,
                    Text(title).fontSize(13).fontWeight(FontWeight.w600),
                    UIHelper.horizontalSpaceSmall,
                    Expanded(
                        child: Column(
                      children: [
                        // Text(time).fontWeight(FontWeight.w600),
                        getslotAfternoon != "" && getslotAfternoon[0]['afn_start_time'] != null
                            ? Text(_afternoonvalues.start.toInt().toString() + "pm   - " + " " + _afternoonvalues.end.toInt().toString() + " pm").fontSize(12).fontWeight(FontWeight.w600)
                            : SizedBox()
                      ],
                    ))
                  ],
                )
              : Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 35,
                        height: 35,
                        child: Image.asset(asseturl),
                      ),
                      Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(title).fontSize(13).fontWeight(FontWeight.w600),
                        Row(
                          children: [
                            Text('OFF   ').fontSize(12).fontWeight(FontWeight.w600),
                            SizedBox(
                              width: 24,
                              child: Transform.scale(
                                alignment: Alignment.centerLeft,
                                scale: 0.5,
                                transformHitTests: false,
                                child: CupertinoSwitch(
                                  activeColor: Colors.green,
                                  value: aftDurationEnabled,
                                  onChanged: (value) {
                                    // achievement_privacy = value;
                                    setState(() {
                                      aftDurationEnabled = value;
                                    });
                                  },
                                ),
                              ),
                            ),
                            Text('ON').fontSize(12).fontWeight(FontWeight.w600),
                          ],
                        )
                      ])
                    ],
                  ),
                  Row(children: [
                    Column(
                      children: [
                        // Text(intial_range_afternoon.start.toInt().toString() + " am  - " + intial_range_afternoon.end.toInt().toString()).fontWeight(FontWeight.w600),
                        // Text(timing[intial_range_afternoon.start.toInt() - 1].toString() + " pm  - " + timing[intial_range_afternoon.end.toInt() - 1].toString() + " pm").fontSize(12).fontWeight(FontWeight.w600),
                        // Text(timing_array[intial_range_afternoon.start.toInt() - 1].toString() +
                        //         (intial_range_afternoon.start.toInt() > 11 ? " pm  - " : " am -") +
                        //         timing_array[intial_range_afternoon.end.toInt() - 1].toString() +
                        //         (intial_range_afternoon.end.toInt() > 11 ? " pm" : " am"))
                        //     .fontSize(12)
                        //     .fontWeight(FontWeight.w600),
                        //  Text(aftr + "pm  - " + " " + aftr_end + " pm").fontSize(12).fontWeight(FontWeight.w600),
                        // isChangedSelection && !isaftEdit
                        //     ? Text(aftr + "pm   - " + " " + aftr_end + " pm")
                        // :
                        Text(_afternoonvalues.start.toInt().toString() + "pm   - " + " " + _afternoonvalues.end.toInt().toString() + " pm").fontSize(12).fontWeight(FontWeight.w600),
                        // SizedBox(
                        //   height: 30,
                        //   child:
                        //   SliderTheme(
                        //       data: SliderThemeData(thumbColor: Colors.red, rangeThumbShape: TriangleThumbShape(), showValueIndicator: ShowValueIndicator.always),
                        //       child: RangeSlider(
                        //         inactiveColor: Color(0xFFEBECED),
                        //         activeColor: Color(0xFFDE2128),
                        //         min: 1.0,
                        //         max: 24.0,
                        //         values: intial_range_afternoon,
                        //         onChanged: (RangeValues value) {
                        //           setState(() {
                        //             intial_range_afternoon = value;
                        //           });
                        //         },
                        //       )),
                        // )

                        Container(
                          width: 190,
                          child: SfRangeSlider(
                            min: 01.0,
                            max: 06.0,
                            values: _afternoonvalues,
                            // interval: 1,
                            // showTicks: true,
                            // showLabels: true,
                            // dragMode: SliderDragMode.onThumb,
                            enableTooltip: true,
                            activeColor: activeColor,
                            //enableTooltip: true,
                            minorTicksPerInterval: 1,
                            onChanged: aftDurationEnabled
                                ? (SfRangeValues values) {
                                    setState(() {
                                      isaftEdit = true;
                                      _afternoonvalues = values;
                                    });
                                  }
                                : null,
                          ),
                        )
                      ],
                    )
                  ])
                ])
        ]));
  }

  Widget getEvgMode(BuildContext context, String asseturl, String title, String manageType, dynamic slt, bool isViewmode) {
    String result = "";
    String resultEnd = "";
    //SfRangeValues t = SfRangeValues(double.parse(result), double.parse(result_end));
    if (!isevgEdit && slt != "" && slt[0]['eve_start_time'] != null) {
      result = slt[0]['eve_start_time'].replaceAll(":", ".");
      result = result.replaceAll(' ', '');
      resultEnd = slt[0]['eve_end_time'].replaceAll(":", ".");
      resultEnd = resultEnd.replaceAll(' ', '');
      // setState(() {
      _values = SfRangeValues(double.parse(result), double.parse(resultEnd));
      //});
    }
    // if (slt == "" || slt[0]['eve_start_time'] == null) {
    //   evgDurationEnabled = !evgDurationEnabled;
    // }
    return Container(
      padding: EdgeInsets.all(8),
      //decoration: UIHelper.roundedBorderWithColorWithShadow(6, Colors.white),
      child: Column(
        children: [
          isViewmode
              ? Row(
                  children: [
                    Container(
                      width: 35,
                      height: 35,
                      child: Image.asset(asseturl),
                    ),
                    UIHelper.horizontalSpaceSmall,
                    Text(title).fontSize(13).fontWeight(FontWeight.w600),
                    UIHelper.horizontalSpaceSmall,
                    Expanded(
                        child: Column(
                      children: [
                        // Text(time).fontWeight(FontWeight.w600),
                        slt != "" && slt[0]['eve_start_time'] != null
                            ? Text(_values.start.toInt().toString() + "pm   - " + " " + _values.end.toInt().toString() + " pm").fontSize(12).fontWeight(FontWeight.w600)
                            : SizedBox()
                      ],
                    ))
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 35,
                          height: 35,
                          child: Image.asset(asseturl),
                        ),
                        Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(title).fontSize(13).fontWeight(FontWeight.w600),
                          Row(
                            children: [
                              Text('OFF   ').fontSize(12).fontWeight(FontWeight.w600),
                              SizedBox(
                                width: 24,
                                child: Transform.scale(
                                  alignment: Alignment.centerLeft,
                                  scale: 0.5,
                                  transformHitTests: false,
                                  child: CupertinoSwitch(
                                    activeColor: Colors.green,
                                    value: slt != "" && slt[0]['eve_start_time'] != null ? evgDurationEnabled : false,
                                    onChanged: (value) {
                                      // achievement_privacy = value;
                                      setState(() {
                                        evgDurationEnabled = value;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              Text('ON').fontSize(12).fontWeight(FontWeight.w600),
                            ],
                          )
                        ])
                      ],
                    ),
                    Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Column(
                        children: [
                          //Text((init_evg_range.start + 4.0).toStringAsFixed(2).toString() + "  - " + " " + double.parse((init_evg_range.end + 4.0).toStringAsFixed(2)).toString()).fontSize(12).fontWeight(FontWeight.w600),
                          //  Text(result + "pm  - " + " " + result_end + " pm").fontSize(12).fontWeight(FontWeight.w600),
                          // isChangedSelection && !isevgEdit
                          //     ? Text(result + "am   - " + " " + result_end + " am")
                          // :
                          Text(_values.start.toInt().toString() + "pm   - " + " " + _values.end.toInt().toString() + " pm").fontSize(12).fontWeight(FontWeight.w600),
                          // Text(slt['eve_start_time']).fontWeight(FontWeight.w600),
                          Container(
                            width: 190,
                            child: SfRangeSlider(
                              min: 06.0,
                              max: 11.0,
                              values: _values,
                              // interval: 1,
                              // showTicks: true,
                              // showLabels: true,
                              dragMode: SliderDragMode.onThumb,
                              enableTooltip: true,
                              activeColor: activeColor,
                              //enableTooltip: true,
                              minorTicksPerInterval: 1,
                              onChanged: evgDurationEnabled
                                  ? (SfRangeValues values) {
                                      setState(() {
                                        isevgEdit = true;
                                        _values = values;
                                      });
                                    }
                                  : null,
                            ),
                          )
                        ],
                      )
                    ])
                  ],
                ),
        ],
      ),
    );
  }

  void showBottomSheet(BuildContext context, ManageCalenderWidgetmodel model) {
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(15.0)),
        ),
        builder: (
          BuildContext context,
        ) {
          return FadeTransition(
              opacity: opacityAnimation!,
              child: Container(
                  height: 260,
                  child: SizeTransition(
                      sizeFactor: _animation!,
                      axis: Axis.vertical,
                      child:
                          // AnimatedContainer(
                          //     duration: new Duration(milliseconds: 200),
                          //     curve: Curves.easeInOut,
                          //     child:
                          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        UIHelper.verticalSpaceSmall,
                        UIHelper.verticalSpaceSmall,
                        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                          GestureDetector(
                            onTap: () async {
                              Navigator.pop(context);
                              // Get.to(() => HomeScreen());
                              // Navigator.push(context, MaterialPageRoute(builder: (context) => AnimatedScreen()));
//                              Navigator.push(
//   context,
//   PageRouteBuilder(
//     pageBuilder: (c, a1, a2) => AnimatedScreen(),
//     transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
//     transitionDuration: Duration(milliseconds: 2000),
//   ),
// );
                              // Navigator.push(
                              //   context,
                              //   new MyCustomRoute(builder: (context) => new HomeScreen()),
                              // );
                              // Navigator.of(context).push(
                              //   PageRouteBuilder(
                              //     pageBuilder: (context, animation, secondaryAnimation) {
                              //       return AnimatedScreen();
                              //     },
                              //     transitionDuration: Duration(seconds: 1),
                              //   ),
                              // );
                              //await model.init();
                              // Loader.show(context);
                              // await model.getSessionDay();
                              // Loader.hide();

                              Get.to(
                                  AvailabilityCalenderView(
                                      // dateView: model.get_session_view,
                                      dateView: selection_date_list,
                                      serviceType: widget.isContainer,
                                      pickerDay: selection_date_list['slot_date'],
                                      clinicName: widget.clinic_name != "" ? widget.clinic_name : '',
                                      clinicId: widget.clinicId,
                                      sessionTime: widget.sessionTime.length == 0 ? model.setSessionTime.toList() : widget.sessionTime),
                                  duration: Duration(seconds: 1),
                                  //topLevel
                                  //rightToLeftWithFade
                                  transition: Transition.rightToLeftWithFade);
                              setState(() {});
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
                                    Text('Edit').fontSize(12).fontWeight(FontWeight.w600),
                                    Icon(Icons.app_registration, size: 20, color: activeColor),
                                  ],
                                )),
                          ),
                        ]),
                        getMorningMode(context, 'assets/morning_icon.png', 'Morning  ', 'Home Visit', selection_date_list['morning_slots'] != null ? selection_date_list['morning_slots'] : '', true,
                            widget.sessionTime.length < 0 ? model.setSessionTime.toList() : widget.sessionTime),
                        getAfternoonMode(context, 'assets/afternoon_icon.png', 'Afternoon', 'Online', selection_date_list['afternoon_slots'] != null ? selection_date_list['afternoon_slots'] : '', true),
                        getEvgMode(context, 'assets/evening_icon.png', 'Evening', 'Home Visit', selection_date_list['evening_slots'] != null ? selection_date_list['evening_slots'] : '', true),
                      ]))));
        });
  }

  void ss(BuildContext context) {
    bool _showSecond = false;
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15.0)),
      ),
      //onClosing: () {},
      builder: (BuildContext context) => AnimatedContainer(
        margin: EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
        child: AnimatedCrossFade(
            firstChild: Container(
              constraints: BoxConstraints.expand(height: MediaQuery.of(context).size.height - 200),
//remove constraint and add your widget hierarchy as a child for first view
              padding: EdgeInsets.all(20),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: RaisedButton(
                  onPressed: () => setState(() => _showSecond = true),
                  padding: EdgeInsets.all(15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text("Suivant"),
                    ],
                  ),
                ),
              ),
            ),
            secondChild: Container(
              constraints: BoxConstraints.expand(height: MediaQuery.of(context).size.height / 3),
//remove constraint and add your widget hierarchy as a child for second view
              padding: EdgeInsets.all(20),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: RaisedButton(
                  onPressed: () => setState(() => _showSecond = false),
                  color: Colors.green,
                  padding: EdgeInsets.all(15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text("ok"),
                    ],
                  ),
                ),
              ),
            ),
            crossFadeState: _showSecond ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: Duration(milliseconds: 400)),
        duration: Duration(milliseconds: 400),
      ),
    );
  }

  Widget duration_widget() {
    List<String> mngDur = ['10 mins', '20 mins', '30 mins', '45 mins', '1 hour'];
    return Column(children: [
      Row(children: [
        Text(
          'Adjust Duration per Patient',
          textAlign: TextAlign.left,
        ).bold(),
      ]),
      UIHelper.verticalSpaceMedium,
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
              decoration: UIHelper.roundedBorderWithColorWithShadow(6, Colors.white),
              width: 82,
              height: 45,
              // height: 21
              child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                Text("Morning").fontSize(10),
                DropdownButton<String>(
                  value: mng_durations_value,
                  //elevation: 5,
                  style: TextStyle(color: Colors.black),
                  underline: SizedBox(),
                  isDense: true,
                  items: mngDurationEnabled
                      ? mngDur.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList()
                      : null,
                  onChanged: (value) {
                    mng_durations = value.toString();
                    setState(() {
                      mng_durations_value = value.toString();
                    });

                    String aStr = mng_durations.replaceAll(new RegExp(r'[^0-9]'), '');
                    int aInt = int.parse(aStr);
                    mng_durations = aInt.toString();
                  },
                ),
              ])),
          Container(
              decoration: UIHelper.roundedBorderWithColorWithShadow(6, Colors.white),
              width: 82,
              height: 45,
              // height: 21
              child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                Text("Afternoon").fontSize(10),
                DropdownButton<String>(
                  value: aft_durations_value,
                  //elevation: 5,
                  style: TextStyle(color: Colors.black),
                  underline: SizedBox(),
                  isDense: true,
                  items: aftDurationEnabled
                      ? <String>['10 mins', '20 mins', '30 mins', '45 mins', '1 hour'].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList()
                      : null,
                  onChanged: (value) {
                    aft_durations = value.toString();
                    setState(() {
                      aft_durations_value = value.toString();
                    });

                    String afStr = aft_durations.replaceAll(new RegExp(r'[^0-9]'), '');
                    int afInt = int.parse(afStr);
                    aft_durations = afInt.toString();
                  },
                ),
              ])),
          Container(
              decoration: UIHelper.roundedBorderWithColorWithShadow(6, Colors.white),
              width: 82,
              height: 45,
              // height: 21
              child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                Text("Evening").fontSize(10),
                DropdownButton<String>(
                  value: evg_durations_value,
                  //elevation: 5,
                  style: TextStyle(color: Colors.black),
                  underline: SizedBox(),
                  isDense: true,
                  items: evgDurationEnabled
                      ? <String>['10 mins', '20 mins', '30 mins', '45 mins', '1 hour'].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList()
                      : null,
                  onChanged: (value) {
                    evg_durations = value.toString();
                    setState(() {
                      evg_durations_value = value.toString();
                    });
                    String evStr = evg_durations.replaceAll(new RegExp(r'[^0-9]'), '');
                    int evInt = int.parse(evStr);
                    evg_durations = evInt.toString();
                  },
                ),
              ])),
        ],
      )
    ]);
  }

  bool validDuration() {
    var div = 0;
    var divAftr = 0;
    var divEvg = 0;
    if (mngDurationEnabled) {
      int k = _mngvalues!.start.toInt();
      int l = _mngvalues!.end.toInt();
      int tot = l - k;
      if (tot > 0) {
        int dur = int.parse(mng_durations == "1 hour" ? "60" : mng_durations.replaceAll(new RegExp(r'[^0-9]'), '')), div = tot * 60 % dur;
        print(div.toString());
      }
      div = 1; //set validation failed(give same start and end time)
    }
    if (aftDurationEnabled) {
      int totAft = _afternoonvalues.end.toInt() - _afternoonvalues.start.toInt();
      if (totAft > 0) {
        int durAfter = int.parse(aft_durations == "1 hour" ? "60" : aft_durations.replaceAll(new RegExp(r'[^0-9]'), ''));
        divAftr = totAft * 60 % durAfter;
        print(divAftr.toString());
      } else
        divAftr = 1;
    }
    if (evgDurationEnabled) {
      int totEvg = _values.end.toInt() - _values.start.toInt();
      if (totEvg > 0) {
        int durEvg = int.parse(evg_durations == "1 hour" ? "60" : evg_durations.replaceAll(new RegExp(r'[^0-9]'), ''));
        divEvg = totEvg * 60 % durEvg;
        print(divEvg.toString());
      } else
        divEvg = 1;
    }

    // print(div.toString() + "sdfasdf" + div_aftr.toString() + "asldjfsdf" + div_evg.toString());
    return div == 0 && divAftr == 0 && divEvg == 0 ? true : false;
  }

  Widget save_widget(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        ElevatedButton(
            onPressed: () {
              //Get.back();
              // String k = st_date;
              // print(k);
              // Get.back();
              //showBottomSheet(context);
              Get.to(() => HomeScreen());
              //ss(context);
            },
            child: Text('Cancel').fontWeight(FontWeight.w600),
            style: ButtonStyle(
              minimumSize: MaterialStateProperty.all(Size(120, 36)),
              backgroundColor: MaterialStateProperty.all(Colors.grey),
            )),
        ViewModelBuilder<ManageCalenderWidgetmodel>.reactive(
            builder: (context, model, child) {
              return ElevatedButton(
                onPressed: () async {
                  if (validDuration()) {
                    //add session
                    String s = (double.parse((intial_range_evg.start).toStringAsFixed(2)) + 12.0).toString();
                    Map<String, dynamic> postParams = {};
                    if (mngDurationEnabled) {
                      String len = _mngvalues!.start.toInt().length;
                      String lenEnd = _mngvalues!.end.toInt().length;
                      postParams['mon_start_time'] = len == "1" ? "0" + _mngvalues!.start.toInt().toStringAsFixed(2).replaceAll(".", " :") : _mngvalues!.start.toInt().toStringAsFixed(2).replaceAll(".", " :");
                      postParams['mon_start_time'] = postParams['mon_start_time'].replaceAll(new RegExp(r"\s+"), "");
                      postParams['mon_end_time'] = lenEnd == "1" ? "0" + _mngvalues!.end.toInt().toStringAsFixed(2).replaceAll(".", " :") : _mngvalues!.end.toInt().toStringAsFixed(2).replaceAll(".", " :");
                      postParams['mon_end_time'] = postParams['mon_end_time'].replaceAll(new RegExp(r"\s+"), "");
                      mng_durations = mng_durations.replaceAll(new RegExp(r'[^0-9]'), '');
                      postParams['mon_duration'] = mng_durations;
                    }

                    if (aftDurationEnabled) {
                      String lenAft = _afternoonvalues.start.toInt().length;
                      postParams['afn_start_time'] =
                          lenAft == "1" ? "0" + _afternoonvalues.start.toInt() + 12.toStringAsFixed(2).replaceAll(".", " :") : _afternoonvalues.start.toInt().toStringAsFixed(2).replaceAll(".", " :");
                      postParams['afn_start_time'] = postParams['afn_start_time'].replaceAll(new RegExp(r"\s+"), "");
                      postParams['afn_end_time'] =
                          lenAft == "1" ? "0" + _afternoonvalues.end.toInt() + 12.toStringAsFixed(2).replaceAll(".", " :") : _afternoonvalues.end.toInt().toStringAsFixed(2).replaceAll(".", " :");
                      postParams['afn_end_time'] = postParams['afn_end_time'].replaceAll(new RegExp(r"\s+"), "");
                      aft_durations = aft_durations.replaceAll(new RegExp(r'[^0-9]'), '');
                      postParams['afn_duration'] = aft_durations;
                    }
                    if (evgDurationEnabled) {
                      String lenEve = _values.start.toInt().length;
                      postParams['eve_start_time'] = lenEve == "1" ? "0" + _values.start.toInt() + 12.toStringAsFixed(2).replaceAll(".", " :") : _values.start.toInt().toStringAsFixed(2).replaceAll(".", " :");
                      postParams['eve_start_time'] = postParams['eve_start_time'].replaceAll(new RegExp(r"\s+"), "");
                      postParams['eve_end_time'] = lenEve == "1" ? "0" + _values.end.toInt() + 12.toStringAsFixed(2).replaceAll(".", " :") : _values.end.toInt().toStringAsFixed(2).replaceAll(".", " :");
                      evg_durations = evg_durations.replaceAll(new RegExp(r'[^0-9]'), '');
                      postParams['eve_end_time'] = postParams['eve_end_time'].replaceAll(new RegExp(r"\s+"), "");
                      postParams['eve_duration'] = evg_durations;
                    }
                    // postParams['slot_date'] = st_date;
                    // postParams['slot_date'] = end_date;
                    postParams['services_type'] = widget.isContainer;
                    days.clear();
                    for (int i = 0; i <= en.difference(str).inDays; i++) {
                      days.add(str.add(Duration(days: i)));
                    }
                    print('----------------------' + s);
                    Loader.show(context);
                    var resp = await model.updateSession(postParams, days);
                    // if (toupdate) {
                    //   postParams['slot_date'] = DateFormat('MM-dd-yyyy').format(str).toString();
                    //   //   if(widget.isContainer=="clinic"){
                    //   //  //  var resp = await model.viewSessionByclinic(postParams,selection);
                    //   //   }else{
                    //   //   var resp = await model.updateSession(postParams);
                    //   //   }
                    //   var resp = await model.updateSession(postParams);
                    // } else {
                    //   var resp = await model.addSession(postParams, days);
                    // }

                    Loader.hide();
                    setState(() {
                      toupdate = false;
                      isViewWidget = true;
                    });
                    setState(() {});
                    // Get.back();
                  } else {
                    Fluttertoast.showToast(
                      msg: "Please give proper duration",
                      backgroundColor: Colors.grey.shade400,
                      gravity: ToastGravity.BOTTOM,
                      textColor: Colors.black,
                    );
                  }
                },
                child: Text('Save').fontWeight(FontWeight.w600),
                style: ButtonStyle(
                  minimumSize: MaterialStateProperty.all(Size(120, 36)),
                  backgroundColor: MaterialStateProperty.all(Colors.green),
                ),
              );
            },
            viewModelBuilder: () => ManageCalenderWidgetmodel()),
      ],
    );
  }

  void selectionChanged(DateRangePickerSelectionChangedArgs args) {
    SchedulerBinding.instance!.addPostFrameCallback((duration) {
      setState(() {
        //  String ar = args.value;
        String sf = DateFormat('dd, MMMM yyyy').format(args.value).toString();
      });
      print('------args' + args.value.toString());
    });
  }

  int daysBetween_wrong1(DateTime date1, DateTime date2) {
    return date1.difference(date2).inDays;
  }

  @override
  Widget build(BuildContext context) {
    String startDt = Jiffy().format('MM-dd-yyyy');
    String getLimitDay = Jiffy(DateTime.now()).add(months: 3).format('MM-dd-yyyy').toString();
    DateTime getLimit = Jiffy(DateTime.now()).add(months: 3).dateTime;
    List<DateTime> dates = [
      DateTime.parse("2022-02-23"),
      DateTime.parse("2022-02-24"),
      DateTime.parse("2022-02-25"),
    ];
    List<DateTime> nxtDates = [
      DateTime.parse("2022-02-27"),
      DateTime.parse("2022-02-28"),
    ];

    //ava_il = widget.available_dates.toList();
    ava_il = current_available_dates.toList();
//    var glist = widget.dataView;
//validate_convert_dates
    var glist = current_dataView;
    List<DateTime> DateList = [];
    //  List<DateTime> gts=DateFormat('MM-dd-yyyy').format(widget.dataView['slot_date']).toString() as List<DateTime>;

    DateFormat format = DateFormat("MM-dd-yyyy");
    //widget.dataView.length > 0 ? DateList = widget.dataView.map<DateTime>((string) => format.parse(string['slot_date'])).toList() : DateList = [];
    current_dataView.length > 0 ? DateList = current_dataView.map<DateTime>((string) => format.parse(string['slot_date'])).toList() : DateList = [];
    final Color weekEndColor = Color(0xFF0e9aa7), specialDatesColor = Colors.green, todayColor = Color(0xFFff6f69), leadingTrailingDatesColor = Color(0xFF88d8b0), blackoutDatesColor = Colors.black;
    return Scaffold(
        appBar: SwarAppDoctorBar(isProfileBar: false),
        backgroundColor: Colors.white,
        // floatingActionButton: FloatingActionButton(
        //   backgroundColor: activeColor,
        //   child: Icon(Icons.post_add),
        //   mini: true,
        //   onPressed: () {},
        // ),
        body: SafeArea(
            top: false,
            child: SingleChildScrollView(
                child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              width: Screen.width(context),
              child: ViewModelBuilder<ManageCalenderWidgetmodel>.reactive(
                  onModelReady: (model) async {
                    // await model.viewSession('sadf', 'asdfdf');
                    print("ready");
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
                      UIHelper.verticalSpaceSmall,
                      widget.isContainer.toLowerCase().contains("in clinic") ? Text("   In Clinic", textAlign: TextAlign.left).fontWeight(FontWeight.w600) : SizedBox(),
                      UIHelper.verticalSpaceSmall,
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        widget.isContainer.toLowerCase().contains("in clinic")
                            ? StreamedWidget(
                                stream: preferencesService.clinicListStream!.outStream!,
                                builder: (context, snapshot) {
                                  List<dynamic> clinicList = preferencesService.clinicListStream!.value!;
                                  // selection = clinic_list[0];
                                  // List<dynamic> members = snapshot.data! as List<dynamic>;
                                  return Row(
                                    children: [
                                      UIHelper.horizontalSpaceSmall,
                                      Container(
                                          width: Screen.width(context) / 3,
                                          child: clinicList.length > 1
                                              ? DropdownButton(
                                                  isExpanded: true,
                                                  // value:model.selectedMembers==null ||model.selectedMembers.isEmpty ?preferencesService.dropdown_user_id :model.selectedMembers,
                                                  // value: preferencesService.dropdown_user_id,
                                                  //  value:snapshot.data!,
                                                  // value: model.selectedMembers,
                                                  value: selection.isNotEmpty ? selection : clinicList[0],
                                                  items: clinicList.map((e) {
                                                    return new DropdownMenuItem(
                                                        value: e,
                                                        child: new Text(
                                                          e['clinic_name'],
                                                          overflow: TextOverflow.ellipsis,
                                                          softWrap: true,
                                                        ).fontSize(14).fontWeight(FontWeight.w600)
                                                        //child: new Text("newmem").fontSize(13),
                                                        );
                                                  }).toList(),
                                                  onChanged: (value) async {
                                                    print(value);
                                                    setState(() {
                                                      selection = value;
                                                    });
                                                    String startDt = Jiffy().format('MM-dd-yyyy');
                                                    String getLimit = Jiffy(DateTime.now()).add(months: 3).format('MM-dd-yyyy').toString();
                                                    Loader.show(context);
                                                    await model.viewSessionByclinic(startDt, getLimit, selection['information_Id'].toLowerCase().toString());
                                                    setState(() {
                                                      // widget.dataView=model.calender_date_view;
                                                      current_dataView = model.calender_date_view;
                                                      current_available_dates = model.convert_dates;
                                                      clinicName = selection['clinic_name'].toLowerCase().toString();
                                                      clinicId = selection['clinic_Id'];
                                                    });
                                                    Loader.hide();
                                                  })
                                              : Text(
                                                  clinicList.length > 0 ? clinicList[0]['clinic_name'].toString() : '',
                                                  overflow: TextOverflow.ellipsis,
                                                  softWrap: true,
                                                ).fontSize(18).bold())
                                    ],
                                  );
                                })
                            : Text("  " + widget.isContainer, textAlign: TextAlign.left).fontWeight(FontWeight.w600),
                        GestureDetector(
                          onTap: () async {
                            // await model.viewSession('02-24-2022', '02-26-2022');
                            // Get.to(() => AvailabilityCalenderView(dateView: model.get_session_view));

                            // Get.to(() => ManageCalenderWidget(
                            //       isContainer: true,
                            //     ));

                            // setState(() {
                            //   isViewWidget = !isViewWidget;
                            // });
                            // Get.to(
                            //     AddAvailabilityCalenderView(
                            //         dataView: current_dataView, dateView: selection_date_list, serviceType: widget.isContainer, pickerDay: selection_date_list['slot_date'], clinicName: clinicName.toLowerCase()),
                            //     duration: Duration(seconds: 1),
                            //     transition: Transition.downToUp);
//******* changes  */
                            // List<DateTime> DateListAll = [];
                            // //  List<DateTime> gts=DateFormat('MM-dd-yyyy').format(widget.dataView['slot_date']).toString() as List<DateTime>;
                            // //validate_calender_date_view
                            // var d2;
                            // dynamic d = selection_date_list;
                            // DateFormat format = DateFormat("MM-dd-yyyy");
                            // var totalDates = model.validate_calender_date_view;
                            // totalDates.map((userg) => {
                            //       // from = Jiffy(user['slot_date']),
                            //       // d2 = from.format('MM-dd-yyyy'),

                            //       d2 = userg['slot_date'],
                            //       // if (d2 != null && d2 == d1)
                            //       //   {
                            //       //     selection_date_list = user,
                            //       //     // setState(() {
                            //       //     //   isload = true;
                            //       //     //   // toupdate = true;
                            //       //     //   isChangedSelection = true;
                            //       //     // })
                            //       //   }
                            //     });

                            // // selection_date_list = userg['slot_date'],
                            // //widget.dataView.length > 0 ? DateList = widget.dataView.map<DateTime>((string) => format.parse(string['slot_date'])).toList() : DateList = [];
                            // current_dataView.length > 0 ? DateListAll = model.validate_calender_date_view.map<DateTime>((string) => format.parse(string['slot_date'])).toList() : DateListAll = [];
                            // print(DateListAll.length);

                            //******* changes  ***********************8*/
                            String startDt = Jiffy().format('MM-dd-yyyy');
                            String getLimit = Jiffy(DateTime.now()).add(months: 3).format('MM-dd-yyyy').toString();
                            clinicName != ""
                                ?
                                //await model.get
                                await model.viewSessionByclinic(startDt, getLimit, preferencesService.clinicListStream!.value![0]['information_Id'])
                                : await model.viewSession(startDt, getLimit, widget.isContainer);
                            final result = await Get.to(
                                AddAvailabilityCalenderView(
                                    //dataView: current_dataView,
                                    dataView: model.validate_calender_date_view,
                                    dateView: selection_date_list,
                                    serviceType: widget.isContainer,
                                    pickerDay: selection_date_list['slot_date'],
                                    clinicName: clinicName.toLowerCase(),
                                    clinicId: clinicId,
                                    sessionTime: widget.sessionTime),
                                duration: Duration(seconds: 1),
                                transition: Transition.downToUp);
                            if (result != null) {
                              //  await model.viewSessionByclinic(startDt, getLimit_day, clinicName.toLowerCase()); // call your own function here to refresh screen
                              setState(() {});
                            }
                            // Navigator.pop(
                            //     context,
                            //     MaterialPageRoute(
                            //       builder: (context) => AddAvailabilityCalenderView(
                            //           dataView: model.validate_calender_date_view,
                            //           dateView: selection_date_list,
                            //           serviceType: widget.isContainer,
                            //           pickerDay: selection_date_list['slot_date'],
                            //           clinicName: clinicName.toLowerCase()),
                            //     ));

                            // //await model.viewSession(startDt, getLimit_day, clinicName.toLowerCase());
                            // setState(() {});
                            // String received = await Navigator.pushReplacement(
                            //     context,
                            //     MaterialPageRoute(
                            //       builder: (_) => AddAvailabilityCalenderView(
                            //           dataView: current_dataView,
                            //           dateView: selection_date_list,
                            //           serviceType: widget.isContainer,
                            //           pickerDay: selection_date_list['slot_date'],
                            //           clinicName: clinicName.toLowerCase(),
                            //           clinicId: clinicId,
                            //           sessionTime: widget.sessionTime),
                            //     ));
                            // if (result != null) {
                            //   //  await model.viewSessionByclinic(startDt, getLimit_day, clinicName.toLowerCase()); // call your own function here to refresh screen
                            //    setState(() {});
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
                                  Text(!isViewWidget ? 'View' : 'New').fontSize(12).fontWeight(FontWeight.w600),
                                  isViewWidget ? Icon(Icons.post_add, size: 20, color: activeColor) : Icon(Icons.grid_on, size: 20, color: activeColor),
                                ],
                              )),
                        ),
                      ]),
                      UIHelper.verticalSpaceMedium,
                      UIHelper.verticalSpaceMedium,
                      Container(
                          height: 450,
                          decoration: UIHelper.roundedBorderWithColorWithShadow(6, Colors.white),
                          // decoration:
                          //     //  preferencesService.stage_level_count! == 2 || preferencesService.stage_level_count! > 2
                          //     UIHelper.rightcornerRadiuswithColorDoctor(4, 20, Colors.white),
                          padding: EdgeInsets.all(4),
                          child: isViewWidget
                              ? SfDateRangePicker(
                                  //onSelectionChanged: selectionChanged,
                                  //showLeadingAndTrailingDates
                                  // startRangeSelectionColor: activeColor,
                                  view: DateRangePickerView.month,
                                  maxDate: getLimit,
                                  enablePastDates: false,
                                  selectionTextStyle: TextStyle(fontStyle: FontStyle.normal, fontWeight: FontWeight.w500, fontSize: 14, color: Colors.white),
                                  // monthCellStyle: DateRangePickerMonthCellStyle(
                                  //   todayTextStyle: TextStyle(color: Colors.cyanAccent),
                                  //   cellDecoration: BoxDecoration(color: Colors.teal, shape: BoxShape.circle),
                                  // ),
                                  monthCellStyle: DateRangePickerMonthCellStyle(
                                    specialDatesDecoration: BoxDecoration(shape: BoxShape.circle, color: specialDatesColor),
                                    specialDatesTextStyle: TextStyle(color: Colors.white),
                                    cellDecoration: BoxDecoration(shape: BoxShape.circle),
                                    todayCellDecoration: BoxDecoration(shape: BoxShape.circle, color: Colors.blue.shade200),
                                    // weekendDatesDecoration: BoxDecoration(color: weekEndColor, border: Border.all(width: 1), shape: BoxShape.circle),
                                    // trailingDatesDecoration: BoxDecoration(
                                    //     shape: BoxShape.rectangle, color: leadingTrailingDatesColor),
                                    // leadingDatesDecoration: BoxDecoration(
                                    //     shape: BoxShape.rectangle, color: leadingTrailingDatesColor)
                                  ),
                                  initialSelectedDate: DateTime.now(),

                                  monthViewSettings: DateRangePickerMonthViewSettings(
                                    numberOfWeeksInView: 6,
                                    firstDayOfWeek: 7,
                                    dayFormat: 'EEE',
                                    //viewHeaderHeight: 70,
                                    showTrailingAndLeadingDates: true,
                                    // specialDates: <DateTime>[DateTime.now().add(Duration(days: 7)), DateTime.now().add(Duration(days: 8))],
                                    specialDates: DateList,
                                    //blackoutDates
                                  ),

                                  // endRangeSelectionColor: activeColor,
                                  // rangeSelectionColor: Color(0xFFFFEFEF),
                                  toggleDaySelection: false,
                                  selectionShape: DateRangePickerSelectionShape.circle,
                                  selectionMode: DateRangePickerSelectionMode.single,
                                  //selectionRadius: 30.0,

                                  //selectionColor: Color(0xFFF7CECD),
                                  selectionColor: activeColor,
                                  selectionRadius: 30.0,

                                  //initialSelectedRange: PickerDateRange(DateTime.now().subtract(const Duration(days: 4)), DateTime.now().add(const Duration(days: 3))),
                                  onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                                    print(args.value);
                                    str = args.value;
                                    selection_date_list = {};
                                    if (args.value != null) {
                                      DateFormat form = DateFormat("MM-dd-yyyy");
//                                    if (selection_date_list != "") selection_date_list.clear();
                                      var d1 = DateFormat('MM-dd-yyyy').format(args.value);
                                      var d2;
                                      Jiffy from;
                                      if (glist.length > 0) {
                                        glist
                                            .map((user) => {
                                                  // from = Jiffy(user['slot_date']),
                                                  // d2 = from.format('MM-dd-yyyy'),

                                                  d2 = user['slot_date'],
                                                  if (d2 != null && d2 == d1)
                                                    {
                                                      selection_date_list = user,
                                                      // setState(() {
                                                      //   isload = true;
                                                      //   // toupdate = true;
                                                      //   isChangedSelection = true;
                                                      // })
                                                    }
                                                  // else
                                                  //   {setState(() {})}
                                                })
                                            .toList();
                                        setState(() {
                                          isload = true;
                                          // toupdate = true;
                                          isChangedSelection = true;
                                        });
                                        // setState(() {
                                        //   //  toupdate = true;
                                        // });
                                      } else {}

                                      // setState(() {
                                      //   //  toupdate = true;
                                      // });
                                      print("========selection date list======" + selection_date_list.toString());
                                    }
                                    if (selection_date_list.isNotEmpty) showBottomSheet(context, model);
                                  },
                                  onViewChanged: (DateRangePickerViewChangedArgs args) {
                                    final PickerDateRange visibleDates = args.visibleDateRange;
                                    final DateRangePickerView view = args.view;
                                    // setState(() {
                                    //   isViewWidget = true;
                                    // });
                                  },
                                )

                              // CustomTableCalendar(dataView: glist)
                              : SfDateRangePicker(
                                  //onSelectionChanged: selectionChanged,
                                  //showLeadingAndTrailingDates
                                  // startRangeSelectionColor: activeColor,
                                  view: DateRangePickerView.month,
                                  maxDate: getLimit,
                                  enablePastDates: false,
                                  selectionTextStyle: TextStyle(fontStyle: FontStyle.normal, fontWeight: FontWeight.w500, fontSize: 12, color: Colors.black),
                                  monthCellStyle: DateRangePickerMonthCellStyle(
                                    blackoutDateTextStyle: TextStyle(color: blackoutDatesColor),
                                    blackoutDatesDecoration: BoxDecoration(shape: BoxShape.circle, color: Color(0xFFF7CECD)),
                                  ),

                                  monthViewSettings: DateRangePickerMonthViewSettings(
                                      numberOfWeeksInView: 6,
                                      firstDayOfWeek: 7,
                                      dayFormat: 'EEE',
                                      //viewHeaderHeight: 70,
                                      showTrailingAndLeadingDates: true,
                                      //specialDates: <DateTime>[DateTime.now().add(Duration(days: 7)), DateTime.now().add(Duration(days: 8))],

                                      blackoutDates: DateList),
                                  startRangeSelectionColor: activeColor,
                                  endRangeSelectionColor: activeColor,
                                  rangeSelectionColor: Color(0xFFFFEFEF),
                                  toggleDaySelection: false,
                                  selectionShape: DateRangePickerSelectionShape.circle,
                                  selectionMode: DateRangePickerSelectionMode.range,
                                  //selectionRadius: 30.0,

                                  //selectionColor: Color(0xFFF7CECD),
                                  selectionColor: activeColor,
                                  selectionRadius: 20.0,

                                  //initialSelectedRange: PickerDateRange(DateTime.now().subtract(const Duration(days: 4)), DateTime.now().add(const Duration(days: 3))),
                                  onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                                    if (args.value != null) {
                                      String sf = DateFormat('MM-dd-yyyy').format(args.value.startDate).toString();
                                      String end = DateFormat('MM-dd-yyyy').format(args.value.endDate).toString();

                                      str = args.value.startDate;
                                      en = args.value.endDate;

                                      // range_start_date = args.value.startDate;
                                      // range_end_date = args.value.endDate;
                                      st_date = sf;
                                      end_date = end;
                                      setState(() {
                                        toupdate = false;
                                      });
                                    }
                                  },
                                  onViewChanged: (DateRangePickerViewChangedArgs args) {
                                    final PickerDateRange visibleDates = args.visibleDateRange;
                                    final DateRangePickerView view = args.view;
                                    // setState(() {
                                    //   isViewWidget = true;
                                    // });
                                  },
                                )),
                      toupdate || editMode || !isViewWidget
                          ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              UIHelper.verticalSpaceSmall,
                              UIHelper.hairLineWidget(),
                              UIHelper.verticalSpaceSmall,
                              Text(widget.sessionTime[0]),
                              Text("Adjust Session Timings", textAlign: TextAlign.left).bold(),
                              UIHelper.verticalSpaceSmall,
                              //         // if(isViewWidget)
                              //         // getMorningMode(context, 'assets/morning_icon.png', 'Morning  ', 'Home Visit', '12.00 am - 8.00 am', widget.dataView['morning_slots'] != null ? widget.dataView['morning_slots'][0] : ''),
                              //         // getAfternoonMode(context, 'assets/afternoon_icon.png', 'Afternoon', 'Online', '12.00 pm - 3.00 pm', widget.dataView['afternoon_slots'] != null ? widget.dataView['afternoon_slots'][0] : ''),
                              //         // getEvgMode(context, 'assets/evening_icon.png', 'Evening', 'Home Visit', '4.00 pm - 8.00 pm', widget.dataView['evening_slots'] != null ? widget.dataView['evening_slots'][0] : ''),

                              //         // //glist
                              //         // toupdate
                              //         //     ? getMorningMode(context, 'assets/morning_icon.png', 'Morning  ', 'Home Visit', selection_date_list['morning_slots'] != null ? selection_date_list['morning_slots'] : '')
                              //         //     : UIHelper.verticalSpaceSmall,
                              //         // toupdate
                              //         //     ? getAfternoonMode(context, 'assets/afternoon_icon.png', 'Afternoon', 'Online', selection_date_list['afternoon_slots'] != null ? selection_date_list['afternoon_slots'] : '')
                              //         //     : UIHelper.verticalSpaceSmall,
                              //         // toupdate
                              //         //     ? getEvgMode(context, 'assets/evening_icon.png', 'Evening', 'Home Visit', selection_date_list['evening_slots'] != null ? selection_date_list['evening_slots'] : '')
                              //         //     : UIHelper.verticalSpaceSmall,

                              getMorningMode(context, 'assets/morning_icon.png', 'Morning  ', 'Home Visit', selection_date_list['morning_slots'] != null ? selection_date_list['morning_slots'] : '', false,
                                  widget.sessionTime.length < 0 ? model.setSessionTime.toList() : widget.sessionTime),
                              getAfternoonMode(context, 'assets/afternoon_icon.png', 'Afternoon', 'Online', selection_date_list['afternoon_slots'] != null ? selection_date_list['afternoon_slots'] : '', false),
                              getEvgMode(context, 'assets/evening_icon.png', 'Evening', 'Home Visit', selection_date_list['evening_slots'] != null ? selection_date_list['evening_slots'] : '', false),

                              UIHelper.hairLineWidget(),
                              duration_widget(),
                              UIHelper.verticalSpaceSmall,
                              UIHelper.verticalSpaceSmall,
                              save_widget(context)
                            ])
                          : SizeTransition(
                              sizeFactor: _animation!,
                              axis: Axis.vertical,
                              child:
                                  // AnimatedContainer(
                                  //     duration: new Duration(milliseconds: 200),
                                  //     curve: Curves.easeInOut,
                                  //     child:
                                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                getMorningMode(context, 'assets/morning_icon.png', 'Morning  ', 'Home Visit', selection_date_list['morning_slots'] != null ? selection_date_list['morning_slots'] : '', true,
                                    widget.sessionTime.length < 0 ? model.setSessionTime.toList() : widget.sessionTime),
                                getAfternoonMode(context, 'assets/afternoon_icon.png', 'Afternoon', 'Online', selection_date_list['afternoon_slots'] != null ? selection_date_list['afternoon_slots'] : '', true),
                                getEvgMode(context, 'assets/evening_icon.png', 'Evening', 'Home Visit', selection_date_list['evening_slots'] != null ? selection_date_list['evening_slots'] : '', true),
                              ]))
                    ]);
                  },
                  viewModelBuilder: () => ManageCalenderWidgetmodel()),
            ))));
  }
}

class MyCustomRoute<T> extends MaterialPageRoute<T> {
  MyCustomRoute({WidgetBuilder? builder, RouteSettings? settings}) : super(builder: builder!, settings: settings);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    // if (settings.isInitialRoute)
    //   return child;
    // Fades between routes. (If you don't want any animation,
    // just return child.)
    //return new FadeTransition(opacity: animation, child: child);
    return new SlideTransition(
      position: Tween(begin: Offset(1.0, 0.0), end: Offset(0.0, 0.0)).animate(animation),
      child: child,
    );
  }
}
