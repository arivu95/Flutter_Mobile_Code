import 'package:stacked/stacked.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/services/preferences_service.dart';

class DoctorAchievementViewModel extends BaseViewModel {
  PreferencesService preferencesService = locator<PreferencesService>();
  ApiService apiService = locator<ApiService>();
  
 List year = [];
  Future getYear() async {
     setBusy(true);
     for (int i = 1900; i < 2050; i++) {
      String value = i.toString();
      year.add(value);
    }
      setBusy(false);
  }

  Future<bool> addDoctorAchievement(String docId, Map<String, dynamic> postParams) async {
    setBusy(true);
    final response = await apiService.addDoctorDetails(docId, postParams, preferencesService.paths);
    setBusy(false);
    return response;
  }

   Future<bool> editDoctorAchievement(String docId, Map<String, dynamic> postParams) async {
    setBusy(true);
    final response = await apiService.editDoctorDetails(docId, postParams, preferencesService.paths);
    setBusy(false);
    return response;
  }

   Future<bool> deleteDoctorAchievement(String docId,String dataId) async {
    setBusy(true);
    final response = await apiService.deleteDoctorDetails(docId,dataId, 'achievement_information');
    setBusy(false);
    return response;
  }
}
