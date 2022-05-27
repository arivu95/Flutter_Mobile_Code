import 'dart:ui';

final themeColor = Color(0xfff5a623);
final primaryColor = Color(0xff203152);
final greyColor = Color(0xffaeaeae);
final greyColor2 = Color(0xffE8E8E8);
final greyColor3 = Color(0xffeaeaea);
final blueColor = Color(0xff0080ff);

final String SORT_ASC = "asc";
final String SORT_DESC = "desc";

final String USER_ARG_NAME = "user";
final String DIALOG_ARG_NAME = "dialog";

final String PARAM_SESSION_ID = 'session_id';
final String PARAM_CALL_TYPE = 'call_type';
final String PARAM_CALLER_ID = 'caller_id';
final String PARAM_CALLER_NAME = 'caller_name';
final String PARAM_CALL_OPPONENTS = 'call_opponents';
final String PARAM_IOS_VOIP = 'ios_voip';
final String PARAM_SIGNAL_TYPE = 'signal_type';

final String SIGNAL_TYPE_START_CALL = "startCall";
final String SIGNAL_TYPE_END_CALL = "endCall";
final String SIGNAL_TYPE_REJECT_CALL = "rejectCall";

class PIPConstants {
  static const double BOTTOM_PADDING_PIP = 16;
  static const double VIDEO_HEIGHT_PIP = 500;
  static const double VIDEO_TITLE_HEIGHT_PIP = 70;
}
