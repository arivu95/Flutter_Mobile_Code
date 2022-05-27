import 'package:stacked/stacked.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/app/pref_util.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/services/preferences_service.dart';
import 'package:connectycube_sdk/connectycube_sdk.dart';

class ProfileViewmodel extends BaseViewModel {
  PreferencesService preferencesService = locator<PreferencesService>();
  ApiService apiService = locator<ApiService>();
  dynamic profile_Info = {};
  String img_url = '';
  String coverimg_url = '';
  List<dynamic> countries = [];
  List<dynamic> recentUploads = [];

  Future getUserProfile(bool isUpdateprofile) async {
    setBusy(true);
    String userId = preferencesService.userId;
    profile_Info = await apiService.getProfile(userId);
    if (profile_Info['azureBlobStorageLink'] != null) {
      img_url = '${ApiService.fileStorageEndPoint}${profile_Info['azureBlobStorageLink']}';
      preferencesService.userInfo = profile_Info;
      preferencesService.profileUrl.value = img_url;

      print(preferencesService.getUserProfileImageUrl());
    }

    if (profile_Info['coverimg_azureBlobStorageLink'] != null) {
      coverimg_url = '${ApiService.fileStorageEndPoint}${profile_Info['coverimg_azureBlobStorageLink']}';
    }
    setBusy(false);
  }

  Future getRecentUploads() async {
    setBusy(true);
    String selected_dropdownid = preferencesService.dropdown_user_id;
    recentUploads = await apiService.getRecentUploads(selected_dropdownid);
    preferencesService.onRefreshRecentDocument!.value = true;
    setBusy(false);
  }

  Future addStatus(String status) async {
    // setBusy(true);
    Map<String, dynamic> postParams = {};
    String userId = preferencesService.userId;
    String name = preferencesService.userInfo['name'];
    if (status.isNotEmpty) {
      postParams['profilestatus'] = status;
    }
    postParams['user_Id'] = userId;
    postParams['name'] = name;
    Map<String, dynamic> newComment = {'profilestatus': status, 'user_Id': userId, 'name': name};
    final response = await apiService.addstatus(postParams);
    preferencesService.onRefreshRecentDocument!.value = true;
    await getUserProfile(false);
    setBusy(false);
  }

  Future updatePreferdNumber(Map<String, dynamic> userInfo, String profileImagePath, String coverImagePath) async {
    setBusy(true);
    String userId = preferencesService.userId;
    final response = await apiService.updateUserProfile(
      userId,
      userInfo,
      profileImagePath.isNotEmpty ? profileImagePath : '',
      coverImagePath.isNotEmpty ? coverImagePath : '',
    );
    //emergency_doctor_number
    //emergency_clinic_number
    await getUserProfile(false);
    setBusy(false);
  }

  Future getCountries() async {
    setBusy(true);
    countries = await apiService.getCountries();
    setBusy(false);
  }
}
