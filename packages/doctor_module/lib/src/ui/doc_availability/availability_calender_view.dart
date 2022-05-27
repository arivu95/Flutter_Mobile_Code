import 'package:doctor_module/src/ui/doc_availability/manage_calender_availability_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:swarapp/shared/app_colors.dart';
import 'package:swarapp/shared/app_doctorprofile_bar.dart';
import 'package:swarapp/shared/app_static_bar.dart';
import 'package:swarapp/shared/flutter_overlay_loader.dart';
import 'package:swarapp/shared/screen_size.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:user_module/src/ui/appoinments/appointment_list_view.dart';
import 'package:user_module/src/ui/doctor_nurse/doctor_nurse_view.dart';
import 'package:stacked/src/state_management/view_model_builder.dart';
import 'package:jiffy/jiffy.dart';
import 'package:intl/src/intl/date_format.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AvailabilityCalenderView extends StatefulWidget {
  final dynamic dateView;
  final String serviceType;
  final String pickerDay;
  final String clinicName;
  final String clinicId;
  dynamic sessionTime;
  AvailabilityCalenderView({Key? key, required this.dateView, required this.serviceType, required this.pickerDay, required this.clinicName, required this.clinicId, required this.sessionTime}) : super(key: key);
  @override
  _AvailabilityCalenderViewState createState() => _AvailabilityCalenderViewState();
}

final kToday = DateTime.now();
final kFirstDay = DateTime(kToday.year, kToday.month - 3, kToday.day);
final kLastDay = DateTime(kToday.year, kToday.month + 3, kToday.day);

class _AvailabilityCalenderViewState extends State<AvailabilityCalenderView> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  int selectedIndex = 0;
  dynamic response = [];
  bool isViewWidget = false;
  bool isChangedSelection = false;
  bool ismngEdit = false;
  bool isaftEdit = false;
  bool isevgEdit = false;
  // SfRangeValues edit_mngvalues = SfRangeValues(7.0, 9.0);
  // SfRangeValues edit_afternoonvalues = SfRangeValues(2.0, 4.0);
  // SfRangeValues edit_values = SfRangeValues(7.0, 9.0);

  SfRangeValues? edit_mngvalues;
  SfRangeValues? edit_afternoonvalues;
  SfRangeValues? edit_values;

  bool editmngDurationEnabled = true;
  bool editaftDurationEnabled = true;
  bool editevgDurationEnabled = true;

  String edit_mng_durations = "10 mins";
  String edit_aft_durations = "10 mins";
  String edit_evg_durations = "10 mins";

  String edit_mng_durations_value = "10 mins";
  String edit_aft_durations_value = "10 mins";
  String edit_evg_durations_value = "10 mins";
  RangeValues intial_range_morning = RangeValues(2.0, 8.0);
  RangeValues intial_range_afternoon = RangeValues(3.0, 8.0);
  RangeValues intial_range_evg = RangeValues(2.0, 2.5);
  RangeValues init_evg_range = RangeValues(2.0, 4.0);
  bool toupdate = false;
  DateTime str = new DateTime.now();
  DateTime en = new DateTime.now();
  List<DateTime> days = [];
  String pickedDate = "";

  get yyyy => null;

  Widget horizandalcalendar(BuildContext context, ManageCalenderWidgetmodel model) {
    return Container(
      decoration: UIHelper.allcornerRadiuswithbottomShadow(6, 6, 6, 6, Colors.white),
      child: TableCalendar(
        firstDay: kFirstDay,
        lastDay: kLastDay,
        focusedDay: _focusedDay,
        headerStyle: HeaderStyle(
          titleTextStyle: TextStyle(fontSize: 14.0),
          headerPadding: const EdgeInsets.only(bottom: 7.0, top: 7.0),
          leftChevronPadding: EdgeInsets.all(0.0),
          rightChevronPadding: const EdgeInsets.all(0.0),
          leftChevronMargin: const EdgeInsets.symmetric(horizontal: 0.0),
          rightChevronMargin: const EdgeInsets.symmetric(horizontal: 0.0),
          formatButtonVisible: false,
          decoration: const BoxDecoration(
            color: fieldBgColor,
          ),
        ),
        calendarStyle: CalendarStyle(
          todayDecoration: const BoxDecoration(color: productOfferBgColor, shape: BoxShape.circle),
          todayTextStyle: TextStyle(color: Colors.black),
          selectedTextStyle: TextStyle(color: Colors.white),
          selectedDecoration: const BoxDecoration(color: activeColor, shape: BoxShape.circle),
        ),
        calendarFormat: _calendarFormat,
        selectedDayPredicate: (day) {
          return isSameDay(_selectedDay, day);
        },
        onDaySelected: (selectedDay, focusedDay) async {
          if (!isSameDay(_selectedDay, selectedDay)) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
              print(_selectedDay);
              print(_focusedDay);
            });

            // DateFormat dateTime =DateFormat('MM-dd-yyyy');
            //  DateTime dateTime = new DateFormat("yyyyMMMdd").parse(_selectedDay);
            Loader.show(context);
            await model.viewSession(_selectedDay.toString(), widget.serviceType.toLowerCase(), '');
            Loader.hide();
            setState(() {
              isViewWidget = true;
            });
          }
        },
        onFormatChanged: (format) {
          if (_calendarFormat != format) {
            setState(() {
              _calendarFormat = format;
            });
          }
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
      ),
    );
  }

  Widget slotcard(BuildContext context, String t1, String t2, String t3) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              selectedIndex = 0;
            });
          },
          child: Container(
            decoration: selectedIndex == 0 ? UIHelper.normalbox(5, activeColor) : UIHelper.normalbox(5, Colors.white),
            padding: EdgeInsets.all(4),
            child: Text(t1, style: selectedIndex == 0 ? TextStyle(color: Colors.white) : TextStyle(color: Colors.black)).fontSize(12),
          ),
        ),
        UIHelper.horizontalSpaceSmall,
        GestureDetector(
          onTap: () {
            setState(() {
              selectedIndex = 1;
            });
          },
          child: Container(
            decoration: selectedIndex == 1 ? UIHelper.normalbox(5, activeColor) : UIHelper.normalbox(5, Colors.white),
            padding: EdgeInsets.all(4),
            child: Text(t2, style: selectedIndex == 1 ? TextStyle(color: Colors.white) : TextStyle(color: Colors.black)).fontSize(12),
          ),
        ),
        UIHelper.horizontalSpaceSmall,
        GestureDetector(
          onTap: () {
            setState(() {
              selectedIndex = 1;
            });
          },
          child: Container(
            decoration: selectedIndex == 1 ? UIHelper.normalbox(5, activeColor) : UIHelper.normalbox(5, Colors.white),
            padding: EdgeInsets.all(4),
            child: Text(t3, style: selectedIndex == 1 ? TextStyle(color: Colors.white) : TextStyle(color: Colors.black)).fontSize(12),
          ),
        ),
        UIHelper.horizontalSpaceSmall,
      ],
    );
  }

  Future<void> _popupselect(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
          insetPadding: EdgeInsets.all(15),
          contentPadding: EdgeInsets.all(8),
          content: Container(
            width: Screen.width(context) - 16,
            height: 300,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: Text('Confirm Booking').fontSize(18).textColor(Colors.black).textAlignment(TextAlign.center)),
                    GestureDetector(
                      onTap: () async {
                        setState(() {
                          Navigator.pop(context);
                        });
                      },
                      child: Icon(
                        Icons.close,
                        size: 30,
                      ),
                    ),
                  ],
                ),
                UIHelper.hairLineWidget(),
                UIHelper.verticalSpaceSmall,
                Container(
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Image.asset(
                    'assets/doctor.png',
                    fit: BoxFit.cover,
                  ),
                  UIHelper.horizontalSpaceSmall,
                  Row(
                    children: [
                      Container(
                          padding: EdgeInsets.all(5),
                          decoration: UIHelper.roundedBorderWithColorWithShadow(6, Colors.white),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Dr. Ganesh').fontSize(12).fontWeight(FontWeight.w600),
                              UIHelper.verticalSpaceTiny,
                              Text('General Physician').fontSize(10).textColor(Colors.black38),
                              UIHelper.verticalSpaceSmall,
                              Row(
                                children: [
                                  Text('Insurance accepted').fontSize(10).fontWeight(FontWeight.w600),
                                  Icon(
                                    Icons.done,
                                    size: 20,
                                    color: Colors.green,
                                  )
                                ],
                              ),
                            ],
                          )),
                      UIHelper.horizontalSpaceSmall,
                      Column(children: [
                        UIHelper.verticalSpaceMedium,
                        Text('Rating 4.5').fontSize(10).fontSize(10).fontWeight(FontWeight.w600),
                        UIHelper.verticalSpaceTiny,
                        Row(children: [
                          Icon(
                            Icons.star_rate_outlined,
                            size: 15,
                            color: Colors.red,
                          ),
                          Icon(
                            Icons.star_rate_outlined,
                            size: 15,
                            color: Colors.red,
                          ),
                          Icon(
                            Icons.star_rate_outlined,
                            size: 15,
                            color: Colors.red,
                          ),
                          Icon(
                            Icons.star_rate_outlined,
                            size: 15,
                            color: Colors.red,
                          ),
                          Icon(
                            Icons.star_rate_outlined,
                            size: 15,
                            color: Colors.black,
                          ),
                        ])
                      ])
                    ],
                  ),
                ])),
                UIHelper.verticalSpaceSmall,
                Container(
                    child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Text('Date  '),
                        UIHelper.verticalSpaceSmall,
                        Text('Sep 10').bold(),
                      ],
                    ),
                    UIHelper.horizontalSpaceSmall,
                    Container(
                      width: 1,
                      height: 60,
                      color: Colors.grey,
                    ),
                    UIHelper.horizontalSpaceSmall,
                    Column(
                      children: [
                        Text('Time'),
                        UIHelper.verticalSpaceSmall,
                        Text(' 11:00 am').bold(),
                      ],
                    ),
                    UIHelper.horizontalSpaceSmall,
                    Container(
                      width: 1,
                      height: 60,
                      color: Colors.grey,
                    ),
                    UIHelper.horizontalSpaceSmall,
                  ],
                )),
                UIHelper.verticalSpaceMedium,
                Container(
                    child: Column(
                  children: [
                    ElevatedButton(
                        onPressed: () async {
                          Get.to(() => AppoinmentListView());
                        },
                        child: Text('Book Now').bold(),
                        style: ButtonStyle(
                          minimumSize: MaterialStateProperty.all(Size(160, 40)),
                          backgroundColor: MaterialStateProperty.all(activeColor),
                        )),
                  ],
                ))
              ],
            ),
          ),
        );
      },
    );
  }

  Widget requestcard(
    BuildContext context,
  ) {
    return Container(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(5),
          width: Screen.width(context),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Image.asset('assets/doctor.png'),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                      padding: EdgeInsets.all(5),
                      decoration: UIHelper.allcornerRadiuswithbottomShadow(12, 12, 12, 12, Colors.white),
                      child: Column(
                        children: [
                          Text('Dr. Ganesh').fontSize(12).fontWeight(FontWeight.w600),
                          UIHelper.verticalSpaceTiny,
                          Text('General Physician').fontSize(10).textColor(Colors.black38),
                          UIHelper.verticalSpaceTiny,
                          Row(
                            children: [
                              Text('Insurance accepted').fontSize(10).fontWeight(FontWeight.w600),
                              Icon(
                                Icons.done,
                                size: 20,
                                color: Colors.green,
                              )
                            ],
                          ),
                        ],
                      )),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  UIHelper.verticalSpaceSmall,
                  Container(
                    height: 20,
                    padding: EdgeInsets.only(left: 4, right: 4),
                    decoration: UIHelper.roundedBorderWithColorWithShadow(6, Colors.white70),
                    child: Row(
                      children: [
                        Align(
                          alignment: Alignment.topRight,
                          child: Text('Favorite').fontSize(10).textColor(Colors.black87),
                        ),
                        UIHelper.horizontalSpaceSmall,
                        Icon(
                          Icons.favorite_border,
                          color: Colors.red,
                          size: 14,
                        ),
                      ],
                    ),
                  ),
                  UIHelper.verticalSpaceSmall,
                  Container(
                    height: 20,
                    padding: EdgeInsets.only(left: 4, right: 4),
                    decoration: UIHelper.roundedBorderWithColorWithShadow(6, Colors.white70),
                    child: Row(
                      children: [
                        Icon(
                          Icons.done_rounded,
                          color: Colors.green,
                          size: 14,
                        ),
                        UIHelper.horizontalSpaceSmall,
                        Text('Verified').fontSize(10).textColor(Colors.black87),
                      ],
                    ),
                  ),
                  UIHelper.verticalSpaceSmall,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text(
                            'Patients',
                          ).fontSize(10).fontWeight(FontWeight.w500),
                          Text(
                            'visit',
                          ).fontSize(10).fontWeight(FontWeight.w500),
                        ],
                      ),
                      Text(' 1.5K').fontSize(16).fontWeight(FontWeight.w200).textColor(activeColor),
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
        Container(
            width: Screen.width(context),
            child: Row(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              ElevatedButton(
                  onPressed: () async {},
                  child: Row(
                    children: [
                      Icon(
                        Icons.videocam,
                        color: Colors.white,
                        size: 14,
                      ),
                      UIHelper.horizontalSpaceSmall,
                      Text('Video Consult').fontSize(13).textColor(Colors.white),
                    ],
                  ),
                  style: ButtonStyle(
                      minimumSize: MaterialStateProperty.all(Size(70, 40)),
                      backgroundColor: MaterialStateProperty.all(activeColor),
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))))),
              UIHelper.horizontalSpaceSmall,
              ElevatedButton(
                  onPressed: () async {
                    // Get.to(() => DoctorNurseView());
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.home,
                        color: Colors.black,
                        size: 14,
                      ),
                      UIHelper.horizontalSpaceSmall,
                      Text('In Clinic Consult').fontSize(13).textColor(Colors.black),
                    ],
                  ),
                  style: ButtonStyle(
                      minimumSize: MaterialStateProperty.all(Size(70, 40)),
                      backgroundColor: MaterialStateProperty.all(Colors.white70),
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))))),
            ])),
        UIHelper.verticalSpaceSmall,
      ],
    ));
  }

  Widget getMorningMode(BuildContext context, String asseturl, String title, String manageType, dynamic getslotMorning, bool isViewmode, List<dynamic> check) {
    String mong = "";
    String mongEnd = "";
    SfRangeValues mng = SfRangeValues(0.0, 0.0);
    print(getslotMorning.toString());
    dynamic vaf = check.where((e) {
      return e['name'].toString().toLowerCase().contains("morning");
    }).toList();
    double mngSrt = vaf.isNotEmpty ? vaf[0]['start_time'] : null;
    double mngEnd = vaf.isNotEmpty ? vaf[0]['end_time'] : null;
    // Jiffyedit_mngvalues = SfRangeValues(mng_srt, mng_end);

    // SfRangeValues t = SfRangeValues(double.parse(mong), double.parse(mong_end));
//SfRangeValues t = SfRangeValues(double.parse(aftr), double.parse(aftr_end));
    if (!ismngEdit && getslotMorning != "" && getslotMorning[0]['mon_start_time'] != null) {
      mong = getslotMorning[0]['mon_start_time'].replaceAll(":", ".");
      mong = mong.replaceAll(' ', '');
      mongEnd = getslotMorning[0]['mon_end_time'].replaceAll(":", ".");
      mongEnd = mongEnd.replaceAll(' ', '');
      //setState(() {
      //_mngvalues
      edit_mngvalues = SfRangeValues(double.parse(mong), double.parse(mongEnd));
      // });
      //_mngvalues = SfRangeValues(double.parse(mong), double.parse(mong_end));
    }
    if (getslotMorning == "" || getslotMorning[0]['mon_start_time'] == null) {
      editmngDurationEnabled = !editmngDurationEnabled;
    }

    return Container(
        padding: EdgeInsets.all(8),
        //decoration: UIHelper.roundedBorderWithColorWithShadow(6, Colors.white),
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
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
                                value: editmngDurationEnabled,
                                onChanged: (value) {
                                  // achievement_privacy = value;
                                  setState(() {
                                    editmngDurationEnabled = value;
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
                  // isChangedSelection && !ismngEdit
                  //     ?
                  // Text(mong + "am   - " + " " + mong_end + " am"),
                  Text(edit_mngvalues!.start.toInt().toString() + " am   - " + " " + edit_mngvalues!.end.toInt().toString() + " am").fontSize(12).fontWeight(FontWeight.w600),
                  Container(
                    width: 190,
                    child: SfRangeSlider(
                      // min: 5.0,
                      // max: 11.0,
                      min: mngSrt,
                      max: mngEnd,
                      values: edit_mngvalues!,
                      // interval: 1,
                      // showTicks: true,
                      // showLabels: true,
                      // dragMode: SliderDragMode.onThumb,
                      enableTooltip: true,
                      activeColor: activeColor,
                      //enableTooltip: true,
                      minorTicksPerInterval: 1,
                      onChanged: editmngDurationEnabled
                          ? (SfRangeValues values) {
                              setState(() {
                                ismngEdit = true;

                                edit_mngvalues = values;
                              });
                            }
                          : null,
                    ),
                  )
                ],
              )
            ]),
          ]),
        ]));
  }

  Widget getAfternoonMode(BuildContext context, String asseturl, String title, String manageType, dynamic getslotAfternoon, bool isViewmode, List<dynamic> aftercheck) {
    String aftr = "";
    String aftrEnd = "";
    //SfRangeValues t = SfRangeValues(double.parse(aftr), double.parse(aftr_end));
    dynamic vafAft = aftercheck.where((e) {
      return e['name'].toString().toLowerCase().contains("afternoon");
    }).toList();
    double aftSrt = vafAft[0]['start_time'];
    double aftEnd = vafAft[0]['end_time'];

    if (!isaftEdit && getslotAfternoon != "" && getslotAfternoon[0]['afn_start_time'] != null) {
      aftr = getslotAfternoon[0]['afn_start_time'].replaceAll(":", ".");
      aftr = aftr.replaceAll(' ', '');
      aftrEnd = getslotAfternoon[0]['afn_end_time'].replaceAll(":", ".");
      aftrEnd = aftrEnd.replaceAll(' ', '');
//setState(() {
      edit_afternoonvalues = SfRangeValues(double.parse(aftr), double.parse(aftrEnd));
      //  });

    }
    if (getslotAfternoon == "" || getslotAfternoon[0]['afn_start_time'] == null) {
      editaftDurationEnabled = !editaftDurationEnabled;
    }
    return Container(
        padding: EdgeInsets.all(8),
        //decoration: UIHelper.roundedBorderWithColorWithShadow(6, Colors.white),
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
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
                            value: editaftDurationEnabled,
                            onChanged: (value) {
                              // achievement_privacy = value;
                              setState(() {
                                editaftDurationEnabled = value;
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
                  //     :

                  Text(edit_afternoonvalues!.start.toInt().toString() + " pm   - " + " " + edit_afternoonvalues!.end.toInt().toString() + " pm").fontSize(12).fontWeight(FontWeight.w600),
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
                      // min: 1.0,
                      // max: 6.0,
                      min: aftSrt,
                      max: aftEnd,
                      values: edit_afternoonvalues!,
                      // interval: 1,
                      // showTicks: true,
                      // showLabels: true,
                      // dragMode: SliderDragMode.onThumb,
                      enableTooltip: true,
                      activeColor: activeColor,
                      //enableTooltip: true,
                      minorTicksPerInterval: 1,
                      onChanged: editaftDurationEnabled
                          ? (SfRangeValues values) {
                              setState(() {
                                isaftEdit = true;
                                edit_afternoonvalues = values;
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

  Widget getEvgMode(BuildContext context, String asseturl, String title, String manageType, dynamic slt, bool isViewmode, List<dynamic> evgcheck) {
    String result = "";
    String resultEnd = "";
    //SfRangeValues t = SfRangeValues(double.parse(result), double.parse(result_end));

    dynamic vafEvg = evgcheck.where((e) {
      return e['name'].toString().toLowerCase().contains("evening");
    }).toList();
    double evgSrt = vafEvg[0]['start_time'];
    double evgEnd = vafEvg[0]['end_time'];

    if (!isevgEdit && slt != "" && slt[0]['eve_start_time'] != null) {
      result = slt[0]['eve_start_time'].replaceAll(":", ".");
      result = result.replaceAll(' ', '');
      resultEnd = slt[0]['eve_end_time'].replaceAll(":", ".");
      resultEnd = resultEnd.replaceAll(' ', '');
      // setState(() {
      edit_values = SfRangeValues(double.parse(result), double.parse(resultEnd));
      //});
    }
    if (slt == "" || slt[0]['eve_start_time'] == null) {
      editevgDurationEnabled = !editevgDurationEnabled;
    }
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
                            ? Text(edit_values!.start.toInt().toString() + " pm   - " + " " + edit_values!.end.toInt().toString() + " pm").fontSize(12).fontWeight(FontWeight.w600)
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
                                    value: editevgDurationEnabled,
                                    onChanged: (value) {
                                      // achievement_privacy = value;
                                      setState(() {
                                        editevgDurationEnabled = value;
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
                          Text(edit_values!.start.toInt().toString() + " pm   - " + " " + edit_values!.end.toInt().toString() + " pm").fontSize(12).fontWeight(FontWeight.w600),
                          // Text(slt['eve_start_time']).fontWeight(FontWeight.w600),
                          Container(
                            width: 190,
                            child: SfRangeSlider(
                              // min: 06.0,
                              // max: 11.0,
                              min: evgSrt,
                              max: evgEnd,
                              values: edit_values!,
                              // interval: 1,
                              // showTicks: true,
                              // showLabels: true,
                              dragMode: SliderDragMode.onThumb,
                              enableTooltip: true,
                              activeColor: activeColor,
                              //enableTooltip: true,
                              minorTicksPerInterval: 1,
                              onChanged: editevgDurationEnabled
                                  ? (SfRangeValues values) {
                                      setState(() {
                                        isevgEdit = true;
                                        edit_values = values;
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

  Widget duration_widget() {
    List<String> mngDur = ['10 mins', '20 mins', '30 mins', '45 mins', '1 hour'];
    return Column(children: [
      Row(children: [
        Text(
          ' Adjust Duration per Patient',
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
                  value: edit_mng_durations_value,
                  //elevation: 5,
                  style: TextStyle(color: Colors.black),
                  underline: SizedBox(),
                  isDense: true,
                  items: editmngDurationEnabled
                      ? mngDur.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList()
                      : null,
                  onChanged: (value) {
                    edit_mng_durations = value.toString();
                    setState(() {
                      edit_mng_durations_value = value.toString();
                    });

                    String aStr = edit_mng_durations.replaceAll(new RegExp(r'[^0-9]'), '');
                    int aInt = int.parse(aStr);
                    edit_mng_durations = aInt.toString();
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
                  value: edit_aft_durations_value,
                  //elevation: 5,
                  style: TextStyle(color: Colors.black),
                  underline: SizedBox(),
                  isDense: true,
                  items: editaftDurationEnabled
                      ? <String>['10 mins', '20 mins', '30 mins', '45 mins', '1 hour'].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList()
                      : null,
                  onChanged: (value) {
                    edit_aft_durations = value.toString();
                    setState(() {
                      edit_aft_durations_value = value.toString();
                    });

                    String afStr = edit_aft_durations.replaceAll(new RegExp(r'[^0-9]'), '');
                    int afInt = int.parse(afStr);
                    edit_aft_durations = afInt.toString();
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
                  value: edit_evg_durations_value,
                  //elevation: 5,
                  style: TextStyle(color: Colors.black),
                  underline: SizedBox(),
                  isDense: true,
                  items: editevgDurationEnabled
                      ? <String>['10 mins', '20 mins', '30 mins', '45 mins', '1 hour'].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList()
                      : null,
                  onChanged: (value) {
                    edit_evg_durations = value.toString();
                    setState(() {
                      edit_evg_durations_value = value.toString();
                    });
                    String evStr = edit_evg_durations.replaceAll(new RegExp(r'[^0-9]'), '');
                    int evInt = int.parse(evStr);
                    edit_evg_durations = evInt.toString();
                  },
                ),
              ])),
        ],
      )
    ]);
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
              Get.back();
              //showBottomSheet(context);
              // Get.to(() => HomeScreen());
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
                onPressed: editmngDurationEnabled || editaftDurationEnabled || editevgDurationEnabled
                    ? () async {
                        if (validDuration()) {
                          //add session
                          String s = (double.parse((intial_range_evg.start).toStringAsFixed(2)) + 12.0).toString();
                          Map<String, dynamic> postParams = {};
                          if (editmngDurationEnabled) {
                            int len = edit_mngvalues!.start.toInt().toString().length;
                            int lenEnd = edit_mngvalues!.end.toInt().toString().length;
                            postParams['mon_start_time'] =
                                len == 1 ? "0" + edit_mngvalues!.start.toInt().toStringAsFixed(2).replaceAll(".", " :") : (edit_mngvalues!.start.toInt()).toStringAsFixed(2).replaceAll(".", " :");
                            postParams['mon_start_time'] = postParams['mon_start_time'].replaceAll(new RegExp(r"\s+"), "");
                            postParams['mon_end_time'] =
                                lenEnd == 1 ? "0" + (edit_mngvalues!.end.toInt()).toStringAsFixed(2).replaceAll(".", " :") : (edit_mngvalues!.end.toInt()).toStringAsFixed(2).replaceAll(".", " :");
                            postParams['mon_end_time'] = postParams['mon_end_time'].replaceAll(new RegExp(r"\s+"), "");
                            edit_mng_durations = edit_mng_durations.replaceAll(new RegExp(r'[^0-9]'), '');
                            postParams['mon_duration'] = edit_mng_durations == "1" ? "60" : edit_mng_durations;
                          }

                          if (editaftDurationEnabled) {
                            String lenAft = edit_afternoonvalues!.start.toInt().toString().length.toString();

                            postParams['afn_start_time'] =
                                (edit_afternoonvalues!.start.toInt() < 12 ? edit_afternoonvalues!.start.toInt() + 12 : edit_afternoonvalues!.start.toInt()).toStringAsFixed(2).replaceAll(".", " :");
                            postParams['afn_start_time'] = postParams['afn_start_time'].replaceAll(new RegExp(r"\s+"), "");

                            postParams['afn_end_time'] = (edit_afternoonvalues!.end.toInt() < 12 ? edit_afternoonvalues!.end.toInt() + 12 : edit_afternoonvalues!.end.toInt()).toStringAsFixed(2).replaceAll(".", " :");
                            postParams['afn_end_time'] = postParams['afn_end_time'].replaceAll(new RegExp(r"\s+"), "");

                            edit_aft_durations = edit_aft_durations.replaceAll(new RegExp(r'[^0-9]'), '');
                            postParams['afn_duration'] = edit_aft_durations == "1" ? "60" : edit_aft_durations;
                          }
                          if (editevgDurationEnabled) {
                            String lenEvg = edit_values!.start.toInt().toString().length.toString();

                            postParams['eve_start_time'] = (edit_values!.start.toInt() < 12 ? edit_values!.start.toInt() + 12 : edit_values!.start.toInt()).toStringAsFixed(2).replaceAll(".", " :");
                            postParams['eve_start_time'] = postParams['eve_start_time'].replaceAll(new RegExp(r"\s+"), "");

                            postParams['eve_end_time'] = (edit_values!.end.toInt() < 12 ? edit_values!.end.toInt() + 12 : edit_values!.end.toInt()).toStringAsFixed(2).replaceAll(".", " :");
                            postParams['eve_end_time'] = postParams['eve_end_time'].replaceAll(new RegExp(r"\s+"), "");

                            edit_evg_durations = edit_evg_durations.replaceAll(new RegExp(r'[^0-9]'), '');

                            postParams['eve_duration'] = edit_evg_durations == "1" ? "60" : edit_evg_durations;
                          }
                          // postParams['slot_date'] = st_date;
                          // postParams['slot_date'] = end_date;
                          postParams['services_type'] = widget.serviceType;
                          days.clear();
                          // for (int i = 0; i <= en!.difference(str!).inDays; i++) {
                          //   days.add(str!.add(Duration(days: i)));
                          // }
                          DateFormat format = DateFormat("MM-dd-yyyy");
                          DateTime dt = format.parse(widget.pickerDay);
                          days.add(dt);
                          print('-----=-----------------' + s);
                          if (widget.clinicName != "") {
                            postParams['clinic_name'] = widget.clinicName;
                            postParams['clinic_Id'] = widget.clinicId;
                          }
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
                          Get.back(result: {'refresh': true});
                        } else {
                          Fluttertoast.showToast(
                            msg: "Please give proper duration",
                            backgroundColor: Colors.grey.shade400,
                            gravity: ToastGravity.BOTTOM,
                            textColor: Colors.black,
                          );
                        }
                      }
                    : null,
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

  bool validDuration() {
    var div = 0;
    var divAftr = 0;
    var divEvg = 0;

//change into integer-durations

    String aStr = edit_mng_durations.replaceAll(new RegExp(r'[^0-9]'), '');
    int aInt = int.parse(aStr);
    edit_mng_durations = aInt.toString();
    String afStr = edit_aft_durations.replaceAll(new RegExp(r'[^0-9]'), '');
    int afInt = int.parse(afStr);
    edit_aft_durations = afInt.toString();

    String evStr = edit_evg_durations.replaceAll(new RegExp(r'[^0-9]'), '');
    int evInt = int.parse(evStr);
    edit_evg_durations = evInt.toString();
    if (editmngDurationEnabled) {
      // int k = edit_mngvalues!.start.toInt();
      // int l = edit_mngvalues!.end.toInt();
      // int tot = l - k;
      // if (tot > 0) {
      //   int dur = int.parse(edit_mng_durations == "1 hour" ? "60" : edit_mng_durations.replaceAll(new RegExp(r'[^0-9]'), ''));
      //   div = tot * 60 % dur;
      //   print(div.toString());
      // }
      // div = 1; //set validation failed(give same start and end time)

      int k = edit_mngvalues!.start.toInt();
      int l = edit_mngvalues!.end.toInt();

      int tot = l - k;
      double kd = edit_mngvalues!.start;
      double ld = edit_mngvalues!.end;
      double de = ld - kd;
      de = double.parse((de).toStringAsFixed(2));
      var arr = de.toString().split('.');
      String durDecimal = arr[1].toString();
      int drc = int.parse(durDecimal);
      String gdm = edit_mng_durations == "1" ? "60" : edit_mng_durations;
      int userDuration = int.parse(gdm);
      if (userDuration > drc && drc != 0) {
        div = 1; //set validation failed(give same start and end time)
      }
    }
    if (editaftDurationEnabled) {
      // int tot_aft = edit_afternoonvalues!.end.toInt() - edit_afternoonvalues!.start.toInt();
      // if (tot_aft > 0) {
      //   int dur_after = int.parse(edit_aft_durations == "1 hour" ? "60" : edit_aft_durations.replaceAll(new RegExp(r'[^0-9]'), ''));
      //   div_aftr = tot_aft * 60 % dur_after;
      //   print(div_aftr.toString());
      // } else
      //   div_aftr = 1;

      double aftrd = edit_afternoonvalues!.start;
      double aftrend = edit_afternoonvalues!.end;
      double afternun = aftrend - aftrd;
      afternun = double.parse((afternun).toStringAsFixed(2));
      var arraft = afternun.toString().split('.');
      String duraftDecimal = arraft[1].toString();
      int drcAft = int.parse(duraftDecimal);
      String gdr = edit_aft_durations == "1" ? "60" : edit_aft_durations;
      int userAftDuration = int.parse(gdr);
      if (userAftDuration > drcAft && drcAft != 0) {
        div = 1; //set validation failed(give same start and end time)
      }
    }
    if (editevgDurationEnabled) {
      // int tot_evg = edit_values!.end.toInt() - edit_values!.start.toInt();
      // if (tot_evg > 0) {
      //   int dur_evg = int.parse(edit_evg_durations == "1 hour" ? "60" : edit_evg_durations.replaceAll(new RegExp(r'[^0-9]'), ''));
      //   div_evg = tot_evg * 60 % dur_evg;
      //   print(div_evg.toString());
      // } else
      //   div_evg = 1;

      double evgd = edit_values!.start;
      double evgend = edit_values!.end;
      double evning = evgend - evgd;
      evning = double.parse((evning).toStringAsFixed(2));
      var arreve = evning.toString().split('.');
      String durevgDecimal = arreve[1].toString();
      int drcEvg = int.parse(durevgDecimal);
      edit_evg_durations = edit_evg_durations == "1" ? "60" : edit_evg_durations;
      int userEvgDuration = int.parse(edit_evg_durations);
      if (userEvgDuration > drcEvg && drcEvg != 0) {
        div = 1; //set validation failed(give same start and end time)
      }
    }

    // print(div.toString() + "sdfasdf" + div_aftr.toString() + "asldjfsdf" + div_evg.toString());
    return div == 0 && divAftr == 0 && divEvg == 0 ? true : false;
  }

  @override
  Widget build(BuildContext context) {
    // Jiffy fromDate_ = Jiffy(widget.dateView['slot_date']);
    // pickedDate = fromDate_.format('MM/dd/yyyy');
    // DateTime pick_d = DateTime.parse(widget.dateView['slot_date'].toString());
    //DateTime pick_d = DateTime.parse(widget.dateView['slot_date'].toString());

    //[yyyy, '/', mm, '/', dd]
    //var todayDate = DateFormat("yMMMd").format(pick_d);
    // //var pick = DateTime.parse(widget.dateView['slot_date']);
    // pickedDate = DateFormat('MM-dd-yyyy').format(pick_d);
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
                  //need to set date for 3 month,
                  // await model.viewSession('sadf', 'asdfdf');
                },
                builder: (context, model, child) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      UIHelper.verticalSpaceSmall,
                      UIHelper.addHeader(context, " " + widget.serviceType, true),
                      UIHelper.verticalSpaceSmall,
                      widget.clinicName.isNotEmpty
                          ? Text(" " + widget.clinicName + " - " + widget.dateView['slot_date'].toString(), textAlign: TextAlign.left).fontWeight(FontWeight.w600)
                          : Text("   " + widget.dateView['slot_date'].toString(), textAlign: TextAlign.left).fontWeight(FontWeight.w600),
                      Expanded(
                          child: SingleChildScrollView(
                        child: Column(
                          children: [
                            // requestcard(context),
                            // UIHelper.verticalSpaceMedium,
                            //horizandalcalendar(context, model),
                            //UIHelper.verticalSpaceMedium,

                            UIHelper.verticalSpaceMedium,
                            getMorningMode(context, 'assets/morning_icon.png', 'Morning  ', 'Home Visit', widget.dateView['morning_slots'] != null ? widget.dateView['morning_slots'] : '', false,
                                widget.sessionTime.length < 0 ? model.setSessionTime.toList() : widget.sessionTime),
                            getAfternoonMode(context, 'assets/afternoon_icon.png', 'Afternoon', 'Online', widget.dateView['afternoon_slots'] != null ? widget.dateView['afternoon_slots'] : '', false,
                                widget.sessionTime.length < 0 ? model.setSessionTime.toList() : widget.sessionTime),
                            getEvgMode(context, 'assets/evening_icon.png', 'Evening', 'Home Visit', widget.dateView['evening_slots'] != null ? widget.dateView['evening_slots'] : '', false,
                                widget.sessionTime.length < 0 ? model.setSessionTime.toList() : widget.sessionTime),

                            UIHelper.hairLineWidget(),
                            duration_widget(),
                            UIHelper.verticalSpaceSmall,
                            UIHelper.verticalSpaceSmall,
                            save_widget(context)
//need to add availability of type of organization, time
                            // getDayMode(context, 'assets/morning_icon.png', 'Morning', 'Home Visit', model.calender_date_view['mon_start_time'] != null ? model.calender_date_view['mon_start_time'] : '',
                            //     model.calender_date_view['morning_slots'] != null ? model.calender_date_view['morning_slots'] : ''),
                            // UIHelper.verticalSpaceTiny,
                            // getDayMode(context, 'assets/afternoon_icon.png', 'Afternoon', 'Online', '12.00 pm - 3.00 pm', widget.dateView['morning_slots'] != null ? model.calender_date_view['morning_slots'] : ''),
                            // UIHelper.verticalSpaceTiny,
                            // getDayMode(
                            //     context, 'assets/evening_icon.png', 'Evening', 'Home Visit', '4.00 pm - 8.00 pm', model.calender_date_view['morning_slots'] != null ? model.calender_date_view['morning_slots'] : ''),
                            // Text('TIME').fontSize(16).fontWeight(FontWeight.w600),
                            // UIHelper.verticalSpaceSmall,
                            // Text('Morning slot').fontSize(13).fontWeight(FontWeight.w600),
                            // UIHelper.verticalSpaceSmall,
                            // slotcard(context, '8.30 am', '9.30 am', '10.30 am'),
                            // UIHelper.verticalSpaceSmall,
                            // Text('Afternoon slot').fontSize(13).fontWeight(FontWeight.w600),
                            // UIHelper.verticalSpaceSmall,
                            // slotcard(context, '12.30. pm', '1.30 pm', '2.30 pm'),
                            // UIHelper.verticalSpaceSmall,
                            // Text('Night slot').fontSize(13).fontWeight(FontWeight.w600),
                            // UIHelper.verticalSpaceSmall,
                            // slotcard(
                            //   context,
                            //   '4.30 pm',
                            //   '5.00 pm',
                            //   '6.00 pm',
                            // ),
                            // UIHelper.verticalSpaceMedium,
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.center,
                            //   children: [
                            //     ElevatedButton(
                            //         onPressed: () async {
                            //           await _popupselect(context);
                            //         },
                            //         child: Text('Book Appointment').bold(),
                            //         style: ButtonStyle(
                            //           minimumSize: MaterialStateProperty.all(Size(160, 40)),
                            //           backgroundColor: MaterialStateProperty.all(activeColor),
                            //         )),
                            //   ],
                            // )
                          ],
                        ),
                      ))
                    ],
                  );
                },
                viewModelBuilder: () => ManageCalenderWidgetmodel()),
          )),
    );
  }
}
