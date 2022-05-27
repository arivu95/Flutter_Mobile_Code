// TODO Implement this library.
import 'package:stacked/stacked.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/services/preferences_service.dart';

class AddMemberViewmodel extends BaseViewModel {
  PreferencesService preferencesService = locator<PreferencesService>();
  ApiService apiService = locator<ApiService>();
  List<dynamic> relations = [];
  List<dynamic> countries = [];

  Future<bool> registerMember(Map<String, dynamic> postParams, String profileImagePath) async {
    setBusy(true);
    final response = await apiService.registerMember(postParams, profileImagePath);
    if (response['id'] != null) {
      preferencesService.memberInfo = response;
      preferencesService.memberId = preferencesService.memberInfo['id'];
      preferencesService.member_email = response['member_email'];
      if (response['azureBlobStorageLink'] != null) {
        String imgurl = '${ApiService.fileStorageEndPoint}${response['azureBlobStorageLink']}';
        //preferencesService.profileUrl.value = imgurl;
        preferencesService.member_profileUrl.value = imgurl;
      }
      print(response);
      //preferencesService.onRefreshRecentDocumentOnUpload!.value = true;
      // preferencesService.onRefreshRecentDocumentOnUpload!.value = true;
      // preferencesService.onRefreshRecentDocument!.refresh();
      String userId = preferencesService.userId;
      List members = await apiService.getUserMembersList(userId);
      setBusy(false);
      return true;
    } else {
      preferencesService.onRefreshRecentDocumentOnUpload!.value = true;
      //preferencesService.onRefreshRecentDocument!.value = true;
      setBusy(false);
      return false;
    }
  }

  Future updateMemberProfile(String memberId, Map<String, dynamic> memberInfo, String profileImagePath, String coverImagePath) async {
    setBusy(true);
    final response = await apiService.updateMemberProfile(memberId, memberInfo, profileImagePath, coverImagePath);
    setBusy(false);
  }

  Future getRelations() async {
    setBusy(true);
    relations = await apiService.getRelations();
    await getCountries();
    setBusy(false);
  }

  Future getCountries() async {
    setBusy(true);
    countries = await apiService.getCountries();
    setBusy(false);
  }
}
