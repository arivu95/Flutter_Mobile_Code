import 'dart:async';

import 'package:doctor_module/src/ui/doc_appoinment/doctor_appointment_model.dart';
import 'package:doctor_module/src/ui/doc_signup/doc_terms_view.dart';
import 'package:flutter/material.dart';
import 'package:swarapp/app/pref_util.dart';
import 'package:swarapp/frideos/streamed_value.dart';
import 'package:swarapp/services/call_manager.dart';
import 'package:swarapp/services/connectycube_services.dart';
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
import 'package:flutter_pin_code_fields/flutter_pin_code_fields.dart';
import 'package:connectycube_sdk/connectycube_sdk.dart';
import 'package:intl/intl.dart';

class DocWaitingView extends StatefulWidget {
  String passcode;
  String patientId;
  String time;
  String date;
  DocWaitingView({Key? key, required this.passcode, required this.patientId, required this.time, required this.date}) : super(key: key);
  @override
  _DocWaitingViewState createState() => _DocWaitingViewState();
}

final kToday = DateTime.now();
final kFirstDay = DateTime(kToday.year, kToday.month - 3, kToday.day);
final kLastDay = DateTime(kToday.year, kToday.month + 3, kToday.day);
TextEditingController searchController = TextEditingController();
String _otp = '';
int selectedIndex = 0;
var focused_date;
var select_appointment;
var change_time;
dynamic selection_date_list = {};
List<dynamic> whole_list = [];
String appointment = '';
String slot_shift = '';
bool isSearch = false;
Timer? countdownTimer;
DateTime timenow = DateTime.now();
bool isOpenOtp = false;
//Duration myDuration = Duration(minutes: timenow.minute); // need to  time to subtract
Duration myDuration = Duration(minutes: timenow.minute);
ValueNotifier minutesDecrementValueNotifier = ValueNotifier(0);
ValueNotifier secondsDecrementValueNotifier = ValueNotifier(0);
StreamedValue<String> currentTimeStream = StreamedValue<String>(initialData: DateFormat('kk:mm').format(timenow));

class _DocWaitingViewState extends State<DocWaitingView> with WidgetsBindingObserver {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool status = false;
  final CallManager callManager = locator<CallManager>();
  ConnectyCubeServices connectyCubeServices = locator<ConnectyCubeServices>();
  String formattedDate = "";
  String _timeString = "";
  void initState() {
    super.initState();
    callManager.init(context);
    WidgetsBinding.instance!.addObserver(this);
    Timer.periodic(Duration(seconds: 1), (Timer t) => _getTime());
  }

  void _getTime() {
    formattedDate = DateFormat('MM-dd-yyyy').format(DateTime.now()).toString();
    //String formattedDateTime = DateFormat('yyyy-MM-dd \n kk:mm:ss')
    final String formattedDateTime = DateFormat('hh:mm').format(DateTime.now()).toString();
    setState(() {
      _timeString = formattedDateTime;
      print(_timeString);
    });
  }

  void cube_connect() {
    bool isChatDisconnected = CubeChatConnection.instance.chatConnectionState == CubeChatConnectionState.Closed || CubeChatConnection.instance.chatConnectionState == CubeChatConnectionState.ForceClosed;
    if (isChatDisconnected && CubeChatConnection.instance.currentUser != null) {
      CubeChatConnection.instance.relogin();
    }
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
              Text('Appointments').fontSize(16).fontWeight(FontWeight.w600),
            ],
          ),
        ],
      ),
    );
  }

  Widget requestcard(BuildContext context, Manageappointmentmodel model) {
    String strDigits(int n) => n.toString().padLeft(2, '0');
    final days = strDigits(myDuration.inDays);
    // Step 7
    final hours = strDigits(myDuration.inHours.remainder(24));
    final minutes = strDigits(myDuration.inMinutes.remainder(60));
    //minutesDecrementValueNotifier.value = minutes;
    //minutesDecrementValueNotifier.value = formattedTime_now;

    final seconds = strDigits(myDuration.inSeconds.remainder(60));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(10),
          width: Screen.width(context) / 1.1,
          decoration: UIHelper.allcornerRadiuswithbottomShadow(12, 12, 12, 12, Colors.white),
          child: Column(
            children: [
              Column(
                children: [
                  Text('Details for this appointments').bold().fontSize(14),
                  UIHelper.verticalSpaceSmall,
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Row(children: [Text('Short reason for request').fontSize(15).textColor(Colors.black38)]),
              ),
              UIHelper.verticalSpaceSmall,
              Container(
                height: 100,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: Colors.black38,
                    )),
                padding: EdgeInsets.all(12),
                child: TextField(
                  decoration: InputDecoration.collapsed(hintText: "Sore throat  and sevier headache"),
                ),
              ),
              UIHelper.verticalSpaceSmall,
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Row(
                  children: [Text('Health records')],
                ),
              ),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: Colors.black38,
                    )),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          height: 70,
                          width: 70,
                          decoration: UIHelper.allcornerRadiuswithbottomShadow(2, 2, 2, 2, fieldBgColor),
                          child: Icon(
                            Icons.note,
                            color: Colors.black38,
                          ),
                        ),
                        UIHelper.horizontalSpaceSmall,
                        Container(
                          height: 70,
                          width: 70,
                          decoration: UIHelper.allcornerRadiuswithbottomShadow(2, 2, 2, 2, fieldBgColor),
                          child: Icon(
                            Icons.note,
                            color: Colors.black38,
                          ),
                        ),
                      ],
                    ),
                    UIHelper.verticalSpaceSmall,
                    Row(
                      children: [
                        UIHelper.horizontalSpaceMedium,
                        Text('Record\n Name'),
                        UIHelper.horizontalSpaceMedium,
                        Text('Record\n Name'),
                      ],
                    ),
                  ],
                ),
              ),
              UIHelper.verticalSpaceLarge,
              // ValueListenableBuilder(
              //     valueListenable: minutesDecrementValueNotifier,
              //     builder: (context, $minutes, child) {
              //       if (int.parse(minutes) == 9) {
              //         //  print('============nine' + $minutes.toString());
              //         // Fluttertoast.showToast(
              //         //   msg: "Call will be endup within $minutes minutes",
              //         //   gravity: ToastGravity.TOP,
              //         // );
              //       }
              //       //                     else if (int.parse(minutes) == 9 && int.parse(seconds) == 3) {
              //       // //need to restrict decline call==while end up with limited time zer0
              //       //                     }
              //       return Positioned(
              //         top: 50.0,
              //         right: 30.0,
              //         child: Text('$hours:$minutes:$seconds      ',
              //             style: TextStyle(
              //               color: Colors.black,
              //               fontSize: 15,
              //             )),
              //       );
              //     }),
              //
              // ValueListenableBuilder(
              //     valueListenable: minutesDecrementValueNotifier,
              //     builder: (context, $minutes, child) {
              //       // if (int.parse(minutes) == 9) {
              //       //   //  print('============nine' + $minutes.toString());
              //       //   // Fluttertoast.showToast(
              //       //   //   msg: "Call will be endup within $minutes minutes",
              //       //   //   gravity: ToastGravity.TOP,
              //       //   // );
              //       // }
              //       //                     else if (int.parse(minutes) == 9 && int.parse(seconds) == 3) {
              //       // //need to restrict decline call==while end up with limited time zer0
              //       //                     }
              //       return Positioned(
              //         top: 50.0,
              //         right: 30.0,
              //         child: Text(formattedTime_now,
              //             style: TextStyle(
              //               color: Colors.black,
              //               fontSize: 15,
              //             )),
              //       );
              //     }),
              // Container(child: StreamBuilder<String?>(stream: currentTimeStream.outStream,

              // builder: (context, snapshotname) => Text(snapshotname.data.toString()
              // ))),
              //need to check current date
              _timeString == widget.time && widget.date == formattedDate
                  ? ElevatedButton(
                      onPressed: () async {
                        // Loader.show(context);
                        preferencesService.isConsultationCall.value = true;
                        //isConsultationCall
                        // Loader.hide();
                        // Get.back();
                        CubeUser? currentUser = await SharedPrefs.getUser();
                        // Loader.show(context);
                        cube_connect();
                        List<int> ccid = [];
                        ccid.add(int.parse(widget.patientId));
                        //                    callManager.startNewCall(context, CallType.VIDEO_CALL, model.ccIds.toSet());
                        callManager.startNewCall(context, CallType.VIDEO_CALL, ccid.toSet());
                      },
                      child: Text(
                        'Join ' + widget.time + _timeString.toString(),
                      ).bold(),
                      style:
                          // ButtonStyle(
                          //   minimumSize: MaterialStateProperty.all(Size(150, 36)),
                          //   backgroundColor: MaterialStateProperty.all(Colors.grey),
                          // )),
                          ButtonStyle(
                              minimumSize: MaterialStateProperty.all(Size(70, 40)),
                              backgroundColor: MaterialStateProperty.all(activeColor),
                              shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)))))
                  : ElevatedButton(
                      onPressed: null,
                      child: Text('Join '
                              //_timeString.toString(),
                              )
                          .bold(),
                      style:
                          // ButtonStyle(
                          //   minimumSize: MaterialStateProperty.all(Size(150, 36)),
                          //   backgroundColor: MaterialStateProperty.all(Colors.grey),
                          // )),
                          ButtonStyle(
                              minimumSize: MaterialStateProperty.all(Size(70, 40)),
                              backgroundColor: MaterialStateProperty.all(greycolor),
                              shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))))),
//for testing
              ElevatedButton(
                  onPressed: () async {
                    // Loader.show(context);
                    // preferencesService.isConsultationCall.value = true;
                    //isConsultationCall
                    // Loader.hide();
                    // Get.back();
                    CubeUser? currentUser = await SharedPrefs.getUser();
                    // Loader.show(context);
                    cube_connect();
                    List<int> ccid = [];
                    preferencesService.isConsultationCall.value = true;

                    ccid.add(int.parse(widget.patientId));
                    //                    callManager.startNewCall(context, CallType.VIDEO_CALL, model.ccIds.toSet());
                    callManager.startNewCall(context, CallType.VIDEO_CALL, ccid.toSet());
                    await optScreen();
                  },
                  child: Text(
                    'check call' + widget.time + _timeString.toString(),
                  ).bold(),
                  style:
                      // ButtonStyle(
                      //   minimumSize: MaterialStateProperty.all(Size(150, 36)),
                      //   backgroundColor: MaterialStateProperty.all(Colors.grey),
                      // )),
                      ButtonStyle(
                          minimumSize: MaterialStateProperty.all(Size(70, 40)),
                          backgroundColor: MaterialStateProperty.all(activeColor),
                          shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)))))
            ],
          ),
        ),
        UIHelper.verticalSpaceSmall,
      ],
    );
  }

  Future optScreen() async {
    return showDialog(
        context: context,
        builder: (BuildContext context) => Dialog(
              child: Container(
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: Colors.white,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    UIHelper.verticalSpaceSmall,
                    Align(
                      alignment: Alignment.centerRight,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          InkWell(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Container(width: 50, height: 20, child: Icon(Icons.cancel)))
                        ],
                      ),
                    ),
                    UIHelper.verticalSpaceSmall,
                    Container(
                        alignment: Alignment.center,
                        width: double.infinity,
                        child: Center(
                            child: Flexible(
                                child: Text(
                          'Please Enter the OTP to start consultation',
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ).bold()))),
                    UIHelper.verticalSpaceSmall,
                    Container(
                        alignment: Alignment.center,
                        width: double.infinity,
                        child: Center(
                            child: Flexible(
                                child: Text(
                          'A Otp has notify in your patient screen',
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ).fontSize(11).textColor(Colors.grey)))),
                    UIHelper.verticalSpaceSmall,
                    Container(
                      width: 200,
                      child: PinCodeFields(
                        length: 4,
                        fieldBorderStyle: FieldBorderStyle.Square,
                        responsive: true,
                        fieldHeight: 35.0,
                        fieldWidth: 30.0,
                        borderWidth: 0.5,
                        // activeBorderColor: Colors.pink,
                        // activeBackgroundColor: Colors.pink.shade100,
                        borderRadius: BorderRadius.circular(5.0),
                        keyboardType: TextInputType.number,
                        autoHideKeyboard: false,
                        fieldBackgroundColor: Colors.black12,
                        borderColor: Colors.black38,

                        onComplete: (output) {
                          // Your logic with pin code
                          print(output);
                          _otp = output;
                        },
                      ),
                    ),
                    ElevatedButton(
                        onPressed: () async {
                          if (_otp != null) {
                            if (_otp == widget.passcode) {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text('Succesfull!'),
                                      content: Text('OTP Verified Succesfully'),
                                      actions: <Widget>[
                                        // FlatButton(
                                        //   color: Colors.red,
                                        //   textColor: Colors.white,
                                        //   child: Text('No'),
                                        //   onPressed: () {
                                        //     Navigator.pop(context);
                                        //   },
                                        // ),
                                        FlatButton(
                                          color: Colors.green,
                                          textColor: Colors.white,
                                          child: Text('OK'),
                                          onPressed: () async {
                                            Navigator.pop(context);
                                            preferencesService.inPipMode!.value = false;
                                            // Loader.show(context);
                                            // await deleteDialog(widget._cubeDialog.dialogId!, isForceDelete);
                                            // Loader.hide();
                                            // Get.back();
                                          },
                                        ),
                                      ],
                                    );
                                  });
                            } else {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text('Failed !'),
                                      content: Text('OTP Verified Failed!!'),
                                      actions: <Widget>[
                                        // FlatButton(
                                        //   color: Colors.red,
                                        //   textColor: Colors.white,
                                        //   child: Text('No'),
                                        //   onPressed: () {
                                        //     Navigator.pop(context);
                                        //   },
                                        // ),
                                        FlatButton(
                                          color: Colors.green,
                                          textColor: Colors.white,
                                          child: Text('OK'),
                                          onPressed: () async {
                                            Navigator.pop(context);
                                            // Loader.show(context);
                                            // await deleteDialog(widget._cubeDialog.dialogId!, isForceDelete);
                                            // Loader.hide();
                                            // Get.back();
                                            preferencesService.inPipMode!.value = false;
                                            // setState(() {
                                            //   preferencesService.isConsultationVerified = "no";
                                            // });
                                          },
                                        ),
                                      ],
                                    );
                                  });
                            }
                          }
                        },
                        child: Text('Verify OTP').bold(),
                        style: ButtonStyle(
                            minimumSize: MaterialStateProperty.all(Size(150, 36)),
                            backgroundColor: MaterialStateProperty.all(activeColor),
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: Colors.red))))),
                    //      child: Text('Verify OTP').bold(),
                    // style: ButtonStyle(
                    //     minimumSize: MaterialStateProperty.all(Size(150, 36)),
                    //     backgroundColor: MaterialStateProperty.all(activeColor),
                    //     shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: Colors.red))))),
                  ],
                ),
              ),
            ));
  }

  Widget requestAcceptcard(BuildContext context, Manageappointmentmodel model) {
    print(widget.passcode.toString());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(10),
          width: Screen.width(context),
          decoration: UIHelper.allcornerRadiuswithbottomShadow(12, 12, 12, 12, Colors.white),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Text('Appointment requested').fontSize(10),
                      UIHelper.verticalSpaceTiny,
                      Row(children: [
                        Text('12 Mar 2021,10.30 Am ').fontSize(11).fontWeight(FontWeight.w600),
                      ]),
                    ],
                  ),
                  UIHelper.horizontalSpaceSmall,
                  Column(
                    children: [
                      Text('Appointment Mode').fontSize(10),
                      UIHelper.verticalSpaceTiny,
                      Row(children: [
                        Icon(
                          Icons.videocam,
                          color: Colors.black,
                          size: 18,
                        ),
                        UIHelper.horizontalSpaceSmall,
                        Text('Video Consultation').fontSize(11).fontWeight(FontWeight.w600),
                      ]),
                    ],
                  ),
                ],
              ),
              UIHelper.hairLineWidget(),
              UIHelper.horizontalSpaceSmall,
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
                          Text('SM-A00001A').fontSize(10).textColor(Colors.black38),
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
                        Text('Sam Sharma').fontSize(12).fontWeight(FontWeight.w600),
                        UIHelper.verticalSpaceTiny,
                        Text('25 Yrs , Male, Chennai').fontSize(10).textColor(Colors.black38),
                        UIHelper.verticalSpaceTiny,
                        Text('+91 9856235689').fontSize(10).fontWeight(FontWeight.w600),
                        UIHelper.verticalSpaceSmall,
                        Text('arun@gmail.com').fontSize(12).fontWeight(FontWeight.w600),
                      ],
                    ),
                  )),
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
                          // _showModalBottomSheet();
                          showDialog(
                              context: context,
                              builder: (BuildContext context) => Dialog(
                                    child: Container(
                                      height: 250,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(Radius.circular(10)),
                                        color: Colors.white,
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: <Widget>[
                                          UIHelper.verticalSpaceSmall,
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [
                                                InkWell(
                                                    onTap: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: Container(width: 50, height: 20, child: Icon(Icons.cancel)))
                                              ],
                                            ),
                                          ),
                                          UIHelper.verticalSpaceSmall,
                                          Container(
                                              alignment: Alignment.center,
                                              width: double.infinity,
                                              child: Center(
                                                  child: Flexible(
                                                      child: Text(
                                                'Please Enter the OTP to start consultation',
                                                textAlign: TextAlign.center,
                                                overflow: TextOverflow.ellipsis,
                                              ).bold()))),
                                          UIHelper.verticalSpaceSmall,
                                          Container(
                                              alignment: Alignment.center,
                                              width: double.infinity,
                                              child: Center(
                                                  child: Flexible(
                                                      child: Text(
                                                'A Otp has notify in your patient screen',
                                                textAlign: TextAlign.center,
                                                overflow: TextOverflow.ellipsis,
                                              ).fontSize(11).textColor(Colors.grey)))),
                                          UIHelper.verticalSpaceSmall,
                                          Container(
                                            width: 200,
                                            child: PinCodeFields(
                                              length: 4,
                                              fieldBorderStyle: FieldBorderStyle.Square,
                                              responsive: true,
                                              fieldHeight: 35.0,
                                              fieldWidth: 30.0,
                                              borderWidth: 0.5,
                                              // activeBorderColor: Colors.pink,
                                              // activeBackgroundColor: Colors.pink.shade100,
                                              borderRadius: BorderRadius.circular(5.0),
                                              keyboardType: TextInputType.number,
                                              autoHideKeyboard: false,
                                              fieldBackgroundColor: Colors.black12,
                                              borderColor: Colors.black38,

                                              onComplete: (output) {
                                                // Your logic with pin code
                                                print(output);
                                                _otp = output;
                                              },
                                            ),
                                          ),
                                          ElevatedButton(
                                              onPressed: () async {
                                                if (_otp != null) {
                                                  if (_otp == widget.passcode) {
                                                    showDialog(
                                                        context: context,
                                                        builder: (context) {
                                                          return AlertDialog(
                                                            title: Text('Succesfull!'),
                                                            content: Text('OTP Verified Succesfully'),
                                                            actions: <Widget>[
                                                              // FlatButton(
                                                              //   color: Colors.red,
                                                              //   textColor: Colors.white,
                                                              //   child: Text('No'),
                                                              //   onPressed: () {
                                                              //     Navigator.pop(context);
                                                              //   },
                                                              // ),
                                                              FlatButton(
                                                                color: Colors.green,
                                                                textColor: Colors.white,
                                                                child: Text('OK'),
                                                                onPressed: () async {
                                                                  Navigator.pop(context);
                                                                  // Loader.show(context);
                                                                  // await deleteDialog(widget._cubeDialog.dialogId!, isForceDelete);
                                                                  // Loader.hide();
                                                                  Get.back();
                                                                },
                                                              ),
                                                            ],
                                                          );
                                                        });
                                                  } else {
                                                    showDialog(
                                                        context: context,
                                                        builder: (context) {
                                                          return AlertDialog(
                                                            title: Text('Failed !'),
                                                            content: Text('OTP Verified Failed!!'),
                                                            actions: <Widget>[
                                                              // FlatButton(
                                                              //   color: Colors.red,
                                                              //   textColor: Colors.white,
                                                              //   child: Text('No'),
                                                              //   onPressed: () {
                                                              //     Navigator.pop(context);
                                                              //   },
                                                              // ),
                                                              FlatButton(
                                                                color: Colors.green,
                                                                textColor: Colors.white,
                                                                child: Text('OK'),
                                                                onPressed: () async {
                                                                  Navigator.pop(context);
                                                                  // Loader.show(context);
                                                                  // await deleteDialog(widget._cubeDialog.dialogId!, isForceDelete);
                                                                  // Loader.hide();
                                                                  Get.back();
                                                                },
                                                              ),
                                                            ],
                                                          );
                                                        });
                                                  }
                                                }
                                              },
                                              child: Text('Verify OTP').bold(),
                                              style: ButtonStyle(
                                                  minimumSize: MaterialStateProperty.all(Size(150, 36)),
                                                  backgroundColor: MaterialStateProperty.all(activeColor),
                                                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: Colors.red))))),
                                        ],
                                      ),
                                    ),
                                  ));
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
          ),
        ),
      ],
    );
  }

//timer
  void startTimer() {
    countdownTimer = Timer.periodic(Duration(seconds: 1), (_) => setCountDown());
  }

  void stopTimer() {
    setState(() => countdownTimer!.cancel());
  }

  void setCountDown() {
    final reduceSecondsBy = 1;
    setState(() {
      final seconds = myDuration.inSeconds - reduceSecondsBy;
      if (seconds < 0) {
        countdownTimer!.cancel();
      } else {
        myDuration = Duration(seconds: seconds);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SwarAppStaticBar(),
      body: Container(
        padding: EdgeInsets.all(12),
        child: ViewModelBuilder<Manageappointmentmodel>.reactive(
            onModelReady: (model) async {
              await model.getUserdetail('Booking List');
              //await model.getPatientsDetails(widget.patientId);
            },
            builder: (context, model, child) {
              return SingleChildScrollView(
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      addHeader(context, true),
                      UIHelper.verticalSpaceSmall,
                      requestAcceptcard(context, model),
                      UIHelper.verticalSpaceSmall,
                      model.isBusy ? CircularProgressIndicator() : requestcard(context, model),
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
