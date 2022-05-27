import 'package:stacked/stacked.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/services/preferences_service.dart';

class DocSignupViewmodel extends BaseViewModel {
  PreferencesService preferencesService = locator<PreferencesService>();
  ApiService apiService = locator<ApiService>();
  String res = "";
  Future<bool> registerDoctor(Map<String, dynamic> postParams, String profileImagePath) async {
    setBusy(true);
    postParams['country'] = preferencesService.user_country;
    postParams['country_id'] = preferencesService.user_country_id;
    postParams['language '] = preferencesService.language;
    postParams['countryCode_digits'] = preferencesService.user_country_degit;
    final response = await apiService.registerDoctor(postParams, profileImagePath);
    //if (response['user_Id'] != null) {
    // if (response['id'] != null) {

    //check mobile already exits..

    if (response == "mobilenumber already exist") {
      res = response;
      setBusy(false);
      return true;
    } else if (response == "email already exist") {
      res = "email already exist";
      setBusy(false);
      return true;
    } else {
      if (response.length == 4) {
        print(response['user'].toString());

        if (response['user'] != null) {
          res = "response data";
          preferencesService.userInfo = response['user'];
          preferencesService.userId = preferencesService.userInfo['id'];
          preferencesService.email = preferencesService.userInfo['email'];
          preferencesService.user_country_degit = preferencesService.userInfo['countryCode_digits'];

          if (preferencesService.userInfo['azureBlobStorageLink'] != null) {
            String imgurl = '${ApiService.fileStorageEndPoint}${preferencesService.userInfo['azureBlobStorageLink']}';
            preferencesService.profileUrl.value = imgurl;
          }
          if (response['subscriptionplan'] != null) {
            preferencesService.subscriptionInfo = response['subscriptionplan'];
            preferencesService.member_count = preferencesService.subscriptionInfo['member_count'];
          }
          // if (response['img_url'] != null) {
          //   String img_url = response['img_url'];
          //   preferencesService.profileUrl.value = img_url;
          // }
          if (response['doctor_profile'] != null) {
            preferencesService.doctorInfo = response['doctor_profile'];

//Future<bool> token = prefs.setString('profile_level', '');
            preferencesService.doctor_profile_id = preferencesService.doctorInfo['_id'];
          }

          //for get dropdown id , name
          if (response['member'] != null) {
            preferencesService.memberInfo = response['member'];
            preferencesService.dropdown_user_age = preferencesService.memberInfo['age'].toString();
            preferencesService.dropdown_user_id = preferencesService.memberInfo['id'];
            preferencesService.dropdown_user_name = preferencesService.memberInfo['member_first_name'];
            print('preferenceservices-------->' + response['member'].toString());
            print('preferenceservices-------->' + preferencesService.dropdown_user_id.toString());
            print('preferenceservices- USER NAME------->' + preferencesService.dropdown_user_name.toString());
          }
          String tokenGet = await locator<PreferencesService>().getUserInfo('token');
          final respToken = await apiService.tokenValidation(tokenGet);

          if (respToken['token'] != null) {
            dynamic tokenObject = respToken['token'];
            if (tokenObject['accessToken'] != null) {
              await preferencesService.setUserInfo('swartoken', tokenObject['accessToken']);
              await preferencesService.setUserInfo('refreshtoken', tokenObject['refreshToken']);
            } else {
              return false; // If the token doesn't exist, then sending the failed state
            }
          }

          print('call regist------------>');
          print(response.length);
          setBusy(false);
          return true;
        }
      }
    }

    setBusy(false);
    return false;
  }
}
