import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swarapp/shared/app_colors.dart';
import 'package:swarapp/shared/app_static_bar.dart';
import 'package:swarapp/shared/screen_size.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:user_module/src/ui/doctor_nurse/checkout_view.dart';

class doc_NurseAppoinmentDetailView extends StatefulWidget {
  dynamic userdata;
  doc_NurseAppoinmentDetailView({Key? key, this.userdata}) : super(key: key);
  @override
  _NurseNurseAppoinmentDetailViewState createState() => _NurseNurseAppoinmentDetailViewState();
}

final kToday = DateTime.now();
final kFirstDay = DateTime(kToday.year, kToday.month - 3, kToday.day);
final kLastDay = DateTime(kToday.year, kToday.month + 3, kToday.day);

class _NurseNurseAppoinmentDetailViewState extends State<doc_NurseAppoinmentDetailView> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  int selectedIndex = 0;

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
                  Icons.arrow_back_ios,
                  size: 20,
                ),
              ),
              Text('Home visit').fontSize(16).fontWeight(FontWeight.w600),
            ],
          ),
          Container(
              decoration: UIHelper.roundedLineBorderWithColor(12, fieldBgColor, 1),
              padding: EdgeInsets.all(4),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: activeColor,
                  ),
                  Text('Chennai').fontSize(12).bold(),
                ],
              )),
        ],
      ),
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

  Widget slotcard(BuildContext context, String t1, String t2) {
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
      ],
    );
  }

  Widget appoinmentcard(
    BuildContext context,
  ) {
    return Container(
      padding: EdgeInsets.all(5),
      width: Screen.width(context),
      decoration: UIHelper.allcornerRadiuswithbottomShadow(12, 12, 12, 12, Colors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 90,
                child: Image.asset('assets/userch1.png'),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.userdata['name']).fontSize(12).fontWeight(FontWeight.w600),
                  UIHelper.verticalSpaceTiny,
                  Text(widget.userdata['specialization']).fontSize(12).fontWeight(FontWeight.w600).textColor(Colors.black38),
                  UIHelper.verticalSpaceSmall,
                  Text(widget.userdata['degree']).fontSize(10).fontWeight(FontWeight.w500),
                  UIHelper.verticalSpaceTiny,
                  Text('5 years experience').fontSize(10).textColor(Colors.black38),
                ],
              ),
              UIHelper.horizontalSpaceLarge,
              Column(
                children: [
                  Text('\$ 500').fontSize(14).fontWeight(FontWeight.w500),
                ],
              ),
            ],
          ),
          UIHelper.verticalSpaceSmall,
          horizandalcalendar(context),
          UIHelper.verticalSpaceSmall,
          Text('TIME').fontSize(16).fontWeight(FontWeight.w600),
          UIHelper.verticalSpaceSmall,
          Text('Morning slot').fontSize(13).fontWeight(FontWeight.w600),
          UIHelper.verticalSpaceSmall,
          slotcard(context, '8.30 am', '11.00 am'),
          UIHelper.verticalSpaceSmall,
          Text('Afternoon slot').fontSize(13).fontWeight(FontWeight.w600),
          UIHelper.verticalSpaceSmall,
          slotcard(context, '4.00 pm', '7.30 pm'),
          UIHelper.verticalSpaceMedium,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                  onPressed: () async {
                    Get.to(() => CheckoutView(userdata: widget.userdata));
                  },
                  child: Text('Book Appointment').bold(),
                  style: ButtonStyle(
                    minimumSize: MaterialStateProperty.all(Size(140, 32)),
                    backgroundColor: MaterialStateProperty.all(activeColor),
                  )),
            ],
          )
        ],
      ),
    );
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
                children: [
                  addHeader(context, true),
                  Expanded(
                      child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        UIHelper.verticalSpaceSmall,
                        Text(widget.userdata['service']).fontSize(14).fontWeight(FontWeight.w600),
                        UIHelper.verticalSpaceSmall,
                        appoinmentcard(context),
                      ],
                    ),
                  ))
                ],
              ))),
    );
  }
}
