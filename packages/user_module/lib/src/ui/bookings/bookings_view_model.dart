import 'dart:convert';

import 'package:extended_image/extended_image.dart';
import 'package:stacked/stacked.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/services/preferences_service.dart';

class BookingsViewModel extends BaseViewModel {
  PreferencesService preferencesService = locator<PreferencesService>();
  ApiService apiService = locator<ApiService>();
  dynamic profileInfo = {};
  dynamic documentInfo = {};
  dynamic documentData = {};
  dynamic doctorId = [];

  List<dynamic> bookingsdata = [];
  List<dynamic> tempDoctorList = [];

  List<dynamic> upcommingdata = [];
  List<dynamic> previousdata = [];
  String sortMode = '';

  Future getbookingList() async {
    setBusy(true);
    String userId = preferencesService.userId;
    profileInfo = await apiService.getBookingList(userId);
    tempDoctorList = await apiService.getDoctorList();
    bookingsdata = profileInfo['booking_slot'];

    if (bookingsdata.length > 0) {
      for (int i = 0; i < bookingsdata.length; i++) {
        for (var doctor in tempDoctorList) {
          if (doctor['_id'] == bookingsdata[i]['doctor_id']) {
            bookingsdata[i]['profileData'] = doctor;
          }
        }
      }
    }
    upcommingdata = bookingsdata.toList();
    previousdata = bookingsdata.toList();
    // upcommingdata.removeWhere((item) =>  item['isBlock'] == false);
    previousdata.removeWhere((item) => item['active_flag'] == false || item['isBlock'] == true);
    setBusy(false);
  }

  void refreshView() {
    if (sortMode == 'name') {
      upcommingdata.sort((a, b) {
        return a['profileData']['name'].toString().toLowerCase().compareTo(b['profileData']['name'].toString().toLowerCase());
      });
      previousdata.sort((a, b) {
        return a['profileData']['name'].toString().toLowerCase().compareTo(b['profileData']['name'].toString().toLowerCase());
      });
    } else if (sortMode == 'date') {
      upcommingdata = bookingsdata.toList();
      previousdata = bookingsdata.toList();
      upcommingdata.removeWhere((item) => item['active_flag'] == false || item['isBooked'] == true);
      previousdata.removeWhere((item) => item['active_flag'] == false || item['isBlock'] == true);

      upcommingdata.sort((a, b) {
        return a['slot_date'].toString().toLowerCase().compareTo(b['slot_date'].toString().toLowerCase());
      });
      previousdata.sort((a, b) {
        return a['slot_date'].toString().toLowerCase().compareTo(b['slot_date'].toString().toLowerCase());
      });
    } else {
      upcommingdata = bookingsdata.toList();
      previousdata = bookingsdata.toList();
      upcommingdata.removeWhere((item) => item['active_flag'] == false || item['isBooked'] == true);
      previousdata.removeWhere((item) => item['active_flag'] == false || item['isBlock'] == true);
    }

    setBusy(false);
  }

  Future addPatientDocument(filePath, String _Id, String notes) async {
    setBusy(true);
    Map<String, dynamic> postParams = {};
    postParams['booking_id'] = _Id;
    if (notes.isNotEmpty) {
      postParams['health_issue_reason'] = notes;
    }

    final response = await apiService.addPatientDocument(postParams, filePath);
    setBusy(false);
    return true;
  }

  Future getPatientDocument(memberId, doctorId) async {
    setBusy(true);
    documentInfo = await apiService.getPatientDocument(memberId, doctorId);
    documentData = documentInfo['BookingData'];
    // print(documentData['appointment_upload_documents'].length.toString());
    setBusy(false);
  }

  Future cancelSlot(String docId, Map<String, dynamic> userInfo) async {
    setBusy(true);
    final response = await apiService.cancelBooking(docId, userInfo);
    setBusy(false);
  }

  Future doctorRatingUpdate(String docId, String points) async {
    setBusy(true);
    dynamic ratingData = {};
    ratingData['booking_id'] = docId;
    ratingData['rating_number'] = points;
    final response = await apiService.doctorRatingUpdate(ratingData);
    await getbookingList();
    setBusy(false);
  }
}
