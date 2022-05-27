import 'package:stacked/stacked.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/services/preferences_service.dart';

class MembersViewmodel extends BaseViewModel {
  PreferencesService preferencesService = locator<PreferencesService>();
  ApiService apiService = locator<ApiService>();
  dynamic profileInfo = {};
  dynamic inviteInfo = {};
  String img_url = '';

  Future getMemberProfile(memberId) async {
    setBusy(true);
    
    profileInfo = await apiService.get_member_Profile(memberId);
    if (profileInfo['azureBlobStorageLink'] != null) {
      img_url = '${ApiService.fileStorageEndPoint}${profileInfo['azureBlobStorageLink']}';
      preferencesService.memberInfo = profileInfo;
      preferencesService.member_profileUrl.value = img_url;
    }
    setBusy(false);
  }
  


Future getInviteMember(String mailId) async {
    setBusy(true);
    String userId = preferencesService.userId;
    inviteInfo = await apiService.getInviteMember(userId,mailId);
    print('-----------INVITE INFRO---'+inviteInfo.toString());
    // if (inviteInfo['rejected'] != null) {
     
    // }
    setBusy(false);
  }

  Future getInviteMemberMobile(String mobile) async {
    setBusy(true);
    String userId = preferencesService.userId;
    inviteInfo = await apiService.getInviteMemberMobile(userId,mobile);
    print('-----------INVITE INFRO---'+inviteInfo.toString());
    // if (inviteInfo['rejected'] != null) {
     
    // }

    setBusy(false);
  }



}
