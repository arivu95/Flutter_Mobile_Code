import 'package:connectycube_sdk/connectycube_sdk.dart';
import 'package:extended_image/extended_image.dart';
import 'package:stacked/stacked.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/app/pref_util.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/services/preferences_service.dart';
import 'package:dio/src/multipart_file.dart' as MP1;

class EditProfileViewmodel extends BaseViewModel {
  PreferencesService preferencesService = locator<PreferencesService>();
  ApiService apiService = locator<ApiService>();
  dynamic profileInfo = {};
  String res = "";
  dynamic profile_Info = {};
  String img_url = '';
  List<dynamic> countries = [];
  String coverimg_url = '';
  Future updateUserProfile(Map<String, dynamic> userInfo, String profileImagePath, String coverImagePath) async {
    setBusy(true);
    String userId = preferencesService.userId;
    final response = await apiService.updateUserProfile(userId, userInfo, profileImagePath, coverImagePath);
    //preferencesService.userName.value = userInfo['name'];
    if (response == "mobilenumber already exist") {
      res = response;
      setBusy(false);
      return true;
    } else if (response == "email already exist") {
      res = "email already exist";
      setBusy(false);
      return true;
    } else if (response['member'] != null) {
      res = "response data";
      preferencesService.userInfo['name'] = response['member']['member_first_name'];
      if (preferencesService.dropdown_user_id == response['member']['id']) {
        preferencesService.dropdown_user_name = response['member']['member_first_name'];
        preferencesService.dropdown_user_age = response['member']['age'].toString();
        preferencesService.dropdownuserName.value = response['member']['member_first_name'];
      }
    }
    if (response['user'] != null) {
      preferencesService.userName.value = response['user']['name'];
    }
    // Update user name in connecty cube as well

    CubeUser? useragain = await SharedPrefs.getUser();
    if (useragain != null) {
      print(useragain.avatar.toString());
      useragain.fullName = userInfo['name'];
      if (profileImagePath.isNotEmpty) {
        String filename = profileImagePath.split('/').last;
        //MP1.MultipartFile getpf=  await MP1.MultipartFile.fromFile(profileImagePath, filename: filename);
        File avatarFile = await File(profileImagePath);
        CubeFile cfile = await uploadFile(avatarFile, isPublic: false);
        useragain.avatar = cfile.uid;
      }

      if (coverImagePath.isNotEmpty) {
        String filename = coverImagePath.split('/').last;
        //MP1.MultipartFile getpf=  await MP1.MultipartFile.fromFile(profileImagePath, filename: filename);
        File avatarFile = await File(coverImagePath);
        CubeFile cfile = await uploadFile(avatarFile, isPublic: false);
        useragain.avatar = cfile.uid;
      }
      // await apiService.updateConnectyCubeAvatat(useragain);
      await updateUser(useragain);
      print(useragain.fullName);
      print(useragain.avatar.toString());
    }
    apiService.getUserMembersList(userId);
    await getUserProfile(false);
    setBusy(false);
  }

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

  Future getCountries() async {
    setBusy(true);
    countries = await apiService.getCountries();
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
}
