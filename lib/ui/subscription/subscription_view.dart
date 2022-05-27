import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
import 'package:jiffy/jiffy.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/services/preferences_service.dart';
import 'package:swarapp/shared/app_colors.dart';
import 'package:swarapp/shared/app_static_bar.dart';
import 'package:swarapp/shared/custom_dialog_box.dart';
import 'package:swarapp/shared/flutter_overlay_loader.dart';
import 'package:swarapp/shared/screen_size.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:swarapp/ui/startup/terms_view.dart';
import 'package:swarapp/ui/subscription/subscribed_view.dart';
import 'package:swarapp/ui/subscription/subscription_viewmodel.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter/services.dart';
import 'dart:math';

class SubscriptionView extends StatefulWidget {
  dynamic data;
  SubscriptionView({Key? key, this.data}) : super(key: key);

  @override
  _SubscriptionViewState createState() => _SubscriptionViewState();
}

class _SubscriptionViewState extends State<SubscriptionView> {
  static const platform = const MethodChannel("razorpay_flutter");
  ApiService apiService = ApiService();
  late Razorpay _razorpay;
  String subscription_plan = preferencesService.subscriptionInfo['subscription_plan'];
  int selectedPlanIndex = 0;
  int selectedIndex = 2;
  String subId = '';
  DateTime currentDate = DateTime.now();
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

    int selectedPlanIndex;
    if (subscription_plan == "Basic") {
      selectedPlanIndex = 0;
    } else {
      selectedPlanIndex = 1;
    }

    initializeIAP();
  }

  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();
  }

  void openCheckout(String description) async {
    Loader.show(context);
    final response = await apiService.getSubscriptionWeb(description.toLowerCase());
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
      'prefill': {'contact': preferencesService.phone, 'email': preferencesService.email},
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

  Future<bool> _verifyPurchase(String payId) async {
    String orderId;
    String planId = locator<PreferencesService>().subPlan;
    String plan = '';
    var now = new DateTime.now();
    Jiffy transactionDate = Jiffy(now);
    String platform = "";
    Random random = new Random();
    int randomNumber = random.nextInt(100);

    if (payId != '') {
      orderId = payId;
    } else {
      orderId = 'ord' + randomNumber.toString();
    }
    platform = 'android';
    if (planId == 'monthly') {
      plan = 'com.kat.swarapp.monthly';
    } else {
      plan = 'com.kat.swarapp.yearly';
    }
    print(planId);
    Map<String, dynamic> postParams = {'productId': plan, 'orderId': orderId, 'purchaseTime': transactionDate.format('MM-dd-yyyy'), 'token': subId, 'active_flag': true, 'platform': platform};
    String userId = locator<PreferencesService>().userId;
    final response = await locator<ApiService>().updateSubscriptionWeb(userId, postParams);
    print(response);
    if (response['subscription'] != null) {
      locator<PreferencesService>().subscriptionStream.value = Map.from(response['subscription']);
    }
    return true;
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    print('Success Response: $response');
    String payId = '';
    final res = await _verifyPurchase(payId);
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

  void _handlePaymentError(PaymentFailureResponse response) {
    print('Error Response: $response');
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

  void initializeIAP() async {}

  Widget headerItem() {
    return Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        height: 30,
        alignment: Alignment.center,
        //padding: EdgeInsets.fromLTRB(4, 8, 4, 8),
        padding: EdgeInsets.fromLTRB(18, 8, 15, 8),
        decoration: UIHelper.roundedBorderWithColor(2, Color(0xFFF5F2E9)),
        child: Text('Features').bold().fontSize(11).textAlignment(TextAlign.left),
      ),

      Container(
        height: 30,
        alignment: Alignment.topLeft,
        // padding: EdgeInsets.fromLTRB(4, 8, 4, 8),
        // color: bgColor,
        child: Text('').bold().fontSize(11).textAlignment(TextAlign.left),
      ),

      Container(
        height: 30,
        alignment: Alignment.topLeft,
        padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
        child: Text('Add Members').bold().fontSize(11).textAlignment(TextAlign.left),
      ),

      Container(
        height: 30,
        alignment: Alignment.topLeft,
        padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
        child: Text('Storage').bold().fontSize(11).textAlignment(TextAlign.left),
      ),

      Container(
        height: 30,
        alignment: Alignment.topLeft,
        padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
        child: Text('Privileges').bold().fontSize(11).textAlignment(TextAlign.left),
      ),

      //),
    ]);
  }

  Widget planItem(String title, SubscriptionViewmodel model) {
    if (title == "Membership") {
      return GestureDetector(
          onTap: () async {
            setState(() {
              selectedPlanIndex = 1;
            });
          },
          child: Container(
              padding: EdgeInsets.fromLTRB(4, 8, 4, 8),
              decoration: UIHelper.roundedBorderWithColorWithShadow(8, Colors.white, borderColor: selectedPlanIndex == 1 ? Colors.red : Colors.white, borderWidth: 3),
              child: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                //Expanded(
                Container(
                  height: 30,
                  alignment: Alignment.center,
                  padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
                  decoration: UIHelper.roundedBorderWithColor(2, Color(0xFFF5F2E9)),
                  child: Text(title).bold().fontSize(11).textAlignment(TextAlign.center),
                ),

                Container(
                    height: 30,
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text('\$').bold().textColor(Colors.red).fontSize(12).textAlignment(TextAlign.center),
                            SizedBox(
                              width: 4,
                            ),
                            Text(model.monthdetails['amount'] != null ? model.monthdetails['amount'] : '').bold().fontSize(13).textAlignment(TextAlign.center),
                          ],
                        ),
                        Text('/per Month').bold().fontSize(8).textAlignment(TextAlign.center)
                      ],
                    )),
                Container(
                  height: 30,
                  alignment: Alignment.center,
                  // padding: EdgeInsets.fromLTRB(4, 8, 4, 8),
                  // color: bgColor,
                  padding: EdgeInsets.fromLTRB(18, 8, 18, 8),
                  decoration: UIHelper.roundedBorderWithColor(2, Color(0xFFF5F2E9)),
                  child: Text(model.monthdetails['member_count'] != null ? model.monthdetails['member_count'] : '').fontSize(11).textAlignment(TextAlign.center),
                ),

                Container(
                  height: 30,
                  alignment: Alignment.center,
                  child: Text(model.monthdetails['storage_size'] != null ? model.monthdetails['storage_size'] : '').fontSize(11).textAlignment(TextAlign.center),
                ),
                Container(
                  height: 30,
                  alignment: Alignment.center,
                  padding: EdgeInsets.fromLTRB(8, 0, 8, 4),
                  decoration: UIHelper.roundedBorderWithColor(2, Color(0xFFF5F2E9)),
                  child: Text(model.monthdetails['privilege'] != null ? model.monthdetails['privilege'] : '').fontSize(11).textAlignment(TextAlign.center),
                ),
              ])));
    } else {
      return GestureDetector(
          onTap: () async {
            setState(() {
              selectedPlanIndex = 0;
            });
          },
          child: Container(
              padding: EdgeInsets.fromLTRB(4, 8, 4, 8),
              decoration: UIHelper.roundedBorderWithColorWithShadow(8, Colors.white, borderColor: selectedPlanIndex == 0 ? Colors.red : Colors.white, borderWidth: 3),
              child: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                //Expanded(
                Container(
                  decoration: UIHelper.roundedBorderWithColor(2, Color(0xFFE1EDE9)),
                  height: 30,
                  alignment: Alignment.center,
                  padding: EdgeInsets.fromLTRB(32, 8, 32, 8),
                  child: Text(title).bold().fontSize(11).textAlignment(TextAlign.center),
                ),

                Container(
                    height: 30,
                    alignment: Alignment.center,
                    child: Row(
                      children: [
                        Text('\$').bold().textColor(Colors.red).fontSize(12).textAlignment(TextAlign.center),
                        SizedBox(
                          width: 4,
                        ),
                        Text('Free').bold().fontSize(13).textAlignment(TextAlign.center)
                      ],
                    )),

                Container(
                  height: 30,
                  alignment: Alignment.center,
                  // padding: EdgeInsets.fromLTRB(4, 8, 4, 8),
                  // color: bgColor,
                  padding: EdgeInsets.fromLTRB(44, 8, 44, 8),
                  decoration: UIHelper.roundedBorderWithColor(2, Color(0xFFE1EDE9)),
                  child: Text(model.basicdetails['member_count'] != null ? model.basicdetails['member_count'] : '').fontSize(11).textAlignment(TextAlign.center),
                ),

                Container(
                  height: 30,
                  alignment: Alignment.center,
                  // padding: EdgeInsets.fromLTRB(4, 8, 4, 8),
                  // color: bgColor,
                  child: Text(model.basicdetails['storage_size'] != null ? model.basicdetails['storage_size'] : '').fontSize(11).textAlignment(TextAlign.center),
                ),
                Container(
                  height: 30,
                  alignment: Alignment.center,
                  // padding: EdgeInsets.fromLTRB(4, 8, 4, 8),
                  // color: bgColor,
                  padding: EdgeInsets.fromLTRB(24, 8, 24, 8),
                  decoration: UIHelper.roundedBorderWithColor(2, Color(0xFFE1EDE9)),
                  child: Text(model.basicdetails['privilege'] != null ? model.basicdetails['privilege'] : '').fontSize(11).textAlignment(TextAlign.center),
                ),
              ])));
    }

    //),
  }

  Widget addFeatureTable(BuildContext context, SubscriptionViewmodel model) {
    return Container(
      width: Screen.width(context) / 1.1,
      alignment: Alignment.center,
      decoration: UIHelper.roundedBorderWithColorWithShadow(12, Colors.white),
      padding: EdgeInsets.fromLTRB(4, 12, 4, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          headerItem(),
          planItem('Basic', model),
          planItem('Membership', model),
        ],
      ),
    );
  }

  Widget showFeatureWindow(BuildContext context, SubscriptionViewmodel model) {
    return Container(
      alignment: Alignment.center,
      width: Screen.width(context),
      child: Column(
        children: [
          addFeatureTable(context, model),
          UIHelper.verticalSpaceMedium,
          selectedPlanIndex == 1
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    GestureDetector(
                        onTap: () async {
                          setState(() {
                            selectedIndex = 1;
                          });
                          preferencesService.subPlan = 'yearly';
                          openCheckout('Yearly');
                          // print(preferencesService.productIds[selectedIndex]);
                          // String productId = preferencesService.productIds[selectedIndex];

                          // List<IAPItem> products = await iapService.products;
                          // if (products.length > 0) {
                          //   IAPItem selectedProduct = products.firstWhere(
                          //     (element) {
                          //       return element.productId == productId;
                          //     },
                          //   );
                          //   await iapService.buyProduct(selectedProduct);
                          // }
                          // ;
                        },
                        child: Stack(
                          children: [
                            Column(children: [
                              SizedBox(height: 14),
                              Container(
                                width: 140,
                                height: 130,
                                decoration: UIHelper.roundedBorderWithColorWithShadow(8, Colors.white, borderColor: selectedIndex == 1 ? Colors.red : Color(0xFF9A9999), borderWidth: 3),
                                child: Column(
                                  children: [
                                    UIHelper.verticalSpaceMedium,
                                    Text('Best Value').fontSize(13).fontWeight(FontWeight.w600),
                                    UIHelper.verticalSpaceTiny,
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text('Yearly').fontSize(17).fontWeight(FontWeight.w600),
                                        SizedBox(
                                          width: 4,
                                        ),
                                        Text('\$').fontWeight(FontWeight.w600).textColor(Colors.red).fontSize(17).textAlignment(TextAlign.center),
                                        SizedBox(
                                          width: 4,
                                        ),
                                        Text(model.yeardetails['amount'] != null ? model.yeardetails['amount'] : '').fontSize(17).fontWeight(FontWeight.w600).textAlignment(TextAlign.center),
                                      ],
                                    ),
                                    UIHelper.verticalSpaceTiny,
                                    UIHelper.verticalSpaceSmall,
                                    GestureDetector(
                                      onTap: () async {
                                        preferencesService.subPlan = 'yearly';
                                        openCheckout('Yearly');
                                      },
                                      child: Container(
                                        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                        decoration: UIHelper.roundedButtonWithGradient(12, [
                                          Color(0xFFFC7D0D),
                                          Color(0xFFE02A53),
                                          Color(0xFFDA1B60),
                                        ]),
                                        child: Text('Subscribe').fontSize(14).bold().textColor(Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ]),
                            Positioned(
                              top: 0,
                              child: Container(
                                width: 140,
                                alignment: Alignment.center,
                                child: UIHelper.tagWidget('Save 35%', Colors.red, radius: 2, fontSize: 14),
                              ),
                            ),
                          ],
                        )),
                    GestureDetector(
                        onTap: () async {
                          setState(() {
                            selectedIndex = 0;
                          });
                          preferencesService.subPlan = 'monthly';
                          openCheckout('Monthly');
                          // String productId = preferencesService.productIds[selectedIndex];

                          // List<IAPItem> products = await iapService.products;
                          // if (products.length > 0) {
                          //   IAPItem selectedProduct = products.firstWhere(
                          //     (element) {
                          //       return element.productId == productId;
                          //     },
                          //   );
                          //   await iapService.buyProduct(selectedProduct);
                          // }
                        },
                        child: Column(
                          children: [
                            SizedBox(height: 14),
                            Container(
                              width: 140,
                              height: 130,
                              decoration: UIHelper.roundedBorderWithColorWithShadow(8, Colors.white, borderColor: selectedIndex == 0 ? Colors.red : Color(0xFF9A9999), borderWidth: 3),
                              child: Column(
                                children: [
                                  UIHelper.verticalSpaceMedium,
                                  Text('Monthly').fontSize(17).fontWeight(FontWeight.w600),
                                  UIHelper.verticalSpaceTiny,
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('\$').fontWeight(FontWeight.w600).textColor(Colors.red).fontSize(17).textAlignment(TextAlign.center),
                                      SizedBox(
                                        width: 4,
                                      ),
                                      Text(model.monthdetails['amount'] != null ? model.monthdetails['amount'] : '').fontSize(17).fontWeight(FontWeight.w600).textAlignment(TextAlign.center),
                                    ],
                                  ),
                                  UIHelper.verticalSpaceSmall,
                                  GestureDetector(
                                    onTap: () async {
                                      preferencesService.subPlan = 'monthly';
                                      openCheckout('Monthly');
                                      // setState(() {
                                      //   selectedIndex = 0;
                                      // });
                                      // String productId = preferencesService.productIds[selectedIndex];

                                      // List<IAPItem> products = await iapService.products;
                                      // if (products.length > 0) {
                                      //   IAPItem selectedProduct = products.firstWhere(
                                      //     (element) {
                                      //       return element.productId == productId;
                                      //     },
                                      //   );
                                      //   await iapService.buyProduct(selectedProduct);
                                      // }
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                      decoration: UIHelper.roundedButtonWithGradient(12, [
                                        Color(0xFFFC7D0D),
                                        Color(0xFFE02A53),
                                        Color(0xFFDA1B60),
                                      ]),
                                      child: Text('Subscribe').fontSize(14).bold().textColor(Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )),
                  ],
                )
              : SizedBox(),
          UIHelper.verticalSpaceSmall,
          selectedPlanIndex == 1
              ? Column(
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
                    UIHelper.verticalSpaceSmall,
                    Text('*Can upgrade for additional storage\n**discount for new features e.g. Chat with others').fontSize(10).textAlignment(TextAlign.center),
                    UIHelper.verticalSpaceMedium,
                    GestureDetector(
                      onTap: () => launch('https://www.swardoctor.com/privacy-policy/'),
                      child: Text('Privacy Policy').textColor(skipColor).fontSize(15),
                    ),
                    UIHelper.verticalSpaceSmall,
                    GestureDetector(
                      onTap: () => launch('https://www.swardoctor.com/termsandconditions/'),
                      child: Text('Terms and Conditions').textColor(skipColor).fontSize(15),
                    ),
                  ],
                )
              : SizedBox(),
          (widget.data != null && widget.data['isload'] == true)
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        Navigator.pop(context);
                        await preferencesService.setPopupInfo('popupShow', 'false');
                        await preferencesService.setPopupInfo('date', currentDate.toString());
                        preferencesService.click_skip = 'clicked';
                        // Navigator.pop(context);
                      },
                      child: Text('Skip  ').textColor(skipColor).fontSize(18),
                    ),
                  ],
                )
              : SizedBox(),
          UIHelper.verticalSpaceSmall,
        ],
      ),
    );
  }

  @override
  Widget subscriptionGradient(BuildContext context) {
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
          Text('Great Start!').bold().textColor(Colors.white).fontSize(20),
          UIHelper.verticalSpaceMedium,
          Text('SWAR Membership').bold().textColor(Colors.white).fontSize(18),
          UIHelper.verticalSpaceTiny,
          Text('Get the best value for your family').textColor(Colors.white).fontSize(16),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SubscriptionViewmodel>.reactive(
        onModelReady: (model) async {
          Loader.show(context);
          await model.getSubscriptionsList();
          Loader.hide();
        },
        builder: (context, model, child) {
          return (widget.data != null && widget.data['isload'] == true)
              ? Scaffold(
                  body: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      color: Color(0xFFF5F3F3),
                      width: Screen.width(context),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        UIHelper.verticalSpaceSmall,
                        UIHelper.verticalSpaceSmall,
                        subscriptionGradient(context),
                        Expanded(
                            child: SingleChildScrollView(
                          child: showFeatureWindow(context, model),
                        ))
                      ])))
              : Scaffold(
                  appBar: SwarAppStaticBar(),
                  backgroundColor: Color(0xFFF5F3F3),
                  body: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      color: Colors.white,
                      width: Screen.width(context),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        UIHelper.verticalSpaceSmall,
                        UIHelper.addHeader(context, "Subscription Plan", true),
                        UIHelper.verticalSpaceSmall,
                        subscriptionGradient(context),
                        Expanded(
                            child: SingleChildScrollView(
                          child: showFeatureWindow(context, model),
                        ))
                      ])));
        },
        viewModelBuilder: () => SubscriptionViewmodel());
  }
}
