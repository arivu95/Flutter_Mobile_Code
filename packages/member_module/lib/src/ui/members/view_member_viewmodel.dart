import 'package:stacked/stacked.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/services/preferences_service.dart';

class MembersViewmodel extends BaseViewModel {
  PreferencesService preferencesService = locator<PreferencesService>();
  ApiService apiService = locator<ApiService>();
  dynamic profileInfo = {};
  String img_url = '';
  String coverimg_url = '';
  String notes_url = '';
    List<dynamic> recentUploads = [];

  Future getMemberProfile(memberId) async {
    setBusy(true);
    profileInfo = await apiService.get_member_Profile(memberId);
    if (profileInfo['azureBlobStorageLink'] != null) {
      img_url = '${ApiService.fileStorageEndPoint}${profileInfo['azureBlobStorageLink']}';
      preferencesService.memberInfo = profileInfo;
      preferencesService.member_profileUrl.value = img_url;
    }

    if (profileInfo['coverimg_azureBlobStorageLink'] != null) {
      coverimg_url = '${ApiService.fileStorageEndPoint}${profileInfo['coverimg_azureBlobStorageLink']}';
    }

    setBusy(false);
  }

  Future deletemember(String memberId) async {
    setBusy(true);
    final response = await apiService.deletemember(memberId);
    if (response) {
      String userId = preferencesService.userId;
      // List getmembers = await apiService.getUserMembersList(userId);
      //preferencesService.dropdown_user_id=getmembers[0]['_id'];
      List oldMembers = preferencesService.memebersListStream!.value!.toList();
      List filtr = oldMembers.where((element) => element['_id'] != memberId).toList();
      if (filtr.length > 0) {
        preferencesService.memebersListStream!.value = filtr;
        preferencesService.dropdown_user_id = filtr[0]['_id'].toString();
      }

      //  print( preferencesService.memebersListStream!.length);
      //  preferencesService.onRefreshRecentDocument!.value = true;
      //  preferencesService.onRefreshRecentDocumentOnUpload!.value = true;
      //  locator<PreferencesService>().isUploadReload.value = true;
    }

    //await  apiService.getUserMembersList(preferencesService.userId);
    setBusy(false);
    return true;
  }

    Future getRecentUploads() async {
    setBusy(true);
    String selectedDropdownid = preferencesService.dropdown_user_id;
    recentUploads = await apiService.getRecentUploads(selectedDropdownid);
    preferencesService.onRefreshRecentDocument!.value = true;
    setBusy(false);
  }

  Future updateMemberProfile(String memberId, Map<String, dynamic> memberInfo, String profileImagePath, String coverImagePath) async {
    setBusy(true);

    String userId = preferencesService.userId;

    final response = await apiService.updateMemberProfile(memberId, memberInfo, profileImagePath, coverImagePath);
    apiService.getUserMembersList(userId);

    setBusy(false);

    return true;
  }

  Future addNotes(String memberId, Map<String, dynamic> memberInfo, String filePath,notes) async {
    setBusy(true);
    if (profileInfo['notes_azureBlobStorageLink'] != null) {
      notes_url = '${ApiService.fileStorageEndPoint}${profileInfo['notes_azureBlobStorageLink']}';
    }

    String userId = preferencesService.userId;
    final response = await apiService.addNotesMemberProfile(memberId, memberInfo, filePath,notes);
    // apiService.getUserMembersList(userId);
    setBusy(false);

    return true;
  }
}
