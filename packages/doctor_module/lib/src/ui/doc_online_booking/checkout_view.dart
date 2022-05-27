import 'dart:async';
import 'package:doctor_module/src/ui/doc_online_booking/bookings_view.dart';
import 'package:doctor_module/src/ui/doc_online_booking/checkout_view_model.dart';
import 'package:doctor_module/src/ui/doc_online_booking/doc_offers_view.dart';
import 'package:swarapp/shared/custom_dialog_box.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stacked/stacked.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/frideos/extended_asyncwidgets.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/services/preferences_service.dart';
import 'package:swarapp/shared/app_colors.dart';
import 'package:swarapp/shared/app_static_bar.dart';
import 'package:swarapp/shared/flutter_overlay_loader.dart';
import 'package:swarapp/shared/screen_size.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:jiffy/jiffy.dart';
import 'package:google_maps_place_picker/google_maps_place_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class CheckoutView extends StatefulWidget {
  final String servicetype;
  final String selected_offers;
  final String selected_offers_amount;
  CheckoutView({Key? key, required this.servicetype, required this.selected_offers, required this.selected_offers_amount}) : super(key: key);

  @override
  _CheckoutViewState createState() => _CheckoutViewState();
}

const APIKeys = "AIzaSyA_76M-Sca9mXdpkJKVHSeUkFRgvvQ3icI";
dynamic userInfo = {};
Map<String, dynamic> razorpayorderInfo = {};
dynamic paymentInfo = {};
final kToday = DateTime.now();
final kFirstDay = DateTime(kToday.year, kToday.month - 3, kToday.day);
final kLastDay = DateTime(kToday.year, kToday.month + 3, kToday.day);
bool isSelectionCategory = false;
bool isSelect_member_Category = false;

class _CheckoutViewState extends State<CheckoutView> {
  static const platform = const MethodChannel("razorpay_flutter");
  late Razorpay _razorpay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  int selectedIndex = 0;
  dynamic response = [];
  String workExperience = '';
  String to_pay = '';
  var selecteddate;
  String end_year = '';
  String network_img_url = '';
  String Insurance = '';
  PreferencesService preferencesService = locator<PreferencesService>();
  TextEditingController searchController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  String selectedTab = '';
  PickResult? selectedPlace;
  static final kInitialPosition = LatLng(-33.8567844, 151.213108);
  List<dynamic>? members_stream;
  List<dynamic> selectedoffers = [];
  double result = 100;
  late Timer timer;
  Checkoutmodel modelRef = Checkoutmodel();
  String radioValue = "online";
  void radioButtonChanges(String value) {
    setState(() {
      radioValue = value;
    });
  }

  void initState() {
    // TODO: implement initState
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    timer = Timer.periodic(Duration(seconds: 5), (Timer t) => autoRefreshPage());
    members_stream = preferencesService.recentMembersListStream!.value!;
  }

  // @override
  // void dispose() {
  //   super.dispose();
  //   _razorpay.clear();
  // }

  openCheckout(String orderId) async {
    var options = {
      'key': 'rzp_test_FTht4oR9HIqbhT',
      'amount': result * 100,
      'name': 'SWAR Doctor',
      'order_id': orderId, // Generate order_id using Orders API
      'description': 'SWAR Doctor',
      'retry': {'enabled': true, 'max_count': 1},
      'send_sms_hash': false,
      //'prefill': {'contact': '8888888888', 'email': 'test@razorpay.com'},
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: e');
    }
  }

  Future _handlePaymentSuccess(PaymentSuccessResponse response) async {
    print('Success Response: $response');
    paymentInfo['razorpay_orderId'] = response.orderId;
    paymentInfo['razorpay_payId'] = response.paymentId;
    paymentInfo['razorpay_signature'] = response.signature;
    // final paymentresponse = await model.paymentinfoupdate(preferencesService.slot_booking_id, paymentInfo);
    final paymentresponse = await locator<ApiService>().paymentinfoupdate(preferencesService.slot_booking_id, paymentInfo);
    print(paymentresponse);
    if (paymentresponse == 200) {
      Loader.hide();
      await showDialog(
          context: context,
          builder: (BuildContext context) {
            return CustomDialogBox(
              title: "Success !",
              descriptions: "Your appointment booked",
              descriptions1: "",
              text: "OK",
            );
          });
      final BottomNavigationBar navigationBar = locator<PreferencesService>().bottomTab_globalKey.currentWidget as BottomNavigationBar;
      navigationBar.onTap!(1);
    } else {
      await showDialog(
          context: context,
          builder: (BuildContext context) {
            return CustomDialogBox(
              title: "Warning !",
              descriptions: "Booking Failed",
              descriptions1: "",
              text: "OK",
            );
          });
    }
    /*Fluttertoast.showToast(
        msg: "SUCCESS: " + response.paymentId!,
        toastLength: Toast.LENGTH_SHORT); */
  }

  Future<void> _handlePaymentError(PaymentFailureResponse response) async {
    print('Error Response: $response');
    /* Fluttertoast.showToast(
        msg: "ERROR: " + response.code.toString() + " - " + response.message!,
        toastLength: Toast.LENGTH_SHORT); */
    Loader.hide();
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return CustomDialogBox(
            title: "Warning !",
            descriptions: "Your payment failed. Try again",
            descriptions1: "",
            text: "OK",
          );
        });
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print('External SDK Response: $response');
    /* Fluttertoast.showToast(
        msg: "EXTERNAL_WALLET: " + response.walletName!,
        toastLength: Toast.LENGTH_SHORT); */
  }

  void autoRefreshPage() {
    if (modelRef.createdat.isNotEmpty) {
      DateTime currentDate = DateTime.now();
      DateTime startDate = DateTime.parse(modelRef.createdat);
      int seconds = 0;
      seconds = currentDate.difference(startDate).inSeconds;

      if (seconds > 1800) {
        //------30 Minutes(0.5*60*60)= 1800 seconds------\\
        modelRef.getRecentMembers();
      }
    }
  }

  void dispose() {
    if (members_stream != null) {
      members_stream!.clear();
    }
    super.dispose();
    _razorpay.clear();
  }

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
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => BookAppointmentView(BookingInfo: '', servicetype: '')),
                  );
                  Get.back();
                },
                child: Icon(
                  Icons.arrow_back,
                  size: 20,
                ),
              ),
              Text(' Check out').fontSize(16).fontWeight(FontWeight.w600),
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

  Widget showcaution() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton(
            onPressed: () async {},
            child: Text('Caution: Its not for emergency service', style: TextStyle(fontWeight: FontWeight.w500)).textColor(Colors.white),
            style: ButtonStyle(
              minimumSize: MaterialStateProperty.all(Size(360, 36)),
              backgroundColor: MaterialStateProperty.all(Color(0xFF00B0FF)),
            )),
      ],
    );
  }

  Widget nurseList(BuildContext context, Checkoutmodel model) {
    if (model.doctor_Info['experience'] != null) {
      if (model.doctor_Info['experience'].length > 0) {
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

    if (model.doctor_details['azureBlobStorageLink'] != null) {
      network_img_url = '${ApiService.fileStorageEndPoint}${model.doctor_details['azureBlobStorageLink']}';
    }
    if ((model.doctor_Info['insurance'] != null) && (model.doctor_Info['insurance'].length > 0)) {
      if (model.doctor_Info['insurance'][0] != "") {
        Insurance = model.doctor_Info['insurance'][0];
      }
    }
    return Container(
      width: Screen.width(context) - 16,
      decoration: UIHelper.allcornerRadiuswithbottomShadow(12, 12, 12, 12, Colors.white),
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(children: [
              network_img_url == ''
                  ? Container(
                      height: 90,
                      width: 70,
                      decoration: UIHelper.allcornerRadiuswithbottomShadow(2, 2, 2, 2, fieldBgColor),
                      child: Icon(
                        Icons.account_circle,
                        color: Colors.black38,
                      ),
                    )
                  : UIHelper.getImage(network_img_url, 70, 90),
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
                          child: Text('SWAR Doctor').fontSize(12.8).bold().textColor(Colors.white).textAlignment(TextAlign.center)),
            ]),
            UIHelper.horizontalSpaceSmall,
            Container(
              width: 290,
              decoration: UIHelper.allcornerRadiuswithbottomShadow(6, 6, 6, 6, Colors.white),
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Row(
                  children: [
                    SizedBox(width: 5),
                    Expanded(
                        child: Container(
                            child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(model.doctor_details['name'] != null ? model.doctor_details['name'] : "").fontSize(12).fontWeight(FontWeight.w600),
                        UIHelper.verticalSpaceTiny,
                        // Text(
                        //'General physician, 5 years exp').fontSize(12).fontWeight(FontWeight.w600).textColor(Colors.black38),
                        Row(
                          children: [
                            Row(
                              children: [
                                model.doctor_details['specialization'] != null
                                    ? Text(model.doctor_details['specialization'][0] != null ? model.doctor_details['specialization'][0] : "").fontSize(12).fontWeight(FontWeight.w600).textColor(Colors.black38)
                                    : Text('').fontSize(12).fontWeight(FontWeight.w600).textColor(Colors.black38)
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  workExperience != '' ? '  ' + workExperience + ' exp' : "",
                                  overflow: TextOverflow.clip,
                                ).fontSize(12).fontWeight(FontWeight.w600).textColor(Colors.black38)
                              ],
                            ),
                          ],
                        ),

                        UIHelper.horizontalSpaceSmall,
                        UIHelper.verticalSpaceSmall,
                        Text(Qualification).fontSize(9).fontWeight(FontWeight.w300).bold(),

                        UIHelper.verticalSpaceTiny,
                        Insurance != ''
                            ? Row(children: [
                                Text(
                                  'Insurance ',
                                  overflow: TextOverflow.clip,
                                ).fontSize(9).fontWeight(FontWeight.w300).bold(),
                                Icon(
                                  Icons.done,
                                  color: Colors.green,
                                  size: 15,
                                ),
                              ])
                            : Row(children: [
                                Text(
                                  'Insurance ',
                                  overflow: TextOverflow.clip,
                                ).fontSize(9).fontWeight(FontWeight.w300).bold(),
                                Icon(
                                  Icons.done,
                                  color: activeColor,
                                  size: 15,
                                ),
                              ]),
                        Row(children: [
                          Icon(
                            Icons.location_pin,
                            color: locationColor,
                            size: 20,
                          ),
                          model.doctor_Info['clinic_details'] != null
                              ? Container(
                                  width: 120,
                                  child: Flexible(
                                      child: Text(model.doctor_Info['clinic_details'].length > 0
                                              ? model.doctor_Info['clinic_details'][0]['clinic_name'] != null
                                                  ? "  " + model.doctor_Info['clinic_details'][0]['clinic_name'] + " "
                                                  : ""
                                              : "")
                                          .fontSize(10)
                                          .fontWeight(FontWeight.w300)
                                          .bold()))
                              : Text('').fontSize(10).fontWeight(FontWeight.w300).bold(),
                        ]),
                      ],
                    ))),
                    UIHelper.horizontalSpaceTiny,
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('Patients visit').fontSize(10).fontSize(10).fontWeight(FontWeight.w600).textColor(Colors.black).paddingZero,
                            UIHelper.horizontalSpaceSmall,
                            Text('1.5K').fontSize(12).fontWeight(FontWeight.w500).textColor(activeColor),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
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
                        UIHelper.verticalSpaceMedium,
                        UIHelper.verticalSpaceMedium,
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget detailcard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      width: Screen.width(context),
      decoration: UIHelper.allcornerRadiuswithbottomShadow(12, 12, 12, 12, Colors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(addressController.text).fontSize(12).fontWeight(FontWeight.w600),
          UIHelper.verticalSpaceSmall,
          Container(
            height: 50,
            decoration: UIHelper.roundedBorderWithColorWithShadow(6, Colors.white),
            padding: EdgeInsets.all(12),
            child: TextField(
              controller: addressController,
              decoration: InputDecoration.collapsed(hintText: "Enter location manually"),
            ),
            // child: FormBuilderTextField(
            //         // readOnly: true,
            //         style: TextStyle(color: Colors.black),
            //         name: 'address',
            //         autocorrect: false,
            //         controller: addressController,
            //         textCapitalization: TextCapitalization.sentences,
            //         onChanged: (value) async {},
            //         decoration: InputDecoration(
            //           fillColor: Colors.white,
            //           filled: true,
            //           contentPadding: EdgeInsets.only(left: 5),
            //           hintText: 'Enter location manually',
            //           // hintStyle: loginInputHintTitleStyle,
            //           hintStyle: TextStyle(color: Colors.black),
            //           enabledBorder: OutlineInputBorder(
            //             borderSide: const BorderSide(color: disabledColor),
            //             borderRadius: BorderRadius.circular(4.0),
            //           ),
            //          // focusedBorder: UIHelper.getInputBorder(1),
            //           // focusedErrorBorder: UIHelper.getInputBorder(1),
            //           // errorBorder: UIHelper.getInputBorder(1),
            //         ),
            //         onEditingComplete: () async {
            //           if (FocusScope.of(context).isFirstFocus) {
            //             FocusScope.of(context).requestFocus(new FocusNode());
            //           }
            //           if (addressController.text.length > 50) {
            //             showDialog(
            //                 context: context,
            //                 builder: (BuildContext context) {
            //                   return CustomDialogBox(
            //                     title: "Alert !",
            //                     descriptions: "Only 50 characters are allowed reason",
            //                     descriptions1: "",
            //                     text: "OK",
            //                   );
            //                 });

            //             return;
            //           } else {
            //             // model.profileInfo['notes_description'] = reasonController.text;
            //             String notes = addressController.text;
            //            // model.addPatientDocument('', widget.patienDetails['_id'], notes, '');
            //           }
            //         },
            //       ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                  onPressed: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return PlacePicker(
                            apiKey: APIKeys,
                            initialPosition: _CheckoutViewState.kInitialPosition,
                            useCurrentLocation: true,
                            selectInitialPosition: true,
                            //usePlaceDetailSearch: true,
                            onPlacePicked: (result) {
                              selectedPlace = result;
                              Navigator.of(context).pop();
                              setState(() {
                                final routeArgs = selectedPlace!.formattedAddress;
                                String vals = routeArgs.toString();
                                String getzip = "";
                                String getstate = "";
                                String getcountry = "";
                                vals.split(",");
                                int le = vals.split(",").length;
                                String addrs = vals.split(",")[0] + "," + vals.split(",")[1];
                                addressController.text = vals;
                                getzip = vals.split(",")[le - 2];
                                getstate = getzip.replaceAll(RegExp(r'[0-9]'), '');
                              });
                            },
                          );
                        },
                      ),
                    );
                  },
                  child: Text('Add Address').bold(),
                  style: ButtonStyle(
                    minimumSize: MaterialStateProperty.all(Size(180, 35)),
                    backgroundColor: MaterialStateProperty.all(activeColor),
                  )),
            ],
          )
        ],
      ),
    );
  }

  Widget details(BuildContext context, Checkoutmodel model) {
    return Container(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            model.slotbooking_details['services_type'] != null
                ? model.slotbooking_details['services_type'] == "Online"
                    ? Icon(
                        Icons.videocam,
                        size: 20,
                      )
                    : Icon(
                        Icons.videocam,
                        size: 20,
                      )
                : Icon(
                    Icons.videocam,
                    size: 20,
                  ),
            //      Image.asset(
            //         'assets/home_visit_img.png',
            //         fit: BoxFit.none,
            //       )
            // : Image.asset(
            //     'assets/home_visit_img.png',
            //     fit: BoxFit.none,
            //   ),
            model.slotbooking_details['services_type'] != null ? Text(model.slotbooking_details['services_type'] + " Consultation") : Text(''),
          ],
        ),
        UIHelper.verticalSpaceTiny,
        Row(
          children: [
            Icon(
              Icons.date_range,
              size: 20,
            ),
            Text(preferencesService.selected_date + ', ' + preferencesService.Selected_time),
          ],
        )
      ],
    ));
  }

  Widget memberlist(BuildContext context, Checkoutmodel model) {
    if (locator<PreferencesService>().isReload.value == true) {
      locator<PreferencesService>().isReload.value = false;
      // modelRef.getRecentFamily();
    }
    return Container(
        decoration: UIHelper.allcornerRadiuswithbottomShadow(6, 6, 6, 6, Colors.white),
        child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Text('Who is this E-Consultation for?').fontSize(14).fontWeight(FontWeight.w500),
                  ],
                ),
                UIHelper.verticalSpaceSmall,
                Row(children: [
                  Container(
                    width: Screen.width(context) / 2.2,
                    height: 80,
                    child: StreamedWidget<List<dynamic>?>(
                        stream: preferencesService.memebersListStream!.outStream!,
                        builder: (context, snapshot) {
                          return ListView.builder(
                              itemCount: preferencesService.memebersListStream!.length,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (
                                context,
                                index,
                              ) {
                                // dynamic get_rs = preferencesService.memebersListStream!.value!;
                                dynamic getRs = snapshot.data;
                                dynamic memberinfo = getRs[index];

                                String imgUrl = '';
                                if (memberinfo['azureBlobStorageLink'] != null) {
                                  String imgurl = memberinfo['azureBlobStorageLink'].toString();
                                  if (imgurl.isNotEmpty) {
                                    imgUrl = '${ApiService.fileStorageEndPoint}$imgurl';
                                  }
                                }
                                return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        // isDeleteModeOn = false;
                                        isSelectionCategory = true;
                                        // selectedTab = groups[index]['title'].toString();
                                        // Tab_id = index;
                                      });
                                    },
                                    child: Container(
                                      margin: EdgeInsets.only(right: 8),
                                      child: Column(children: [
                                        Stack(children: <Widget>[
                                          index == 0
                                              ? StreamBuilder<String?>(
                                                  stream: locator<PreferencesService>().profileUrl.outStream,
                                                  builder: (context, uploadimg) => !uploadimg.hasData || uploadimg.data == ''
                                                      ? GestureDetector(
                                                          onTap: () {
                                                            setState(() {
                                                              //isDeleteModeOn = false;
                                                              isSelectionCategory = true;
                                                              isSelect_member_Category = false;
                                                              // selectedTab = groups[index]['title'].toString();
                                                              // Tab_id = index;
                                                            });
                                                          },
                                                          child: Container(
                                                            child: Icon(Icons.account_circle, size: 40, color: Colors.grey),
                                                            width: 43,
                                                            height: 43,
                                                            decoration: UIHelper.roundedLineBorderWithColor(22, Colors.transparent, 2, borderColor: isSelectionCategory == true ? activeColor : Colors.white),
                                                          ))
                                                      : GestureDetector(
                                                          onTap: () {
                                                            setState(() {
                                                              //isDeleteModeOn = false;
                                                              isSelectionCategory = true;
                                                              isSelect_member_Category = false;
                                                              // selectedTab = groups[index]['title'].toString();
                                                              // Tab_id = index;
                                                            });
                                                          },
                                                          child: Container(
                                                            width: 43,
                                                            height: 43,
                                                            child: ClipRRect(borderRadius: BorderRadius.circular(20.0), child: UIHelper.getImage(imgUrl, 43, 43)),
                                                            decoration: UIHelper.roundedLineBorderWithColor(22, Colors.transparent, 2, borderColor: isSelectionCategory == true ? activeColor : Colors.white),
                                                          )
                                                          // ClipRRect(borderRadius: BorderRadius.circular(20.0), child: UIHelper.getImage(uploadimg.data!, 43, 43),),
                                                          ))
                                              : StreamBuilder<String?>(
                                                  stream: locator<PreferencesService>().profileUrl.outStream,
                                                  builder: (context, uploadimg) => !uploadimg.hasData || imgUrl.isEmpty
                                                      ? GestureDetector(
                                                          onTap: () {
                                                            setState(() {
                                                              //isDeleteModeOn = false;
                                                              isSelect_member_Category = true;
                                                              isSelectionCategory = false;
                                                              // selectedTab = groups[index]['title'].toString();
                                                              // Tab_id = index;
                                                            });
                                                          },
                                                          child: Container(
                                                            child: Icon(Icons.account_circle, size: 40, color: Colors.grey),
                                                            width: 43,
                                                            height: 43,
                                                            decoration: UIHelper.roundedLineBorderWithColor(22, Colors.transparent, 2, borderColor: isSelect_member_Category == true ? activeColor : Colors.white),
                                                          ))
                                                      : GestureDetector(
                                                          onTap: () {
                                                            setState(() {
                                                              //isDeleteModeOn = false;
                                                              isSelect_member_Category = true;
                                                              isSelectionCategory = false;
                                                              // selectedTab = groups[index]['title'].toString();
                                                              // Tab_id = index;
                                                            });
                                                          },
                                                          child: Container(
                                                            width: 43,
                                                            height: 43,
                                                            child: ClipRRect(borderRadius: BorderRadius.circular(20.0), child: UIHelper.getImage(imgUrl, 43, 43)),
                                                            decoration: UIHelper.roundedLineBorderWithColor(22, Colors.transparent, 2, borderColor: isSelect_member_Category == true ? activeColor : Colors.white),
                                                          ))),
                                        ]),
                                        UIHelper.verticalSpaceTiny,
                                        index == 0
                                            ? StreamBuilder<String?>(
                                                stream: locator<PreferencesService>().userName.outStream,
                                                builder: (context, snapshotname) =>
                                                    !snapshotname.hasData || snapshotname.data == '' ? Text(preferencesService.userInfo['name']).fontSize(14).bold() : Text(snapshotname.data!).fontSize(14).bold())
                                            : Text(memberinfo['member_first_name']).fontSize(14).fontWeight(FontWeight.w500),
                                        UIHelper.verticalSpaceTiny,
                                        index == 0 ? Text('You').fontSize(12).bold() : Text(memberinfo['relation'] != null ? memberinfo['relation'] : '').fontSize(12),
                                      ]),
                                    ));
                              });
                        }),
                    // decoration: isSelectionCategory ? UIHelper.roundedBorderWithColorWithShadow(6, fieldBgColor, borderColor: activeColor) : UIHelper.roundedBorderWithColor(6, fieldBgColor),
                  ),
                ]),
              ],
            )));
  }

  //for payment mode selection
  Widget paymentmodeselection(BuildContext context, Checkoutmodel model) {
    return Container(
        decoration: UIHelper.allcornerRadiuswithbottomShadow(6, 6, 6, 6, Colors.white),
        child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Text('Payment mode').fontSize(14).fontWeight(FontWeight.w800),
                  ],
                ),
                SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Radio(
                      visualDensity: VisualDensity.compact,
                      activeColor: blackColor,
                      value: 'cash',
                      groupValue: radioValue,
                      onChanged: widget.servicetype == "Online"
                          ? null
                          : (value) {
                              setState(() {
                                radioValue = 'cash';
                              });
                            },
                    ),
                    Text("Cash On Delivery", style: radioValue == 'cash' ? TextStyle(fontWeight: FontWeight.w900, fontSize: 15) : TextStyle(fontWeight: FontWeight.w600)),
                    UIHelper.horizontalSpaceSmall,
                    Radio(
                      visualDensity: VisualDensity.compact,
                      activeColor: blackColor,
                      value: 'online',
                      groupValue: radioValue,
                      onChanged: (value) {
                        setState(() {
                          radioValue = 'online';
                        });
                      },
                    ),
                    Text("Online", style: radioValue == 'online' ? TextStyle(fontWeight: FontWeight.w900, fontSize: 15) : TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            )));
  }

  Widget offers(BuildContext context, Checkoutmodel model) {
    return Container(
      child: Column(
        children: [
          GestureDetector(
              onTap: () {
                Get.to(() => DocOffersListView());
              },
              child: Container(
                  decoration: UIHelper.allcornerRadiuswithbottomShadow(6, 6, 6, 6, fieldBgColor),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(
                          Icons.local_offer,
                          color: activeColor,
                          size: 20,
                        ),
                        widget.selected_offers_amount != '' ? Text('Offers Applied').bold() : Text('Apply offers').bold(),
                        Text('            '),
                      ],
                    ),
                  ))),
          UIHelper.verticalSpaceSmall,
          Container(
              child: Row(
            children: [
              Text('Total Charges').bold(),
            ],
          )),
          UIHelper.verticalSpaceSmall,
          Container(
              decoration: UIHelper.allcornerRadiuswithbottomShadow(6, 6, 6, 6, Colors.white),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Consult Fee ').textColor(Colors.black).fontSize(14),
                        // Text('₹ 500').fontWeight(FontWeight.w500),
                        model.slotbooking_details['fees'] != null ? Text('₹ ' + model.slotbooking_details['fees']).fontWeight(FontWeight.w500) : Text('₹ 500').fontWeight(FontWeight.w500),
                      ],
                    ),
                    UIHelper.verticalSpaceSmall,
                    widget.selected_offers_amount != ''
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Offer ').textColor(Colors.black).fontSize(14),
                              Text(widget.selected_offers_amount != '' ? ' - ' + widget.selected_offers_amount : '').fontWeight(FontWeight.w500),
                            ],
                          )
                        : Text(''),
                    UIHelper.verticalSpaceMedium,
                    UIHelper.verticalSpaceSmall,
                    UIHelper.hairLineWidget(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('  To Pay').textColor(Colors.black).fontSize(15).bold(),
                        Text(result.toString()).fontWeight(FontWeight.w500),
                      ],
                    ),
                    UIHelper.verticalSpaceSmall,
                  ],
                ),
              )),
          UIHelper.verticalSpaceSmall,
          SizedBox(
            width: Screen.width(context) / 2.2,
            child: ElevatedButton(
                onPressed: () async {
                  setState(() {
                    userInfo['offers_id'] = '628248ac2f8ece002e654de9';
                    userInfo['offer_type'] = preferencesService.offers_type;
                    //userInfo['fees'] = preferencesService.consult_fee;
                    userInfo['offer_amount'] = widget.selected_offers_amount;
                    userInfo['paid_amount'] = result;
                    userInfo['homevisit_address'] = addressController.text;
                    //  razorpayorderInfo['amount'] = preferencesService.consult_fee;
                    razorpayorderInfo['currency'] = 'INR';
                    razorpayorderInfo['receipt'] = "test";
                    userInfo['payment_mode'] = radioValue;
                    paymentInfo['isPaid'] = true;
                  });
                  if (widget.servicetype == "Home visit" && addressController.text == "") {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return CustomDialogBox(
                            title: "Alert !",
                            descriptions: "Address is mandatory for Homevisit",
                            descriptions1: "",
                            text: "OK",
                          );
                        });
                  } else {
                    Loader.show(context);
                    final orderresponse = await model.createrazorpayorder(razorpayorderInfo);
                    final response = await model.paymentinfoupdate(preferencesService.slot_booking_id, userInfo);
                    if (radioValue == "online") {
                      await openCheckout(orderresponse['id']);
                    } else {
                      Loader.hide();
                      await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return CustomDialogBox(
                              title: "Success !",
                              descriptions: "Your appointment booked",
                              descriptions1: "",
                              text: "OK",
                            );
                          });
                      final BottomNavigationBar navigationBar = locator<PreferencesService>().bottomTab_globalKey.currentWidget as BottomNavigationBar;
                      navigationBar.onTap!(1);
                    }
                  }
                },
                child: Text('Pay ₹ ' + result.toString()).fontSize(15).textColor(Colors.white),
                style: ButtonStyle(
                    minimumSize: MaterialStateProperty.all(Size(65, 40)),
                    backgroundColor: MaterialStateProperty.all(activeColor),
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))))),
          ),
          UIHelper.verticalSpaceLarge,
        ],
      ),
    );
  }

  void offerapply(Checkoutmodel model) {
    print("doctorfees" + model.slotbooking_details['fees'].toString());
    if (widget.selected_offers_amount != '' && model.slotbooking_details['fees'] != null && model.slotbooking_details['fees'] != '') {
      result = (double.parse(model.slotbooking_details['fees'])) - (double.parse(widget.selected_offers_amount));
    } else {
      result = double.parse(model.slotbooking_details['fees']);
    }
    // setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    members_stream = preferencesService.memebersListStream!.value!;
    return Scaffold(
      appBar: SwarAppStaticBar(),
      backgroundColor: Colors.white,
      body: Container(
        width: Screen.width(context),
        child: ViewModelBuilder<Checkoutmodel>.reactive(
            onModelReady: (model) async {
              Loader.show(context);
              await model.getUserProfile();
              Loader.hide();
              offerapply(model);
            },
            builder: (context, model, child) {
              return Column(
                children: [
                  UIHelper.commonTopBar(' Check out'),
                  UIHelper.verticalSpaceSmall,
                  Expanded(
                      child: SingleChildScrollView(
                    child: Container(
                      decoration: UIHelper.accountCardwithShadow(6, 6, Colors.white),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: model.isBusy
                            ? Center(
                                child: UIHelper.swarPreloader(),
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  nurseList(context, model),
                                  UIHelper.verticalSpaceSmall,
                                  // detailcard(context),
                                  widget.servicetype == "Home visit" ? detailcard(context) : UIHelper.verticalSpaceSmall,
                                  UIHelper.verticalSpaceSmall,
                                  details(context, model),
                                  UIHelper.verticalSpaceSmall,
                                  memberlist(context, model),
                                  UIHelper.verticalSpaceSmall,
                                  paymentmodeselection(context, model),
                                  UIHelper.verticalSpaceSmall,
                                  offers(context, model),
                                ],
                              ),
                      ),
                    ),
                  )),
                  UIHelper.verticalSpaceSmall,
                  widget.servicetype == "Home visit" ? showcaution() : UIHelper.verticalSpaceSmall,
                ],
              );
            },
            viewModelBuilder: () => Checkoutmodel()),
      ),
    );
  }
}
