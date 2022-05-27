// GridView(
//       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 4, // <<<< Here
//         childAspectRatio: 0.5,
//       ),
//       children: List<Widget>.generate(20, (int i) {
//         return Builder(builder: (BuildContext context) {
//           return Text('$i');
//         });
//       }),
//     );

import 'package:doctor_module/src/ui/doc_signup/doc_terms_view.dart';
import 'package:doctor_module/src/ui/patient/patient_model.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/shared/app_doctorprofile_bar.dart';
import 'package:swarapp/shared/app_colors.dart';
import 'package:get/get.dart';
import 'package:swarapp/shared/screen_size.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class PatientDocumnetListView extends StatefulWidget {
  final dynamic patientDoc;
  PatientDocumnetListView({Key? key, required this.patientDoc}) : super(key: key);
  @override
  _PatientDocumnetListViewState createState() => _PatientDocumnetListViewState();
}

final kToday = DateTime.now();
final kFirstDay = DateTime(kToday.year, kToday.month - 3, kToday.day);
final kLastDay = DateTime(kToday.year, kToday.month + 3, kToday.day);
TextEditingController searchController = TextEditingController();
int selectedIndex = 0;

class _PatientDocumnetListViewState extends State<PatientDocumnetListView> {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool status = false;
  // List<dynamic> formtype = [
  //   [
  //     {"containertype": "1", "container_name": "patients", "stagetitle": " Your Patients\n", "assetImage": "assets/patients.png"},
  //     {"containertype": "2", "container_name": "manage_appointment", "stagetitle": " Manage\n Appoinments", "assetImage": "assets/appoinment.png"},
  //   ],
  //   [
  //     {"containertype": "3", "container_name": "profile", "stagetitle": " Profile\n", "assetImage": "assets/doctor_profile.png"},
  //     {"containertype": "4", "container_name": "fees_offers", "stagetitle": " Manage\n Fees and Offers", "assetImage": "assets/offer.png"},
  //   ]
  // ];
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
            // setState(() {
            //   selectedIndex = 0;
            //   preferencesService.selected_role = 'request';
            // });
          },
          child: Container(
            decoration: selectedIndex == 0 ? UIHelper.rowSeperator(activeColor) : UIHelper.rowSeperator(Colors.white),
            padding: EdgeInsets.all(4),
            child: Text('Offers').fontSize(16).fontWeight(FontWeight.w600),
          ),
        ),
        GestureDetector(
          onTap: () {
            // setState(() {
            //   selectedIndex = 1;
            //   preferencesService.selected_role = 'accept';
            // });
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

  Widget manage_types(PatientWidgetmodel model) {
    //List<dynamic> currentForm = formtype.toList();
    // List<dynamic> currentForm = model.fileName.toList();
    List<dynamic> currentForm = widget.patientDoc;
    double screenWidth = MediaQuery.of(context).size.width;

    var width = (screenWidth - ((2 - 1) * 5)) / 2;
    var height = width / 2 / 1.4;
    int row = 2;
    int column = 2;
    int i = 0;

    return currentForm.length > 0
        ? Container(
            height: 210,
            child:
                //  StreamBuilder<String?>(
                //     stream: locator<PreferencesService>().doctorStageValue!.outStream,
                //     builder: (context, snapshot) {
                //       // setState(() {
                //       print("k");
                //       if (preferencesService.stage_level_count != 0) {
                //         preferencesService.stage_level_count! > 1 ? isAllow = true : false;
                //       }

                LayoutBuilder(builder: (context, constraints) {
              return GridView.count(
                  primary: false,
                  //crossAxisCount: constraints.maxWidth > 700 ? 4 : 2,
                  crossAxisCount: 3,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  padding: const EdgeInsets.all(20),
                  children: <Widget>[
                    for (var gettype in currentForm)
                      Container(
                        padding: const EdgeInsets.all(8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child:
                              //Image.asset('${ApiService.fileStorageEndPoint}${gettype}'),

                              gettype.toLowerCase().contains('.docx')
                                  ? Image.asset(
                                      'assets/word_icon.png',
                                      fit: BoxFit.none,
                                      height: 120,
                                      width: 120,
                                    )
                                  : gettype.toLowerCase().contains('.pdf')
                                      ? Image.asset(
                                          'assets/PDF.png',
                                          fit: BoxFit.none,
                                          height: 120,
                                          width: 120,
                                        )
                                      : gettype.toLowerCase().contains('.xlsx') || gettype.toLowerCase().contains('.xls')
                                          ? Image.asset(
                                              'assets/excel_icon.png',
                                              fit: BoxFit.none,
                                              height: 120,
                                              width: 120,
                                            )
                                          : ClipRRect(child: UIHelper.getImage('${ApiService.fileStorageEndPoint}$gettype', 120, 120)),
                        ),

                        // color: Colors.orange[200],
                      ),
                  ]);
            }))
        : Container(
            width: Screen.width(context),
            height: Screen.height(context) / 2,
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "No more documents available",
                  textAlign: TextAlign.center,
                ).bold(),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SwarAppDoctorBar(isProfileBar: false),
      body: SafeArea(
          top: false,
          child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              width: Screen.width(context),
              child: ViewModelBuilder<PatientWidgetmodel>.reactive(
                  onModelReady: (model) async {
                    // await model.getOffers();
                    // await model.getDoctorList();
                  },
                  builder: (context, model, child) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        UIHelper.verticalSpaceSmall,
                        UIHelper.addHeader(context, " Patients", true),
                        UIHelper.verticalSpaceTiny,
                        // selectProfession(context),
                        //showSearchField(context),
                        UIHelper.verticalSpaceSmall,
                        Text(' All Records').bold(),
                        Expanded(
                            child: SingleChildScrollView(
                          child: Column(
                            children: [
                              UIHelper.verticalSpaceMedium,
                              manage_types(model)
                              //: requestAcceptcard(context, model),
                            ],
                          ),
                        ))
                      ],
                    );
                  },
                  viewModelBuilder: () => PatientWidgetmodel()))),
    );
  }
}
