import 'package:doctor_module/src/ui/doc_subscription/subscription_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/services/iap_service.dart';
import 'package:swarapp/shared/app_static_bar.dart';
import 'package:swarapp/shared/custom_dialog_box.dart';
import 'package:swarapp/shared/screen_size.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:swarapp/ui/startup/terms_view.dart';
import 'package:get/get.dart';
import 'package:doctor_module/src/ui/doc_subscription/subscription_view.dart';

class MembershipListView extends StatefulWidget {
  dynamic data;
  MembershipListView({Key? key, this.data}) : super(key: key);

  @override
  _MembershipListViewState createState() => _MembershipListViewState();
}

class _MembershipListViewState extends State<MembershipListView> {
  IapService iapService = locator<IapService>();

  String subscription_plan = preferencesService.subscriptionInfo['subscription_plan'];
  DateTime currentDate = DateTime.now();

  List<dynamic> membershipList = [
    {
      "title": "Free Trial (3 Months)",
      "content": ['Membership  benefits']
    },
    {
      "title": "Online subscription ",
      "content": ['SWAR Enchanced', 'SWAR Proffesional']
    },
  ];
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
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<DocSubscriptionViewmodel>.reactive(
        onModelReady: (model) async {},
        builder: (context, model, child) {
          return
              // (widget.data != null && widget.data['isload'] == true)
              //     ? Scaffold(
              //         body: Container(
              //             padding: EdgeInsets.symmetric(horizontal: 8),
              //             color: Color(0xFFF5F3F3),
              //             width: Screen.width(context),
              //             child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              //               UIHelper.verticalSpaceSmall,
              //               UIHelper.verticalSpaceSmall,
              //               membershipListWidget(context),
              //               Expanded(
              //                   child: SingleChildScrollView(
              //                 child: showFeatureWindow(context, model),
              //               ))
              //             ])))
              //     :
              Scaffold(
                  appBar: SwarAppStaticBar(),
                  backgroundColor: Color(0xFFF5F3F3),
                  body: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      color: Colors.white,
                      width: Screen.width(context),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        UIHelper.verticalSpaceSmall,
                        UIHelper.addHeader(context, "Subscription", true),
                        UIHelper.verticalSpaceSmall,
                        membershipListWidget(context),
                      ])));
        },
        viewModelBuilder: () => DocSubscriptionViewmodel());
  }

  @override
  Widget membershipListWidget(BuildContext context) {
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
          borderRadius: BorderRadius.all(Radius.circular(12))),
      padding: EdgeInsets.all(10),
      child: Column(
        children: [
          Text('Doctor Membership ').bold().textColor(Colors.white).fontSize(20),
          UIHelper.verticalSpaceMedium,
          ListView.separated(
              separatorBuilder: (context, index) {
                return SizedBox();
              },
              padding: EdgeInsets.only(top: 0),
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: membershipList.length,
              itemBuilder: (context, index) {
                return Column(children: [
                  Stack(children: [
                    Row(
                      children: [
                        SizedBox(width: 15),
                        Expanded(
                            child: Container(
                          padding: EdgeInsets.all(10),
                          height: 130,
                          decoration: UIHelper.roundedBorderWithColorWithShadow(6, Colors.white),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(membershipList[index]['title']).fontSize(16).bold(),
                            UIHelper.verticalSpaceSmall,
                            ListView.separated(
                                separatorBuilder: (context, index) {
                                  return SizedBox();
                                },
                                padding: EdgeInsets.only(top: 0),
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: membershipList[index]['content'].length,
                                itemBuilder: (context, index) {
                                  return Column(children: [
                                    Row(
                                      children: [
                                        SizedBox(width: 20),
                                        ClipRRect(
                                            borderRadius: BorderRadius.circular(55), child: Container(color: Colors.green, padding: EdgeInsets.all(3), child: Icon(Icons.done_outlined, size: 16, color: Colors.white))),
                                        UIHelper.horizontalSpaceSmall,
                                        Text(membershipList[index]['content'][index]).fontSize(12).bold(),
                                      ],
                                    ),
                                    UIHelper.verticalSpaceSmall
                                  ]);
                                }),
                          ]),
                        )),
                        SizedBox(width: 25)
                      ],
                    ),
                    Positioned(
                      bottom: 3,
                      right: 28,
                      child: Text('Read terms and condition').fontSize(12),
                    ),
                    Positioned(
                        right: 0,
                        bottom: 40,
                        child: Container(
                          alignment: Alignment.center,
                          child: SizedBox(
                            width: 50,
                            height: 50,
                            child: ElevatedButton(
                                onPressed: () {
                                  if (membershipList[index]['title'] == 'Free Trial (3 Months)') {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return CustomDialogBox(
                                            title: "Free Trial 3 Months",
                                            descriptions: "Conditions apply",
                                            descriptions1: "",
                                            text: "OK",
                                          );
                                        });
                                  } else {
                                    Get.to(() => DocSubscriptionView());
                                  }
                                },
                                child: Icon(
                                  Icons.keyboard_arrow_right,
                                  size: 24,
                                  color: Colors.black54,
                                ),
                                style: ButtonStyle(
                                  shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0))),
                                  backgroundColor: MaterialStateProperty.all(Colors.white),
                                  padding: MaterialStateProperty.all(EdgeInsets.zero),
                                )),
                          ),
                        ))
                  ]),
                  UIHelper.verticalSpaceMedium
                ]);
              }),
        ],
      ),
    );
  }
}
