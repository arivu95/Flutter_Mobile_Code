import 'package:flutter/material.dart';

const Color backgroundColor = Color(0xFFD8B677);
const Color skipColor = Color.fromRGBO(0, 0, 255, 1);
const Color commentColor = Color.fromARGB(255, 255, 246, 196);
const Color applicationColor = Color(0xFF8dc542);
const Color greycolor = Color(0xffaeaeae);
const Color optionalColor = Color.fromRGBO(141, 141, 141, 1);
const Color camerabgColor = Color.fromRGBO(234, 234, 234, 1);
const Color activeColor = Color(0xFFDE2128);
const Color primaryColor = Color(0xFFd7b677);
const Color submitBtnColor = Color(0xFF00C064);
const Color fieldBgColor = Color(0xFFF4F4F4);
const Color blackColor = Color(0xFF000000);
final themeColor = Color(0xfff5a623);
const Color disabledColor = Color(0x331D1159);
const Color subtleColor = Color(0xFFF5F3F3);
const Color appbarColor = Color(0xFFF5F3F4);
const Color addToCartColor = Color(0xFF28a745);
const Color productBgColor = Color(0x11EEEEEE);
const Color productOfferBgColor = Color(0xFFFFE2AF);
const Color dealOfDayBgColor = Color(0xFFFFE01E);
const Color saveForLaterColor = Color(0xFF342F2F);
const Color contentBgColor = Color(0xFFF4F4F8);
const Color appdrawerColor = Color(0xFFD8B677);
const Color textColor = Color(0xFF8A0007);
const Color borderColor = Color(0xFF5A2D0C);
const Color peachColor = Color.fromRGBO(255, 236, 236, 1);
const Color leafgreen = Color.fromRGBO(0, 167, 107, 1);
const Color lightgreen = Color.fromRGBO(21, 189, 178, 1);
const Color skyblue = Color.fromRGBO(95, 159, 255, 1);
const Color deepskyblue = Color.fromRGBO(98, 95, 255, 1);
const Color orange = Color.fromRGBO(247, 144, 75, 1);
const Color darkorange = Color.fromRGBO(255, 95, 69, 1);
const Color darkblueColor = Color.fromRGBO(68, 73, 102, 1);
const Color blueshadow = Color.fromRGBO(112, 127, 150, 1);
const Color littledarkblueColor = Color.fromRGBO(134, 123, 255, 1);
const Color statusColor = Color.fromRGBO(240, 240, 240, 0.58);
const Color peachColor1 = Color.fromRGBO(253, 250, 250, 1);
const Color transparentColor = Color.fromRGBO(169, 169, 169, 0.3);
const List<Color> btnActiveColor = [Color(0xFFD6B476), Color(0xFFF3D8A7), Color(0xFFD6B476)];
const List<Color> btnTBActiveColor = [Color(0xFF338023), Color(0xFF42A230), Color(0xFF338023)];
const List<Color> btnTBInActiveColor = [Color(0xFFBF0A0A), Color(0xFFBF0A0A), Color(0xFFBF0A0A)];
const Color disablebtncolor = Color.fromRGBO(151, 151, 151, 1);
const Color bg_color = Color(0xFFE5E5E5);
const Color goldenColor = Color.fromRGBO(255, 206, 49, 1);
const Color img_badgeColor = Color.fromRGBO(22, 115, 255, 1);
const Color bookingicon = Color.fromRGBO(146, 146, 146, 1);
const Color bookingbutton = Color.fromRGBO(227, 227, 227, 1);
const Color locationColor = Color.fromRGBO(118, 194, 205, 1);
const Color acceptColor = Color.fromRGBO(3, 125, 59, 1);
const Color cancelbuttonColor = Color.fromRGBO(252, 183, 80, 1);

class ButtonColors extends MaterialStateColor {
  static const int _defaultColor = 0xFFDE2128;
  static const int _pressedColor = 0x55DE2128;

  const ButtonColors() : super(_defaultColor);

  @override
  Color resolve(Set<MaterialState> states) {
    if (states.contains(MaterialState.pressed)) {
      return const Color(_pressedColor);
    }
    return const Color(_defaultColor);
  }
}
