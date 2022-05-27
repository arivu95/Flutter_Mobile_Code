import 'package:flutter/material.dart';
import 'package:swarapp/shared/app_colors.dart';
import 'package:swarapp/shared/app_static_bar.dart';
import 'package:swarapp/shared/screen_size.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:user_module/src/ui/appoinments/appointment_list_view.dart';
import 'package:user_module/src/ui/doctor_nurse/doctor_nurse_view.dart';

class BookAppointmentView extends StatefulWidget {
  BookAppointmentView({Key? key}) : super(key: key);
  @override
  _BookAppointmentViewState createState() => _BookAppointmentViewState();
}

final kToday = DateTime.now();
final kFirstDay = DateTime(kToday.year, kToday.month - 3, kToday.day);
final kLastDay = DateTime(kToday.year, kToday.month + 3, kToday.day);

class _BookAppointmentViewState extends State<BookAppointmentView> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  int selectedIndex = 0;

  Widget horizandalcalendar(BuildContext context) {
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
        onDaySelected: (selectedDay, focusedDay) {
          if (!isSameDay(_selectedDay, selectedDay)) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SwarAppStaticBar(),
      body: SafeArea(
          top: false,
          child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              width: Screen.width(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  UIHelper.verticalSpaceSmall,
                  UIHelper.addHeader(context, "Appointment", true),
                  UIHelper.verticalSpaceSmall,
                  Expanded(
                      child: SingleChildScrollView(
                    child: Column(
                      children: [
                        requestcard(context),
                        UIHelper.verticalSpaceMedium,
                        horizandalcalendar(context),
                        UIHelper.verticalSpaceMedium,
                        Text('TIME').fontSize(16).fontWeight(FontWeight.w600),
                        UIHelper.verticalSpaceSmall,
                        Text('Morning slot').fontSize(13).fontWeight(FontWeight.w600),
                        UIHelper.verticalSpaceSmall,
                        slotcard(context, '8.30 am', '9.30 am', '10.30 am'),
                        UIHelper.verticalSpaceSmall,
                        Text('Afternoon slot').fontSize(13).fontWeight(FontWeight.w600),
                        UIHelper.verticalSpaceSmall,
                        slotcard(context, '12.30. pm', '1.30 pm', '2.30 pm'),
                        UIHelper.verticalSpaceSmall,
                        Text('Night slot').fontSize(13).fontWeight(FontWeight.w600),
                        UIHelper.verticalSpaceSmall,
                        slotcard(
                          context,
                          '4.30 pm',
                          '5.00 pm',
                          '6.00 pm',
                        ),
                        UIHelper.verticalSpaceMedium,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                                onPressed: () async {
                                  await _popupselect(context);
                                },
                                child: Text('Book Appointment').bold(),
                                style: ButtonStyle(
                                  minimumSize: MaterialStateProperty.all(Size(160, 40)),
                                  backgroundColor: MaterialStateProperty.all(activeColor),
                                )),
                          ],
                        )
                      ],
                    ),
                  ))
                ],
              ))),
    );
  }
}
