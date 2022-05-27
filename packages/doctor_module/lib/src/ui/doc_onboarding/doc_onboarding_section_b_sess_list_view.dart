import 'package:doctor_module/src/ui/doc_onboarding/widgets/doc_nav_back_widget.dart';
import 'package:flutter/material.dart';
import 'package:swarapp/shared/app_bar.dart';
import 'package:swarapp/shared/screen_size.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:styled_widget/styled_widget.dart';

class DocOnboardingSectionBSessionListView extends StatefulWidget {
  DocOnboardingSectionBSessionListView({Key? key}) : super(key: key);

  @override
  _DocOnboardingSectionBSessionListViewState createState() => _DocOnboardingSectionBSessionListViewState();
}

class _DocOnboardingSectionBSessionListViewState extends State<DocOnboardingSectionBSessionListView> {
  Widget getBorder(BuildContext context) {
    return Container(
      color: Colors.black12,
      height: 1,
    );
  }

  Widget getDayMode(BuildContext context, String asseturl, String title) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: UIHelper.roundedBorderWithColorWithShadow(6, Colors.white),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 35,
                height: 35,
                child: Image.asset(asseturl),
              ),
              UIHelper.horizontalSpaceSmall,
              Text(title).fontSize(16).fontWeight(FontWeight.w600),
              UIHelper.horizontalSpaceSmall,
              Expanded(
                  child: Column(
                children: [
                  Text('9.00 am - 12.00 pm ').fontWeight(FontWeight.w600),
                  SizedBox(
                    height: 30,
                    child: SliderTheme(
                        data: SliderThemeData(thumbColor: Colors.red, rangeThumbShape: TriangleThumbShape()),
                        child: RangeSlider(
                          inactiveColor: Color(0xFFEBECED),
                          activeColor: Color(0xFFDE2128),
                          min: 0,
                          max: 1,
                          values: RangeValues(0.2, 0.8),
                          onChanged: (value) {
                            setState(() {});
                          },
                        )),
                  )
                ],
              ))
            ],
          ),
          Row(
            children: [
              Container(
                width: 35,
                height: 35,
                child: SizedBox(),
              ),
              UIHelper.horizontalSpaceSmall,
              Text('Duration').fontSize(13).fontWeight(FontWeight.w600),
              UIHelper.horizontalSpaceMedium,
              Container(
                decoration: UIHelper.roundedBorderWithColorWithShadow(6, Colors.white),
                width: 82,
                height: 32,
                // height: 21,
                child: DropdownButton<String>(
                  value: ' 10 mins',
                  //elevation: 5,
                  style: TextStyle(color: Colors.black),

                  items: <String>[' 10 mins', '30 mins'].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (value) {},
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFFFAF9F9),
        appBar: SwarAppBar(2),
        body: Container(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
              UIHelper.verticalSpaceSmall,
              DocNavBackWidget(title: 'Session Timings'),
              UIHelper.verticalSpaceSmall,
              Expanded(
                  child: SingleChildScrollView(
                child: Container(
                  width: Screen.width(context) - 24,
                  decoration: UIHelper.roundedBorderWithColor(8, Colors.white),
                  padding: EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Type').fontSize(11),
                      UIHelper.verticalSpaceSmall,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Row(
                            children: [Icon(Icons.check_box_outlined), Text('In video consulation')],
                          ),
                          Row(
                            children: [Icon(Icons.check_box_outline_blank), Text('In clinic')],
                          )
                        ],
                      ),
                      UIHelper.hairLineWidget(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            // decoration: UIHelper.roundedBorderWithColorWithShadow(6, Colors.white),
                            // width: 82,
                            height: 32,
                            // height: 21,
                            child: DropdownButton<String>(
                              value: ' Clinic Name',
                              //elevation: 5,
                              style: TextStyle(color: Colors.black),

                              items: <String>[' Clinic Name', 'Master Clinic'].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (value) {},
                            ),
                          ),
                          Row(
                            children: [
                              Text('Every weekday '),
                              UIHelper.horizontalSpaceSmall,
                              Image.asset('assets/toggle_switch.png'),
                            ],
                          )
                        ],
                      ),
                      UIHelper.hairLineWidget(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('MON'),
                          Text('TUE'),
                          Text('WED'),
                          Text('THU'),
                          Text('FRI'),
                          Text('SAT'),
                          Text('SUN'),
                        ],
                      ),
                      UIHelper.hairLineWidget(),
                      getDayMode(context, 'assets/morning_icon.png', 'Morning'),
                      UIHelper.verticalSpaceSmall,
                      getDayMode(context, 'assets/afternoon_icon.png', 'Afternoon'),
                      UIHelper.verticalSpaceSmall,
                      getDayMode(context, 'assets/evening_icon.png', 'Evening')
                    ],
                  ),
                ),
              ))
            ])));
  }
}

class TriangleThumbShape extends RangeSliderThumbShape {
  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size(30, 40);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    bool? isDiscrete,
    bool? isEnabled,
    bool? isOnTop,
    TextDirection? textDirection,
    required SliderThemeData sliderTheme,
    Thumb? thumb,
    bool? isPressed,
  }) {
    final canvas = context.canvas;
    final dx = (thumb! == Thumb.start ? center.dx + 1.0 : center.dx - 1.0);
    final dy = center.dy;
    canvas.drawCircle(
        Offset(dx, dy),
        6,
        Paint()
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke
          ..color = sliderTheme.thumbColor ?? Colors.blueAccent);
    canvas.drawCircle(Offset(dx, dy), 6, Paint()..color = Colors.white ?? Colors.blueAccent);
  }
}
