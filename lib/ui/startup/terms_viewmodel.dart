import 'package:stacked/stacked.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/services/preferences_service.dart';

class tearmsViewmodel extends BaseViewModel {
  PreferencesService preferencesService = locator<PreferencesService>();
  ApiService apiService = locator<ApiService>();
  dynamic memberloginInfo = {};

  Future memberlogin_check(memberid) async {
    setBusy(true);
    String country = preferencesService.user_country;
    String countryId = preferencesService.user_country_id;
    String language = preferencesService.language;
    memberloginInfo = await apiService.member_login(memberid, country, countryId, language);
    // Map<String, dynamic> info = Map.from(memberloginInfo);
    // if (info.keys.length > 0) {
    //   preferencesService.userInfo = memberloginInfo;
    //   preferencesService.userId = preferencesService.userInfo['id'];
    //   print('preferenceservices---------------->' + preferencesService.userInfo.toString());
    //   preferencesService.email = memberloginInfo['email'];
    // }
 String azuretoken = preferencesService.getUserInfo('token') as String;
      final response = await apiService.tokenValidation(azuretoken);
        if (response['token'] != null) {
          dynamic tokenObject = response['token'];
          if (tokenObject['accessToken'] != null) {
            await preferencesService.setUserInfo('swartoken', tokenObject['accessToken']);
            await preferencesService.setUserInfo('refreshtoken', tokenObject['refreshToken']);
          }
        }
    setBusy(false);
  }
}
