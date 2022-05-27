import 'package:doctor_module/src/ui/doc_online_booking/checkout_view.dart';
import 'package:doctor_module/src/ui/doc_online_booking/doc_offers_model.dart';
import 'package:doctor_module/src/ui/doc_signup/doc_terms_view.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/shared/app_doctorprofile_bar.dart';
import 'package:swarapp/shared/app_colors.dart';
import 'package:get/get.dart';
import 'package:swarapp/shared/app_static_bar.dart';
import 'package:swarapp/shared/screen_size.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class DocOffersListView extends StatefulWidget {
  DocOffersListView({Key? key}) : super(key: key);
  @override
  _DocOffersListViewState createState() => _DocOffersListViewState();
}

final kToday = DateTime.now();
final kFirstDay = DateTime(kToday.year, kToday.month - 3, kToday.day);
final kLastDay = DateTime(kToday.year, kToday.month + 3, kToday.day);
TextEditingController searchController = TextEditingController();
int selectedIndex = 0;

class _DocOffersListViewState extends State<DocOffersListView> {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool status = false;

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
              Text(' Offers').fontSize(16).fontWeight(FontWeight.w600),
            ],
          ),
        ],
      ),
    );
  }

  Widget selectProfession(BuildContext context) {
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
            child: Text('Offers').fontSize(16).fontWeight(FontWeight.w600),
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
            child: Text('Doctor offers').fontSize(16).fontWeight(FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget showSearchField(BuildContext context) {
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

  Widget requestcard(BuildContext context, OffersListViewmodel model) {
    return Container(
        padding: EdgeInsets.all(10),
        width: Screen.width(context),
        child: Column(
          children: [
            ListView.builder(
                itemCount: model.Offers.length,
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return Column(children: [
                    GestureDetector(
                        onTap: () => {
                              preferencesService.offers_type = 'admin_offer',
                              preferencesService.Final_amount,
                              Get.to(() => CheckoutView(servicetype: "", selected_offers: model.Offers[index]['_id'], selected_offers_amount: model.Offers[index]['offer_amount'])),
                              setState(() {}),
                            },
                        child: Container(
                          decoration: UIHelper.allcornerRadiuswithbottomShadow(12, 12, 12, 12, Colors.white),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(
                                children: [
                                  Container(
                                    height: 55,
                                    width: 63,
                                    decoration: UIHelper.allcornerRadiuswithbottomShadow(2, 2, 2, 2, fieldBgColor),
                                    child: Image.asset(
                                      'assets/offers_img.png',
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(model.Offers[index]['Title']).fontSize(13).fontWeight(FontWeight.w600),
                                  UIHelper.verticalSpaceTiny,
                                  Text(model.Offers[index]['description']).fontSize(10).fontWeight(FontWeight.w500),
                                  UIHelper.verticalSpaceSmall,
                                  Text(model.Offers[index]['start_date'] + ' to ' + model.Offers[index]['end_date']).fontSize(10).fontWeight(FontWeight.w600),
                                ],
                              ),
                              Column(
                                children: [
                                  Column(
                                    children: [
                                      ElevatedButton(
                                          onPressed: () async {},
                                          child: Text('₹' + model.Offers[index]['offer_amount']).fontSize(14).textColor(Colors.black),
                                          style: ButtonStyle(
                                              minimumSize: MaterialStateProperty.all(Size(50, 20)),
                                              elevation: MaterialStateProperty.all(1),
                                              backgroundColor: MaterialStateProperty.all(Colors.white),
                                              shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))))),
                                    ],
                                  ),
                                  Row(children: [
                                    Text('Ending in 3 days').fontSize(10).fontWeight(FontWeight.w500),
                                  ]),
                                  UIHelper.verticalSpaceSmall,
                                ],
                              ),
                            ],
                          ),
                        )),
                    UIHelper.verticalSpaceSmall,
                  ]);
                }),
          ],
        ));
  }

  Widget requestAcceptcard(BuildContext context, OffersListViewmodel model) {
    String StartDate = '';
    String EndDate = '';
    String remainingdays = '';
    return Container(
        padding: EdgeInsets.all(10),
        width: Screen.width(context),
        child: Column(
          children: [
            model.selected_doctors_offers.length > 0
                ? ListView.builder(
                    itemCount: model.selected_doctors_offers.length,
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      String networkImgUrl = '';
                      if (model.selected_doctors_offers[index]['offer_description_link'].isNotEmpty) {
                        networkImgUrl = '${ApiService.fileStorageEndPoint}${model.selected_doctors_offers[index]['offer_description_link'][0]}';
                      } else {
                        print("NOT UPDATEDDD");
                      }
                      if (model.selected_doctors_offers[index]['start_date'] != "") {
                        StartDate = model.selected_doctors_offers[index]['start_date'];
                      } else {
                        StartDate = "";
                      }
                      if (model.selected_doctors_offers[index]['end_date'] != "") {
                        EndDate = model.selected_doctors_offers[index]['end_date'];
                      } else {
                        EndDate = "";
                      }
                      if (model.selected_doctors_offers[index]['start_date'] != null &&
                          model.selected_doctors_offers[index]['start_date'] != '' &&
                          model.selected_doctors_offers[index]['end_date'] != null &&
                          model.selected_doctors_offers[index]['end_date'] != '') {
                        var _startDate = Jiffy(model.selected_doctors_offers[index]['start_date'], 'dd/MM/yyyy');
                        var _endDate = Jiffy(model.selected_doctors_offers[index]['end_date'], 'dd/MM/yyyy');
                        String remaining = _endDate.diff(_startDate, Units.DAY).toString();
                        remainingdays = 'Ending in $remaining days';
                      }
                      // final difference = End_date.difference(Start_date).inDays;

                      // Jiffy start_date = Jiffy(model.selected_doctors_offers[index]['offer_start_date']);
                      // Jiffy end_date = Jiffy(model.doctors_offers[index]['offer_end_date']);
                      // String dateStr = start_date.format('MM-dd-yyyy');
                      // String endstr = end_date.format('MM-dd-yyyy');
                      // print("SDFDSFDSFDSF" + dateStr.toString());
                      return Column(children: [
                        GestureDetector(
                            onTap: () => {
                                  preferencesService.offers_type = 'doctor_offer',
                                  Get.to(() => CheckoutView(servicetype: "", selected_offers: model.selected_doctors_offers[index]['_id'], selected_offers_amount: model.selected_doctors_offers[index]['offer_amount'])),
                                  setState(() {}),
                                },
                            child: Container(
                              decoration: UIHelper.allcornerRadiuswithbottomShadow(12, 12, 12, 12, Colors.white),
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    model.selected_doctors_offers[index]['offer_description_link'].isNotEmpty
                                        ? Column(
                                            children: [
                                              Container(height: 55, width: 63, decoration: UIHelper.allcornerRadiuswithbottomShadow(2, 2, 2, 2, fieldBgColor), child: UIHelper.getImage(networkImgUrl, 70, 100)),
                                            ],
                                          )
                                        : Column(
                                            children: [
                                              Container(
                                                height: 55,
                                                width: 63,
                                                decoration: UIHelper.allcornerRadiuswithbottomShadow(2, 2, 2, 2, fieldBgColor),
                                                child: Image.asset(
                                                  'assets/offers_img.png',
                                                ),
                                              ),
                                            ],
                                          ),
                                    SizedBox(width: 3),
                                    Expanded(
                                        child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                          child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(model.selected_doctors_offers[index]['offer_title'] != "" ? model.selected_doctors_offers[index]['offer_title'] : "").fontSize(13).fontWeight(FontWeight.w600),
                                          Text(model.selected_doctors_offers[index]['offer_description_text'] != "" ? model.selected_doctors_offers[index]['offer_description_text'] : "")
                                              .fontSize(10)
                                              .fontWeight(FontWeight.w500),
                                          Text(StartDate + ' to ' + EndDate).fontSize(10).fontWeight(FontWeight.w600),
                                          UIHelper.verticalSpaceSmall,
                                        ],
                                      )),
                                    )),
                                    Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Column(
                                        children: [
                                          Column(
                                            children: [
                                              ElevatedButton(
                                                  onPressed: () async {},
                                                  child: Text('₹' + model.selected_doctors_offers[index]['offer_amount'] != "" ? '₹ ' + model.selected_doctors_offers[index]['offer_amount'] : "")
                                                      .fontSize(14)
                                                      .textColor(Colors.black),
                                                  style: ButtonStyle(
                                                      minimumSize: MaterialStateProperty.all(Size(50, 20)),
                                                      elevation: MaterialStateProperty.all(1),
                                                      backgroundColor: MaterialStateProperty.all(Colors.white),
                                                      shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))))),
                                            ],
                                          ),
                                          Row(children: [
                                            Text(remainingdays).fontSize(10).fontWeight(FontWeight.w500),
                                          ]),
                                          UIHelper.verticalSpaceSmall,
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )),
                        UIHelper.verticalSpaceSmall,
                      ]);
                    })
                : Container(
                    child: Text('No Records Found'),
                  )
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
              child: ViewModelBuilder<OffersListViewmodel>.reactive(
                  onModelReady: (model) async {
                    await model.getOffers();
                    await model.getDoctorList();
                  },
                  builder: (context, model, child) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        UIHelper.verticalSpaceSmall,
                        addHeader(context, true),
                        UIHelper.verticalSpaceTiny,
                        selectProfession(context),
                        UIHelper.verticalSpaceSmall,
                        Expanded(
                            child: SingleChildScrollView(
                          child: Column(
                            children: [
                              UIHelper.verticalSpaceMedium,
                              preferencesService.selected_role == 'request' || preferencesService.selected_role == '' ? requestcard(context, model) : requestAcceptcard(context, model),
                            ],
                          ),
                        ))
                      ],
                    );
                  },
                  viewModelBuilder: () => OffersListViewmodel()))),
    );
  }
}
