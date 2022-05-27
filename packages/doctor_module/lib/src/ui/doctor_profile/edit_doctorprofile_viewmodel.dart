import 'package:connectycube_sdk/connectycube_sdk.dart';
import 'package:extended_image/extended_image.dart';
import 'package:stacked/stacked.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/app/pref_util.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/services/preferences_service.dart';

class EditProfileViewmodel extends BaseViewModel {
  PreferencesService preferencesService = locator<PreferencesService>();
  ApiService apiService = locator<ApiService>();
  dynamic profileInfo = {};
  Future updateUserProfile(Map<String, dynamic> userInfo, String profileImagePath) async {
    setBusy(true);
    String userId = preferencesService.userId;
    final response = await apiService.updateUserProfile(userId, userInfo, profileImagePath,'');
    if (response['member'] != null) {
      if (preferencesService.dropdown_user_id == response['member']['id']) {
        preferencesService.dropdown_user_name = response['member']['member_first_name'];
        preferencesService.dropdown_user_age = response['member']['age'].toString();
      }
    }
  CubeUser? useragain = await SharedPrefs.getUser();
    if (useragain != null) {
      print(useragain.avatar.toString());
      useragain.fullName = userInfo['name'];
      if (profileImagePath.isNotEmpty) {
        String filename = profileImagePath.split('/').last;
        File avatarFile = File(profileImagePath);
        CubeFile cfile = await uploadFile(avatarFile, isPublic: false);
        useragain.avatar = cfile.uid;
      }
      await updateUser(useragain);
      print(useragain.fullName);
      print(useragain.avatar.toString());
    }
    apiService.getUserMembersList(userId);
    setBusy(false);
  }
}
