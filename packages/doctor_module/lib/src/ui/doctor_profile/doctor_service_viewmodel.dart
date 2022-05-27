import 'package:stacked/stacked.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/services/preferences_service.dart';

class DoctorServicesViewmodel extends BaseViewModel {
  PreferencesService preferencesService = locator<PreferencesService>();
  ApiService apiService = locator<ApiService>();
     
  Future updateAboutme(List<String> content) async {
      String userId = preferencesService.userId;
    Map<String, dynamic> postParams={};
    postParams['doctor_services']=content;
    setBusy(true);
    final response = await apiService.updateUserProfile(userId, postParams, '','');
    setBusy(false);
  }
}
