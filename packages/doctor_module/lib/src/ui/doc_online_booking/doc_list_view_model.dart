import 'package:stacked/stacked.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/services/preferences_service.dart';

class DoclistViewmodel extends BaseViewModel {
  PreferencesService preferencesService = locator<PreferencesService>();
  ApiService apiService = locator<ApiService>();
  List<dynamic> loginRole = [];
  List<dynamic> healthproviders = [];

  Future getLoginRole() async {
    setBusy(true);
    loginRole = await apiService.getSpecialization();
    await getProviderRole();
    setBusy(false);
  }

  Future getProviderRole() async {
    healthproviders = await apiService.gethealthproviders();
  }
}
