import 'package:doctor_module/src/ui/doc_signup/doc_terms_view.dart';
import 'package:doctor_module/src/ui/patient/patient_document_view.dart';
import 'package:doctor_module/src/ui/patient/patient_model.dart';
import 'package:flutter/material.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/app/pref_util.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/services/call_manager.dart';
import 'package:swarapp/services/connectycube_services.dart';
import 'package:swarapp/shared/app_doctorprofile_bar.dart';
import 'package:get/get.dart';
import 'package:swarapp/shared/app_colors.dart';
import 'package:swarapp/shared/flutter_overlay_loader.dart';
import 'package:swarapp/shared/screen_size.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:doctor_module/src/ui/patient/patient_detail_view.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:swarapp/ui/communication/chat_dialog_screen.dart';
import 'package:stacked/src/state_management/view_model_builder.dart';
import 'package:connectycube_sdk/connectycube_sdk.dart';
import 'package:jiffy/jiffy.dart';
import 'package:intl/intl.dart';

class PatientsView extends StatefulWidget {
  PatientsView({Key? key}) : super(key: key);
  @override
  _PatientsViewState createState() => _PatientsViewState();
}

final kToday = DateTime.now();
final kFirstDay = DateTime(kToday.year, kToday.month - 3, kToday.day);
final kLastDay = DateTime(kToday.year, kToday.month + 3, kToday.day);

class _PatientsViewState extends State<PatientsView> with WidgetsBindingObserver {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  late CubeUser currentUser;
  TextEditingController searchController = TextEditingController();
  final CallManager callManager = locator<CallManager>();
  ConnectyCubeServices connectyCubeServices = locator<ConnectyCubeServices>();
  bool _isInForeground = true;
  Jiffy slotDate = Jiffy();
  String img_url = "";
  bool isSearch = false;
  void initState() {
    super.initState();
    callManager.init(context);
    WidgetsBinding.instance!.addObserver(this);
  }

  void cube_connect() {
    bool isChatDisconnected = CubeChatConnection.instance.chatConnectionState == CubeChatConnectionState.Closed || CubeChatConnection.instance.chatConnectionState == CubeChatConnectionState.ForceClosed;
    if (isChatDisconnected && CubeChatConnection.instance.currentUser != null) {
      CubeChatConnection.instance.relogin();
    }
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

  void getChatDialogs() async {
    currentUser = (await SharedPrefs.getUser())!;
    //print(currentUser.avatar);
    await connectyCubeServices.getCubeDialogs();
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
                          // UIHelper.hairLineWidget(),
                          // Text('12.07.2021 ,10.30 Am ').fontSize(11).fontWeight(FontWeight.w600).textColor(Colors.white),
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
              Text('Patients').fontSize(16).fontWeight(FontWeight.w600),
            ],
          ),
          Row(
            children: [
              Icon(
                Icons.filter_alt,
                size: 25,
                color: Colors.black,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget addSearchHeader(BuildContext context,Pat) {
  //   return Padding(
  //     padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       children: [
  //         showSearchField(context),
  //       ],
  //     ),
  //   );
  // }

  Widget patients_List_card(BuildContext context, PatientWidgetmodel model, int index, dynamic val) {
    Jiffy fromDate_ = Jiffy(val['slot_date']);
    DateTime? patientDate;
    String slot = "";
    if (model.bookingsdata[index]['slot_date'] != null) {
      //slotDate = Jiffy(model.bookingsdata[index]['slot_date'].toString());
      // String s = slotDate.format('dd MMM yyyy');
      DateTime nowSlot = DateTime.parse(model.bookingsdata[index]['slot_date']);
      patientDate = nowSlot;
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
        Loader.show(context);
        await model.getBookedPatientDetail((val['patient_id']), index);
        Loader.hide();
        //await Get.to(() => PatientDetailView(patientId: (model.bookingsdata[index]['patient_id'])));
        await Get.to(() => PatientDetailView(patientId: (val['patient_id']), patientData: val, patientDoc: model.bookingappoinments[index]['appointment_upload_documents'], index: index));
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
                      Text(val['swar_Id']).fontSize(10).textColor(Colors.black38).bold(),
                    ],
                  ),
                  UIHelper.horizontalSpaceSmall,
                  Container(
                    width: Screen.width(context) / 3.1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(val['name']).fontSize(14).fontWeight(FontWeight.w600),
                        UIHelper.verticalSpaceTiny,
                        //+""+ val['gender'] + val['address']
                        val['age'] != null ? Text(val['age'].toString()).fontSize(10).textColor(Colors.black38).bold() : SizedBox(),
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
                        //UIHelper.verticalSpaceSmall,
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
                      width: Screen.width(context) / 3.5,
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
                              Text(" " + model.bookingsdata[index]["time"] != null ? model.bookingsdata[index]["time"].toString() : '').fontSize(11).bold(),
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
                              model.bookingsdata[index]['services_type'].toString().toLowerCase() == "online"
                                  ? Icon(
                                      Icons.videocam_rounded,
                                      size: 20,
                                      color: Colors.green,
                                    )
                                  : SizedBox(),
                              Text(model.bookingsdata[index]['services_type'] != null && model.bookingsdata[index]['services_type'] != "" ? model.bookingsdata[index]['services_type'] : '')
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
                              Text(model.bookingsdata[index]['paid_amount'] != null && model.bookingsdata[index]['paid_amount'] != "" ? "₹ " + model.bookingsdata[index]['paid_amount'] : '')
                                  .fontSize(10)
                                  .fontWeight(FontWeight.w600),
                              SizedBox(width: Screen.width(context) / 6),
                              //Text('Cancel ').fontSize(12).fontWeight(FontWeight.w600).textColor(activeColor),
                            ],
                          ),
                          // Container(
                          //   alignment: Alignment.topRight,
                          //   color: Colors.amber,
                          //   child: Align(
                          //     alignment: Alignment.topRight,
                          //     child: Text("Cancel"),
                          //   ),
                          // ),

                          UIHelper.verticalSpaceSmall,
                        ],
                      ),
                    ),
                    UIHelper.verticalSpaceSmall,
                  ])
                ]),
                UIHelper.hairLineWidget(),
                Text(patientDate!.isBefore(DateTime.now()) ? "Previous " : '' + slot).fontSize(10).fontWeight(FontWeight.w600)
                // DateFormat('dd MMM yyyy').format(DateTime.now()).toString()==slot ?
                //Text(slot).fontSize(10).fontWeight(FontWeight.w600)
                //Text('Previous - Online 12 March 2021 - Pnemonia ').fontSize(10).bold(),
              ])),
          UIHelper.verticalSpaceSmall,
        ],
      ),
    );
  }

  Widget showSearchField(BuildContext context, PatientWidgetmodel model) {
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
                    model.getPatient_search(value);

                    setState(() {
                      isSearch = true;
                    });
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
                              onPressed: () {
                                searchController.clear();
                                model.getPatient_search('');
                                setState(() {
                                  isSearch = true;
                                });
                                FocusManager.instance.primaryFocus!.unfocus();
                              }),
                      contentPadding: EdgeInsets.only(left: 20),
                      enabledBorder: UIHelper.getInputBorder(0, radius: 12, borderColor: Color(0xFFCCCCCC)),
                      focusedBorder: UIHelper.getInputBorder(0, radius: 12, borderColor: Color(0xFFCCCCCC)),
                      focusedErrorBorder: UIHelper.getInputBorder(0, radius: 12, borderColor: Color(0xFFCCCCCC)),
                      errorBorder: UIHelper.getInputBorder(0, radius: 12, borderColor: Color(0xFFCCCCCC)),
                      filled: true,
                      hintStyle: new TextStyle(color: Colors.grey[800]),
                      hintText: "Search(Swar id, name, phone number)",
                      fillColor: fieldBgColor),
                ),
              ),
            ),
            // Icon(
            //   Icons.filter_alt,
            //   size: 25,
            //   color: Colors.black,
            // ),
            // Container(
            //   // decoration: UIHelper.roundedLineBorderWithColor(12, fieldBgColor, 1),
            //   padding: EdgeInsets.all(0),
            //   child: PopupMenuButton(
            //     padding: EdgeInsets.all(0),
            //     icon: Icon(
            //       Icons.filter_alt,
            //       size: 25,
            //       color: Colors.black,
            //     ),
            //     //Image.asset('assets/sort_icon.png'),
            //     onSelected: (value) async {
            //       model.sortMode = value.toString();

            //       // model.refreshView();

            //       // if (selectedIndex == 0) {
            //       //   model.refreshView('request');
            //       //   setState(() {
            //       //     selectedIndex = 0;
            //       //     preferencesService.selected_role = 'request';
            //       //   });
            //       // } else {
            //       //   model.refreshView('');
            //       //   setState(() {
            //       //     selectedIndex = 1;
            //       //     preferencesService.selected_role = 'accepted';
            //       //   });
            //       // }
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
            //           value: 'swarid',
            //           child: Row(children: [
            //             Icon(
            //               Icons.calendar_today,
            //             ),
            //             UIHelper.horizontalSpaceSmall,
            //             Text(
            //               'Sort by Swar Id',
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
            // ),
            UIHelper.verticalSpaceLarge,
          ],
        ),
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    setState(() {
      if (state == AppLifecycleState.paused) {
        _isInForeground = false;
      } else {
        _isInForeground = true;
      }
    });
  }

  @override
  void dispose() {
    // msgSubscription?.cancel();
    // deliveredSubscription?.cancel();
    // readSubscription?.cancel();
    // typingSubscription?.cancel();
    // textEditingController.dispose();
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  Widget patientsList(PatientWidgetmodel model) {
    return Container(
        // color: Colors.grey,
        height: Screen.height(context) / 1.5,
        child: ListView.builder(
            itemCount: isSearch ? model.search_Patients_list.length : model.bookingPatients.length,
            itemBuilder: (BuildContext context, int index) {
              print("new");
              return patients_List_card(context, model, index, isSearch ? model.search_Patients_list[index] : model.bookingPatients[index]);
            }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: SwarAppDoctorBar(isProfileBar: false),
        body: SafeArea(
            top: false,
            child: SingleChildScrollView(
                child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    width: Screen.width(context),
                    child: ViewModelBuilder<PatientWidgetmodel>.reactive(
                        onModelReady: (model) async {
                          //setState(() {});
                          // await model.getPatientsDetails("623d47fd8f2e2e002e3e26b1");
                          //
                          await model.getPatientsList(preferencesService.userId);

                          print(model.sourceUsers.toString());
                        },
                        builder: (context, model, child) {
                          return model.bookingPatients.length > 0
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    UIHelper.verticalSpaceSmall,
                                    // addHeader(context, true),

                                    Text(' Patients').bold(),

                                    // Expanded(
                                    // child: SingleChildScrollView(
                                    // Column(
                                    //   children: [

                                    showSearchField(context, model),

                                    // GestureDetector(
                                    //   onTap: () {
                                    //     Get.to(() => PatientDocumnetListView());
                                    //   },
                                    //   child: Text(
                                    //     "Click here to all view records",
                                    //     textAlign: TextAlign.center,
                                    //     style: TextStyle(
                                    //       decoration: TextDecoration.underline,
                                    //     ),
                                    //   ).textColor(activeColor).fontSize(14).bold(),
                                    // ),

                                    patientsList(model),

                                    //  ]))
                                  ],
                                )
                              : Container(
                                  width: Screen.width(context),
                                  height: Screen.height(context) / 2,
                                  alignment: Alignment.center,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [Text("No more Patients")],
                                  ));
                        },
                        viewModelBuilder: () => PatientWidgetmodel())))));
  }
}
