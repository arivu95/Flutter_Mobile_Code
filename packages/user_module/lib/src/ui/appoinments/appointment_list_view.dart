import 'package:flutter/material.dart';
import 'package:swarapp/shared/app_colors.dart';
import 'package:swarapp/shared/app_static_bar.dart';
import 'package:swarapp/shared/screen_size.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:styled_widget/styled_widget.dart';

class AppoinmentListView extends StatefulWidget {
  AppoinmentListView({Key? key}) : super(key: key);
  @override
  _AppoinmentListViewState createState() => _AppoinmentListViewState();
}

class _AppoinmentListViewState extends State<AppoinmentListView> {
  Widget pickdate(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
          child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ElevatedButton(
              onPressed: () async {},
              child: Row(
                children: [
                  Text('Today').fontSize(17).textColor(Colors.white),
                  UIHelper.horizontalSpaceSmall,
                  Icon(
                    Icons.cancel,
                    color: Colors.white,
                    size: 25,
                  ),
                ],
              ),
              style: ButtonStyle(
                  minimumSize: MaterialStateProperty.all(Size(70, 30)),
                  backgroundColor: MaterialStateProperty.all(activeColor),
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))))),
          UIHelper.horizontalSpaceSmall,
          Text('Remove All').fontSize(15).textColor(Colors.black),
        ],
      ))
    ]);
  }

  Widget requestAcceptcard(
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('This month').fontSize(12).textColor(Colors.black),
        UIHelper.verticalSpaceSmall,
        Container(
            padding: EdgeInsets.all(5),
            width: Screen.width(context),
            decoration: UIHelper.allcornerRadiuswithbottomShadow(12, 12, 12, 12, Colors.white),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Image.asset('assets/userch2.png'),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Dr.Santhosh').fontSize(12).fontWeight(FontWeight.w600),
                    UIHelper.verticalSpaceTiny,
                    Text('Chennai').fontSize(10).fontWeight(FontWeight.w600),
                    UIHelper.verticalSpaceSmall,
                    Text('Appointment Date/time').fontSize(10).textColor(Colors.black38),
                    UIHelper.verticalSpaceTiny,
                    Text('12.07.2021 10.30 Am ').fontSize(10),
                  ],
                ),
                Column(
                  children: [
                    Text('Appointment Mode').fontSize(11).textColor(Colors.black38),
                    UIHelper.verticalSpaceSmall,
                    Row(
                      children: [
                        Icon(
                          Icons.videocam,
                          color: Colors.green,
                          size: 19,
                        ),
                        UIHelper.horizontalSpaceSmall,
                        Text('Video Consultation').fontSize(12).textColor(Colors.black),
                      ],
                    ),
                    ElevatedButton(
                        onPressed: () async {},
                        child: Row(
                          children: [
                            Text('Accepted').fontSize(10).textColor(Colors.white),
                          ],
                        ),
                        style: ButtonStyle(
                            minimumSize: MaterialStateProperty.all(Size(70, 22)),
                            backgroundColor: MaterialStateProperty.all(addToCartColor),
                            shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))))),
                  ],
                ),
              ],
            )),
      ],
    );
  }

  Widget requestAcceptcard3(
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
            padding: EdgeInsets.all(5),
            width: Screen.width(context),
            decoration: UIHelper.allcornerRadiuswithbottomShadow(12, 12, 12, 12, Colors.white),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Image.asset('assets/userch1.png'),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Dr.Sharma').fontSize(12).fontWeight(FontWeight.w600),
                    UIHelper.verticalSpaceTiny,
                    Text('Chennai').fontSize(10).fontWeight(FontWeight.w600),
                    UIHelper.verticalSpaceSmall,
                    Text('Appointment Date/time').fontSize(10).textColor(Colors.black38),
                    UIHelper.verticalSpaceTiny,
                    Text('12.07.2021 10.30 Am ').fontSize(10),
                  ],
                ),
                Column(
                  children: [
                    Text('Appointment Mode').fontSize(11).textColor(Colors.black38),
                    UIHelper.verticalSpaceSmall,
                    Row(
                      children: [
                        Icon(
                          Icons.videocam,
                          color: Colors.green,
                          size: 19,
                        ),
                        UIHelper.horizontalSpaceSmall,
                        Text('Video Consultation').fontSize(12).textColor(Colors.black),
                      ],
                    ),
                    ElevatedButton(
                        onPressed: () async {},
                        child: Row(
                          children: [
                            Text('Accepted').fontSize(10).textColor(Colors.white),
                          ],
                        ),
                        style: ButtonStyle(
                            minimumSize: MaterialStateProperty.all(Size(70, 22)),
                            backgroundColor: MaterialStateProperty.all(addToCartColor),
                            shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))))),
                  ],
                ),
              ],
            )),
        UIHelper.verticalSpaceSmall,
      ],
    );
  }

  Widget requestAcceptcard2(
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
            padding: EdgeInsets.all(5),
            width: Screen.width(context),
            decoration: UIHelper.allcornerRadiuswithbottomShadow(12, 12, 12, 12, Colors.white),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Image.asset('assets/userch1.png'),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Dr.Sharma').fontSize(12).fontWeight(FontWeight.w600),
                    UIHelper.verticalSpaceTiny,
                    Text('Chennai').fontSize(10).fontWeight(FontWeight.w600),
                    UIHelper.verticalSpaceSmall,
                    Text('Appointment Date/time').fontSize(10).textColor(Colors.black38),
                    UIHelper.verticalSpaceTiny,
                    Text('12.07.2021 10.30 Am ').fontSize(10),
                  ],
                ),
                Column(
                  children: [
                    Text('Appointment Mode').fontSize(11).textColor(Colors.black38),
                    UIHelper.verticalSpaceSmall,
                    Row(
                      children: [
                        Icon(
                          Icons.videocam,
                          color: Colors.green,
                          size: 19,
                        ),
                        UIHelper.horizontalSpaceSmall,
                        Text('Video Consultation').fontSize(12).textColor(Colors.black),
                      ],
                    ),
                    ElevatedButton(
                        onPressed: () async {},
                        child: Row(
                          children: [
                            Text('Accepted').fontSize(10).textColor(Colors.white),
                          ],
                        ),
                        style: ButtonStyle(
                            minimumSize: MaterialStateProperty.all(Size(70, 22)),
                            backgroundColor: MaterialStateProperty.all(addToCartColor),
                            shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))))),
                  ],
                ),
              ],
            )),
        UIHelper.verticalSpaceSmall,
        Text('Last month').fontSize(12).textColor(Colors.black),
      ],
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
                  UIHelper.verticalSpaceSmall,
                  UIHelper.addHeader(context, "Appointments", true),
                  UIHelper.verticalSpaceSmall,
                  Expanded(
                      child: SingleChildScrollView(
                    child: Column(
                      children: [
                        pickdate(context),
                        UIHelper.verticalSpaceMedium,
                        requestAcceptcard(context),
                        UIHelper.verticalSpaceMedium,
                        requestAcceptcard2(context),
                        UIHelper.verticalSpaceMedium,
                        requestAcceptcard3(context),
                        UIHelper.verticalSpaceMedium,
                        requestAcceptcard(context),
                      ],
                    ),
                  ))
                ],
              ))),
    );
  }
}
