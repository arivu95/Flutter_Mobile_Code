import 'dart:math';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:swarapp/shared/shimmer.dart';
import 'app_colors.dart';
import 'package:connectycube_sdk/connectycube_core.dart';

class UIHelper {
  // Vertical spacing constants. Adjust to your liking.
  static const double _VerticalSpaceVerryTiny = 1.0;
  static const double _VerticalSpaceTiny = 4.0;
  static const double _VerticalSpaceSmall = 10.0;
  static const double _VerticalSpaceMedium = 20.0;
  static const double _VerticalSpaceLarge = 60.0;
  static const double _VerticalSpaceVeryLarge = 100.0;
  static const double _VerticalSpaceNormal = 5;
  // Vertical spacing constants. Adjust to your liking.
  static const double _HorizontalSpaceTiny = 2.0;
  static const double _HorizontalSpaceSmall = 10.0;
  static const double _HorizontalSpaceMedium = 20.0;
  static const double _HorizontalSpaceLarge = 60.0;

  static const Widget VerticalSpaceVerryTiny = SizedBox(height: _VerticalSpaceVerryTiny);
  static const Widget verticalSpaceTiny = SizedBox(height: _VerticalSpaceTiny);
  static const Widget verticalSpaceSmall = SizedBox(height: _VerticalSpaceSmall);
  static const Widget verticalSpaceMedium = SizedBox(height: _VerticalSpaceMedium);
  static const Widget verticalSpaceLarge = SizedBox(height: _VerticalSpaceLarge);
  static const Widget verticalSpaceVeryLarge = SizedBox(height: _VerticalSpaceVeryLarge);
  static const Widget verticalSpaceNormal = SizedBox(height: _VerticalSpaceNormal);

  static const Widget horizontalSpaceTiny = SizedBox(width: _HorizontalSpaceTiny);
  static const Widget horizontalSpaceSmall = SizedBox(width: _HorizontalSpaceSmall);
  static const Widget horizontalSpaceMedium = SizedBox(width: _HorizontalSpaceMedium);
  static const Widget horizontalSpaceLarge = SizedBox(width: _HorizontalSpaceLarge);

  static final String SORT_ASC = "asc";
  static final String SORT_DESC = "desc";

  static final String USER_ARG_NAME = "user";
  static final String DIALOG_ARG_NAME = "dialog";

  static Widget hairLineWidget({Color borderColor = const Color(0x88A5A5A5)}) {
    return Container(
      margin: EdgeInsets.only(top: 6, bottom: 6),
      color: borderColor,
      height: 1,
    );
  }

  static Widget verticalDividerWidget({Color borderColor = const Color(0x88A5A5A5)}) {
    return new Container(
      height: 30.0,
      width: 1.0,
      color: borderColor,
      margin: const EdgeInsets.only(left: 10.0, right: 10.0),
    );
  }

  static swarPreloader() {
    return Center(
        child: HeartbeatProgressIndicator(
      child: Opacity(
        opacity: 0.7,
        child: Image.asset(
          'assets/swar_logo_grey.png',
          width: 20,
          height: 20,
        ),
      ),
    ));
  }

  static OutlineInputBorder getInputBorder(double width, {double radius: 10, Color borderColor: Colors.transparent}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(radius)),
      borderSide: BorderSide(color: borderColor, width: width),
    );
  }

  static commonTopBar(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 25, 0, 0),
      child: GestureDetector(
        onTap: () {
          Get.back();
        },
        child: Row(
          children: [
            Icon(
              Icons.arrow_back,
              size: 20,
            ),
            Text(title).bold(),
          ],
        ),
      ),
    );
  }

  static String randomString(int length) {
    var r = Random();
    const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    return List.generate(length, (index) => _chars[r.nextInt(_chars.length)]).join();
  }

  static Widget tagWidget(String value, Color color, {textColor: Colors.white, double radius: 6, double fontSize: 10}) {
    return Container(
      decoration: UIHelper.roundedBorderWithColor(radius, color),
      padding: EdgeInsets.fromLTRB(6, 2, 6, 3),
      child: Text(
        value,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize, color: textColor, shadows: [Shadow(offset: Offset(0, 1), blurRadius: 0.0, color: Colors.black26)]),
      ),
    );
  }

  static BoxDecoration roundedBorder(double radius, {Color borderColor = Colors.transparent}) {
    return BoxDecoration(borderRadius: BorderRadius.circular(radius), border: Border.all(width: 1, color: borderColor));
  }

  static BoxDecoration roundedBorderWithColor(double radius, Color backgroundColor, {Color borderColor = Colors.transparent}) {
    return BoxDecoration(borderRadius: BorderRadius.circular(radius), border: Border.all(width: 1, color: borderColor), color: backgroundColor);
  }

  static BoxDecoration roundeddisabledColor(double radius, Color backgroundColor, {Color borderColor = Colors.white}) {
    return BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(width: 1, color: Color(0xFFFAFAFA)),
        color: Color(0xFFFAFAFA),
        gradient: LinearGradient(colors: [Color(0xFFFAFAFA), Color(0xFFFAFAFA).withOpacity(0.0)], begin: FractionalOffset(0, 6), end: FractionalOffset(0, 6), stops: [0.6, 1.6], tileMode: TileMode.clamp),
        boxShadow: [
          //background color of box
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 3, // soften the shadow
            spreadRadius: 3, //extend the shadow
            offset: Offset(
              3.0, // Move to right 10  horizontally
              3.0, // Move to bottom 10 Vertically
            ),
          )
        ]);
  }

  static BoxDecoration roundedLineBorderWithColor(double radius, Color backgroundColor, double wid, {Color borderColor = Colors.transparent}) {
    return BoxDecoration(borderRadius: BorderRadius.circular(radius), border: Border.all(width: wid, color: borderColor), color: backgroundColor);
  }

  static BoxDecoration roundedActiveButtonLineBorderWithGradient(double radius, double wid, {Color borderColor = Colors.transparent}) {
    return BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, stops: [0.1, 0.9], colors: [Color(0xFFFFF7B2), Color(0xFFFFC46B)]),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(width: wid, color: borderColor));
  }

  static BoxDecoration roundedButtonWithGradient(double radius, List<Color> colors) {
    return BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, stops: [0.1, 0.5, 0.9], colors: colors), borderRadius: BorderRadius.circular(radius));
  }

  static BoxDecoration rightcornerRadiuswithColor(double alledge, double radius, Color backgroundColor) {
    return BoxDecoration(
        borderRadius: BorderRadius.only(topRight: Radius.circular(radius), topLeft: Radius.circular(alledge), bottomLeft: Radius.circular(alledge), bottomRight: Radius.circular(alledge)), color: backgroundColor);
  }

  static BoxDecoration rightcornerRadiuswithColorDoctor(double alledge, double radius, Color backgroundColor) {
    return BoxDecoration(
      borderRadius: BorderRadius.only(topRight: Radius.circular(radius), topLeft: Radius.circular(alledge), bottomLeft: Radius.circular(alledge), bottomRight: Radius.circular(alledge)),
      color: backgroundColor,
      boxShadow: [
        //background color of box
        BoxShadow(
          color: Colors.grey.shade300,
          blurRadius: 2.0, // soften the shadow
          spreadRadius: 1.0, //extend the shadow
          offset: Offset(
            2.0, // Move to right 10  horizontally
            2.0, // Move to bottom 10 Vertically
          ),
        )
      ],
    );
  }

  static BoxDecoration allcornerRadiuswithbottomShadow(double topL, double topR, double bottomL, double bottomR, Color backgroundColor, {Color borderColor = Colors.transparent, double borderWidth: 1}) {
    return BoxDecoration(
      borderRadius: BorderRadius.only(topRight: Radius.circular(topR), topLeft: Radius.circular(topL), bottomLeft: Radius.circular(bottomL), bottomRight: Radius.circular(bottomR)),
      color: backgroundColor,
      boxShadow: [
        BoxShadow(
          color: Colors.black26,
          offset: Offset(0, 1),
          blurRadius: 2.0,
        )
      ],
    );
  }

  static BoxDecoration accountCardwithShadow(double radius, double radius1, Color backgroundColor, {Color borderColor = Colors.transparent, double borderWidth: 1}) {
    return BoxDecoration(
        borderRadius: BorderRadius.only(topRight: Radius.circular(radius1), topLeft: Radius.circular(radius), bottomLeft: Radius.circular(radius), bottomRight: Radius.circular(radius)),
        border: Border.all(width: borderWidth, color: borderColor),
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 1),
            blurRadius: 2.0,
          )
        ]);
  }

  static BoxDecoration allcornerRadiuswithColor(double topL, double topR, double bottomL, double bottomR, Color backgroundColor) {
    return BoxDecoration(
      borderRadius: BorderRadius.only(topRight: Radius.circular(topR), topLeft: Radius.circular(topL), bottomLeft: Radius.circular(bottomL), bottomRight: Radius.circular(bottomR)),
      color: backgroundColor,
    );
  }

  static BoxDecoration normalbox(double radius, Color backgroundColor) {
    return BoxDecoration(border: Border.all(color: Colors.black26, width: 1), color: backgroundColor, borderRadius: BorderRadius.circular(radius));
  }

  static BoxDecoration rowSeperator(Color bgcolor) {
    return BoxDecoration(border: Border(bottom: BorderSide(color: bgcolor, width: 2)));
  }

  static BoxDecoration rowRightBorder() {
    return BoxDecoration(
      border: Border(
        right: BorderSide(width: 1.0, color: Colors.black12),
      ),
    );
  }

  static BoxDecoration roundedBorderWithColorWithShadow(double radius, Color backgroundColor, {Color borderColor = Colors.transparent, double borderWidth: 1}) {
    return BoxDecoration(borderRadius: BorderRadius.circular(radius), border: Border.all(width: borderWidth, color: borderColor), color: backgroundColor, boxShadow: [
      BoxShadow(
        color: Colors.black26,
        offset: Offset(0, 1),
        blurRadius: 2.0,
      )
    ]);
  }

  static BoxDecoration addShadow() {
    return BoxDecoration(color: Colors.white, boxShadow: [
      BoxShadow(
        color: Colors.black12,
        offset: Offset(0, 1),
        blurRadius: 2.0,
      )
    ]);
  }

  static ButtonStyle elevatedButtonStyle({Size size = const Size(80, 32)}) {
    return ButtonStyle(
        minimumSize: MaterialStateProperty.all(size),
        elevation: MaterialStateProperty.all(0),
        backgroundColor: MaterialStateProperty.all(activeColor),
        shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))));
  }

  static Color getColor(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
    };
    if (states.any(interactiveStates.contains)) {
      return Colors.blue;
    }
    return activeColor;
  }

  static Widget addHeader(BuildContext context, String title, bool isBackBtnVisible) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
      child: Row(
        children: [
          isBackBtnVisible
              ? GestureDetector(
                  onTap: () {
                    Get.back();
                  },
                  child: Icon(
                    Icons.arrow_back_outlined,
                  ),
                )
              : SizedBox(),
          Text(title).bold().fontSize(16),
          Expanded(child: SizedBox()),
        ],
      ),
    );
  }

  static String getInitials(String bankAccountName) => bankAccountName.isNotEmpty ? bankAccountName.trim().split(' ').map((l) => l[0]).take(2).join() : '';

  static ExtendedImage getProfileImageWithInitials(String imageUrl, double width, double height, String name) {
    String initials = getInitials(name);
    return ExtendedImage.network(imageUrl, width: width, height: height, cache: true, fit: BoxFit.cover, loadStateChanged: (ExtendedImageState state) {
      switch (state.extendedImageLoadState) {
        case LoadState.loading:
          return Container(
            alignment: Alignment.center,
            width: width,
            height: height,
            color: Colors.black12,
            child: Text(initials).bold(),
          );
          break;
        case LoadState.completed:
          return ExtendedRawImage(
            fit: BoxFit.cover,
            image: state.extendedImageInfo?.image,
            width: width,
            height: height,
          );
          break;
        case LoadState.failed:
          return Container(
            alignment: Alignment.center,
            color: Colors.black12,
            width: width,
            height: height,
            child: Text(initials).bold(),
          );
          break;
      }
    });
  }

  static ExtendedImage getImage(String imageUrl, double width, double height) {
    return ExtendedImage.network(imageUrl, width: width, height: height, cache: true, fit: BoxFit.cover, loadStateChanged: (ExtendedImageState state) {
      switch (state.extendedImageLoadState) {
        case LoadState.loading:
          return Container(
            width: width,
            height: height,
            color: subtleColor,
            child: Shimmer.fromColors(
              baseColor: subtleColor,
              highlightColor: activeColor,
              child: Icon(Icons.refresh),
            ),
          );
          break;
        case LoadState.completed:
          return ExtendedRawImage(
            filterQuality: FilterQuality.high,
            scale: 2.3,
            fit: BoxFit.cover,
            image: state.extendedImageInfo?.image,
            width: width,
            height: height,
          );
          break;
        case LoadState.failed:
          return Container(
            color: Colors.black12,
            width: width,
            height: height,
          );
          break;
      }
    });
  }

  static ExtendedImage getThumbnailImage(String imageUrl, double width, double height) {
    return ExtendedImage.network(imageUrl, width: width, height: height, cache: true, fit: BoxFit.cover, loadStateChanged: (ExtendedImageState state) {
      switch (state.extendedImageLoadState) {
        case LoadState.loading:
          return Container(
            width: width,
            height: height,
            color: subtleColor,
            child: Shimmer.fromColors(
              baseColor: subtleColor,
              highlightColor: activeColor,
              child: Icon(Icons.refresh),
            ),
          );
          break;
        case LoadState.completed:
          return Stack(
            children: <Widget>[
              Container(
                alignment: Alignment.center,
                child: Image.network(
                  imageUrl,
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Container(alignment: Alignment.center, child: Icon(Icons.play_circle_outlined, color: Colors.white, size: 30)),
            ],
          );
          break;
        case LoadState.failed:
          return Container(
            color: Colors.black12,
            width: width,
            height: height,
          );
          break;
      }
    });
  }

  static Widget getAvatarTextWidget(bool condition, String? text) {
    if (condition)
      return SizedBox.shrink();
    else
      return ClipRRect(
        borderRadius: BorderRadius.circular(55),
        child: Text(
          isEmpty(text) ? '?' : text!,
          style: TextStyle(fontSize: 30),
        ),
      );
  }

  static Future<dynamic> showAlertDialog(BuildContext context, String title, String message) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text(title),
          content: new Text(message),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Show toast
  static void showToast(String title) async {
    await Fluttertoast.cancel();
    Fluttertoast.showToast(
      msg: title,
      gravity: ToastGravity.BOTTOM,
      fontSize: 12,
    );
  }
}

class CustomShape extends CustomPainter {
  final Color bgColor;

  CustomShape(this.bgColor);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()..color = bgColor;

    var path = Path();
    path.lineTo(-5, 0);
    path.lineTo(0, 10);
    path.lineTo(5, 0);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
