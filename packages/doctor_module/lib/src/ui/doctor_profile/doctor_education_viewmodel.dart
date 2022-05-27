import 'package:stacked/stacked.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/services/preferences_service.dart';

class DoctorEducationInfoViewModel extends BaseViewModel {
  PreferencesService preferencesService = locator<PreferencesService>();
  ApiService apiService = locator<ApiService>();

  List<dynamic> specializations = [];
  List<dynamic> levels = [];
  List<dynamic> qualifications = [];
  List<dynamic> countries = [];
  List<dynamic> colleges = [];
  List year = [];
  Future getSpecialization() async {
    setBusy(true);

    for (int i = 1900; i < 2050; i++) {
      String value = i.toString();
      year.add(value);
    }

    specializations = await apiService.getSpecialization();
    specializations.sort((a, b) {
      //sorting in ascending order
      return a['name'].compareTo(b['name']);
    });
    await getLevels();
    await getQualification();
    await getCountry();
    setBusy(false);
  }

  Future getLevels() async {
    levels = await apiService.getLevels();
  }

  Future getQualification() async {
    qualifications = await apiService.getQualification();
    qualifications.sort((a, b) {
      //sorting in ascending order
      return a['name'].compareTo(b['name']);
    });
  }

  Future getCountry() async {
    countries = await apiService.getCollegesCountries();
  }

  Future getColleges(country) async {
    setBusy(true);
    colleges = await apiService.getCollegesList(country);
    setBusy(false);
    print(colleges);
  }

  Future<bool> addDoctorDetails(String docId, Map<String, dynamic> postParams) async {
    setBusy(true);
    String userId = preferencesService.doctor_profile_id;
    final response = await apiService.addDoctorDetails(docId, postParams, preferencesService.paths);
    await locator<ApiService>().getStageProfile(userId);
    setBusy(false);
    return response;
  }

  Future<bool> editDoctorEducation(String docId, Map<String, dynamic> postParams) async {
    setBusy(true);
    String userId = preferencesService.doctor_profile_id;
    final response = await apiService.editDoctorDetails(docId, postParams, preferencesService.paths);
    await locator<ApiService>().getStageProfile(userId);
    setBusy(false);
    return response;
  }

  Future<bool> deleteDoctorEducation(String docId, String dataId) async {
    setBusy(true);
    final response = await apiService.deleteDoctorDetails(docId, dataId, 'educational_information');
    setBusy(false);
    return response;
  }
}
