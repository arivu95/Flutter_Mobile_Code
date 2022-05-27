import 'package:doctor_module/src/ui/doc_signup/doc_terms_view.dart';
import 'package:doctor_module/src/ui/patient/patient_document_view.dart';
import 'package:doctor_module/src/ui/patient/patient_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/shared/app_doctorprofile_bar.dart';
import 'package:swarapp/shared/app_colors.dart';
import 'package:swarapp/shared/screen_size.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:stacked/src/state_management/view_model_builder.dart';
import 'package:jiffy/jiffy.dart';

class PatientDetailView extends StatefulWidget {
  final String patientId;
  final dynamic patientData;
  final dynamic patientDoc;
  final int index;
  PatientDetailView({Key? key, required this.patientId, required this.patientData, required this.patientDoc, required this.index}) : super(key: key);
  @override
  _PatientDetailViewState createState() => _PatientDetailViewState();
}

final kToday = DateTime.now();
final kFirstDay = DateTime(kToday.year, kToday.month - 3, kToday.day);
final kLastDay = DateTime(kToday.year, kToday.month + 3, kToday.day);

class _PatientDetailViewState extends State<PatientDetailView> {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  int selectedIndex = -1.obs;
  TextEditingController searchController = TextEditingController();
  Jiffy slotDate = Jiffy();
  String img_url = "";
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

  Widget patient_detail_card(
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
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Image.asset('assets/userch2.png'),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Sam Sharma').fontSize(12).fontWeight(FontWeight.w600),
                    UIHelper.verticalSpaceTiny,
                    Text('Chennai').fontSize(10).fontWeight(FontWeight.w600),
                    UIHelper.verticalSpaceSmall,
                    Text('Last Appointment Date').fontSize(10).textColor(Colors.black38).bold(),
                    UIHelper.verticalSpaceSmall,
                    Text('Last Prescription').fontSize(10).textColor(Colors.black38).bold(),
                    UIHelper.verticalSpaceSmall,
                    Text('Case History').fontSize(10).textColor(Colors.black38).bold(),
                  ],
                ),
                Column(
                  children: [
                    Container(
                      width: 40,
                      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 6),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: subtleColor,
                          style: BorderStyle.solid,
                          width: 1.0,
                        ),
                        color: subtleColor,
                        borderRadius: BorderRadius.circular(10.0),
                      ),

                      child: Text(
                        "32",
                        textAlign: TextAlign.right,
                      ).fontSize(12).fontWeight(FontWeight.w600), // Text
                    ), // Cont
                    Text('').fontSize(10).fontWeight(FontWeight.w600),
                    Text('23/10/2020').fontSize(10).fontWeight(FontWeight.w600),
                    UIHelper.verticalSpaceSmall,
                    Text('View').fontSize(10).textColor(activeColor),
                    UIHelper.verticalSpaceSmall,
                    Text('View').fontSize(10).textColor(activeColor),
                  ],
                ),
              ],
            )),
        UIHelper.verticalSpaceSmall,
      ],
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
                  Icons.arrow_back_ios,
                  size: 20,
                ),
              ),
              Text('View Patients').fontSize(16).fontWeight(FontWeight.w600),
            ],
          ),
        ],
      ),
    );
  }

  Widget showSearchField(BuildContext context) {
    return SizedBox(
      height: 74,
      child: Container(
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 38,
                child: TextField(
                  controller: searchController,
                  onChanged: (value) {
                    //model.getMembers_search(value);
                  },
                  style: TextStyle(fontSize: 14),
                  decoration: new InputDecoration(
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.grey,
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
                      hintText: "Search(date, Swar id, name, phone number)",
                      fillColor: fieldBgColor),
                ),
              ),
            ),
            Icon(
              Icons.filter_alt,
              size: 25,
              color: Colors.black,
            ),
            UIHelper.verticalSpaceLarge,
          ],
        ),
      ),
    );
  }

  Widget patients_List_card(BuildContext context, PatientWidgetmodel model, dynamic val) {
    Jiffy fromDate_ = Jiffy(val['slot_date']);
    String slot = "";
    print(model.bookedappoinments[widget.index]["slot_date"]);
    if (model.bookedappoinments[widget.index]["slot_date"] != null) {
      //slotDate = Jiffy(model.bookingsdata[index]['slot_date'].toString());
      // String s = slotDate.format('dd MMM yyyy');
      DateTime nowSlot = DateTime.parse(model.bookedappoinments[widget.index]["slot_date"]);
      String isoDate = nowSlot.toIso8601String();
      Jiffy fromDate_ = Jiffy(isoDate);
      slot = fromDate_.format('dd MMM yyyy');
    }
    if (val['azureBlobStorageLink'] != null) {
      String noteImg = val['azureBlobStorageLink'];
      img_url = '${ApiService.fileStorageEndPoint}${noteImg.toString()}';
    }

    return GestureDetector(
      onTap: () async {
        //await Get.to(() => PatientDetailView());
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              padding: EdgeInsets.all(10),
              width: Screen.width(context),
              decoration: UIHelper.allcornerRadiuswithbottomShadow(12, 12, 12, 12, Colors.white),
              child: Column(children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image.asset('assets/userch2.png'),
                      // UIHelper.horizontalSpaceMedium,
                      // SizedBox(
                      //   height: 40,
                      // )
                      Container(
                        // height: 55,
                        // width: 63,
                        decoration: UIHelper.allcornerRadiuswithbottomShadow(2, 2, 2, 2, fieldBgColor),
                        child: val['azureBlobStorageLink'] != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.only(topLeft: Radius.circular(5), topRight: Radius.circular(5)),
                                child: Image.network(
                                  img_url,
                                  height: 80,
                                  width: Screen.width(context) / 4.5,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : ClipRRect(borderRadius: BorderRadius.only(topLeft: Radius.circular(5), topRight: Radius.circular(5)), child: Icon(Icons.person, size: 55)),
                        // Image.asset(
                        //   'assets/userch2.png',
                        // ),
                      ),
                      UIHelper.verticalSpaceSmall,
                      Text(val['swar_Id'] != null ? val['swar_Id'] : '').fontSize(10).textColor(Colors.black38).bold(),
                    ],
                  ),
                  UIHelper.horizontalSpaceTiny,
                  Container(
                    width: Screen.width(context) / 3.1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(val['name'] != null ? val['name'] : '').fontSize(14).fontWeight(FontWeight.w600),
                        UIHelper.verticalSpaceTiny,
                        //+""+ val['gender'] + val['address']
                        Text(val['age'] != null ? val['age'].toString() : '').fontSize(10).textColor(Colors.black38).bold(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            //val['mobilenumber'])

                            val['countryCode_digits'] != null ? Text(val['countryCode_digits']).fontSize(10).textColor(Colors.black).bold() : SizedBox(),
                            val['mobilenumber'] != null ? Text(val['mobilenumber']).fontSize(10).textColor(Colors.black).bold() : SizedBox(),

                            Icon(
                              Icons.call,
                              size: 15,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                        UIHelper.verticalSpaceSmall,
                        Text(
                          val['email'] != null ? val['email'] : '',
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                          ),
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.ellipsis,
                        ).fontSize(12).fontWeight(FontWeight.w600),

                        UIHelper.verticalSpaceSmall,
                      ],
                    ),
                  ),
                  Column(children: [
                    Container(
                      padding: EdgeInsets.all(4),
                      width: Screen.width(context) / 3.9,
                      // height: 100,
                      decoration: BoxDecoration(
                        color: Color(0xFFF7CECD), //remove color to make it transpatent
                        border: Border.all(style: BorderStyle.solid, color: Colors.white),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      //color: Color(0xFFF7CECD),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          UIHelper.verticalSpaceSmall,
                          //Text('Appointment Mode').fontSize(10).textColor(Colors.black38).bold(),

                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.start,
                          //   children: <Widget>[
                          //     UIHelper.verticalSpaceMedium,
                          //     Text('Date & Time  :').fontSize(10).fontWeight(FontWeight.w600),
                          //     // Icon(
                          //     //   Icons.videocam_rounded,
                          //     //   size: 20,
                          //     //   color: Colors.green,
                          //     // ),
                          //     // Text(
                          //     //   ' Online',
                          //     //   maxLines: 1,
                          //     //   softWrap: false,
                          //     //   overflow: TextOverflow.ellipsis,
                          //     // ).fontSize(10).fontWeight(FontWeight.w600),
                          //   ],
                          // ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Text(slot).fontSize(10).fontWeight(FontWeight.w600),
                              UIHelper.horizontalSpaceTiny,
                              Text(model.bookedappoinments[widget.index]["time"] != null ? model.bookedappoinments[widget.index]["time"].toString() : '').fontSize(11).bold(),
                              // Icon(
                              //   Icons.videocam_rounded,
                              //   size: 20,
                              //   color: Colors.green,
                              // ),
                            ],
                          ),
                          //Text(model.bookingsdata[index]['payment_mode'])
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Text("Mode  : ").fontSize(10).fontWeight(FontWeight.w600),
                              model.bookedappoinments[widget.index]['services_type'].toString().toLowerCase() == "online"
                                  ? Icon(
                                      Icons.videocam_rounded,
                                      size: 20,
                                      color: Colors.green,
                                    )
                                  : SizedBox(),
                              Text(model.bookedappoinments[widget.index]['services_type'] != null && model.bookedappoinments[widget.index]['services_type'] != ""
                                      ? model.bookedappoinments[widget.index]['services_type']
                                      : '')
                                  .fontSize(10)
                                  .fontWeight(FontWeight.w600),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Text('Accepted ').fontSize(10).fontWeight(FontWeight.w600),
                              Icon(
                                Icons.check_circle,
                                size: 20,
                                color: Colors.green,
                              ),
                            ],
                          ),
                          //UIHelper.verticalSpaceSmall,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
//                             GestureDetector(
//                               onTap: () async {
//                                 //  getChatDialogs();
//                                 //call type_video-1
//                                 // callManager.startNewCall(context, CallType.VIDEO_CALL, model.ccIds.toSet());
//                                 // Get.back(result: {'refresh': true});
// // List<int>? occupants = widget._cubeDialog.occupantsIds;
// //                                         if (occupants!.contains(widget._cubeUser.id)) {
// //                                           occupants.remove(widget._cubeUser.id);
// //                                         }
// //                                        callManager.startNewCall(context, CallType.VIDEO_CALL,model.cc);
//                                 // callManager.startCall(context, CallType.VIDEO_CALL,)
//                                 CubeUser? currentUser = await SharedPrefs.getUser();
//                                 // Loader.show(context);
//                                 cube_connect();
//                                 callManager.startNewCall(context, CallType.VIDEO_CALL, model.ccIds.toSet());
//                                 //CubeDialog newDialog = CubeDialog(CubeDialogType.PRIVATE, occupantsIds: model.ccIds);
//                                 // await createDialog(newDialog).then((createdDialog) {
//                                 //   Future.delayed(Duration(seconds: 4), () {
//                                 //     Loader.hide();
//                                 //   });
//                                 //   Get.to(() => ChatDialogScreen(currentUser!, createdDialog));
//                                 // }).catchError((error) {
//                                 //   Loader.hide();
//                                 //   print(error);
//                                 // });
//                               },
//                               child: Row(
//                                 children: [
//                                   // Icon(
//                                   //   Icons.arrow_back_outlined,
//                                   //   size: 20,
//                                   // ),
//                                   Text(' Chat').bold(),
//                                 ],
//                               ),
//                             ),
                              //SizedBox(width: Screen.width(context) / 6),
                              Text(model.bookedappoinments[widget.index]['paid_amount'] != null && model.bookedappoinments[widget.index]['paid_amount'] != ""
                                      ? "₹ " + model.bookedappoinments[widget.index]['paid_amount']
                                      : '')
                                  .fontSize(10)
                                  .fontWeight(FontWeight.w600),
                              SizedBox(width: Screen.width(context) / 6),
                              //Text('Cancel ').fontSize(12).fontWeight(FontWeight.w600).textColor(activeColor),
                            ],
                          ),

                          UIHelper.verticalSpaceSmall,
                        ],
                      ),
                    ),
                    UIHelper.verticalSpaceSmall
                  ]),
                ]),
              ])),
          UIHelper.verticalSpaceSmall,
        ],
      ),
    );
  }

  Widget docTypeMenuItem(String title, Widget icon, int index) {
    //String filePath = preferencesService.paths[0];
    // String filename = filePath.split('/').last;
    return GestureDetector(
      onTap: () {
        // setState(() {
        //   //   selectedIndex = index;
        //   //  if(widget.camera_mode == "Camera"){
        //   //   fieldController.text = title +'_'+ DateTime.now().toString();
        //   //   }else{
        //   //   fieldController.text = filename;
        //   //   }
        //   //});
        //   fieldController.clear();
        //   List<String> numbers = ["Registration/Insurance", "Prescription", "Lab Report", "Medical Report", "Others", "C.DOC", "Maternity & Child vaccine record"];
        //   if (widget.camera_mode == "Camera") {
        //     if (fieldController.text == "") {
        //       fieldController.text = title + '_' + DateFormat("HH_mm_ss").format(DateTime.now());
        //       //DateTime.now().toString();
        //     }
        //     if (numbers.contains(fieldController.text.split('_').first)) {
        //       title == 'Registration/Insurance'
        //           ? fieldController.text = 'Registration_Insurance' + '_' + DateFormat("yy-MM-dd_HH_mm_ss").format(DateTime.now())
        //           : fieldController.text = title + '_' + DateFormat("yyyy-MM-dd_HH_mm_ss").format(DateTime.now());
        //     } else {
        //       fieldController.text;
        //     }
        //   } else {
        //     //fieldController.text = filename;
        //     //title == 'Registration/Insurance' ? fieldController.text = 'Registration_Insurance' + '_' + DateTime.now().toString() : fieldController.text = title + '_' + DateTime.now().toString();
        //     fieldController.text = "fileAttach";
        //   }
        // });
        // selectedIndex = index;
        // //   print('++++++++++=selected index is'+selectedIndex.toString());
        // // Get.to(() => VaccineMaternityListView());
        // if (index == 6) {
        //   //Get.to(() => VaccineMaternityListView());
        // }

        // if (index == 5) {
        //   //Get.to(() => CovidRecordView());
        // }
      },
      child: Row(
        children: [
          UIHelper.horizontalSpaceSmall,
          icon,
          UIHelper.horizontalSpaceSmall,
          Expanded(child: Text(title).textColor(selectedIndex == index ? activeColor : Colors.black).fontWeight(selectedIndex == index ? FontWeight.bold : FontWeight.normal)),
          Icon(
            Icons.arrow_forward_ios,
            size: 14,
            color: Colors.black45,
          ),
          UIHelper.horizontalSpaceSmall,
        ],
      ),
    );
  }

  Widget showCategories(BuildContext context) {
    return Container(
      //padding: EdgeInsets.fromLTRB(6, 20, 6, 20),
      width: Screen.width(context),
      decoration: BoxDecoration(
        color: greycolor,
      ),
      //subtleColor
      // decoration: UIHelper.allcornerRadiuswithbottomShadow(12, 12, 12, 12, Colors.white),
      // height: 100,

      child: Column(
        children: [
          Text(
            "Case History",
            textAlign: TextAlign.center,
          ).fontSize(14).bold(),
          UIHelper.verticalSpaceMedium,
          Row(
            children: [
              Flexible(
                child: docTypeMenuItem('Registration/Insurance', Image.asset('assets/reg_insurance_icon.png'), 0),
              ),
              Flexible(
                child: docTypeMenuItem('Prescription', Image.asset('assets/prescription_icon.png'), 1),
              ),
            ],
          ),
          UIHelper.verticalSpaceSmall,
          UIHelper.hairLineWidget(),
          UIHelper.verticalSpaceSmall,
          Row(
            children: [
              Flexible(
                child: docTypeMenuItem('Lab Report', Image.asset('assets/lr_icon.png'), 2),
              ),
              Flexible(
                child: docTypeMenuItem('Medical Report', Image.asset('assets/mr_icon.png'), 3),
              ),
            ],
          ),
          UIHelper.verticalSpaceSmall,
          UIHelper.hairLineWidget(),
          UIHelper.verticalSpaceSmall,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: Screen.width(context) / 2,
                child: docTypeMenuItem('Others', Image.asset('assets/others_icon.png'), 4),
              ),
            ],
          ),
          UIHelper.verticalSpaceSmall,
        ],
      ),
    );
  }

  Widget showTable(context, model) {
    // Jiffy fromDate_ = Jiffy(tab_val['slot_date']);
    // String slot = "";
    // if (model.bookingsdata[index]['slot_date'] != null) {
    //   //slotDate = Jiffy(model.bookingsdata[index]['slot_date'].toString());
    //   // String s = slotDate.format('dd MMM yyyy');
    //   DateTime now_slot = DateTime.parse(model.bookingsdata[index]['slot_date']);
    //   String isoDate = now_slot.toIso8601String();
    //   Jiffy fromDate_ = Jiffy(isoDate);
    //   slot = fromDate_.format('dd MMM yyyy');
    // }
    dynamic getslot = [];
    String slot = "";
//    for (var getslotdates in model.bookingappoinments) {

//    for (var getslotdates in model.bookedpatientInfo['BookingData']) {
    for (var getslotdates in model.bookedappoinments) {
      DateTime nowSlot = DateTime.parse(getslotdates['slot_date']);
      String isoDate = nowSlot.toIso8601String();
      Jiffy fromDate_ = Jiffy(isoDate);
      slot = fromDate_.format('MM-dd-yyyy');
      getslot.add(slot);
    }
    return Container(
      margin: EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: subtleColor,
        border: Border.all(
          //color: Colors.white,
          color: Colors.grey,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Table(
        defaultColumnWidth: IntrinsicColumnWidth(),
        // border: TableBorder.symmetric(inside: BorderSide.none),
        border: TableBorder(verticalInside: BorderSide(width: 1, color: Colors.blue, style: BorderStyle.solid)),
        //border: TableBorder.all(),
        columnWidths: {0: FractionColumnWidth(.2), 1: FractionColumnWidth(.2), 2: FractionColumnWidth(.2), 3: FractionColumnWidth(.2), 4: FractionColumnWidth(.2), 5: FractionColumnWidth(.2)},
        children: [
          TableRow(children: [
            Column(children: [UIHelper.verticalSpaceTiny, Text('Date'), UIHelper.verticalSpaceTiny]),
            for (var getdates in getslot) Column(children: [UIHelper.verticalSpaceTiny, Text(getdates).fontSize(11), UIHelper.verticalSpaceTiny]),
            // Column(children: [UIHelper.verticalSpaceTiny, Text('23/10/2020').fontSize(11), UIHelper.verticalSpaceTiny]),
            // Column(children: [UIHelper.verticalSpaceTiny, Text('23/10/2020').fontSize(11), UIHelper.verticalSpaceTiny]),
            // Column(children: [UIHelper.verticalSpaceTiny, Text('23/10/2020').fontSize(11), UIHelper.verticalSpaceTiny]),
          ]),

          TableRow(children: [
            Column(children: [UIHelper.verticalSpaceTiny, Text('Mode'), UIHelper.verticalSpaceTiny]),
            for (var getmode in model.bookedappoinments)
              Column(children: [UIHelper.verticalSpaceTiny, Text(getmode['services_type'] != null ? getmode['services_type'] : '', textAlign: TextAlign.center), UIHelper.verticalSpaceTiny]),
            // Column(children: [UIHelper.verticalSpaceTiny, Text('Home Visit', textAlign: TextAlign.center), UIHelper.verticalSpaceTiny]),
            // Column(children: [UIHelper.verticalSpaceTiny, Text('In clinic', textAlign: TextAlign.center), UIHelper.verticalSpaceTiny]),
            // Column(children: [UIHelper.verticalSpaceTiny, Text('Phone', textAlign: TextAlign.center), UIHelper.verticalSpaceTiny]),
          ]),
//
          TableRow(children: [
            Column(children: [UIHelper.verticalSpaceTiny, Text('payment'), UIHelper.verticalSpaceTiny]),
            for (var getpayment in model.bookedappoinments) Column(children: [UIHelper.verticalSpaceTiny, Text(getpayment['paid_amount'] != null ? getpayment['paid_amount'] : ''), UIHelper.verticalSpaceTiny]),
            // Column(children: [UIHelper.verticalSpaceTiny, Text('400'), UIHelper.verticalSpaceTiny]),
            // Column(children: [UIHelper.verticalSpaceTiny, Text('400'), UIHelper.verticalSpaceTiny]),
            // Column(children: [UIHelper.verticalSpaceTiny, Text('400'), UIHelper.verticalSpaceTiny]),
          ]),

          TableRow(children: [
            Column(children: [UIHelper.verticalSpaceTiny, Text('Details'), UIHelper.verticalSpaceTiny]),
            for (var getview in model.bookedappoinments)
              Column(children: [
                UIHelper.verticalSpaceTiny,
                GestureDetector(
                  onTap: () {
                    //model.bookingappoinments[index]['appointment_upload_documents']
                    Get.to(() => PatientDocumnetListView(patientDoc: getview['appointment_upload_documents']));
                  },
                  child: Text(
                    'View',
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                    ),
                  ).textColor(activeColor),
                ),
                UIHelper.verticalSpaceTiny
              ]),
            // Column(children: [UIHelper.verticalSpaceTiny, Text('View').textColor(activeColor), UIHelper.verticalSpaceTiny]),
            // Column(children: [UIHelper.verticalSpaceTiny, Text('View').textColor(activeColor), UIHelper.verticalSpaceTiny]),
            // Column(children: [UIHelper.verticalSpaceTiny, Text('View').textColor(activeColor), UIHelper.verticalSpaceTiny]),
          ]),
        ],
      ),
    );
  }

  Widget patientsList(PatientWidgetmodel model) {
    return Container(
      // color: Colors.grey,
      //bookingPatients
//      height: model.bookeddata.length > 0 ? Screen.height(context) / 3.5 : 100,
      height: Screen.height(context) / 3.8,
      child: patients_List_card(context, model, widget.patientData),
      //child: model.bookeddata.length > 0 ? patients_List_card(context, model, widget.patientData) : Text("No data"),
    );
    // child: ListView.builder(
    //     itemCount: model.bookeddata.length,
    //     itemBuilder: (BuildContext context, int index) {
    //       print("new");
    //       return patients_List_card(context, model, index, model.bookeddata);
    //     }));
  }

  // Widget TableList(PatientWidgetmodel model) {
  //   return Container(
  //       // color: Colors.grey,
  //       height: Screen.height(context) / 2,
  //       child: ListView.builder(
  //           itemCount: model.bookingPatients.length,
  //           itemBuilder: (BuildContext context, int index) {
  //             print("new");
  //             return showTable(context, model, index, model.bookingappoinments[index]);
  //           }));
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: SwarAppDoctorBar(isProfileBar: false),
        body: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SafeArea(
                top: false,
                child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    width: Screen.width(context),
                    child: ViewModelBuilder<PatientWidgetmodel>.reactive(
                        onModelReady: (model) async {
                          //setState(() {});
                          // await model.getPatientsDetails("623d47fd8f2e2e002e3e26b1");
                          // await model.getPatientsList(preferencesService.userId);
                          // print(model.sourceUsers.toString());
                          //await model.getPatientsList("6200c2021da5d80033aa6ea8");
                          model.getBookedPatientDetail(widget.patientId, 0);
                        },
                        builder: (context, model, child) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              UIHelper.verticalSpaceSmall,
                              UIHelper.addHeader(context, " View Patients", true),
                              //addHeader(context, true),
                              UIHelper.verticalSpaceSmall,
                              // Expanded(
                              //     child: SingleChildScrollView(
                              Column(
                                children: [
                                  UIHelper.verticalSpaceSmall,
                                  //  showSearchField(context),
                                  // UIHelper.verticalSpaceMedium, patients_list_card(context),
                                  model.isBusy ? UIHelper.swarPreloader() : patientsList(model),
                                  // showCategories(context),
                                  //patient_list_card(context)
                                  //UIHelper.verticalSpaceSmall,
                                  GestureDetector(
                                    onTap: () {
                                      // Get.to(() => PatientDocumnetListView(patientDoc: widget.patientDoc));
                                      Get.to(() => PatientDocumnetListView(patientDoc: model.fileName));
                                    },
                                    child: Text(
                                      "Click here to all view records",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        decoration: TextDecoration.underline,
                                      ),
                                    ).textColor(activeColor).fontSize(14).bold(),
                                  ),
                                  UIHelper.verticalSpaceMedium,
                                  Text("History", textAlign: TextAlign.center).fontSize(14).bold(),
                                  UIHelper.verticalSpaceSmall,
                                  //showTable()
                                  //TableList(model)
                                  showTable(context, model)
                                ],
                              ),
                            ],
                          );
                        },
                        viewModelBuilder: () => PatientWidgetmodel())))));
  }
}
