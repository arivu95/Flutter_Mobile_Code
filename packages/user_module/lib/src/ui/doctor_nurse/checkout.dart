import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swarapp/shared/app_bar.dart';
import 'package:swarapp/shared/app_colors.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:styled_widget/styled_widget.dart';

class checkout extends StatefulWidget {
  checkout({Key? key}) : super(key: key);
  @override
  _checkoutState createState() => _checkoutState();
}

class _checkoutState extends State<checkout> {
  TextEditingController searchController = TextEditingController();
  int selectedIndex = 1;

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
              Text('Checkout').fontSize(16).fontWeight(FontWeight.w600),
            ],
          ),
          Container(decoration: UIHelper.roundedLineBorderWithColor(12, fieldBgColor, 1), padding: EdgeInsets.all(4), child: Row()),
        ],
      ),
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
                              onPressed: () {
                                FocusManager.instance.primaryFocus!.unfocus();
                              }),
                      contentPadding: EdgeInsets.only(left: 20),
                      enabledBorder: UIHelper.getInputBorder(0, radius: 12, borderColor: Color(0xFFCCCCCC)),
                      focusedBorder: UIHelper.getInputBorder(0, radius: 12, borderColor: Color(0xFFCCCCCC)),
                      focusedErrorBorder: UIHelper.getInputBorder(0, radius: 12, borderColor: Color(0xFFCCCCCC)),
                      errorBorder: UIHelper.getInputBorder(0, radius: 12, borderColor: Color(0xFFCCCCCC)),
                      filled: true,
                      hintStyle: new TextStyle(color: Colors.grey[800]),
                      hintText: selectedIndex == 0 ? "Search Doctor" : "Search Nurse",
                      fillColor: fieldBgColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget doctorcard(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Container(
            padding: EdgeInsets.fromLTRB(10, 4, 70, 4),
            decoration: UIHelper.allcornerRadiuswithbottomShadow(12, 12, 12, 12, Colors.white),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Image.asset('assets/member.jpg', width: 70, height: 80),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Varun').fontSize(14).fontWeight(FontWeight.w600),
                  UIHelper.verticalSpaceTiny,
                  Text('General doctor').fontSize(14).fontWeight(FontWeight.w600).textColor(Colors.black38),
                  UIHelper.verticalSpaceSmall,
                  Text('Insurance Accepted').fontSize(14).fontWeight(FontWeight.w500),
                  UIHelper.verticalSpaceTiny,
                ],
              ),
              Column(
                children: [
                  Row(
                    children: [
                      UIHelper.horizontalSpaceSmall,
                    ],
                  ),
                ],
              ),
            ])),
      ],
    );
  }

  Widget consultant(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Container(
            padding: EdgeInsets.fromLTRB(10, 4, 70, 4),
            decoration: UIHelper.allcornerRadiuswithbottomShadow(12, 12, 12, 12, Colors.white),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Image.asset('assets/userch2.png', width: 70, height: 80),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset('assets/userch1.png', width: 70, height: 80),
                ],
              ),
              Column(
                children: [
                  Row(
                    children: [
                      Image.asset('assets/userch2.png', width: 70, height: 80),
                    ],
                  ),
                ],
              ),
            ])),
      ],
    );
  }

  Widget feesdetail(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Container(
            padding: EdgeInsets.fromLTRB(10, 4, 100, 4),
            decoration: UIHelper.allcornerRadiuswithbottomShadow(12, 12, 12, 12, Colors.white),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Consult Fees').fontSize(14).fontWeight(FontWeight.w600),
                  UIHelper.verticalSpaceTiny,
                  Text('To Pay').fontSize(14).fontWeight(FontWeight.w600),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  UIHelper.horizontalSpaceLarge,
                  Text(' \u{20B9} 500').fontSize(14).fontWeight(FontWeight.w600),
                  UIHelper.horizontalSpaceLarge,
                  Text(' \u{20B9} 500').fontSize(14).fontWeight(FontWeight.w600),
                ],
              ),
            ])),
      ],
    );
  }

  Widget applycoupon(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
      Container(
        padding: EdgeInsets.fromLTRB(4, 4, 140, 4),
        decoration: UIHelper.allcornerRadiuswithbottomShadow(12, 12, 12, 12, Colors.white),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  Get.back();
                },
                child: Icon(
                  Icons.cancel_outlined,
                  size: 20,
                ),
              ),
              Text('Apply Coupon').fontSize(16).fontWeight(FontWeight.w600),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [],
          ),
        ]),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SwarAppBar(4),
      body: SafeArea(
          top: false,
          child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  addHeader(context, true),
                  UIHelper.verticalSpaceMedium,
                  doctorcard(context),
                  UIHelper.verticalSpaceMedium,
                  Expanded(
                      child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(20, 4, 4, 4),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Get.back();
                                },
                                child: Icon(
                                  Icons.video_call_outlined,
                                  size: 20,
                                ),
                              ),
                              Text('Video Consultation').fontSize(16).fontWeight(FontWeight.w600),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(20, 4, 4, 4),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Get.back();
                                },
                                child: Icon(
                                  Icons.calendar_today_outlined,
                                  size: 20,
                                ),
                              ),
                              Text('May 10, 10.00 am').fontSize(16).fontWeight(FontWeight.w600),
                            ],
                          ),
                        ),
                        UIHelper.verticalSpaceMedium,
                        consultant(context),
                        UIHelper.verticalSpaceMedium,
                        applycoupon(context),
                        Padding(
                          padding: EdgeInsets.fromLTRB(20, 4, 4, 4),
                          child: Row(
                            children: [
                              Text('Fees Detail').fontSize(16).fontWeight(FontWeight.w600),
                            ],
                          ),
                        ),
                        UIHelper.verticalSpaceMedium,
                        feesdetail(context),
                        UIHelper.verticalSpaceMedium,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                                onPressed: () async {},
                                child: Text('Checkout').bold(),
                                style: ButtonStyle(
                                  minimumSize: MaterialStateProperty.all(Size(140, 32)),
                                  backgroundColor: MaterialStateProperty.all(activeColor),
                                )),
                          ],
                        )
                      ],
                    ),
                  ))
                ],
              ))),
    );
  }
}
