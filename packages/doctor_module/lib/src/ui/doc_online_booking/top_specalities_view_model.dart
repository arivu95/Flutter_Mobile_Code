import 'package:stacked/stacked.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/services/preferences_service.dart';

class SpecialistViewmodel extends BaseViewModel {
  PreferencesService preferencesService = locator<PreferencesService>();
  ApiService apiService = locator<ApiService>();

  List<dynamic> loginRole = [];
  List<dynamic> tempDoctorList = [];
  List<dynamic> doctorList = [];
  List<dynamic> doc_total_list = [];

  Future getLoginRole() async {
    setBusy(true);
    loginRole = await apiService.getTopSpecialiation();
    await getDoctorList();
    setBusy(false);
  }

  Future getDoctorList() async {
    setBusy(true);
    tempDoctorList = await apiService.getDoctorList();
    List<dynamic> ratingData = await apiService.getDoctorRating();

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

    for (var i = 0; i < doc_total_list.length; i++) {
      for (var each in ratingData) {
        if (doc_total_list[i]['_id'] == each['doctor_id']) {
          doc_total_list[i]['count'] = each['patients_totalCount'].toString();
          if (each['average_rating'] != null) {
            doc_total_list[i]['rating'] = each['average_rating'].toString();
          } else {
            doc_total_list[i]['rating'] = '0.0';
          }
        }
      }
    }

    // for (var i = 0; i < doc_total_list.length; i++) {
    //   doc_total_list[i]['count'] = ratingData['patients_totalCount'].toString();
    //   if (ratingData['average_rating'] != null) {
    //     doc_total_list[i]['rating'] = ratingData['average_rating'].toString();
    //   } else {
    //     doc_total_list[i]['rating'] = '0.0';
    //   }
    // }
    setBusy(false);
  }

  Future getFilteredDoctor(String cat) async {
    setBusy(true);
    if (doc_total_list.length > 0) {
      doctorList = doc_total_list.where((e) {
        return e['specialization'].toString().toLowerCase().contains(cat.toLowerCase());
      }).toList();
    }
    setBusy(false);
  }
}
