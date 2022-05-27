import 'package:stacked/stacked.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/services/preferences_service.dart';

class DoctorMedicalRegistrationViewModel extends BaseViewModel {
  PreferencesService preferencesService = locator<PreferencesService>();
  ApiService apiService = locator<ApiService>();

  List<dynamic> states = [];
  List<dynamic> states1 = [];
  List<dynamic> country = [];
  Future getCountry() async {
    setBusy(true);
    country = await apiService.getCountryState();
    setBusy(false);
  }

  Future getState(search) async {
    setBusy(true);
    print(search);

    states1 = country.where((e) {
      return e['name'].toString().contains(search);
    }).toList();
    if (states1.length > 0) {
      for (var i = 0; i < states1.length; i++) {
        if (states1[i]['states'].isNotEmpty) {
          states = states1[i]['states'];
        }
      }
    }
    states = states1[0]['states'];
    print(states1);
    setBusy(false);
  }

  Future<bool> addDoctorRegistration(String docId, Map<String, dynamic> postParams) async {
    setBusy(true);
    String userId = preferencesService.doctor_profile_id;
    final response = await apiService.addDoctorDetails(docId, postParams, preferencesService.paths);
    await locator<ApiService>().getStageProfile(userId);
    setBusy(false);
    return response;
  }

  Future<bool> editDoctorRegistration(String docId, Map<String, dynamic> postParams) async {
    setBusy(true);
    String userId = preferencesService.doctor_profile_id;
    final response = await apiService.editDoctorDetails(docId, postParams, preferencesService.paths);
    await locator<ApiService>().getStageProfile(userId);
    setBusy(false);
    return response;
  }

  Future<bool> deleteDoctorRegistration(String docId, String dataId) async {
    setBusy(true);
    final response = await apiService.deleteDoctorDetails(docId, dataId, 'medical_registration');
    setBusy(false);
    return response;
  }
}
