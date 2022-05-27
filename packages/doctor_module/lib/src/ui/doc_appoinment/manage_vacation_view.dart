import 'package:flutter/material.dart';
import 'package:swarapp/shared/app_colors.dart';
import 'package:swarapp/shared/app_bar.dart';
import 'package:swarapp/shared/screen_size.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:table_calendar/table_calendar.dart';

class ManageVacationView extends StatefulWidget {
  ManageVacationView({Key? key}) : super(key: key);
  @override
  _ManageVacationViewState createState() => _ManageVacationViewState();
}

final kToday = DateTime.now();
final kFirstDay = DateTime(kToday.year, kToday.month - 3, kToday.day);
final kLastDay = DateTime(kToday.year, kToday.month + 3, kToday.day);

class _ManageVacationViewState extends State<ManageVacationView> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  int selectedIndex = 0;

  Future<void> _showAddDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
            title: Container(
                width: Screen.width(context),
                padding: EdgeInsets.all(2),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                            onPressed: () async {
                              setState(() {
                                Navigator.pop(context);
                                print("selectedddadadffdd" + _selectedDay.toString());
                              });
                            },
                            child: Row(
                              children: [
                                Text('Not Available').fontSize(13).textColor(Colors.white),
                                UIHelper.horizontalSpaceTiny,
                                Icon(
                                  Icons.cancel,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ],
                            ),
                            style: ButtonStyle(
                                minimumSize: MaterialStateProperty.all(Size(10, 30)),
                                backgroundColor: MaterialStateProperty.all(activeColor),
                                shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))))),
                        UIHelper.horizontalSpaceTiny,
                        ElevatedButton(
                            onPressed: () async {
                              setState(() {
                                Navigator.pop(context);
                              });
                            },
                            child: Row(
                              children: [
                                Text('Available').fontSize(13).textColor(Colors.white),
                                UIHelper.horizontalSpaceTiny,
                                Icon(
                                  Icons.done,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ],
                            ),
                            style: ButtonStyle(
                                minimumSize: MaterialStateProperty.all(Size(10, 30)),
                                backgroundColor: MaterialStateProperty.all(addToCartColor),
                                shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))))),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text('Session').fontSize(15).textColor(Colors.black),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Morning Slot').fontSize(15).textColor(Colors.black),
                        UIHelper.horizontalSpaceMedium,
                        ElevatedButton(
                            onPressed: () async {
                              setState(() {
                                Navigator.pop(context);
                                print("selectedddadadffdd" + _selectedDay.toString());
                              });
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Icon(
                                  Icons.cancel,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ],
                            ),
                            style: ButtonStyle(
                                minimumSize: MaterialStateProperty.all(Size(10, 30)),
                                backgroundColor: MaterialStateProperty.all(activeColor),
                                shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))))),
                        UIHelper.verticalSpaceSmall,
                        UIHelper.horizontalSpaceMedium,
                        ElevatedButton(
                            onPressed: () async {
                              setState(() {
                                Navigator.pop(context);
                              });
                            },
                            child: Row(
                              children: [
                                Icon(
                                  Icons.done,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ],
                            ),
                            style: ButtonStyle(
                                minimumSize: MaterialStateProperty.all(Size(10, 30)),
                                backgroundColor: MaterialStateProperty.all(addToCartColor),
                                shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))))),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('Afternoon Slot').fontSize(15).textColor(Colors.black),
                        UIHelper.horizontalSpaceTiny,
                        UIHelper.horizontalSpaceTiny,
                        ElevatedButton(
                            onPressed: () async {
                              setState(() {
                                Navigator.pop(context);
                                print("selectedddadadffdd" + _selectedDay.toString());
                              });
                            },
                            child: Row(
                              children: [
                                Icon(
                                  Icons.cancel,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ],
                            ),
                            style: ButtonStyle(
                                minimumSize: MaterialStateProperty.all(Size(10, 30)),
                                backgroundColor: MaterialStateProperty.all(activeColor),
                                shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))))),
                        UIHelper.verticalSpaceSmall,
                        UIHelper.horizontalSpaceMedium,
                        ElevatedButton(
                            onPressed: () async {
                              setState(() {
                                Navigator.pop(context);
                              });
                            },
                            child: Row(
                              children: [
                                Icon(
                                  Icons.done,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ],
                            ),
                            style: ButtonStyle(
                                minimumSize: MaterialStateProperty.all(Size(10, 30)),
                                backgroundColor: MaterialStateProperty.all(addToCartColor),
                                shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))))),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Evening Slot').fontSize(15).textColor(Colors.black),
                        UIHelper.horizontalSpaceMedium,
                        ElevatedButton(
                            onPressed: () async {
                              setState(() {
                                Navigator.pop(context);
                                print("selectedddadadffdd" + _selectedDay.toString());
                              });
                            },
                            child: Row(
                              children: [
                                Icon(
                                  Icons.cancel,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ],
                            ),
                            style: ButtonStyle(
                                minimumSize: MaterialStateProperty.all(Size(10, 30)),
                                backgroundColor: MaterialStateProperty.all(activeColor),
                                shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))))),
                        UIHelper.verticalSpaceSmall,
                        UIHelper.horizontalSpaceMedium,
                        ElevatedButton(
                            onPressed: () async {
                              setState(() {
                                Navigator.pop(context);
                              });
                            },
                            child: Row(
                              children: [
                                Icon(
                                  Icons.done,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ],
                            ),
                            style: ButtonStyle(
                                minimumSize: MaterialStateProperty.all(Size(10, 30)),
                                backgroundColor: MaterialStateProperty.all(addToCartColor),
                                shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))))),
                      ],
                    ),
                  ],
                )));
      },
    );
  }

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
        onDaySelected: (selectedDay, focusedDay) async {
          await _showAddDialog(context);
          if (!isSameDay(_selectedDay, selectedDay)) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
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

  Widget requestcard(
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
            padding: EdgeInsets.all(10),
            width: Screen.width(context),
            decoration: UIHelper.allcornerRadiuswithColor(12, 12, 0, 0, activeColor),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Appointment requested').fontSize(10).textColor(Colors.white),
                        UIHelper.verticalSpaceTiny,
                        Row(children: [
                          Icon(
                            Icons.pending_actions_outlined,
                            color: Colors.white,
                            size: 18,
                          ),
                          UIHelper.horizontalSpaceSmall,
                          Text('12.07.2021 ,10.30 Am ').fontSize(11).fontWeight(FontWeight.w600).textColor(Colors.white),
                        ]),
                      ],
                    ),
                    UIHelper.horizontalSpaceSmall,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Appointment Mode').fontSize(10).textColor(Colors.white),
                        UIHelper.verticalSpaceTiny,
                        Row(children: [
                          Icon(
                            Icons.videocam,
                            color: Colors.white,
                            size: 18,
                          ),
                          UIHelper.horizontalSpaceSmall,
                          Text('Video Consultation').fontSize(11).fontWeight(FontWeight.w600).textColor(Colors.white),
                        ]),
                      ],
                    ),
                  ],
                ),
              ],
            )),
        Container(
            padding: EdgeInsets.all(5),
            width: Screen.width(context),
            decoration: UIHelper.allcornerRadiuswithbottomShadow(0, 0, 12, 12, Colors.white),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Image.asset('assets/userch1.png'),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Sam Sharma').fontSize(12).fontWeight(FontWeight.w600),
                    UIHelper.verticalSpaceTiny,
                    Text('Chennai').fontSize(10).fontWeight(FontWeight.w600),
                  ],
                ),
                ElevatedButton(
                    onPressed: () async {},
                    child: Text('Decline').fontSize(12).textColor(Colors.white),
                    style: ButtonStyle(
                        minimumSize: MaterialStateProperty.all(Size(70, 19)),
                        elevation: MaterialStateProperty.all(0),
                        backgroundColor: MaterialStateProperty.all(activeColor),
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))))),
                ElevatedButton(
                    onPressed: () async {},
                    child: Text('Accept').fontSize(12).textColor(Colors.white),
                    style: ButtonStyle(
                        minimumSize: MaterialStateProperty.all(Size(70, 19)),
                        elevation: MaterialStateProperty.all(0),
                        backgroundColor: MaterialStateProperty.all(addToCartColor),
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))))),
              ],
            )),
        UIHelper.verticalSpaceSmall,
        Text('10.00 - 12.00 Am').fontSize(12).textColor(Colors.black54),
      ],
    );
  }

  Widget requestAcceptcard(
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
            padding: EdgeInsets.all(5),
            width: Screen.width(context),
            decoration: UIHelper.allcornerRadiuswithbottomShadow(12, 12, 12, 12, Colors.white),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Image.asset('assets/userch2.png'),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Sam Sharma').fontSize(12).fontWeight(FontWeight.w600),
                    UIHelper.verticalSpaceTiny,
                    Text('Chennai').fontSize(10).fontWeight(FontWeight.w600),
                    UIHelper.verticalSpaceSmall,
                    Text('Appointment Date/time').fontSize(10).textColor(Colors.black38),
                    UIHelper.verticalSpaceTiny,
                    Text('12.07.2021 10.30 Am ').fontSize(10),
                  ],
                ),
                Column(
                  children: [
                    Text('Appointment Accepted').fontSize(10).textColor(Colors.black38),
                    ElevatedButton(
                        onPressed: () async {},
                        child: Text('Cancel Appointment').fontSize(10).textColor(Colors.white),
                        style: ButtonStyle(
                            minimumSize: MaterialStateProperty.all(Size(70, 19)),
                            backgroundColor: MaterialStateProperty.all(activeColor),
                            shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))))),
                    ElevatedButton(
                        onPressed: () async {},
                        child: Row(
                          children: [
                            Icon(
                              Icons.videocam,
                              color: Colors.white,
                              size: 14,
                            ),
                            Text('Begin call').fontSize(10).textColor(Colors.white),
                          ],
                        ),
                        style: ButtonStyle(
                            minimumSize: MaterialStateProperty.all(Size(70, 19)),
                            backgroundColor: MaterialStateProperty.all(addToCartColor),
                            shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))))),
                  ],
                ),
              ],
            )),
        UIHelper.verticalSpaceSmall,
        Text('03.00 - 05.00 Am').fontSize(12).textColor(Colors.black54),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SwarAppBar(2),
      body: SafeArea(
          top: false,
          child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              width: Screen.width(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  UIHelper.verticalSpaceSmall,
                  UIHelper.addHeader(context, "Manage Vacation", true),
                  UIHelper.verticalSpaceSmall,
                  Expanded(
                      child: SingleChildScrollView(
                    child: Column(
                      children: [
                        UIHelper.verticalSpaceSmall,
                        horizandalcalendar(context),
                      ],
                    ),
                  ))
                ],
              ))),
    );
  }
}
