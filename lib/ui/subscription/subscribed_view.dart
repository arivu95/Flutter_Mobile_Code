import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inapp_purchase/modules.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/services/preferences_service.dart';
import 'package:swarapp/shared/app_colors.dart';
import 'package:swarapp/shared/app_static_bar.dart';
import 'package:swarapp/shared/custom_dialog_box.dart';
import 'package:swarapp/shared/flutter_overlay_loader.dart';
import 'package:swarapp/shared/screen_size.dart';
import 'package:swarapp/shared/span_calculator.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:swarapp/ui/subscription/subscription_view.dart';

class SubscribedView extends StatefulWidget {
  SubscribedView({Key? key}) : super(key: key);

  @override
  _SubscribedViewState createState() => _SubscribedViewState();
}

class _SubscribedViewState extends State<SubscribedView> {
  late IAPItem currentItem;
  PreferencesService preferencesService = locator<PreferencesService>();
  ApiService apiService = locator<ApiService>();
  bool isLoading = true;
  String duration = '';
  String img_url = '';
  String name = '';
  String plan_type = '';
  String daysLeft = '';
  double sliderval = 0.0;
  @override
  void initState() {
    super.initState();
    updateSubscriptionInfo();
    initializeIAP();
  }

  void initializeIAP() async {
    print(DateTime.now());
  }

  Future updateSubscriptionInfo() async {
    String userId = preferencesService.userId;
    dynamic profileInfo = await apiService.getProfile(userId);
    if (profileInfo['azureBlobStorageLink'] != null) {
      setState(() {
        img_url = '${ApiService.fileStorageEndPoint}${profileInfo['azureBlobStorageLink']}';
      });

      //  preferencesService.userInfo = profileInfo;
      // preferencesService.profileUrl.value = img_url;
    }
    name = '${profileInfo['name']} ${profileInfo['lastname']}';

    dynamic purchasedItem = preferencesService.subscriptionInfo;
    String productId = purchasedItem['productId'];
    print(productId);
    plan_type = purchasedItem['subscription_plan'];
    if (purchasedItem['productId'] != null) {
      setState(() {
        name = '${profileInfo['name']} ${profileInfo['lastname']}';
        String? key;
        if (purchasedItem['subscription_plan'] == 'Monthly') {
          key = 'P1M';
        } else {
          key = 'P1Y';
        }
        duration = preferencesService.subscriptionDuration[key]!;
        Map<String, dynamic>? subscriptionInfo = preferencesService.subscriptionStream.value;
        if (subscriptionInfo!['purchaseTime'] != null) {
          String purchaseTimeStr = subscriptionInfo['purchaseTime'];
          String productId = subscriptionInfo['productId'];
          Jiffy purchaseDt = Jiffy(purchaseTimeStr);
          DateDuration dduration = SpanCalculator.timeToNextSubscription(purchaseDt.dateTime);
          DateTime nextsub = SpanCalculator.nextBirthDate(purchaseDt.dateTime);
          Duration days = nextsub.difference(DateTime.now());
          if (productId.contains('monthly')) {
            if (dduration.days > 0) {
              int dLeft = 30 - dduration.days;
              sliderval = dLeft / 30;
              daysLeft = '${dduration.days} days left';
              Jiffy atill = Jiffy().add(days: dduration.days);
              duration = atill.format('dd, MMM, yyyy');
            } else {
              sliderval = 0.0;
              daysLeft = '30 days left';
              Jiffy atill = Jiffy().add(days: 30);
              duration = atill.format('dd, MMM, yyyy');
            }
          } else if (productId.contains('yearly')) {
            if (days.inDays > 0) {
              daysLeft = '${days.inDays} days left';
              int dLeft = 365 - days.inDays;
              sliderval = dLeft / 365;
              Jiffy atill = Jiffy().add(days: days.inDays);
              duration = atill.format('dd, MMM, yyyy');
            } else {
              sliderval = 0.0;
              daysLeft = '365 days left';
              Jiffy atill = Jiffy().add(days: 365);
              duration = atill.format('dd, MMM, yyyy');
            }
          }
          setState(() {});
        }
      });
    }
    setState(() {
      // currentItem = iapItem;
      isLoading = false;
    });
    // }
  }

  Widget showFeatureWindow(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      // padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      width: Screen.width(context) - 32,
      child: Column(
        children: [
          UIHelper.verticalSpaceMedium,
          // Text('Renew Your Membership').fontSize(17).fontWeight(FontWeight.w600),
          // UIHelper.verticalSpaceMedium,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                width: 140,
                height: 100,
                decoration: UIHelper.roundedBorderWithColorWithShadow(8, Colors.white, borderColor: plan_type.toLowerCase() != "monthly" ? Colors.red : Color(0xFF9A9999), borderWidth: 3),
                child: Column(
                  children: [
                    UIHelper.tagWidget('Best value', Colors.red, radius: 2),
                    UIHelper.verticalSpaceTiny,
                    Text('Yearly').fontSize(17).fontWeight(FontWeight.w600),
                    UIHelper.verticalSpaceTiny,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('\$').fontWeight(FontWeight.w600).textColor(Colors.red).fontSize(17).textAlignment(TextAlign.center),
                        SizedBox(
                          width: 4,
                        ),
                        Text('14.99').fontSize(17).fontWeight(FontWeight.w600).textAlignment(TextAlign.center),
                      ],
                    ),
                    UIHelper.verticalSpaceTiny,
                    Text('  Save 35%').fontSize(11).textAlignment(TextAlign.center),
                  ],
                ),
              ),
              Container(
                width: 140,
                height: 100,
                decoration: UIHelper.roundedBorderWithColorWithShadow(8, Colors.white, borderColor: plan_type.toLowerCase() == "monthly" ? Colors.red : Color(0xFF9A9999), borderWidth: 3),
                child: Column(
                  children: [
                    UIHelper.tagWidget('', Colors.transparent, radius: 2),
                    UIHelper.verticalSpaceTiny,
                    Text('Monthly').fontSize(17).fontWeight(FontWeight.w600),
                    UIHelper.verticalSpaceTiny,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('\$').fontWeight(FontWeight.w600).textColor(Colors.red).fontSize(17).textAlignment(TextAlign.center),
                        SizedBox(
                          width: 4,
                        ),
                        Text('1.99').fontSize(17).fontWeight(FontWeight.w600).textAlignment(TextAlign.center),
                      ],
                    ),
                    UIHelper.verticalSpaceTiny,
                    Text('  ').fontSize(11).textAlignment(TextAlign.center),
                  ],
                ),
              )
            ],
          ),
          UIHelper.verticalSpaceSmall,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // return AnnotatedRegion(
    //     value: SystemUiOverlayStyle.light,
    //     child: SafeArea(
    //         child: Scaffold(
    return Scaffold(
        appBar: SwarAppStaticBar(),
        // backgroundColor: Color(0xFFF5F3F3),
        body: Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            width: Screen.width(context),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              UIHelper.verticalSpaceSmall,
              UIHelper.addHeader(context, "Membership", true),
              UIHelper.verticalSpaceMedium,
              isLoading
                  ?
                  //Text('isLoading')
                  Center(
                      child: CircularProgressIndicator(),
                    )
                  : Expanded(
                      child: SingleChildScrollView(
                          child: Column(
                      children: [
                        Column(
                          children: [
                            Container(
                              height: 180,
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
                              padding: EdgeInsets.fromLTRB(16, 20, 16, 16),
                              child: Column(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(30.0),
                                    child: img_url == ''
                                        ? Container(
                                            color: subtleColor,
                                            child: Icon(Icons.portrait),
                                            width: 60,
                                            height: 60,
                                          )
                                        : UIHelper.getImage(img_url, 60, 60),
                                  ),
                                  UIHelper.verticalSpaceSmall,
                                  Text('Hi, $name 👑').textColor(Colors.white).fontSize(16).textAlignment(TextAlign.center),
                                  //    Text(currentItem.title!).bold().textColor(Colors.white).fontSize(16).textAlignment(TextAlign.center),
                                  Text(plan_type + ' Membership (SWAR Doctor)'),
                                  UIHelper.verticalSpaceTiny,
                                  Text('Valid up to $duration').textColor(Colors.white),
                                ],
                              ),
                            ),
                            UIHelper.verticalSpaceSmall,
                            daysLeft.isEmpty
                                ? SizedBox()
                                : Card(
                                    child: Container(
                                    padding: EdgeInsets.fromLTRB(40, 20, 20, 20),
                                    width: Screen.width(context),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text(daysLeft).bold(),
                                            Text(' in Membership').fontSize(12),
                                          ],
                                        ),
                                        UIHelper.verticalSpaceSmall,
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: LinearProgressIndicator(
                                            minHeight: 8,
                                            value: sliderval,
                                            backgroundColor: Colors.black12,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                                          ),
                                        )
                                      ],
                                    ),
                                  )),
                            UIHelper.verticalSpaceSmall,
                            Container(
                              width: Screen.width(context),
                              height: 320,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12)),
                              ),
                              child: showFeatureWindow(context),
                            ),
                            Center(
                              child: Column(
                                children: [
                                  ElevatedButton(
                                      onPressed: () async {
                                        String userId = locator<PreferencesService>().userId;
                                        final response = await apiService.getSubscription(userId);
                                        print(response);
                                        if (response == false) {
                                          showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return CustomDialogBox(
                                                  title: "Alert !",
                                                  descriptions: "Something went wrong!",
                                                  descriptions1: "Please try again later",
                                                  text: "OK",
                                                );
                                              });
                                        } else {
                                          final subId = response['subscription_Id'];
                                          print('tututu-----' + response['token']);
                                          Loader.show(context);
                                          final responseCancel = await apiService.cancelSubscriptionWeb(response['token']);
                                          print(responseCancel);
                                          Loader.hide();
                                          if (responseCancel['status'] == 'active') {
                                            dynamic data = {'isload': false};
                                            Get.to(() => SubscriptionView(data: data));
                                            showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return CustomDialogBox(
                                                    title: "Success !",
                                                    descriptions: "Subscription cancelled",
                                                    descriptions1: "You can use the remaining subscription days",
                                                    text: "OK",
                                                  );
                                                });
                                          }
                                        }
                                      },
                                      child: Column(
                                        children: [
                                          Text(
                                            'CANCEL SUBSCRIPTION',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      style: ButtonStyle(
                                          minimumSize: MaterialStateProperty.all(Size(160, 50)),
                                          backgroundColor: MaterialStateProperty.resolveWith((states) {
                                            return Colors.redAccent;
                                          }))),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    )))
            ])));
    // ))
  }
}
