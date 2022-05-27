import 'package:stacked/stacked.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/services/preferences_service.dart';

class DocListmodel extends BaseViewModel {
  PreferencesService preferencesService = locator<PreferencesService>();
  ApiService apiService = locator<ApiService>();
  List<dynamic> tempDoctorList = [];
  List<dynamic> doctorList = [];
  List<dynamic> doc_total_list = [];

  Future getDoctorList(String cat) async {
    setBusy(true);
    tempDoctorList = await apiService.getDoctorList();
    if (tempDoctorList != null) {
      List doctorstages = ['verified', 'Enhanced', 'swar doctor'];
      for (int i = 0; i < doctorstages.length; i++) {
        for (var doctors in tempDoctorList) {
          if (doctors['doctor_profile_id']['stage'] == doctorstages[i]) {
            doc_total_list.add(doctors);
          }
        }
      }
    }
    if (doc_total_list.length > 0) {
      doctorList = doc_total_list.where((e) {
        return e['specialization'].toString().toLowerCase().contains(cat.toLowerCase());
      }).toList();
    }
    for (var i = 0; i < doctorList.length; i++) {
      dynamic ratingData = await apiService.getDoctorRating();
      doctorList[i]['count'] = ratingData['patients_totalCount'].toString();
      if (ratingData['average_rating'] != null) {
        doctorList[i]['rating'] = ratingData['average_rating'].toString();
      } else {
        doctorList[i]['rating'] = '0.0';
      }
    }
    setBusy(false);
  }
}
