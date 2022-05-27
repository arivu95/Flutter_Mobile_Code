import 'package:stacked/stacked.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/services/preferences_service.dart';

class HealthProviderViewmodel extends BaseViewModel {
  PreferencesService preferencesService = locator<PreferencesService>();
  ApiService apiService = locator<ApiService>();
  String res = "";
  Future<bool> registerDoctor(Map<String, dynamic> postParams, String profileImagePath) async {
    setBusy(true);
    postParams['country'] = preferencesService.user_country;
    postParams['country_id'] = preferencesService.user_country_id;
    postParams['language '] = preferencesService.language;

    final response = await apiService.registerUser(postParams, profileImagePath);
  
    if (response == "mobilenumber already exist") {
      res = response;
      setBusy(false);
      return true;
    } else if (response == "email already exist") {
      res = "email already exist";
      setBusy(false);
      return true;
    } else {
      if (response.length == 3) {
        print(response['user'].toString());

        if (response['user'] != null) {
          res = "response data";
          preferencesService.userInfo = response['user'];
          preferencesService.userId = preferencesService.userInfo['id'];
          preferencesService.email = preferencesService.userInfo['email'];
          if (preferencesService.userInfo['azureBlobStorageLink'] != null) {
            String imgurl = '${ApiService.fileStorageEndPoint}${preferencesService.userInfo['azureBlobStorageLink']}';
            preferencesService.profileUrl.value = imgurl;
          }
         if (response['member'] != null) {
            preferencesService.memberInfo = response['member'];
            preferencesService.dropdown_user_id = preferencesService.memberInfo['id'];
            preferencesService.dropdown_user_name = preferencesService.memberInfo['member_first_name'];
          }
       setBusy(false);
          return true;
        }
      }
    }

    setBusy(false);
    return false;
  }
}
