import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swarapp/shared/app_colors.dart';
import 'package:swarapp/shared/app_static_bar.dart';
import 'package:swarapp/shared/screen_size.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:user_module/src/ui/appoinments/appointment_list_view.dart';

class CheckoutView extends StatefulWidget {
  dynamic userdata;
  CheckoutView({Key? key, this.userdata}) : super(key: key);
  @override
  _CheckoutViewState createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<CheckoutView> {
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
              Text('check out').fontSize(16).fontWeight(FontWeight.w600),
            ],
          ),
          Container(
              decoration: UIHelper.roundedLineBorderWithColor(12, fieldBgColor, 1),
              padding: EdgeInsets.all(4),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: activeColor,
                  ),
                  Text('Chennai').fontSize(12).bold(),
                ],
              )),
        ],
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
          Text('Sasidharan').fontSize(12).fontWeight(FontWeight.w600),
          UIHelper.verticalSpaceSmall,
          Text('1213,thendral nagar, tiruvannamalai,').fontSize(12).fontWeight(FontWeight.w600),
          UIHelper.verticalSpaceTiny,
          Text('Tamil nadu.').fontSize(12).fontWeight(FontWeight.w500),
          UIHelper.verticalSpaceTiny,
          Text('606601.').fontSize(12),
          UIHelper.verticalSpaceSmall,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                  onPressed: () async {},
                  child: Text('Change address').bold(),
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

  Widget appoinmentcard(
    BuildContext context,
  ) {
    return Container(
      padding: EdgeInsets.all(5),
      width: Screen.width(context),
      decoration: UIHelper.allcornerRadiuswithbottomShadow(12, 12, 12, 12, Colors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 90,
                child: Image.asset('assets/userch1.png'),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Arun').fontSize(12).fontWeight(FontWeight.w600),
                  UIHelper.verticalSpaceTiny,
                  Text('General nurse').fontSize(12).fontWeight(FontWeight.w600).textColor(Colors.black38),
                  UIHelper.verticalSpaceSmall,
                  Text('B.sc Nursing').fontSize(10).fontWeight(FontWeight.w500),
                  UIHelper.verticalSpaceTiny,
                  Text('5 years experinece').fontSize(10).textColor(Colors.black38),
                  Text('\$ 500').fontSize(14).fontWeight(FontWeight.w600),
                  Text('12%off').fontSize(12).fontWeight(FontWeight.w500).textColor(addToCartColor),
                ],
              ),
              UIHelper.horizontalSpaceMedium,
              Column(
                children: [
                  Text('Rating 4.0').fontSize(10).fontWeight(FontWeight.w500),
                  Row(
                    children: [
                      Icon(
                        Icons.star_outline_outlined,
                        size: 18,
                        color: activeColor,
                      ),
                      Icon(
                        Icons.star_outline_outlined,
                        size: 18,
                        color: activeColor,
                      ),
                      Icon(
                        Icons.star_outline_outlined,
                        size: 18,
                        color: activeColor,
                      ),
                      Icon(
                        Icons.star_outline_outlined,
                        size: 18,
                        color: activeColor,
                      ),
                      Icon(
                        Icons.star_outline_outlined,
                        size: 18,
                      ),
                    ],
                  ),
                  UIHelper.verticalSpaceSmall,
                  Row(
                    children: [
                      Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.fromLTRB(0, 0, 9, 0),
                          decoration: BoxDecoration(
                            border: Border(
                              right: BorderSide(width: 1.0),
                            ),
                          ),
                          child: Column(
                            children: [
                              Text('Date').fontSize(12).fontWeight(FontWeight.w600),
                              UIHelper.verticalSpaceSmall,
                              Text('JUly 10').fontSize(11).fontWeight(FontWeight.w600),
                            ],
                          )),
                      Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.fromLTRB(6, 0, 9, 0),
                          decoration: BoxDecoration(
                            border: Border(
                              right: BorderSide(width: 1.0),
                            ),
                          ),
                          child: Column(
                            children: [
                              Text('Time').fontSize(12).fontWeight(FontWeight.w600),
                              UIHelper.verticalSpaceSmall,
                              Text('10:00 am').fontSize(11).fontWeight(FontWeight.w600),
                            ],
                          ))
                    ],
                  ),
                ],
              ),
            ],
          ),
          UIHelper.verticalSpaceSmall,
        ],
      ),
    );
  }

  Widget pricecard(
    BuildContext context,
  ) {
    return Container(
      padding: EdgeInsets.all(10),
      width: Screen.width(context),
      decoration: UIHelper.allcornerRadiuswithbottomShadow(12, 12, 12, 12, Colors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Price Details').fontSize(12).fontWeight(FontWeight.w600),
          UIHelper.verticalSpaceSmall,
          UIHelper.hairLineWidget(borderColor: Colors.black12),
          UIHelper.verticalSpaceSmall,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Visiting charges').fontSize(12).fontWeight(FontWeight.w600),
              Text('\$ 500').fontSize(12).fontWeight(FontWeight.w600),
            ],
          ),
          UIHelper.verticalSpaceTiny,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Travelling charges').fontSize(12).fontWeight(FontWeight.w600),
              Text('Free').fontSize(12).fontWeight(FontWeight.w600),
            ],
          ),
          UIHelper.verticalSpaceSmall,
          UIHelper.hairLineWidget(borderColor: Colors.black12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Amount').fontSize(12).fontWeight(FontWeight.w600),
              Text('\$ 500').fontSize(12).fontWeight(FontWeight.w600),
            ],
          ),
          UIHelper.verticalSpaceSmall,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  Expanded(
                      child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        UIHelper.verticalSpaceSmall,
                        Text(widget.userdata['service']).fontSize(14).fontWeight(FontWeight.w600),
                        UIHelper.verticalSpaceSmall,
                        Container(
                            color: contentBgColor,
                            child: Column(
                              children: [
                                detailcard(context),
                                UIHelper.verticalSpaceSmall,
                                appoinmentcard(context),
                                UIHelper.verticalSpaceSmall,
                                pricecard(context),
                                UIHelper.verticalSpaceMedium,
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ElevatedButton(
                                        onPressed: () async {
                                          Get.to(() => AppoinmentListView());
                                        },
                                        child: Text('Conform booking').bold(),
                                        style: ButtonStyle(
                                          minimumSize: MaterialStateProperty.all(Size(140, 32)),
                                          backgroundColor: MaterialStateProperty.all(activeColor),
                                        )),
                                  ],
                                ),
                                UIHelper.verticalSpaceSmall,
                              ],
                            )),
                      ],
                    ),
                  )),
                ],
              ))),
    );
  }
}
