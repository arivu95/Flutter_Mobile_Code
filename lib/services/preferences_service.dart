import 'dart:async';
import 'package:connectycube_sdk/connectycube_sdk.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/frideos/streamed_list.dart';
import 'package:swarapp/frideos/streamed_map.dart';
import 'package:swarapp/frideos/streamed_value.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/ui/communication/conversation_screen_overlay_widget.dart';
import 'package:swarapp/ui/startup/terms_view.dart';
import 'package:swarapp/ui/subscription/subscription_view.dart';

class PreferencesService {
  String userId = '';
  String login_roleId = '';
  String email = '';
  String phone = '';
  String language = '';
  String user_country = '';
  String user_country_id = '';
  String user_country_flag = '';
  String user_country_degit = '';
  bool isPhoneLogin = false;
  bool isEmailLogin = false;
  String health_provider_role = '';
  String doctor_profile_id = '';
  String user_login = '';
  String select_upload = '';
  String current_index = '';
  String subPlan = '';
  String upload_index = '';
  String click_skip = '';
  String selected_doctor_id = '';
  String selected_doctor_info_id = '';
  String slot_booking_id = '';
  String selected_role = '';
  String select_online = '';
  String select_inclinic = '';
  String offers_id = '';
  String offers_type = '';
  String selected_offers = '';
  String consult_fee = '';
  String selected_slot = '';
  String selected_date = '';
  String Selected_time = '';
  String Final_amount = '';
  int tempappbarIndex = 0;
  String Final_discount = '';
  String Final_fees = '';
  String request_chat = '';
  //Dynamic link ref id
  String RefId = '';
  String dropdown_user_id = '';
  String dropdown_user_name = '';
  String dropdown_user_dob = '';
  String dropdown_user_age = '';
  String dropdown_user_pragnancy_date = '';
  String dropdown_user_vaccine_date = '';
  String isbgCallString = '';
  String device_token = '';
  //memberinformation
  String memberId = '';
  String member_email = '';
  String member_phone = '';
  String member_count = '';
  late CubeDialog newDialog;
  bool isNewGroupCreated = false;
  bool isSignout = false;
  bool isbgCall = false;
  bool vac_date_is_empty = false;
  String selectedCourrency = 'INR';
  String selectedCourrencySymbol = '\u{20B9}';
  //bool isUserSubscribed = false;
  String notificationCount = '';
  String select_services = '';
//dropdown
  Map<String, dynamic> dropdown_userInfo = {};
  List<dynamic> doctors_offers = [];

//user
  Map<String, dynamic> userInfo = {};

//doctor
  Map<String, dynamic> doctorInfo = {};

  // Map<String, dynamic> subscriptionInfo = {};
  List<String> paths = [];
  Map<String, dynamic> thumbnail_paths = {};
  StreamedValue<String> profileUrl = StreamedValue<String>(initialData: '');
  StreamedValue<String> notificationStreamCount = StreamedValue<String>(initialData: '');
  final downloadMessage = StreamedValue<String>(initialData: '');
  RxBool isConsultationCall = false.obs;
  String isConsultationVerified = "";
  RxBool isReload = false.obs;
  RxBool isUploadReload = false.obs;
  RxBool isDownloadReload = false.obs;
  RxBool ischatListReload = false.obs;
  RxBool isBg = false.obs;
  RxBool isNotification = false.obs;
  RxBool isReloadFeed = false.obs;
  RxBool isConsultantCall = false.obs;

//member
  Map<String, dynamic> memberInfo = {};
  List<String> member_paths = [];
  List<dynamic> servicesStream = [];
  RxString member_profileUrl = ''.obs;
  final member_downloadMessage = StreamedValue<String>(initialData: '');
  RxBool member_isReload = false.obs;
  dynamic alertContentList = {};
  List<dynamic>? bookingList = [];
  StreamedList<dynamic>? memebersListStream = StreamedList<dynamic>(initialData: []);
  List<dynamic> manage_type_bar = [];
  StreamedList<dynamic>? servicesListStream = StreamedList<dynamic>(initialData: []);
  StreamedList<dynamic>? usersServiceListStream = StreamedList<dynamic>(initialData: []);
  StreamedValue<String> userName = StreamedValue<String>(initialData: '');
  StreamedValue<String> dropdownuserName = StreamedValue<String>(initialData: '');
  StreamedList<dynamic>? recentdocListStream = StreamedList<dynamic>(initialData: []);
  StreamedList<dynamic>? friendsListStream = StreamedList<dynamic>(initialData: []);
  StreamedList<dynamic>? recentMembersListStream = StreamedList<dynamic>(initialData: []);
  StreamedList<dynamic>? notificationListStream = StreamedList<dynamic>(initialData: []);
  StreamedList<dynamic>? doctorsListStream = StreamedList<dynamic>(initialData: []);
  StreamedValue<String> doctorStageValue = StreamedValue<String>(initialData: '');
  StreamedList<dynamic>? usersListStream = StreamedList<dynamic>(initialData: []);
  StreamedList<dynamic>? userInviteListStream = StreamedList<dynamic>(initialData: []);
  StreamedList<dynamic>? contactusersListStream = StreamedList<dynamic>(initialData: []);
  StreamedList<dynamic>? deviceContactList = StreamedList<dynamic>(initialData: []);
  StreamedList<dynamic>? clinicListStream = StreamedList<dynamic>(initialData: []);
  //StreamedList<dynamic>? servicesStream = StreamedList<dynamic>(initialData: []);
  final List<String> productIds = [
    'com.kat.swarapp.monthly',
    'com.kat.swarapp.yearly',
    'com.kat.swarapp.enhanced.monthly',
    'com.kat.swarapp.enhanced.yearly',
    'com.kat.swarapp.proffessional.monthly',
    'com.kat.swarapp.proffessional.yearly',
  ];
  final Map<String, String> subscriptionDuration = {'P1W': 'One Week', 'P1M': 'One Month', 'P3M': 'Three Months', 'P1Y': 'One Year'};
  final StreamedMap<String, dynamic> subscriptionStream = StreamedMap<String, dynamic>(initialData: {});

  // Listener actions
  StreamedValue<bool>? onRefreshRecentDocument;
  StreamedValue<bool>? onRefreshRecentDocumentOnUpload;
  StreamedValue<bool>? onRefreshRecentDocumentOnDownload;
  StreamedValue<bool>? onRefreshRecentDocumentFromTable;
  StreamedValue<int>? onRefreshActivityfeed;

  StreamedValue<bool>? onRefreshDownloadDocumentFromTable;
  StreamedValue<AppLifecycleState>? appCycleState = StreamedValue<AppLifecycleState>(initialData: AppLifecycleState.inactive);

  //////////////////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////////
  /// PIP RELATED
  /////////////////////////////////////////////////////////////////////////////////
  StreamedValue<bool>? inPipMode = StreamedValue(initialData: false);
  OverlayEntry? overlayEntry;
  double _aspectRatio = 1.77;
  get overlayActive => overlayEntry != null;
  get aspectRatio => _aspectRatio;

  // bottom tab key
  GlobalKey bottomTab_globalKey = new GlobalKey(debugLabel: 'bottom_bar_index');
  PreferencesService();

//subscription for
  Map<String, dynamic> subscriptionInfo = {};
  Map<String, dynamic> BookingInfo = {};

//doctor profile stage level
  int stage_level_count = 0;

  void initRefreshRecentDocument() {
    onRefreshRecentDocument = StreamedValue<bool>(initialData: false);
  }

  void initRefreshRecentDocumentOnUpload() {
    onRefreshRecentDocumentOnUpload = StreamedValue<bool>(initialData: false);
  }

  void initRefreshRecentDocumentOnDownload() {
    onRefreshRecentDocumentOnDownload = StreamedValue<bool>(initialData: false);
  }

  void initRefreshRecentDocumentFromTable() {
    onRefreshRecentDocumentFromTable = StreamedValue<bool>(initialData: false);
  }

  void initRefreshActivityfeed() {
    onRefreshActivityfeed = StreamedValue<int>(initialData: 0);
  }

  void initDownloadDocuments() {
    onRefreshDownloadDocumentFromTable = StreamedValue<bool>(initialData: false);
  }

  // Check if the user is logged In
  Future<bool> isUserLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('userkey') ?? '';
    if (token != '') {
      return true;
    }
    return false;
  }

  String getUserProfileImageUrl() {
    if (userInfo['azureBlobStorageLink'] != null) {
      String imgurl = '${ApiService.fileStorageEndPoint}${userInfo['azureBlobStorageLink']}';
      profileUrl.value = imgurl;
      return imgurl;
    }
    return '';
  }

  bool isSubscriptionMarkedInSwar() {
    if (subscriptionStream.value!['productId'] != null) {
      String productId = subscriptionStream.value!['productId'].toString().toLowerCase();
      if (productIds.contains(productId)) {
        return true;
      }
    }
    return false;
  }

  // Subscription
  String getCurrentSubscriptionPlanImage() {
    if (isSubscriptionMarkedInSwar()) {
      return "vip_icon.png";
    }
    return "cr.png";
  }

//member
  String getMemberProfileImageUrl() {
    if (memberInfo['azureBlobStorageLink'] != null) {
      String imgurl = '${ApiService.fileStorageEndPoint}${userInfo['azureBlobStorageLink']}';
      member_profileUrl.value = imgurl;
      return imgurl;
    }
    return '';
  }

  Future<bool> setUserInfo(String key, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
    return true;
  }

  //invite reference id
  Future<bool> setRefId(String key, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
    await locator<ApiService>().checkRefId(preferencesService.userId, value);
    Future.delayed(Duration(milliseconds: 1000), () {
      print(preferencesService.onRefreshActivityfeed!.value);
      preferencesService.onRefreshActivityfeed!.value = preferencesService.onRefreshActivityfeed!.value! + 1;
    });
    return true;
  }

  Future<String> getRefId(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String refid = prefs.getString(key) ?? '';
    if (refid != '') {
      return refid;
    }
    return '';
  }

  //member
  Future<bool> setMemberInfo(String key, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
    return true;
  }

  Future<String> getUserInfo(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userid = prefs.getString(key) ?? '';
    if (userid != '') {
      return userid;
    }
    return '';
  }

  //member
  Future<String> getMemberInfo(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userid = prefs.getString(key) ?? '';
    if (userid != '') {
      return userid;
    }
    return '';
  }

  Future<bool> clearUserInfo(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
    return true;
  }

  //member
  Future<bool> clearMemberInfo(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
    return true;
  }

  //Subscription popup date
  Future<bool> setPopupInfo(String key, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
    return true;
  }

  Future<String> getPopupInfo(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String date = prefs.getString(key) ?? '';
    if (date != '') {
      return date;
    }
    return '';
  }

  Future showSubscriptionPopup(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String popupShow = '';
    String dateShow = '';
    int seconds = 0;
    dateShow = await locator<PreferencesService>().getPopupInfo('date');
    DateTime currentDate = DateTime.now();

    if (dateShow.isNotEmpty) {
      DateTime startDate = DateTime.parse(dateShow);
      seconds = currentDate.difference(startDate).inSeconds;
    }

    if (dateShow.isEmpty || seconds > 1800) {
      //------24 hours(24*60*60)= 86400 seconds------\\
      await preferencesService.setPopupInfo('popupShow', 'true');
    } else {
      await preferencesService.setPopupInfo('popupShow', 'false');
    }

    popupShow = await locator<PreferencesService>().getPopupInfo('popupShow');
    if (popupShow == "true" && subscriptionInfo['productId'] == "com.kat.swarapp.basic") {
      _subscriptionAlertBox(context);
    }
  }

  Future<List<dynamic>> setServices() async {
    manage_type_bar = [];
    for (var getSeparate in preferencesService.servicesStream) {
      if (getSeparate != "Chat") {
        manage_type_bar.add({
          "containertype": getSeparate == "In clinic" ? "1" : "2",
          "container_name": getSeparate.toString().toLowerCase(),
          "stagetitle": getSeparate,
          "barImage": getSeparate == "In clinic"
              ? "assets/clinic.png"
              : getSeparate == "Online"
                  ? "assets/online_img.png"
                  : "assets/home_visit_img.png"
        });
      }
    }
    return manage_type_bar;
  }

  Future<void> _subscriptionAlertBox(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          dynamic data = {'isload': true};
          return SubscriptionView(data: data);
        });
  }

  Future cleanAllPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('oid');
    await prefs.remove('userkey');
    await prefs.remove('countryCode');
    await prefs.remove('swartoken');
    await prefs.remove('refreshtoken');
    await prefs.remove('popupShow');
    await prefs.remove('date');
    await prefs.remove('profile_id');
    await prefs.remove('profile_level');

    phone = '';
    email = '';
    isEmailLogin = false;

    isPhoneLogin = false;
    profileUrl.value = '';
    userName.value = '';
    notificationStreamCount.value = '';
    stage_level_count = 0;
    doctorStageValue.value = '';
    userInfo = {};
    dropdown_user_name = '';
    device_token = '';
    click_skip = '';
    select_upload = '';
  }

  //call the feed dynamic
  Future call_feeds() async {
    Timer _timer;
    // Timer.periodic(Duration(seconds: 20), (timer) async {
    //   String is_swarToken = await locator<PreferencesService>().getUserInfo('swartoken');
    //   if (is_swarToken.isNotEmpty) {
    //      preferencesService.onRefreshActivityfeed!.value = preferencesService.onRefreshActivityfeed!.value! + 1;
    //   } else {
    //     timer.cancel();
    //   }
    // });
  }

  //////////////////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////////
  /// PIP RELATED
  /////////////////////////////////////////////////////////////////////////////////
  enablePip(double aspect) {
    inPipMode!.value = true;
    _aspectRatio = aspect;
    print("$inPipMode enablePip");
  }

  disablePip() {
    inPipMode!.value = false;
    print("$inPipMode disablePip");
  }

  insertOverlay(BuildContext context, OverlayEntry overlay) {
    if (overlayEntry != null) {
      overlayEntry!.remove();
    }
    overlayEntry = null;
    inPipMode!.value = false;
    Overlay.of(context)!.insert(overlay);
    overlayEntry = overlay;
  }

  removeOverlay(BuildContext context) {
    if (overlayEntry != null) {
      overlayEntry!.remove();
    }
    overlayEntry = null;
  }

  //
  addAudioCallOverlay(BuildContext context, P2PSession session, bool isIncoming) {
    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => ConversationScreenOverlayWidget(
        onClear: () {
          removeOverlay(context);
        },
        session: session,
        isIncoming: isIncoming,
      ),
    );
    insertOverlay(context, overlayEntry);
  }
}
