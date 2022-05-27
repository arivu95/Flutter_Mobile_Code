import 'dart:ffi';
import 'package:doctor_module/src/ui/doc_online_booking/booking_view_model.dart';
import 'package:doctor_module/src/ui/doc_online_booking/top_specalities_view_model.dart';
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
import 'package:doctor_module/src/ui/doc_online_booking/doc_list_view.dart';
import 'package:doctor_module/src/ui/doc_online_booking/doc_detail_view.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:doctor_module/src/ui/doc_online_booking/checkout_view.dart';
import 'package:jiffy/jiffy.dart';
import 'package:intl/intl.dart';

class BookAppointmentView extends StatefulWidget {
  dynamic BookingInfo;
  final String servicetype;
  BookAppointmentView({Key? key, this.BookingInfo, required this.servicetype}) : super(key: key);

  @override
  _BookAppointmentViewState createState() => _BookAppointmentViewState();
}

dynamic userInfo = {};
final kToday = DateTime.now();
final kFirstDay = DateTime(kToday.year, kToday.month - 3, kToday.day);
final kLastDay = DateTime(kToday.year, kToday.month + 3, kToday.day);

class _BookAppointmentViewState extends State<BookAppointmentView> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();

  DateTime? _selectedDay;
  int selectedIndex = 0;
  dynamic response = [];
  PreferencesService preferencesService = locator<PreferencesService>();
  TextEditingController searchController = TextEditingController();
  TextEditingController slotController = TextEditingController();

  String selectedTab = '';
  String selectedSlot = '';
  int Tab_id = 3;
  bool select_personal = false;
  bool select_doc = false;
  var focused_date;
  dynamic selection_date_list = {};
  List<dynamic> appointment_date_list = [];
  List<dynamic> slot_list_based_servicetype = [];
  String suffix_time = '';
  String start_year = '';
  String end_year = '';
  String workExperience = '';
  String network_img_url = '';

  String Fees = '';
  String Discount = '';
  String final_amount = '';
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
              Text(' Bookings').fontSize(16).fontWeight(FontWeight.w600),
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

  Widget docCard(BuildContext context, ManageBookingsWidgetmodel model, bool ispopupshow) {
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

    if (model.doctor_details['azureBlobStorageLink'] != null) {
      network_img_url = '${ApiService.fileStorageEndPoint}${model.doctor_details['azureBlobStorageLink']}';
    }
    String insurance = '';

    if (model.doctor_Info['insurance'].length > 0) {
      for (int i = 0; model.doctor_Info['insurance'].length > i; i++) {
        var qua = model.doctor_Info['insurance'][i];
        if (qua != "" && qua != null) {
          insurance != '' ? insurance = insurance + ',' + qua.toString() : insurance = qua.toString();
        }
      }
    }

    for (var i = 0; i < model.doctor_Info['services'].length; i++) {
      if (model.doctor_Info['services'][i]['services_type'] == widget.servicetype) {
        Fees = model.doctor_Info['services'][i]['fees'];
        preferencesService.Final_fees = model.doctor_Info['services'][i]['fees'];
      }
      if (model.doctor_Info['services'][i]['services_type'] == widget.servicetype) {
        Discount = model.doctor_Info['services'][i]['discount'];
        preferencesService.Final_discount = model.doctor_Info['services'][i]['discount'];
      }
      if (model.doctor_Info['services'][i]['services_type'] == widget.servicetype) {
        final_amount = model.doctor_Info['services'][i]['final_amount'];
        preferencesService.Final_amount = model.doctor_Info['services'][i]['final_amount'];
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
    return Container(
      width: Screen.width(context) / 1.1,
      decoration: UIHelper.allcornerRadiuswithbottomShadow(12, 12, 12, 12, Colors.white),
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(children: [
              network_img_url == ''
                  ? Container(
                      height: 100,
                      width: 70,
                      decoration: UIHelper.allcornerRadiuswithbottomShadow(2, 2, 2, 2, fieldBgColor),
                      child: Icon(Icons.person, color: Colors.black, size: 35),
                    )
                  : UIHelper.getImage(network_img_url, 70, 100),
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
            ]),
            SizedBox(width: 5),
            Expanded(
              child: Container(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    model.doctor_details['name'] != null ? model.doctor_details['name'] : "",
                    overflow: TextOverflow.clip,
                  ).fontSize(11).fontWeight(FontWeight.w600),
                  UIHelper.verticalSpaceTiny,
                  Text(
                    model.doctor_details['specialization'][0] != null && model.doctor_details['specialization'][0] != '' ? model.doctor_details['specialization'][0] : "",
                    overflow: TextOverflow.clip,
                  ).fontSize(12).fontWeight(FontWeight.w600).textColor(Colors.black38),
                  Row(
                    children: [Text(workExperience != null ? " " + workExperience + ' exp' : "").fontSize(12).fontWeight(FontWeight.w600).textColor(Colors.black38)],
                  ),
                  UIHelper.verticalSpaceTiny,
                  Text(
                    Qualification,
                    overflow: TextOverflow.clip,
                  ).fontSize(9).fontWeight(FontWeight.w300).bold(),
                  UIHelper.verticalSpaceTiny,
                  insurance != ''
                      ? Row(children: [
                          Text('Insurance  ').fontSize(9).fontWeight(FontWeight.w300).bold(),
                          Icon(
                            Icons.done,
                            color: Colors.green,
                            size: 15,
                          ),
                        ])
                      : Row(children: [
                          Text('Insurance  ').fontSize(9).fontWeight(FontWeight.w300).bold(),
                          Icon(
                            Icons.cancel,
                            color: activeColor,
                            size: 15,
                          ),
                        ]),
                  UIHelper.verticalSpaceTiny,
                ],
              )),
            ),
            Container(
              width: 100,
              child: Column(
                children: [
                  Row(
                    children: [
                      Text('Patients visit').fontSize(10).fontWeight(FontWeight.w600).textColor(Colors.black).paddingZero,
                      UIHelper.horizontalSpaceSmall,
                      Text('1.5K').fontSize(12).fontWeight(FontWeight.w500).textColor(activeColor),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
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
                  ispopupshow
                      ? Padding(
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
                                    ).fontSize(12).fontWeight(FontWeight.w600),
                                ]),
                              ],
                            ),
                          ),
                        )
                      : SizedBox(),
                  UIHelper.verticalSpaceSmall,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ispopupshow ? Text(preferencesService.Final_amount != "" ? 'Discount %' : '') : SizedBox(),
                      preferencesService.Final_amount != "" && ispopupshow
                          ? Row(
                              children: [
                                preferencesService.Final_discount != ''
                                    ? Text('₹' + Fees,
                                        style: TextStyle(
                                          decoration: TextDecoration.lineThrough,
                                        )).textColor(Colors.black38)
                                    : Text(
                                        Fees,
                                      ).textColor(Colors.black38),
                                UIHelper.horizontalSpaceTiny,
                                Text(final_amount != '' ? '₹' + final_amount : "").textColor(activeColor),
                              ],
                            )
                          : Text(''),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buttontabs(BuildContext context, ManageBookingsWidgetmodel model) {
    return Container(
        child: Column(
      children: [
        Text(widget.servicetype.toString() == "Online" ? 'Online Consultation' : widget.servicetype.toString()).fontSize(14).bold(),
      ],
    ));
  }

  Widget horizandalcalendar(BuildContext context, ManageBookingsWidgetmodel model) {
    String availablityDate = '';
    String focusedText = '';
    var dateSlot;
    var glist = model.calender_date_view;

    if ((_focusedDay != null) || (_focusedDay != "")) {
      Jiffy focusday_ = Jiffy(_focusedDay);
      focused_date = focusday_.format("MM-dd-yyyy");
    }

    return Container(
      width: Screen.width(context) / 1.1,
      decoration: UIHelper.allcornerRadiuswithbottomShadow(6, 6, 6, 6, Colors.white),
      child: TableCalendar(
        firstDay: DateTime.now(),
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
          selection_date_list.clear();
          preferencesService.selected_slot = "";
          selectedTab = "";
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
            if ((_focusedDay != null) || (_focusedDay != "")) {
              Jiffy focusday_ = Jiffy(_focusedDay);
              focused_date = focusday_.format("MM-dd-yyyy");
            }
          });
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

  Widget slotcard1(BuildContext context, ManageBookingsWidgetmodel model) {
    return Container(
      width: Screen.width(context) / 4,
      decoration: UIHelper.roundedBorderWithColor(8, Colors.white, borderColor: Colors.transparent),
      child: Column(children: [
        ListView.builder(
            itemCount: model.calender_date_view.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return Container(child: Column());
            })
      ]),
    );
  }

  Widget slotcard2(BuildContext context, ManageBookingsWidgetmodel model) {
    List<dynamic> morningDateList = [];
    List<dynamic> bookedList = [];
    String bookedSlot = '';
    bool timeSelect = false;
    List<Widget> list = <Widget>[];

    slot_list_based_servicetype = model.calender_date_view.where((msg) => msg['services_type'].contains(widget.servicetype)).toList();

    if (focused_date != null) {
      appointment_date_list = slot_list_based_servicetype.where((msg) => msg['slot_date'].contains(focused_date.toString())).toList();
    }

    if (appointment_date_list.length > 0) {
      preferencesService.selected_slot = appointment_date_list[0]['_id'];
    }
    if (appointment_date_list.isNotEmpty) {
      for (var i = 0; i < appointment_date_list.length; i++) {
        for (var j = 0; j < appointment_date_list[0]['morning_slots'].length; j++) {
          morningDateList.add(appointment_date_list[0]['morning_slots'][j]);

          list.add(new GestureDetector(
            onTap: () {
              setState(() {
                if (morningDateList[j]['isBlock'] != true) {
                  selectedTab = morningDateList[j]['time'];
                  selectedSlot = "morning";
                  timeSelect = selectedTab != "" ? true : false;
                }
              });
            },
            child: Column(children: [
              Container(
                  width: Screen.width(context) / 5,
                  height: 30,
                  padding: EdgeInsets.all(5),
                  decoration: UIHelper.allcornerRadiuswithbottomShadow(6, 6, 6, 6, selectedTab == morningDateList[j]['time'] && selectedSlot == "morning" ? activeColor : Colors.white),
                  child: selectedTab == morningDateList[j]['time']
                      ? Text(morningDateList[j]['time'] + ' pm').textColor(selectedTab == morningDateList[j]['time'] && selectedSlot == "morning" ? Colors.white : Colors.black).textAlignment(TextAlign.center)
                      : Text(morningDateList[j]['time'] + ' pm').textAlignment(TextAlign.center).textColor(morningDateList[j]['isBlock'] == true ? disabledColor : Colors.black))
            ]),
          ));
        }
        break;
      }
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(list.isNotEmpty ? 'Morning slot' : '').fontSize(16).fontWeight(FontWeight.w600),
          ],
        ),
        UIHelper.verticalSpaceSmall,
        Wrap(spacing: 10, runSpacing: 15, children: list),
      ]),
    );
  }

  Widget afternoonslot(BuildContext context, ManageBookingsWidgetmodel model) {
    List<dynamic> morningDateList = [];
    List<Widget> list = <Widget>[];
    slot_list_based_servicetype = model.calender_date_view.where((msg) => msg['services_type'].contains(widget.servicetype)).toList();

    if (focused_date != null) {
      appointment_date_list = slot_list_based_servicetype.where((msg) => msg['slot_date'].contains(focused_date.toString())).toList();
    }
    if (appointment_date_list.length > 0) {
      preferencesService.selected_slot = appointment_date_list[0]['_id'];
    }
    if (appointment_date_list.isNotEmpty) {
      for (var i = 0; i < appointment_date_list.length; i++) {
        for (var j = 0; j < appointment_date_list[0]['afternoon_slots'].length; j++) {
          morningDateList.add(appointment_date_list[0]['afternoon_slots'][j]);
          list.add(new GestureDetector(
              onTap: () {
                setState(() {
                  if (morningDateList[j]['isBlock'] != true) {
                    selectedTab = morningDateList[j]['time'];
                    selectedSlot = "afternoon";
                    print("SLOTTTIMEE" + selectedTab.toString());
                  }
                });
              },
              child: Column(children: [
                Container(
                    width: Screen.width(context) / 5,
                    height: 30,
                    padding: EdgeInsets.all(5),
                    decoration: UIHelper.allcornerRadiuswithbottomShadow(6, 6, 6, 6, selectedTab == morningDateList[j]['time'] ? activeColor : Colors.white),
                    child: selectedTab == morningDateList[j]['time']
                        ? Text(morningDateList[j]['time'] + ' pm').textColor(selectedTab == morningDateList[j]['time'] ? Colors.white : Colors.black).textAlignment(TextAlign.center)
                        : Text(morningDateList[j]['time'] + ' pm').textAlignment(TextAlign.center).textColor(morningDateList[j]['isBlock'] == true ? disabledColor : Colors.black))
              ])));
        }
        break;
      }
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(list.isNotEmpty ? 'Afternoon slot' : '').fontSize(16).fontWeight(FontWeight.w600),
          ],
        ),
        UIHelper.verticalSpaceSmall,
        Wrap(spacing: 10, runSpacing: 15, children: list),
      ]),
    );
  }

  Widget evengslot(BuildContext context, ManageBookingsWidgetmodel model) {
    List<dynamic> morningDateList = [];
    List<Widget> list = <Widget>[];
    slot_list_based_servicetype = model.calender_date_view.where((msg) => msg['services_type'].contains(widget.servicetype)).toList();

    if (focused_date != null) {
      appointment_date_list = slot_list_based_servicetype.where((msg) => msg['slot_date'].contains(focused_date.toString())).toList();
    }
    if (appointment_date_list.length > 0) {
      preferencesService.selected_slot = appointment_date_list[0]['_id'];
    }
    if (appointment_date_list.isNotEmpty) {
      for (var i = 0; i < appointment_date_list.length; i++) {
        for (var j = 0; j < appointment_date_list[0]['evening_slots'].length; j++) {
          morningDateList.add(appointment_date_list[0]['evening_slots'][j]);
          list.add(new GestureDetector(
              onTap: () {
                setState(() {
                  selectedTab = morningDateList[j]['time'];
                  selectedSlot = "evening";
                });
              },
              child: Column(children: [
                Container(
                    width: Screen.width(context) / 5,
                    height: 30,
                    padding: EdgeInsets.all(5),
                    decoration: UIHelper.allcornerRadiuswithbottomShadow(6, 6, 6, 6, selectedTab == morningDateList[j]['time'] && selectedSlot == "evening" ? activeColor : Colors.white),
                    child: selectedTab == morningDateList[j]['time']
                        ? Text(morningDateList[j]['time'] + ' pm').textColor(selectedTab == morningDateList[j]['time'] && selectedSlot == "evening" ? Colors.white : Colors.black).textAlignment(TextAlign.center)
                        : Text(morningDateList[j]['time'] + ' pm').textAlignment(TextAlign.center).textColor(morningDateList[j]['isBlock'] == true ? disabledColor : Colors.black))
              ])));
        }
        break;
      }
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(list.isNotEmpty ? 'Evening slot' : '').fontSize(16).fontWeight(FontWeight.w600),
          ],
        ),
        UIHelper.verticalSpaceSmall,
        Wrap(spacing: 10, runSpacing: 15, children: list),
      ]),
    );
  }

  Widget slotcard(BuildContext context, String t1, String t2, String t3, String t4, String t5) {
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
        GestureDetector(
          onTap: () {
            setState(() {
              selectedIndex = 1;
            });
          },
          child: Container(
            decoration: selectedIndex == 1 ? UIHelper.normalbox(5, activeColor) : UIHelper.normalbox(5, Colors.white),
            padding: EdgeInsets.all(4),
            child: Text(t4, style: selectedIndex == 1 ? TextStyle(color: Colors.white) : TextStyle(color: Colors.black)).fontSize(12),
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
            child: Text(t5, style: selectedIndex == 1 ? TextStyle(color: Colors.white) : TextStyle(color: Colors.black)).fontSize(12),
          ),
        ),
      ],
    );
  }

  Widget timeslot(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
          child: Column(
        children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Time').bold().fontSize(15),
          ]),
          UIHelper.verticalSpaceTiny,
          Row(
            children: [
              Text('Morning slot').fontSize(13),
            ],
          ),
          UIHelper.verticalSpaceSmall,
          Row(
            children: [
              slotcard(context, '8.30 am', '9.30 am', '10.30 am', '11.30 am', '12.30 am'),
            ],
          ),
          UIHelper.verticalSpaceSmall,
          Row(
            children: [
              Text('Afternoon slot').fontSize(13),
            ],
          ),
          UIHelper.verticalSpaceSmall,
          Row(
            children: [
              slotcard(context, '1.30 pm', '2.30 pm', '3.30 pm', '4.30 pm', '12.30 pm'),
            ],
          ),
          UIHelper.verticalSpaceSmall,
          Row(
            children: [
              Text('Evening slot').fontSize(13),
            ],
          ),
          UIHelper.verticalSpaceSmall,
          Row(
            children: [
              slotcard(context, '5.30 pm', '6.30 pm', '7.30 pm', '8.30 pm', '9.30 pm'),
            ],
          ),
        ],
      )),
    );
  }

  Future<void> _popupselect(BuildContext context, ManageBookingsWidgetmodel model) async {
    if ((selectedSlot == 'afternoon') || (selectedSlot == 'evening')) {
      suffix_time = 'pm';
    } else if (selectedSlot == 'morning') {
      suffix_time = 'am';
    }

    if ((_focusedDay != null) || (_focusedDay != "")) {
      Jiffy focusday_ = Jiffy(_focusedDay);
      focused_date = focusday_.format("MMM dd");
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

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
          insetPadding: EdgeInsets.all(15),
          contentPadding: EdgeInsets.all(8),
          content: Container(
            width: Screen.width(context) - 16,
            height: 350,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: Text('Confirm Booking').fontSize(18).bold().textColor(Colors.black).textAlignment(TextAlign.center)),
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
                docCard(context, model, false),
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
                        Text(focused_date).bold(),
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
                        Text(selectedTab + ' ' + suffix_time).bold(),
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
                          String slotId = preferencesService.selected_slot;
                          setState(() {
                            preferencesService.selected_date = focused_date;
                            preferencesService.Selected_time = selectedTab + ' ' + suffix_time;
                            userInfo['patient_id'] = preferencesService.userId;
                            userInfo['time'] = selectedTab;
                            userInfo['shift'] = selectedSlot;
                            userInfo['services_type'] = widget.servicetype;
                            userInfo['fees'] = Fees;
                          });
                          Loader.show(context);
                          final response = await model.bookslot(slotId, userInfo);
                          Loader.hide();
                          Navigator.pop(context);
                          await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => CheckoutView(servicetype: widget.servicetype, selected_offers: '', selected_offers_amount: '')),
                          );
                          _focusedDay = DateTime.now();
                          selectedTab = "";
                          selectedSlot = '';
                          _selectedDay = DateTime.now();
                          await model.viewSession(preferencesService.selected_doctor_info_id, '');
                          setState(() {});
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SwarAppStaticBar(),
      backgroundColor: Colors.white,
      body: Container(
        padding: EdgeInsets.all(12),
        child: ViewModelBuilder<ManageBookingsWidgetmodel>.reactive(
            onModelReady: (model) async {
              // final now = new DateTime.now();
              // String formatter = DateFormat('MM-dd-y').format(now);
              // String startDate = formatter.toString();
              await model.viewSession(preferencesService.selected_doctor_info_id, '');
              await model.getUserdetail();
              await model.getUserProfile();
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
                            docCard(context, model, true),
                            UIHelper.verticalSpaceSmall,
                            horizandalcalendar(context, model),
                            UIHelper.verticalSpaceSmall,
                            slotcard2(context, model),
                            UIHelper.verticalSpaceSmall,
                            afternoonslot(context, model),
                            UIHelper.verticalSpaceSmall,
                            evengslot(context, model),
                            UIHelper.verticalSpaceMedium,
                            (widget.servicetype == "Home visit")
                                ? (_selectedDay != null) && (selectedTab != "")
                                    ? ElevatedButton(
                                        onPressed: () async {
                                          _popupselect(context, model);
                                        },
                                        child: Text('Book Appointment').fontSize(15).textColor(Colors.white),
                                        style: ButtonStyle(
                                            minimumSize: MaterialStateProperty.all(Size(65, 40)),
                                            backgroundColor: MaterialStateProperty.all(activeColor),
                                            shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)))))
                                    : ElevatedButton(
                                        onPressed: () async {},
                                        child: Text('Book Appointment').fontSize(15).textColor(Colors.white),
                                        style: ButtonStyle(
                                            minimumSize: MaterialStateProperty.all(Size(65, 40)),
                                            backgroundColor: MaterialStateProperty.all(disablebtncolor),
                                            shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)))))
                                : (_selectedDay != null) && (_selectedDay != "") && (selectedTab != null) && (selectedTab != "") && (preferencesService.selected_slot != "")
                                    ? ElevatedButton(
                                        onPressed: () async {
                                          _popupselect(context, model);
                                        },
                                        child: Text('Book Appointment').fontSize(15).textColor(Colors.white),
                                        style: ButtonStyle(
                                            minimumSize: MaterialStateProperty.all(Size(65, 40)),
                                            backgroundColor: MaterialStateProperty.all(activeColor),
                                            shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)))))
                                    : ElevatedButton(
                                        onPressed: () async {},
                                        child: Text('Book Appointment').fontSize(15).textColor(Colors.white),
                                        style: ButtonStyle(
                                            minimumSize: MaterialStateProperty.all(Size(65, 40)),
                                            backgroundColor: MaterialStateProperty.all(disablebtncolor),
                                            shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)))))
                          ],
                        ),
                      ),
                    );
            },
            viewModelBuilder: () => ManageBookingsWidgetmodel()),
      ),
    );
  }
}
