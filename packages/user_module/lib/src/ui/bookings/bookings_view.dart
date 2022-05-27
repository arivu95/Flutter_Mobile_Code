import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:stacked/stacked.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/services/preferences_service.dart';
import 'package:swarapp/services/pushnotification_service.dart';
import 'package:swarapp/shared/app_colors.dart';
import 'package:swarapp/shared/app_static_bar.dart';
import 'package:swarapp/shared/flutter_overlay_loader.dart';
import 'package:swarapp/shared/screen_size.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:get/get.dart';
import 'package:flutter_rating_stars/flutter_rating_stars.dart';
import 'package:user_module/src/ui/bookings/bookings_tab_view.dart';
import 'package:user_module/src/ui/bookings/bookings_view_model.dart';

class PatientAppointmentsView extends StatefulWidget {
  const PatientAppointmentsView({Key? key}) : super(key: key);

  @override
  State<PatientAppointmentsView> createState() => _PatientAppointmentsViewState();
}

class _PatientAppointmentsViewState extends State<PatientAppointmentsView> {
  BookingsViewModel modelRef = BookingsViewModel();
  Map<String, dynamic> userInfo = {};
  final kToday = DateTime.now();
  double value = 0.0;
// final kFirstDay = DateTime(kToday.year, kToday.month - 3, kToday.day);
// final kLastDay = DateTime(kToday.year, kToday.month + 3, kToday.day);
  Jiffy slotDate = Jiffy();
  String timeZone = '';

  Future<void> _displayStarDialog(BuildContext context, BookingsViewModel model, String docId, String doctorName) async {
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              content: SizedBox(
                height: 120,
                child: Column(children: [
                  UIHelper.verticalSpaceMedium,
                  Text('Rate your Consultation by').fontSize(14).textColor(Colors.black38),
                  UIHelper.verticalSpaceSmall,
                  Text(doctorName).fontSize(16).bold(),
                  UIHelper.verticalSpaceMedium,
                  RatingStars(
                    value: value,
                    onValueChanged: (v) {
                      //
                      setState(() {
                        value = v;
                      });
                    },
                    starBuilder: (index, color) => Icon(
                      Icons.star_border_outlined,
                      color: color,
                    ),
                    starCount: 5,
                    starSize: 20,
                    valueLabelColor: const Color(0xff9b9b9b),
                    valueLabelTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w400, fontStyle: FontStyle.normal, fontSize: 12.0),
                    valueLabelRadius: 10,
                    maxValue: 5,
                    starSpacing: 2,
                    maxValueVisibility: true,
                    valueLabelVisibility: true,
                    animationDuration: Duration(milliseconds: 1000),
                    valueLabelPadding: const EdgeInsets.symmetric(vertical: 1, horizontal: 8),
                    valueLabelMargin: const EdgeInsets.only(right: 8),
                    starOffColor: const Color(0xffe7e8ea),
                    starColor: activeColor,
                  ),
                ]),
              ),
              actions: <Widget>[
                FlatButton(
                  color: Colors.red,
                  textColor: Colors.white,
                  child: Text('CANCEL'),
                  onPressed: () {
                    setState(() {
                      Navigator.pop(context);
                    });
                  },
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    int ratingConvert = value.toInt();
                    await model.doctorRatingUpdate(docId, ratingConvert.toString());
                    setState(() {
                      value = 0.0;
                    });
                  },
                  child: Text('Ok'),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith((states) {
                      return Colors.green;
                    }),
                  ),
                ),
              ],
            );
          });
        });
  }

  Widget addHeader(BuildContext context, bool isBackBtnVisible) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Bookings').fontSize(16).fontWeight(FontWeight.w600),
          Container(
            // decoration: UIHelper.roundedLineBorderWithColor(12, fieldBgColor, 1),
            padding: EdgeInsets.all(0),
            child: PopupMenuButton(
              padding: EdgeInsets.all(0),
              icon: Icon(Icons.filter_alt),
              onSelected: (value) async {
                modelRef.sortMode = value.toString();
                modelRef.refreshView();
              },
              itemBuilder: (context) {
                return <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'name',
                    child: Row(children: [
                      Icon(
                        Icons.sort_by_alpha,
                      ),
                      UIHelper.horizontalSpaceSmall,
                      Text(
                        'Sort by\nDoctor Name',
                        style: TextStyle(fontSize: 13),
                      ),
                    ]),
                  ),
                  PopupMenuItem<String>(
                    value: 'date',
                    child: Row(children: [
                      Icon(
                        Icons.calendar_today,
                      ),
                      UIHelper.horizontalSpaceSmall,
                      Text(
                        'Sort by Date',
                        style: TextStyle(fontSize: 13),
                      ),
                    ]),
                  ),
                  PopupMenuItem<String>(
                    value: 'cancel',
                    child: Row(children: [
                      Icon(
                        Icons.close,
                      ),
                      UIHelper.horizontalSpaceSmall,
                      Text(
                        'Remove',
                        style: TextStyle(fontSize: 13),
                      ),
                    ]),
                  ),
                ];
              },
            ),
            //  Row(
            //   children: [
            //     InkWell(
            //       onTap: () {
            //         setState(() {
            //           book = 2;
            //         });
            //       },
            //       onDoubleTap: () {
            //         setState(() {
            //           book = 1;
            //         });
            //       },
            //       child: book != 1
            //           ? Icon(
            //               Icons.filter_alt_outlined,
            //             )
            //           : Icon(
            //               Icons.filter_alt,
            //             ),
            //     ),
            //   ],
            // )
          ),
        ],
      ),
    );
  }

  Widget bookingAppointment(
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
            padding: EdgeInsets.only(left: 10, right: 20, top: 20, bottom: 10),
            width: Screen.width(context),
            decoration: UIHelper.allcornerRadiuswithbottomShadow(12, 12, 12, 12, Colors.white),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Want to book an appointment?').fontSize(12).bold(),
                    UIHelper.verticalSpaceSmall,
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: activeColor, // background
                          onPrimary: Colors.white, // foreground
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                        ),
                        onPressed: () {
                          final BottomNavigationBar navigationBar = locator<PreferencesService>().bottomTab_globalKey.currentWidget as BottomNavigationBar;

                          navigationBar.onTap!(0);
                          preferencesService.user_login = '';

                          setState(() {});
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(builder: (context) => const BookingsTabView()),
                          // );
                        },
                        child: Text('Book an appointment'))
                  ],
                ),
                Spacer(
                  flex: 1,
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 15, right: 8.0),
                  child: CircleAvatar(
                      backgroundColor: Colors.blue,
                      radius: 30,
                      child: Image.asset(
                        'assets/userch2.png',
                        fit: BoxFit.cover,
                        height: 100,
                      )),
                ),
              ],
            )),
        UIHelper.verticalSpaceSmall,
      ],
    );
  }

  Widget tabView(BuildContext context, BookingsViewModel model) {
    return DefaultTabController(
        length: 2, // length of tabs
        initialIndex: 0,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
          Container(
            child: TabBar(
              labelStyle: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
              indicatorColor: activeColor,
              tabs: [
                Tab(text: 'Upcoming'),
                Tab(text: 'Previous'),
              ],
            ),
          ),
          Container(
              height: Screen.height(context) / 1.47, //height of TabBarView
              decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.grey, width: 0.5))),
              child: TabBarView(children: <Widget>[
                Container(
                  padding: EdgeInsets.only(top: 5),
                  child: model.isBusy
                      ? Center(child: Container(child: CircularProgressIndicator()))
                      : model.upcommingdata.length == 0
                          ? Center(child: Text('No Appointments'))
                          : ListView.builder(
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              itemCount: model.upcommingdata.length,
                              itemBuilder: (BuildContext context, int index) {
                                return listofAppoinmentCard(context, model, model.upcommingdata[index], index, 'upcomming');
                              }),
                ),
                Container(
                  child: model.isBusy
                      ? Center(child: Container(child: CircularProgressIndicator()))
                      : model.previousdata.length == 0
                          ? Center(child: Text('No Appointments'))
                          : ListView.builder(
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              itemCount: model.previousdata.length,
                              itemBuilder: (BuildContext context, int index) {
                                return listofAppoinmentCard(context, model, model.previousdata[index], index, 'previous');
                              }),
                )
              ])),
        ]));
  }

  Widget listofAppoinmentCard(BuildContext context, BookingsViewModel model, dynamic data, int index, String title) {
    Jiffy fromDate_ = Jiffy(data['slot_date']);
    if (data['slot_date'] != null) {
      slotDate = Jiffy(data['slot_date']);
    }
    String img_url = '';
    if (data['profileData']['azureBlobStorageLink'] != null) {
      img_url = '${ApiService.fileStorageEndPoint}${data['profileData']['azureBlobStorageLink']}';
    }

    if (data["shift"] != 'evening' && data["shift"] != 'afternoon') {
      timeZone = 'AM';
    } else {
      timeZone = 'PM';
    }

    dynamic doctorDetails = data['profileData']['doctor_profile_id'];

    String qualification = '';
    if (doctorDetails['educational_information'].length > 0) {
      for (int i = 0; doctorDetails['educational_information'].length > i; i++) {
        var qua = doctorDetails['educational_information'][i]['qualification'];
        if (qua != "" && qua != null) {
          qualification != '' ? qualification = qualification + ',' + qua.toString() : qualification = qua.toString();
        }
      }
    }

    return InkWell(
      onTap: () async {
        String userId = preferencesService.userId;
        await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ManageBookingsView(
                  qualification: qualification,
                  patientId: userId,
                  doctorId: data['doctor_id'],
                  date: data['slot_date'],
                  time: data["time"],
                  doctorDetails: data['profileData'],
                  patienDetails: data,
                  passcode: data['passcode'])),
        );

        //    await model.getbookingList();
        setState(() {});
      },
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
                padding: EdgeInsets.only(left: 5, right: 5, top: 5, bottom: 10),
                width: Screen.width(context),
                decoration: UIHelper.allcornerRadiuswithbottomShadow(15, 15, 15, 15, Colors.white),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(alignment: Alignment.center, child: Text('Appointment Date').fontSize(10)),
                            UIHelper.verticalSpaceSmall,
                            Container(
                                padding: EdgeInsets.only(bottom: 5),
                                alignment: Alignment.center,
                                height: 20,
                                //width: Screen.width(context) / 2.3,
                                child: Text(slotDate.format('dd MMM yyyy') + ' , ' + data["time"] + ' ' + timeZone.toString()).fontSize(12).bold()),
                          ],
                        ),
                        Spacer(
                          flex: 1,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(alignment: Alignment.center, child: Text('Appointment Mode').fontSize(10)),
                            UIHelper.verticalSpaceSmall,
                            Container(
                                height: 20,
                                // width: Screen.width(context) / 2.3,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    FittedBox(
                                      child: data['services_type'] != null
                                          ? data['services_type'] == "Online"
                                              ? Container(
                                                  padding: EdgeInsets.only(bottom: 5),
                                                  alignment: Alignment.topCenter,
                                                  child: Icon(
                                                    Icons.videocam,
                                                    size: 20,
                                                  ),
                                                )
                                              : Container(
                                                  padding: EdgeInsets.only(bottom: 5),
                                                  alignment: Alignment.topCenter,
                                                  child: Image.asset(
                                                    'assets/home_visit_img.png',
                                                    fit: BoxFit.none,
                                                  ),
                                                )
                                          : Container(
                                              padding: EdgeInsets.only(bottom: 5),
                                              alignment: Alignment.topCenter,
                                              child: Image.asset(
                                                'assets/home_visit_img.png',
                                                fit: BoxFit.none,
                                              ),
                                            ),
                                    ),
                                    SizedBox(width: 3),
                                    data['services_type'] != null
                                        ? data['services_type'] == "Online"
                                            ? Text('Online Consultation').fontSize(12).bold()
                                            : Text(data['services_type']).fontSize(12).bold()
                                        : Text(''),
                                  ],
                                )),
                          ],
                        ),
                      ],
                    ),
                    Divider(
                      thickness: 1,
                      color: Colors.grey,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 3, right: 3),
                      child: Row(
                        children: [
                          Column(
                            children: [
                              Container(
                                height: 120,
                                width: 80,
                                // color: Colors.blue,
                                child: Stack(alignment: Alignment.center, children: [
                                  Positioned(
                                    width: 80,
                                    height: 120,
                                    child: Container(
                                      decoration: BoxDecoration(color: disabledColor, border: Border.all(color: disabledColor), borderRadius: BorderRadius.all(Radius.circular(5.0))),
                                      child: InkWell(
                                        child: img_url != ''
                                            ? ClipRRect(
                                                borderRadius: BorderRadius.only(topLeft: Radius.circular(5), topRight: Radius.circular(5)),
                                                child: Image.network(
                                                  img_url,
                                                  fit: BoxFit.cover,
                                                ),
                                              )
                                            : ClipRRect(
                                                borderRadius: BorderRadius.only(topLeft: Radius.circular(5), topRight: Radius.circular(5), bottomLeft: Radius.circular(5.0), bottomRight: Radius.circular(5.0)),
                                                child: Icon(
                                                  Icons.person,
                                                  size: 50,
                                                )),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                      bottom: 0,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.blue,
                                          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(5.0), bottomRight: Radius.circular(5.0)),
                                        ),
                                        width: 80,
                                        child: Center(
                                            child: Text(
                                          'Verified',
                                          style: TextStyle(color: Colors.white),
                                        )),
                                      ))
                                ]),
                              ),
                            ],
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          UIHelper.horizontalSpaceSmall,
                          Container(
                            padding: EdgeInsets.only(top: 5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(data['profileData']['name'] != null ? data['profileData']['name'] : '', overflow: TextOverflow.ellipsis).bold(),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                        width: 100, child: Text(data['profileData']['specialization'] != null ? data['profileData']['specialization'][0].toString() : '', overflow: TextOverflow.ellipsis).fontSize(12)),
                                    Container(
                                        child: Text(doctorDetails['experience'] != null && doctorDetails['experience'].length != 0 ? doctorDetails['experience'][0]['work_experience'] + ' ' 'years' : '',
                                                overflow: TextOverflow.ellipsis)
                                            .fontSize(12)),
                                  ],
                                ),
                                SizedBox(
                                  height: 1,
                                ),
                                Container(child: Text(qualification.toString(), overflow: TextOverflow.ellipsis).fontSize(12)),
                                SizedBox(
                                  height: 1,
                                ),
                                Row(
                                  children: [
                                    Text('Insurance', overflow: TextOverflow.ellipsis),
                                    doctorDetails['insurance'] != null && doctorDetails['insurance'].length != 0 ? Icon(Icons.done, size: 18, color: Colors.green) : Icon(Icons.cancel, size: 18, color: activeColor)
                                  ],
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Icon(
                                        Icons.location_pin,
                                        color: locationColor,
                                        size: 20,
                                      ),
                                    ),
                                    Container(
                                      width: Screen.width(context) / 2,
                                      child: Text(data['profileData']['address'], overflow: TextOverflow.ellipsis, maxLines: 3).fontSize(12).bold(),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: 3,
                                ),
                                Container(
                                  child: Row(
                                    children: [
                                      Container(
                                          //width: Screen.width(context) / 2.8,
                                          child: Row(
                                        children: [
                                          Container(width: 15, child: Text('₹', style: TextStyle(color: activeColor, fontSize: 15)).bold()),

                                          data['fees'] != null ? Text(data['fees'], style: TextStyle(fontSize: 15)).bold() : Text(''),
                                          SizedBox(
                                            width: 3,
                                          ),
                                          data['isPaid'] != false
                                              ? CircleAvatar(backgroundColor: Colors.green, radius: 10, child: Icon(Icons.done, size: 18, color: Colors.white))
                                              : CircleAvatar(backgroundColor: activeColor, radius: 10, child: Icon(Icons.cancel, size: 18, color: Colors.white)),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Container(width: 33, child: Text('paid')),
                                          //  SizedBox(
                                          //   width:5,
                                          // ),
                                        ],
                                      )),
                                      title == 'upcomming'
                                          ? data['isBlock'] == true
                                              ? Container(
                                                  decoration: BoxDecoration(
                                                    color: activeColor,
                                                    borderRadius: BorderRadius.all(
                                                      Radius.circular(5.0),
                                                    ),
                                                  ),
                                                  alignment: Alignment.center,
                                                  height: 30,
                                                  width: 80,
                                                  child: GestureDetector(
                                                    onTap: () async {
                                                      String slotId = data['_id'];
                                                      setState(() {
                                                        userInfo['canceled_by'] = 'User';
                                                        userInfo['status'] = 'Decline';
                                                      });
                                                      print(userInfo);
                                                      Loader.show(context);
                                                      final response = await model.cancelSlot(slotId, userInfo);
                                                      await model.getbookingList();
                                                      print(userInfo);
                                                      Loader.hide();
                                                    },
                                                    child: Text(
                                                      'Cancel',
                                                      style: TextStyle(color: Colors.white),
                                                    ).bold(),
                                                  ))
                                              : Container(
                                                  decoration: BoxDecoration(
                                                    color: disabledColor,
                                                    borderRadius: BorderRadius.all(
                                                      Radius.circular(5.0),
                                                    ),
                                                  ),
                                                  alignment: Alignment.center,
                                                  height: 30,
                                                  width: 80,
                                                  child: GestureDetector(
                                                    onTap: () async {
                                                      //   String slotId = data['_id'];
                                                      //   setState(() {
                                                      //     userInfo['canceled_by'] = 'User';
                                                      //     userInfo['status'] = 'Decline';
                                                      //   });
                                                      //   print(userInfo);
                                                      //   Loader.show(context);
                                                      //   final response = await model.cancelSlot(slotId, userInfo);
                                                      //  await model.getbookingList();
                                                      //   print(userInfo);
                                                      //   Loader.hide();
                                                    },
                                                    child: Text(
                                                      'Canceled',
                                                      style: TextStyle(color: Colors.white),
                                                    ).bold(),
                                                  ))
                                          : data['rating_number'] == null
                                              ? Container(
                                                  decoration: BoxDecoration(
                                                    color: activeColor,
                                                    borderRadius: BorderRadius.all(
                                                      Radius.circular(5.0),
                                                    ),
                                                  ),
                                                  height: 30,
                                                  width: 90,
                                                  child: GestureDetector(
                                                      onTap: () async {
                                                        _displayStarDialog(context, model, data['_id'], data['profileData']['name']);
                                                      },
                                                      child: Row(
                                                        children: [
                                                          Text(
                                                            '  Rate us',
                                                            style: TextStyle(color: Colors.white),
                                                          ).bold(),
                                                          UIHelper.horizontalSpaceTiny,
                                                          Icon(Icons.star_border_outlined, color: Colors.white, size: 16),
                                                        ],
                                                      )))
                                              : Container(
                                                  decoration: BoxDecoration(
                                                    color: greycolor,
                                                    borderRadius: BorderRadius.all(
                                                      Radius.circular(5.0),
                                                    ),
                                                  ),
                                                  height: 30,
                                                  width: 90,
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Text(
                                                        data['rating_number'].toString(),
                                                        style: TextStyle(color: Colors.white),
                                                      ).bold(),
                                                      UIHelper.horizontalSpaceTiny,
                                                      Icon(Icons.star_border_outlined, color: Colors.white, size: 16),
                                                    ],
                                                  ))
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                )),
            UIHelper.verticalSpaceSmall,
          ],
        ),
      ),
    );
  }

  var book = 2;

  @override
  Widget build(BuildContext context) {
    modelRef.getbookingList();
    return modelRef.bookingsdata.length != 0
        ? Scaffold(
            appBar: SwarAppStaticBar(),
            body: SafeArea(
                top: false,
                child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    width: Screen.width(context),
                    child: ViewModelBuilder<BookingsViewModel>.reactive(
                      onModelReady: (model) {
                        modelRef = model;
                        model.getbookingList();
                      },
                      builder: (context, model, child) {
                        return SingleChildScrollView(
                          child: Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [addHeader(context, true), tabView(context, model)],
                            ),
                          ),
                        );
                      },
                      viewModelBuilder: () => BookingsViewModel(),
                    ))),
          )
        : Scaffold(
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
                        SizedBox(
                          height: 50,
                        ),
                        Expanded(
                            child: Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              UIHelper.verticalSpaceSmall,
                              Text("You don't have any appointments!").fontSize(14).fontWeight(FontWeight.w600),
                              UIHelper.verticalSpaceSmall,
                              SizedBox(
                                height: 40,
                              ),
                              Center(child: bookingAppointment(context)),
                            ],
                          ),
                        ))
                      ],
                    ))),
          );
  }
}
