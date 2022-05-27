import 'package:connectycube_sdk/connectycube_sdk.dart';
import 'package:extended_image/extended_image.dart';
import 'package:stacked/stacked.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/app/pref_util.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/services/preferences_service.dart';
import 'package:dio/src/multipart_file.dart' as MP1;
import 'package:jiffy/jiffy.dart';

class Manageappointmentmodel extends BaseViewModel {
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
  List<dynamic> doctor_details = [];
  List<dynamic> accepted_doctor_details = [];
  dynamic doctor_Info = {};
  List<dynamic> searchlist = [];
  List<dynamic> accept_appointments = [];
  List<dynamic> calender_date_view = [];
  List<dynamic> accepted_date_view = [];
  List<dynamic> accepteddata = [];
  String get_date = '';
  List<dynamic> string_date_list = [];
  String sortMode = '';
  List<dynamic> sortList = [];
  List<dynamic> searchacceptlist = [];
  List<int> ccIds = [];
  Future getSpecialization() async {
    setBusy(true);
    specialization = await apiService.getSpecialization();
    setBusy(false);
  }

  Future getUserdetail(String listMode) async {
    setBusy(true);
    // String get_Id = preferencesService.selected_doctor_info_id;
    listMode = "Booking List";
    String userId = preferencesService.userId;
    doctor_details = await apiService.getappointment(userId, listMode);

    for (dynamic slot in doctor_details) {
      get_date = slot['slot_date'];
      DateTime now = DateTime.parse(slot['slot_date']);
      String isoDate = now.toIso8601String();
      Jiffy fromDate_ = Jiffy(isoDate);
      String dateType = fromDate_.format('MM-dd-yyyy');
      slot['slot_date'] = dateType;
      calender_date_view = doctor_details;
      // Jiffy fromDate_ = Jiffy(get_date);
      // String date_type = fromDate_.format('MM-dd-yyyy');
      accepteddata = calender_date_view.toList();
      accepteddata.removeWhere((item) => item['isBooked'] == true || item['isBlock'] == false);
    }
    searchlist = doctor_details.toList();
    setBusy(false);
  }

  void searchList(String value) {
    doctor_details = searchlist.where((e) {
      return e['patient_id']['name'].toString().toLowerCase().contains(value.toLowerCase()) ||
          e['patient_id']['swar_Id'].toString().toLowerCase().contains(value.toLowerCase()) ||
          e['patient_id']['mobilenumber'].toString().toLowerCase().contains(value.toLowerCase());
    }).toList();
    accepteddata = doctor_details;
  }

  void searchacceptList(String value) {
    doctor_details = searchacceptlist.where((e) {
      return e['patient_id']['name'].toString().toLowerCase().contains(value.toLowerCase()) ||
          e['patient_id']['swar_Id'].toString().toLowerCase().contains(value.toLowerCase()) ||
          e['patient_id']['mobilenumber'].toString().toLowerCase().contains(value.toLowerCase());
    }).toList();
    accepted_date_view = doctor_details;
  }

  Future acceptAppointment(String docId, Map<String, dynamic> userInfo) async {
    setBusy(true);
    final response = await apiService.acceptAppointment(docId, userInfo);
    setBusy(false);
  }

  Future cancelAppointment(String docId, Map<String, dynamic> userInfo) async {
    setBusy(true);
    var response = await apiService.cancelAppointment(docId, userInfo);
    setBusy(false);
  }

  Future getAcceptedList(String listMode, String cat) async {
    setBusy(true);
    // String get_Id = preferencesService.selected_doctor_info_id;
    listMode = "Accepted List";
    String userId = preferencesService.userId;
    accepted_doctor_details = await apiService.getappointment(userId, listMode);

    for (dynamic slot in accepted_doctor_details) {
      get_date = slot['slot_date'];
      DateTime now = DateTime.parse(slot['slot_date']);
      String isoDate = now.toIso8601String();
      Jiffy fromDate_ = Jiffy(isoDate);
      String dateType = fromDate_.format('MM-dd-yyyy');
      slot['slot_date'] = dateType;
      accepted_date_view = accepted_doctor_details;
      searchacceptlist = accepted_date_view.toList();
    }
    setBusy(false);
  }

  Future getPatientsDetails(String patientsId) async {
    setBusy(true);
    ccIds.clear();
    //623c00e303e5c6002e85bb0b -patients_id
    //623d47fd8f2e2e002e3e26b1
    //final patients = await apiService.getProfile('623d47fd8f2e2e002e3e26b1');
    //patients_id
    final patients = await apiService.getProfile(patientsId);
    if (patients['connectycube_id'] != null) {
      ccIds.add(int.parse(patients['connectycube_id'].toString()));
    }
    // print(ccIds.length);
    // if (ccIds.length == 0) {
    //   setBusy(false);
    // }
    setBusy(false);
  }

// }
  Future refreshView(String tab) async {
    sortList = calender_date_view.toList();
    print(sortList.toString());
    if (tab == 'request') {
      if (sortMode == 'name') {
        calender_date_view.sort((b, a) {
          return a['patient_id']['name'].toString().toLowerCase().compareTo(b['patient_id']['name'].toString().toLowerCase());
        });
      } else {
        calender_date_view.sort((a, b) {
          return a['patient_id']['name'].toString().toLowerCase().compareTo(b['patient_id']['name'].toString().toLowerCase());
        });
      }
    } else {
      if (sortMode == 'name') {
        accepted_date_view.sort((b, a) {
          return a['patient_id']['name'].toString().toLowerCase().compareTo(b['patient_id']['name'].toString().toLowerCase());
        });
      } else {
        accepted_date_view.sort((a, b) {
          return a['patient_id']['name'].toString().toLowerCase().compareTo(b['patient_id']['name'].toString().toLowerCase());
        });
      }
    }
    print(sortList.toString());
  }
}
