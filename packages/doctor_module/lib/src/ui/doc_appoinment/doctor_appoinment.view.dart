import 'dart:convert';
import 'package:doctor_module/src/ui/doc_appoinment/doc_waitingroom_view.dart';
import 'package:doctor_module/src/ui/doc_appoinment/doctor_appointment_model.dart';
import 'package:doctor_module/src/ui/doc_signup/doc_terms_view.dart';
import 'package:flutter/material.dart';
import 'package:swarapp/shared/app_bar.dart';
import 'package:swarapp/shared/app_doctorprofile_bar.dart';
import 'package:swarapp/shared/app_colors.dart';
import 'package:get/get.dart';
import 'package:swarapp/shared/app_static_bar.dart';
import 'package:swarapp/shared/screen_size.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:doctor_module/src/ui/doctor_profile/doctor_profile_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stacked/stacked.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/services/preferences_service.dart';
import 'package:swarapp/shared/app_colors.dart';
import 'package:swarapp/shared/app_doctorprofile_bar.dart';
import 'package:swarapp/shared/app_static_bar.dart';
import 'package:swarapp/shared/custom_dialog_box.dart';
import 'package:swarapp/shared/flutter_overlay_loader.dart';
import 'package:swarapp/shared/screen_size.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:swarapp/ui/startup/language_select_view.dart';
import 'package:swarapp/ui/startup/role_select_viewmodel.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:doctor_module/src/ui/doc_signup/role_select_view.dart';
import 'package:jiffy/jiffy.dart';
import 'package:intl/src/intl/date_format.dart';

class AppoinmentDetailView extends StatefulWidget {
  AppoinmentDetailView({Key? key}) : super(key: key);
  @override
  _AppoinmentDetailViewState createState() => _AppoinmentDetailViewState();
}

Map<String, dynamic> userInfo = {};
final kToday = DateTime.now();
final kFirstDay = DateTime(kToday.year, kToday.month - 3, kToday.day);
final kLastDay = DateTime(kToday.year, kToday.month + 3, kToday.day);
TextEditingController searchController = TextEditingController();
int selectedIndex = 0;
var focused_date;
var select_appointment;
var change_time;
List<dynamic> selection_date_list = [];
List<dynamic> accepted_user_list = [];
List<dynamic> accepted_date_list = [];
List<dynamic> whole_list = [];
List<dynamic> accepted_list = [];
String appointment = '';
String slot_shift = '';
bool isSearch = false;
String sortMode = '';
String patients_age = '';

class _AppoinmentDetailViewState extends State<AppoinmentDetailView> {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool status = false;

  Widget horizandalcalendar(BuildContext context, Manageappointmentmodel model) {
    if ((_focusedDay != null) || (_focusedDay != "")) {
      Jiffy focusday_ = Jiffy(_focusedDay);
      focused_date = focusday_.format("MM-dd-yyyy");
    }
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
          formatButtonTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          formatButtonDecoration: const BoxDecoration(
            color: activeColor,
            borderRadius: const BorderRadius.all(Radius.circular(12.0)),
          ),
          decoration: const BoxDecoration(
            color: fieldBgColor,
          ),
        ),
        calendarStyle: CalendarStyle(
          todayDecoration: const BoxDecoration(color: activeColor, shape: BoxShape.rectangle),
          todayTextStyle: TextStyle(color: Colors.white),
          selectedTextStyle: TextStyle(color: Colors.black),
          selectedDecoration: const BoxDecoration(color: productOfferBgColor, shape: BoxShape.rectangle),
        ),
        calendarFormat: _calendarFormat,
        selectedDayPredicate: (day) {
          return isSameDay(_selectedDay, day);
        },
        onDaySelected: (selectedDay, focusedDay) {
          if (!isSameDay(_selectedDay, selectedDay)) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
              if ((_focusedDay != null) || (_focusedDay != "")) {
                Jiffy focusday_ = Jiffy(_focusedDay);
                focused_date = focusday_.format("MM-dd-yyyy");
                print("SDFDFDDDD3343242" + focused_date.toString());
              }

              print(_selectedDay);
              print(_focusedDay);
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

  Widget addHeader(BuildContext context, bool isBackBtnVisible, Manageappointmentmodel model) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Appointments').fontSize(16).fontWeight(FontWeight.w600),
          // Container(
          //   // decoration: UIHelper.roundedLineBorderWithColor(12, fieldBgColor, 1),
          //   padding: EdgeInsets.all(0),
          //   child: PopupMenuButton(
          //     padding: EdgeInsets.all(0),
          //     icon: Image.asset('assets/sort_icon.png'),
          //     onSelected: (value) async {
          //       model.sortMode = value.toString();
          //       // model.refreshView();
          //       await model.calender_date_view;
          //       if (selectedIndex == 0) {
          //         model.refreshView('request');
          //         setState(() {
          //           selectedIndex = 0;
          //           preferencesService.selected_role = 'request';
          //         });
          //       } else {
          //         model.refreshView('');
          //         setState(() {
          //           selectedIndex = 1;
          //           preferencesService.selected_role = 'accepted';
          //         });
          //       }
          //     },
          //     itemBuilder: (context) {
          //       return <PopupMenuEntry<String>>[
          //         PopupMenuItem<String>(
          //           value: 'name',
          //           child: Row(children: [
          //             Icon(
          //               Icons.sort_by_alpha,
          //             ),
          //             UIHelper.horizontalSpaceSmall,
          //             Text(
          //               'Sort by\nPatient Name',
          //               style: TextStyle(fontSize: 13),
          //             ),
          //           ]),
          //         ),
          //         PopupMenuItem<String>(
          //           value: 'date',
          //           child: Row(children: [
          //             Icon(
          //               Icons.calendar_today,
          //             ),
          //             UIHelper.horizontalSpaceSmall,
          //             Text(
          //               'Sort by Date',
          //               style: TextStyle(fontSize: 13),
          //             ),
          //           ]),
          //         ),
          //         PopupMenuItem<String>(
          //           value: 'cancel',
          //           child: Row(children: [
          //             Icon(
          //               Icons.close,
          //             ),
          //             UIHelper.horizontalSpaceSmall,
          //             Text(
          //               'Remove',
          //               style: TextStyle(fontSize: 13),
          //             ),
          //           ]),
          //         ),
          //       ];
          //     },
          //   ),
          //   //  Row(
          //   //   children: [
          //   //     InkWell(
          //   //       onTap: () {
          //   //         setState(() {
          //   //           book = 2;
          //   //         });
          //   //       },
          //   //       onDoubleTap: () {
          //   //         setState(() {
          //   //           book = 1;
          //   //         });
          //   //       },
          //   //       child: book != 1
          //   //           ? Icon(
          //   //               Icons.filter_alt_outlined,
          //   //             )
          //   //           : Icon(
          //   //               Icons.filter_alt,
          //   //             ),
          //   //     ),
          //   //   ],
          //   // )
          // ),
        ],
      ),
    );
  }

  Widget selectProfession(BuildContext context, Manageappointmentmodel model) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              selectedIndex = 0;
              preferencesService.selected_role = 'request';
            });
          },
          child: Container(
            decoration: selectedIndex == 0 ? UIHelper.rowSeperator(activeColor) : UIHelper.rowSeperator(Colors.white),
            padding: EdgeInsets.all(4),
            child: Text('Request').fontSize(16).fontWeight(FontWeight.w600),
          ),
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              selectedIndex = 1;
              preferencesService.selected_role = 'accept';
            });
          },
          child: Container(
            decoration: selectedIndex == 1 ? UIHelper.rowSeperator(activeColor) : UIHelper.rowSeperator(Colors.white),
            padding: EdgeInsets.all(4),
            child: Text('Accepted').fontSize(16).fontWeight(FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget showSearchField(BuildContext context, Manageappointmentmodel model) {
    return SizedBox(
      height: 44,
      child: Container(
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 38,
                child: TextField(
                  controller: searchController,
                  onChanged: (value) {
                    model.searchList(value);
                    setState(() {});
                  },
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
                              onPressed: () {
                                searchController.clear();
                                model.searchList('');
                                setState(() {});
                                FocusManager.instance.primaryFocus!.unfocus();
                              }),
                      contentPadding: EdgeInsets.only(left: 20),
                      enabledBorder: UIHelper.getInputBorder(0, radius: 12, borderColor: Color(0xFFCCCCCC)),
                      focusedBorder: UIHelper.getInputBorder(0, radius: 12, borderColor: Color(0xFFCCCCCC)),
                      focusedErrorBorder: UIHelper.getInputBorder(0, radius: 12, borderColor: Color(0xFFCCCCCC)),
                      errorBorder: UIHelper.getInputBorder(0, radius: 12, borderColor: Color(0xFFCCCCCC)),
                      filled: true,
                      hintStyle: new TextStyle(color: Colors.grey[800]),
                      hintText: selectedIndex == 0 ? "Search(date,Swar id,name,phone number)" : "Search(date,Swar id,name,phone number)",
                      fillColor: fieldBgColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget requestcard(BuildContext context, Manageappointmentmodel model) {
    if (focused_date == null) {
      DateTime now = DateTime.now();
      focused_date = DateFormat('MM-dd-yyyy').format(now);
      selection_date_list = model.accepteddata.where((msg) => msg['slot_date'].contains(focused_date.toString())).toList();
    } else {
      selection_date_list = model.accepteddata.where((msg) => msg['slot_date'].contains(focused_date.toString())).toList();
    }

    return Container(
      width: Screen.width(context),
      child: Column(
        children: [
          selection_date_list.length > 0
              ? ListView.builder(
                  itemCount: selection_date_list.length,
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    if (selection_date_list[index]['patient_id']['age'] != "null") {
                      patients_age = selection_date_list[index]['patient_id']['age'].toString();
                    }
                    if (selection_date_list[index]['shift'] == 'morning') {
                      slot_shift = 'Am';
                    } else if ((selection_date_list[index]['shift'] == 'afternoon') || selection_date_list[index]['shift'] == 'evening') {
                      slot_shift = 'Pm';
                    }
                    // DateTime tempDate = new DateFormat("dd MMM yyyy").parse(selection_date_list[index]['slot_date']);
                    // print("DFVCVCVXCVXCVVV" + tempDate.toString());
                    return Column(children: [
                      GestureDetector(
                          child: Container(
                              decoration: UIHelper.roundedBorderWithColor(8, Colors.white, borderColor: Colors.transparent),
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Column(children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Appointment requested').fontSize(10),
                                          UIHelper.verticalSpaceTiny,
                                          Row(children: [
                                            Text(selection_date_list[index]['slot_date'] + ',' + selection_date_list[index]['time'] + ' ' + slot_shift).fontSize(11).fontWeight(FontWeight.w600),
                                          ]),
                                        ],
                                      ),
                                      UIHelper.horizontalSpaceSmall,
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Appointment Mode').fontSize(10),
                                          UIHelper.verticalSpaceTiny,
                                          selection_date_list[index]['services_type'] == 'Online'
                                              ? Row(children: [
                                                  Icon(
                                                    Icons.videocam,
                                                    color: Colors.black,
                                                    size: 18,
                                                  ),
                                                  UIHelper.horizontalSpaceSmall,
                                                  selection_date_list[index]['services_type'] != null
                                                      ? Text(selection_date_list[index]['services_type'] + ' Consultation').fontSize(11).fontWeight(FontWeight.w600)
                                                      : Text('').fontSize(11).fontWeight(FontWeight.w600),
                                                ])
                                              : Row(children: [
                                                  Image.asset(
                                                    'assets/home_visit_img.png',
                                                    fit: BoxFit.none,
                                                  ),
                                                  UIHelper.horizontalSpaceSmall,
                                                  selection_date_list[index]['services_type'] != null
                                                      ? Text(selection_date_list[index]['services_type'] + ' Consultation').fontSize(11).fontWeight(FontWeight.w600)
                                                      : Text('').fontSize(11).fontWeight(FontWeight.w600),
                                                ]),
                                        ],
                                      ),
                                    ],
                                  ),
                                  UIHelper.hairLineWidget(),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Column(
                                        children: [
                                          Container(
                                            height: 55,
                                            width: 63,
                                            decoration: UIHelper.allcornerRadiuswithbottomShadow(2, 2, 2, 2, fieldBgColor),
                                            child: Icon(
                                              Icons.account_circle,
                                              color: Colors.black38,
                                            ),
                                          ),
                                          UIHelper.verticalSpaceTiny,
                                          Row(
                                            children: [
                                              Text(selection_date_list[index]['patient_id']['swar_Id'] != "" && selection_date_list[index]['patient_id']['swar_Id'] != null
                                                      ? selection_date_list[index]['patient_id']['swar_Id']
                                                      : "")
                                                  .fontSize(10)
                                                  .fontWeight(FontWeight.w600),
                                            ],
                                          )
                                        ],
                                      ),
                                      SizedBox(width: 5),
                                      Expanded(
                                          child: Container(
                                              child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(selection_date_list[index]['patient_id']['name']).fontSize(12).fontWeight(FontWeight.w600),
                                          UIHelper.verticalSpaceTiny,
                                          Text(patients_age == "null"
                                                  ? ''
                                                  : patients_age + ' years' + selection_date_list[index]['patient_id']['gender'] != ""
                                                      ? selection_date_list[index]['patient_id']['gender']
                                                      : "" + selection_date_list[index]['patient_id']['city'] != ""
                                                          ? selection_date_list[index]['patient_id']['city']
                                                          : "")
                                              .fontSize(10)
                                              .textColor(Colors.black38),
                                          UIHelper.verticalSpaceTiny,
                                          Text(selection_date_list[index]['patient_id']['mobilenumber'] != "" ? selection_date_list[index]['patient_id']['mobilenumber'] : "").fontSize(10).fontWeight(FontWeight.w600),
                                          UIHelper.verticalSpaceSmall,
                                          // Container(
                                          //   child: Text(selection_date_list[index]['patient_id']['email'] != "" ? selection_date_list[index]['patient_id']['email'] : "").fontSize(12).fontWeight(FontWeight.w600),
                                          // )
                                          Container(
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    selection_date_list[index]['patient_id']['email'] != "" ? selection_date_list[index]['patient_id']['email'] : "".toString(),
                                                    overflow: TextOverflow.clip,
                                                  ).fontSize(12).fontWeight(FontWeight.w600),
                                                )
                                              ],
                                            ),
                                          )
                                        ],
                                      ))),
                                      Column(
                                        children: [
                                          Column(
                                            children: [
                                              Text('Payment Status').fontSize(12).textColor(Colors.black38).bold(),
                                              UIHelper.verticalSpaceTiny,
                                              Text('Paid').fontSize(10).fontWeight(FontWeight.w600),
                                            ],
                                          ),
                                          Row(children: [
                                            ElevatedButton(
                                                // onPressed: () async {
                                                //   await model.cancelAppointment(selection_date_list[index]['_id']);
                                                //   setState(() {});
                                                // },
                                                onPressed: () async {
                                                  setState(() {
                                                    userInfo['status'] = 'Declined';
                                                    userInfo['canceled_by'] = 'Doctor';
                                                  });
                                                  Loader.show(context);
                                                  await model.cancelAppointment(selection_date_list[index]['_id'], userInfo);
                                                  await model.getUserdetail('Booking List');
                                                  Loader.hide();
                                                },
                                                child: Text('Decline').fontSize(12).textColor(Colors.white),
                                                style: ButtonStyle(
                                                    minimumSize: MaterialStateProperty.all(Size(70, 19)),
                                                    elevation: MaterialStateProperty.all(0),
                                                    backgroundColor: MaterialStateProperty.all(activeColor),
                                                    shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))))),
                                            UIHelper.horizontalSpaceSmall,
                                            ElevatedButton(
                                                onPressed: () async {
                                                  setState(() {
                                                    userInfo['status'] = 'Accept';
                                                  });
                                                  Loader.show(context);
                                                  await model.acceptAppointment(selection_date_list[index]['_id'], userInfo);
                                                  await model.getAcceptedList('Accepted List', '');
                                                  await model.getUserdetail('Booking List');
                                                  Loader.hide();
                                                },
                                                child: Text('Accept').fontSize(12).textColor(Colors.white),
                                                style: ButtonStyle(
                                                    minimumSize: MaterialStateProperty.all(Size(70, 19)),
                                                    elevation: MaterialStateProperty.all(0),
                                                    backgroundColor: MaterialStateProperty.all(acceptColor),
                                                    shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))))),
                                          ])
                                        ],
                                      ),
                                    ],
                                  ),
                                ]),
                              ))),
                      UIHelper.verticalSpaceSmall,
                    ]);
                  })
              : Center(
                  child: Text('No Records Found'),
                )
        ],
      ),
    );
  }

  Widget requestAcceptcard(BuildContext context, Manageappointmentmodel model) {
    if (focused_date != null) {
      accepted_date_list = model.accepted_date_view.where((msg) => msg['slot_date'].contains(focused_date.toString())).toList();
    }
    return Container(
        width: Screen.width(context),
        child: Column(
          children: [
            accepted_date_list.length > 0
                ? ListView.builder(
                    itemCount: accepted_date_list.length,
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      if (accepted_date_list[index]['patient_id']['age'] != "null") {
                        patients_age = accepted_date_list[index]['patient_id']['age'].toString();
                      }
                      if (accepted_date_list[index]['shift'] == 'morning') {
                        slot_shift = 'Am';
                      } else if ((accepted_date_list[index]['shift'] == 'afternoon') || accepted_date_list[index]['shift'] == 'evening') {
                        slot_shift = 'Pm';
                      }
                      // Jiffy date_of_appointment = Jiffy(accepted_date_list[index]['slot_date']);
                      // appointment = date_of_appointment.format('dd MMM yyyy');
                      return Column(children: [
                        GestureDetector(
                            child: Container(
                                decoration: UIHelper.roundedBorderWithColor(8, Colors.white, borderColor: Colors.transparent),
                                child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text('Appointment requested').fontSize(10),
                                                UIHelper.verticalSpaceTiny,
                                                Row(children: [
                                                  Text(accepted_date_list[index]['slot_date'] + ',' + accepted_date_list[index]['time'] + ' ' + slot_shift).fontSize(11).fontWeight(FontWeight.w600),
                                                ]),
                                              ],
                                            ),
                                            UIHelper.horizontalSpaceSmall,
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text('Appointment Mode').fontSize(10),
                                                UIHelper.verticalSpaceTiny,
                                                selection_date_list[index]['services_type'] == 'Online'
                                                    ? Row(children: [
                                                        Icon(
                                                          Icons.videocam,
                                                          color: Colors.black,
                                                          size: 18,
                                                        ),
                                                        UIHelper.horizontalSpaceSmall,
                                                        selection_date_list[index]['services_type'] != null
                                                            ? Text(selection_date_list[index]['services_type'] + ' Consultation').fontSize(11).fontWeight(FontWeight.w600)
                                                            : Text('').fontSize(11).fontWeight(FontWeight.w600),
                                                      ])
                                                    : Row(children: [
                                                        Icon(
                                                          Icons.videocam,
                                                          color: Colors.black,
                                                          size: 18,
                                                        ),
                                                        UIHelper.horizontalSpaceSmall,
                                                        selection_date_list[index]['services_type'] != null
                                                            ? Text(selection_date_list[index]['services_type'] + ' Consultation').fontSize(11).fontWeight(FontWeight.w600)
                                                            : Text('').fontSize(11).fontWeight(FontWeight.w600),
                                                      ]),
                                              ],
                                            ),
                                          ],
                                        ),
                                        UIHelper.hairLineWidget(),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Column(
                                              children: [
                                                Container(
                                                  height: 55,
                                                  width: 63,
                                                  decoration: UIHelper.allcornerRadiuswithbottomShadow(2, 2, 2, 2, fieldBgColor),
                                                  child: Icon(
                                                    Icons.account_circle,
                                                    color: Colors.black38,
                                                  ),
                                                ),
                                                UIHelper.verticalSpaceTiny,
                                                Row(
                                                  children: [
                                                    Text(accepted_date_list[index]['patient_id']['swar_Id'] != "" && accepted_date_list[index]['patient_id']['swar_Id'] != null
                                                            ? accepted_date_list[index]['patient_id']['swar_Id']
                                                            : "")
                                                        .fontSize(10)
                                                        .fontWeight(FontWeight.w600),
                                                  ],
                                                )
                                              ],
                                            ),
                                            SizedBox(width: 5),
                                            Expanded(
                                                child: Container(
                                                    child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(accepted_date_list[index]['patient_id']['name']).fontSize(12).fontWeight(FontWeight.w600),
                                                UIHelper.verticalSpaceTiny,
                                                Text(patients_age == "null"
                                                        ? ''
                                                        : patients_age + ' years' + accepted_date_list[index]['patient_id']['gender'] != ""
                                                            ? accepted_date_list[index]['patient_id']['gender']
                                                            : "" + accepted_date_list[index]['patient_id']['city'] != ""
                                                                ? accepted_date_list[index]['patient_id']['city']
                                                                : "")
                                                    .fontSize(10)
                                                    .textColor(Colors.black38),
                                                UIHelper.verticalSpaceTiny,
                                                Text(accepted_date_list[index]['patient_id']['mobilenumber'] != "" ? accepted_date_list[index]['patient_id']['mobilenumber'] : "").fontSize(10).fontWeight(FontWeight.w600),
                                                UIHelper.verticalSpaceSmall,
                                                Container(
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          accepted_date_list[index]['patient_id']['email'] != "" ? accepted_date_list[index]['patient_id']['email'] : "".toString(),
                                                          overflow: TextOverflow.clip,
                                                        ).fontSize(12).fontWeight(FontWeight.w600),
                                                      )
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ))),
                                            Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
                                              Text('Appointment Accepted').fontSize(12).textColor(Colors.black38).bold(),

                                              // ElevatedButton(
                                              //     onPressed: () async {},
                                              //     child: Text('Modify Appointment').fontSize(12).textColor(Colors.white),
                                              //     style: ButtonStyle(
                                              //         minimumSize: MaterialStateProperty.all(Size(70, 19)),
                                              //         elevation: MaterialStateProperty.all(0),
                                              //         backgroundColor: MaterialStateProperty.all(activeColor),
                                              //         shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))))),
                                              ElevatedButton(
                                                  onPressed: () async {
                                                    // List<dynamic> kg = accepted_date_list[index]['patient_id'];
                                                    Map<String, dynamic> subscriptionObj = accepted_date_list[index]['patient_id'];
                                                    dynamic s = Map.from(subscriptionObj);
                                                    Get.to(() => DocWaitingView(
                                                        patientId: s['connectycube_id'].toString(),
                                                        passcode: accepted_date_list[index]['passcode'],
                                                        time: accepted_date_list[index]['time'],
                                                        date: accepted_date_list[index]['slot_date']));
                                                  },
                                                  child: Text('Start').fontSize(12).textColor(Colors.white),
                                                  style: ButtonStyle(
                                                      minimumSize: MaterialStateProperty.all(Size(70, 19)),
                                                      elevation: MaterialStateProperty.all(0),
                                                      backgroundColor: MaterialStateProperty.all(acceptColor),
                                                      shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))))),
                                            ])
                                          ],
                                        ),
                                      ],
                                    )))),
                        UIHelper.verticalSpaceSmall,
                      ]);
                    })
                : Center(
                    child: Text('No Records Found'),
                  )
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SwarAppDoctorBar(isProfileBar: false),
      body: Container(
        padding: EdgeInsets.all(12),
        child: ViewModelBuilder<Manageappointmentmodel>.reactive(
            onModelReady: (model) async {
              Loader.show(context);
              await model.getUserdetail('Booking List');
              await model.getAcceptedList('Accepted List', '');
              setState(() {});
              Loader.hide();
            },
            builder: (context, model, child) {
              return SingleChildScrollView(
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      addHeader(context, true, model),
                      UIHelper.verticalSpaceTiny,
                      showSearchField(context, model),
                      UIHelper.verticalSpaceTiny,
                      selectProfession(context, model),
                      UIHelper.verticalSpaceSmall,
                      horizandalcalendar(context, model),
                      UIHelper.verticalSpaceMedium,
                      preferencesService.selected_role == 'request' || preferencesService.selected_role == '' ? requestcard(context, model) : requestAcceptcard(context, model),
                    ],
                  ),
                ),
              );
            },
            viewModelBuilder: () => Manageappointmentmodel()),
      ),
    );
  }
}
