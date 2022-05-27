import 'package:stacked/stacked.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/services/preferences_service.dart';

class DoctorAoutViewModel extends BaseViewModel {
  PreferencesService preferencesService = locator<PreferencesService>();
  ApiService apiService = locator<ApiService>();
 
 
   
  Future updateAboutme(String content) async {
    Map<String, dynamic> postParams={};
      String userId = preferencesService.userId;
    postParams['aboutme']=content;
    setBusy(true);
    final response = await apiService.updateUserProfile(userId, postParams, '','');
    setBusy(false);
  }
}
