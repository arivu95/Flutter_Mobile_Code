import 'package:doctor_module/src/ui/doc_subscription/subscription_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
import 'package:stacked/stacked.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/services/preferences_service.dart';
import 'package:swarapp/shared/app_static_bar.dart';
import 'package:swarapp/shared/custom_dialog_box.dart';
import 'package:swarapp/shared/flutter_overlay_loader.dart';
import 'package:swarapp/shared/screen_size.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:jiffy/jiffy.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:swarapp/ui/startup/terms_view.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:badges/badges.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter/services.dart';
import 'dart:math';

class DocSubscriptionView extends StatefulWidget {
  dynamic data;
  DocSubscriptionView({Key? key, this.data}) : super(key: key);

  @override
  _DocSubscriptionViewState createState() => _DocSubscriptionViewState();
}

class _DocSubscriptionViewState extends State<DocSubscriptionView> {
  int selectedIndex = 2;
  int selectedTab = 0;
  ApiService apiService = ApiService();
  late Razorpay _razorpay;
  String subId = '';
  DateTime currentDate = DateTime.now();
  List<dynamic> headerDataData = [
    {'title1': 'Great Start!', 'title2': 'SWAR Enhanced*', 'desc': ''},
    {'title1': 'Great Service!', 'title2': 'SWAR Proffessional*', 'desc': 'Only Verified Doctors Eligibile'},
  ];
  List<String> benefitsData = [
    'Your Patients\n ',
    'Manage\nAppointments',
    'Manage\nAvailability',
    'Manage\nFees & Offers',
    'Secured Online Payments from Patients',
    '24x7 Technical Support',
  ];

  dynamic bgContainerColor = {
    "1": Color(0xFFC1FF99),
    "2": Color(0xFFFFE8AC),
    "3": Color(0XFFABF0FF),
    "4": Color(0xFFFDFF98),
    "5": Color.fromRGBO(223, 255, 171, 1),
  };

  final Shader linearGradient = LinearGradient(
    colors: <Color>[
      Color(0xFFFC7D0D),
      Color(0xFFE02A53),
      Color(0xFFDA1B60),
    ],
  ).createShader(Rect.fromLTWH(
    0.0,
    0.0,
    320.0,
    70.0,
  ));

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    print('Success Response: $response');
    final res = await _verifyPurchase();
    if (res) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return CustomDialogBox(
              title: "Success!",
              descriptions: "Plan Upgraded Successfully",
              descriptions1: '',
              text: "OK",
            );
          });
      //   Get.to(() => SubscribedView());
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) async{
    print('Error Response: $response');
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
    /* Fluttertoast.showToast(
        msg: "ERROR: " + response.code.toString() + " - " + response.message!,
        toastLength: Toast.LENGTH_SHORT); */
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print('External SDK Response: $response');
    /* Fluttertoast.showToast(
        msg: "EXTERNAL_WALLET: " + response.walletName!,
        toastLength: Toast.LENGTH_SHORT); */
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<DocSubscriptionViewmodel>.reactive(
        onModelReady: (model) async {
          Loader.show(context);
          await model.getSubscriptionsList();
          Loader.hide();
        },
        builder: (context, model, child) {
          return Scaffold(
              appBar: SwarAppStaticBar(),
              backgroundColor: Color(0xFFF5F3F3),
              body: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  color: Colors.white,
                  width: Screen.width(context),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    UIHelper.addHeader(context, "Subscription", true),
                    UIHelper.verticalSpaceSmall,
                    DefaultTabController(
                        length: 2, // length of tabs
                        initialIndex: 0,
                        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
                          Container(
                              height: Screen.height(context) / 1.2, //height of TabBarView
                              child: TabBarView(children: <Widget>[
                                onlineSubscriptionTab(context, model, 0, headerDataData[0], [model.subscriptionAmount[0], model.subscriptionAmount[1]]),
                                onlineSubscriptionTab(context, model, 1, headerDataData[1], [model.subscriptionAmount[2], model.subscriptionAmount[3]])
                              ]))
                        ])),
                  ])));
        },
        viewModelBuilder: () => DocSubscriptionViewmodel());
  }

  @override
  Widget onlineSubscriptionTab(BuildContext context, DocSubscriptionViewmodel model, int tabviewIndex, dynamic gradientdata, List amount) {
    return SingleChildScrollView(
        child: Column(children: [
      subscriptionGradient(context, gradientdata),
      showFeatureWindow(context, model, amount, tabviewIndex),
      benifitsListWidget(context, tabviewIndex),
      UIHelper.verticalSpaceSmall,
    ]));
  }

  @override
  Widget subscriptionGradient(BuildContext context, dynamic gradientdata) {
    return Container(
      width: Screen.width(context),
      decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, stops: [
            0.1,
            0.5,
            0.9
          ], colors: [
            Color(0xFFDA1B60),
            Color(0xFFE02A53),
            Color(0xFFFC7D0D),
          ]),
          borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12))),
      padding: EdgeInsets.fromLTRB(16, 16, 16, 35),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              (widget.data != null && widget.data['isload'] == true)
                  ? GestureDetector(
                      onTap: () async {
                        Navigator.pop(context, true);

                        await preferencesService.setPopupInfo('popupShow', 'false');
                        await preferencesService.setPopupInfo('date', currentDate.toString());
                      },
                      child: Icon(
                        Icons.close_outlined,
                        color: Colors.white,
                      ),
                    )
                  : SizedBox(),
            ],
          ),
          Text(gradientdata['title1']).bold().textColor(Colors.white).fontSize(18),
          UIHelper.verticalSpaceMedium,
          Text(gradientdata['title2']).bold().textColor(Colors.white).fontSize(22),
          UIHelper.verticalSpaceTiny,
          Text(gradientdata['desc']).textColor(Colors.white).fontSize(13),
        ],
      ),
    );
  }

  Widget showFeatureWindow(BuildContext context, DocSubscriptionViewmodel model, List amount, int tabviewIndex) {
    return Container(
      alignment: Alignment.center,
      width: Screen.width(context),
      child: Column(
        children: [
          UIHelper.verticalSpaceSmall,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                  onTap: () async {
                    setState(() {
                      selectedIndex = 1;
                      selectedTab = tabviewIndex;
                    });
                  },
                  child: Stack(
                    children: [
                      Column(children: [
                        tabviewIndex == 0 ? SizedBox(height: 35) : SizedBox(),
                        Container(
                          width: 140,
                          height: 130,
                          decoration: UIHelper.roundedBorderWithColorWithShadow(8, Colors.white, borderColor: selectedTab == tabviewIndex && selectedIndex == 1 ? Colors.red : Color(0xFF9A9999), borderWidth: 3),
                          child: Column(
                            children: [
                              tabviewIndex == 0 ? UIHelper.verticalSpaceMedium : UIHelper.verticalSpaceSmall,
                              Text('Yearly').fontSize(17).fontWeight(FontWeight.w600),
                              UIHelper.verticalSpaceTiny,
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('\$').fontWeight(FontWeight.w600).textColor(Colors.red).fontSize(17).textAlignment(TextAlign.center),
                                  SizedBox(
                                    width: 4,
                                  ),
                                  Text(amount[0] != '' ? amount[0] : '').fontSize(17).fontWeight(FontWeight.w600).textAlignment(TextAlign.center),
                                ],
                              ),
                              tabviewIndex == 0 ? SizedBox() : Text('of all payments').fontSize(12),
                              UIHelper.verticalSpaceSmall,
                              GestureDetector(
                                onTap: () async {
                                  setState(() {
                                    selectedIndex = 1;
                                    selectedTab = tabviewIndex;
                                  });
                                  String desc = '';
                                  if (tabviewIndex == 0) {
                                    preferencesService.subPlan = 'com.kat.swarapp.enhanced.yearly';
                                    desc = 'enhanced_yearly';
                                  } else {
                                    preferencesService.subPlan = 'com.kat.swarapp.proffessional.yearly';
                                    desc = 'professional_yearly';
                                  }
                                  openCheckout(desc);
                                },
                                child: Container(
                                    height: 30,
                                    width: 100,
                                    // padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                    decoration: UIHelper.roundedButtonWithGradient(12, [
                                      Color(0xFFFC7D0D),
                                      Color(0xFFE02A53),
                                      Color(0xFFDA1B60),
                                    ]),
                                    child: Center(
                                      child: Text('Subscribe').fontSize(14).bold().textColor(Colors.white),
                                    )),
                              ),
                            ],
                          ),
                        ),
                      ]),
                      tabviewIndex == 0
                          ? Positioned(
                              top: 0,
                              child: Column(
                                children: [
                                  Text('Best Value').fontSize(13).fontWeight(FontWeight.w600),
                                  UIHelper.verticalSpaceSmall,
                                  Container(
                                    width: 140,
                                    alignment: Alignment.center,
                                    child: UIHelper.tagWidget('Save 35%', Colors.red, radius: 2, fontSize: 14),
                                  ),
                                ],
                              ))
                          : SizedBox(),
                    ],
                  )),
              tabviewIndex == 0
                  ? SizedBox()
                  : Text(
                      'OR',
                      style: new TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, foreground: Paint()..shader = linearGradient),
                    ),
              GestureDetector(
                  onTap: () async {
                    setState(() {
                      selectedIndex = 0;
                      selectedTab = tabviewIndex;
                    });
                  },
                  child: Column(
                    children: [
                      tabviewIndex == 0 ? SizedBox(height: 35) : SizedBox(),
                      Container(
                        width: 140,
                        height: 130,
                        decoration: UIHelper.roundedBorderWithColorWithShadow(8, Colors.white, borderColor: selectedTab == tabviewIndex && selectedIndex == 0 ? Colors.red : Color(0xFF9A9999), borderWidth: 3),
                        child: Column(
                          children: [
                            tabviewIndex == 0 ? UIHelper.verticalSpaceMedium : UIHelper.verticalSpaceSmall,
                            Text(tabviewIndex == 0 ? 'Monthly' : 'One Time').fontSize(17).fontWeight(FontWeight.w600),
                            UIHelper.verticalSpaceTiny,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('\$').fontWeight(FontWeight.w600).textColor(Colors.red).fontSize(17).textAlignment(TextAlign.center),
                                SizedBox(
                                  width: 4,
                                ),
                                Text(amount[1] != '' ? amount[1] : '').fontSize(17).fontWeight(FontWeight.w600).textAlignment(TextAlign.center),
                              ],
                            ),
                            tabviewIndex == 0 ? SizedBox() : Text('of all payments').fontSize(12),
                            UIHelper.verticalSpaceSmall,
                            GestureDetector(
                              onTap: () async {
                                setState(() {
                                  selectedIndex = 0;
                                  selectedTab = tabviewIndex;
                                });
                                String desc = '';
                                if (tabviewIndex == 0) {
                                  preferencesService.subPlan = 'com.kat.swarapp.enhanced.monthly';
                                  desc = 'enhanced_monthly';
                                } else {
                                  preferencesService.subPlan = 'com.kat.swarapp.proffessional.monthly';
                                  desc = 'professional_monthly';
                                }
                                print(desc);
                                openCheckout(desc);
                              },
                              child: Container(
                                  height: 30,
                                  width: 100,
                                  // padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  decoration: UIHelper.roundedButtonWithGradient(12, [
                                    Color(0xFFFC7D0D),
                                    Color(0xFFE02A53),
                                    Color(0xFFDA1B60),
                                  ]),
                                  child: Center(
                                    child: Text('Subscribe').fontSize(14).bold().textColor(Colors.white),
                                  )),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )),
            ],
          ),
          tabviewIndex == 0
              ? SizedBox()
              : Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          'VIP',
                          style: new TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, foreground: Paint()..shader = linearGradient),
                        ),
                        Text(
                          'VIP',
                          style: new TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, foreground: Paint()..shader = linearGradient),
                        ),
                      ],
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  @override
  Widget benifitCardWidget(BuildContext context, double width, String title, Color colour, bool batchIcon) {
    return Badge(
      elevation: 2,
      badgeColor: batchIcon ? Colors.green : Colors.black12,
      badgeContent: batchIcon ? Icon(Icons.done_outlined, size: 15, color: Colors.white) : Icon(Icons.remove, size: 15, color: Colors.white),
      child: Container(
          padding: width == 2.5 ? EdgeInsets.only(top: 3, left: 5) : EdgeInsets.only(top: 7),
          height: width == 2.5 ? 50 : 35,
          width: Screen.width(context) / width,
          decoration: UIHelper.accountCardwithShadow(6, 25, colour),
          child: Text(title).fontSize(13).bold().textAlignment(width == 2.5 ? TextAlign.left : TextAlign.center)),
    );
  }

  @override
  Widget benifitsListWidget(BuildContext context, int tabviewIndex) {
    var emergency;
    return Container(
        width: Screen.width(context),
        decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(20))),
        padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('Benefits', textAlign: TextAlign.center).fontSize(16).fontWeight(FontWeight.w800),
          ]),
          UIHelper.verticalSpaceSmall,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              benifitCardWidget(context, 2.5, benefitsData[0], bgContainerColor['1'], true),
              benifitCardWidget(context, 2.5, benefitsData[1], bgContainerColor['2'], true),
            ],
          ),
          UIHelper.verticalSpaceSmall,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              benifitCardWidget(context, 2.5, benefitsData[2], bgContainerColor['3'], true),
              benifitCardWidget(context, 2.5, benefitsData[3], bgContainerColor['4'], true),
            ],
          ),
          UIHelper.verticalSpaceSmall,
          tabviewIndex == 0
              ? Stack(
                  children: [
                    benifitCardWidget(context, 1, benefitsData[4], Colors.white70, false),
                    // Positioned(
                    //     top: 8,
                    //     child:
                    Icon(
                      Icons.new_releases,
                      size: 15,
                    )
                    //),
                  ],
                )
              : benifitCardWidget(context, 1, benefitsData[4], bgContainerColor['5'], true),
          UIHelper.verticalSpaceSmall,
          tabviewIndex == 0 ? benifitCardWidget(context, 1, benefitsData[5], Colors.white70, false) : benifitCardWidget(context, 1, benefitsData[5], bgContainerColor['5'], true),
          UIHelper.verticalSpaceSmall,
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(
              Icons.fiber_manual_record,
              size: 15,
              color: tabviewIndex == 0 ? Colors.black : Colors.black38,
            ),
            Icon(
              Icons.fiber_manual_record,
              size: 15,
              color: tabviewIndex == 1 ? Colors.black : Colors.black38,
            ),
          ]),
          UIHelper.verticalSpaceSmall,
          tabviewIndex == 0
              ? Row(children: [
                  Icon(
                    Icons.new_releases,
                    size: 15,
                  ),
                  Text(' Click here to avail separetly').textColor(Colors.black38).fontSize(10),
                ])
              : SizedBox(),
          UIHelper.verticalSpaceSmall,
          Row(
            children: [
              GestureDetector(
                onTap: () => launch('https://www.swardoctor.com/privacy-policy/'),
                child: Text('*Read carefully  all our Policies,').textColor(Colors.black54).fontSize(10),
              ),
              GestureDetector(
                onTap: () => launch('https://www.swardoctor.com/termsandconditions/'),
                child: Text('Terms and Conditions').textColor(Colors.black54).fontSize(10),
              ),
            ],
          ),
        ]));
  }

//RazorPay Checkout Function
  void openCheckout(String description) async {
    Loader.show(context);
    final response = await apiService.getSubscriptionWeb(description);
    subId = response['id'];
    Loader.hide();
    var options = {
      'key': 'rzp_test_FTht4oR9HIqbhT',
      'name': 'SWAR Doctor',
      "image": 'https://swardev.blob.core.windows.net/b2csignin/swar.png',
      "subscription_id": subId,
      'description': description,
      'retry': {'enabled': true, 'max_count': 1},
      'send_sms_hash': false,
      'prefill': {'contact': '', 'email': ''},
      "theme": {"color": "#FF0000"},
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

// After Payment Transaction
  Future<bool> _verifyPurchase() async {
    String orderId;
    String plan = '';
    var now = new DateTime.now();
    Jiffy transactionDate = Jiffy(now);
    String platform = "";
    Random random = new Random();
    int randomNumber = random.nextInt(100);
    orderId = 'ord' + randomNumber.toString();
    platform = 'android';
    plan = preferencesService.subPlan;

    Map<String, dynamic> postParams = {'productId': plan, 'orderId': orderId, 'purchaseTime': transactionDate.format('MM-dd-yyyy'), 'token': subId, 'active_flag': true, 'platform': platform};
    String userId = locator<PreferencesService>().userId;
    final response = await locator<ApiService>().updateSubscriptionWeb(userId, postParams);
    print(response);
    if (response['subscription'] != null) {
      locator<PreferencesService>().subscriptionStream.value = Map.from(response['subscription']);
    }
    return true;
  }
}
