import 'package:stacked/stacked.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/services/preferences_service.dart';

class LanguageSelectViewmodel extends BaseViewModel {
  PreferencesService preferencesService = locator<PreferencesService>();
  ApiService apiService = locator<ApiService>();
  List<dynamic> countries = [];
  List<dynamic> languages = [];

  Future getCountries() async {
    setBusy(true);
    countries = await apiService.getCountries();
    await getLanguages();
    setBusy(false);
  }

  Future getLanguages() async {
    languages = await apiService.getLanguages();
  }
}
