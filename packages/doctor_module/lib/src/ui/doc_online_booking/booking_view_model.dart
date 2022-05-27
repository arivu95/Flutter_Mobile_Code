import 'package:connectycube_sdk/connectycube_sdk.dart';
import 'package:extended_image/extended_image.dart';
import 'package:stacked/stacked.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/app/pref_util.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/services/preferences_service.dart';
import 'package:dio/src/multipart_file.dart' as MP1;
import 'package:jiffy/jiffy.dart';
import 'package:intl/intl.dart';

class ManageBookingsWidgetmodel extends BaseViewModel {
  PreferencesService preferencesService = locator<PreferencesService>();
  ApiService apiService = locator<ApiService>();
  dynamic profileInfo = {};
  String res = "";
  dynamic session_info = {};
  List<dynamic> specialization = [];
  String img_url = '';
  List<dynamic> countries = [];
  String coverimg_url = '';
  List<dynamic> get_session_view = [];
  dynamic doctor_details = {};
  dynamic doctor_Info = {};
  List<dynamic> calender_date_view = [];
  String get_date = '';
  List<dynamic> string_date_list = [];
  Future getSpecialization() async {
    setBusy(true);
    specialization = await apiService.getSpecialization();
    setBusy(false);
  }

  Future getUserdetail() async {
    setBusy(true);
    String getId = preferencesService.selected_doctor_info_id;
    doctor_details = await apiService.getProfile(getId);
    setBusy(false);
  }

  Future getUserProfile() async {
    setBusy(true);
    String docId = preferencesService.selected_doctor_id;
    doctor_Info = await apiService.getDoctorProfile(docId);
    setBusy(false);
  }

// Future addSession(){
// session_info=await
// }
  Future bookslot(String docId, dynamic userInfo) async {
    setBusy(true);
    String docId = preferencesService.selected_slot;
    final response = await apiService.bookAppoinment(docId, userInfo);
    if (response != null) {
      preferencesService.slot_booking_id = response['_id'];
    }
    setBusy(false);
  }

//session view_all_button

  Future viewSession(String userId, String startDate) async {
    setBusy(true);
    String userId = preferencesService.selected_doctor_info_id;

    final now = new DateTime.now();
    String formatter = DateFormat('MM-dd-y').format(now);
    String startDate = formatter.toString();
    get_session_view = await apiService.getSessionsSlots(userId, startDate);
    // get_date = get_session_view.where((e) {
    //   return e['slot_date'].contains(cat);
    // }).toList();

    for (dynamic slot in get_session_view) {
      get_date = slot['slot_date'];
      DateTime now = DateTime.parse(slot['slot_date']);
      String isoDate = now.toIso8601String();
      Jiffy fromDate_ = Jiffy(isoDate);
      String dateType = fromDate_.format('MM-dd-yyyy');
      slot['slot_date'] = dateType;
      calender_date_view = get_session_view;
      // Jiffy fromDate_ = Jiffy(get_date);
      // String date_type = fromDate_.format('MM-dd-yyyy');
    }

    // for (dynamic slot in get_session_view) {
    //   String gt = slot['slot_date'];
    //   Jiffy fromDate_ = Jiffy(gt);
    //   String m = fromDate_.format('MM-dd-yyyy');

    //   print("88888888" + m);
    // }
    setBusy(false);
  }
}
