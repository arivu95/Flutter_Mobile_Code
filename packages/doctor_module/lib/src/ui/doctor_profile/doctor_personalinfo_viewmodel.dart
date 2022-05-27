import 'package:stacked/stacked.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/services/preferences_service.dart';

class DoctorPersonalinfoViewModel extends BaseViewModel {
  PreferencesService preferencesService = locator<PreferencesService>();
  ApiService apiService  = locator<ApiService>();
  String res = "";
  dynamic user = {};
  List<String> specialization = [];
  List<String> languages = [];
  List<dynamic> countries = [];

  Future getSpecialization() async {
    setBusy(true);
    List<dynamic> special = await apiService.getSpecialization();
    if (special.length > 0) {
      for (var i = 0; i < special.length; i++) {
        specialization.add(special[i]['name']);
      }

      specialization.sort((a, b) {
        //sorting in ascending order
        return a.compareTo(b);
      });
    }
    await getLanguages();
    await getProfile();
    await getCountry();
    setBusy(false);
  }

  Future getLanguages() async {
    setBusy(true);
    List<dynamic> lang = await apiService.getLanguageknown();
    if (lang.length > 0) {
      for (var i = 0; i < lang.length; i++) {
        languages.add(lang[i]['languageknown']);
      }
      languages.sort((a, b) {
        //sorting in ascending order
        return a.compareTo(b);
      });
    }
    setBusy(false);
  }

  Future getCountry() async {
    setBusy(true);
    countries = await apiService.getCountries();
    setBusy(false);
  }

  Future getProfile() async {
    setBusy(true);
    String userId = preferencesService.userId;
    user = await apiService.getProfile(userId);
    setBusy(false);
  }

  Future registerUser(Map<String, dynamic> postParams) async {
    res = "";
    setBusy(true);
    String userId = preferencesService.userId;
    final response = await apiService.updatedoctorProfile(userId, postParams, preferencesService.paths);
    if (response == "mobilenumber already exist") {
      res = response;
      setBusy(false);
      return true;
    } else if (response == "email already exist") {
      res = "email already exist";
      setBusy(false);
      return true;
    }
    await locator<ApiService>().getStageProfile(userId);
    setBusy(false);
    return false;
  }
}
