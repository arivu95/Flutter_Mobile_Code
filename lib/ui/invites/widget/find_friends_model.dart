import 'package:jiffy/jiffy.dart';
import 'package:stacked/stacked.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/services/dynamic_link_service.dart';
import 'package:swarapp/services/preferences_service.dart';

class FindFriendmodel extends BaseViewModel {
  PreferencesService preferencesService = locator<PreferencesService>();
  ApiService apiService = locator<ApiService>();
  dynamic getsearchedInfo = {};

  String img_url = '';
  dynamic invite_exits = '';
  List<dynamic> searchBy_lists = [];
  List<dynamic> searchBy_Contactlists = [];
  //dynamic sourceFileDates;
  Map<String, List> getSections = {};
  Map<String, List> reminderSections = {};
  dynamic reminderDates = {};
  List<dynamic> countries = [];
  void getUsers_search(String search) {
    List<dynamic> usersListStream = preferencesService.usersListStream!.value!;

    // recentFamily.add({});
    // recentFriends = memSections.where((e) {
    searchBy_lists = usersListStream.where((e) {
      return e['name'].toString().toLowerCase().contains(search.toLowerCase());
    }).toList();
    // recentFriends.add({});
    setBusy(false);
  }

  void getContact_search(String search) {
    List<dynamic> usersContactList = preferencesService.deviceContactList!.value!;

// for(var each in users_contact_list){
//  List<dynamic>  getfilterlist= each.displayName;
// }

    searchBy_Contactlists = usersContactList.where((e) {
      return e.displayName.toString().toLowerCase().contains(search.toLowerCase());
    }).toList();
  }

  Future inviteSwarUser(String userIdId) async {
    setBusy(true);
    final response = await apiService.inviteSwarUser(userIdId);
    print(response);
    setBusy(false);
  }

  Future inviteNewUser(Map<String, dynamic> postParams) async {
    setBusy(true);
    final response;
    String userId = preferencesService.userId;
    String inviteType = 'friend_invite';
    //Map<String, dynamic> postParams = {};
    // if (postParams['mobilenumber'] != null || postParams['mobilenumber'] != "") {
    //   String country = postParams['mobilenumber'];
    //   postParams['mobilenumber'] = "91" + country;
    // }
    final responseRef = await apiService.getInviteMemberRefId(userId, inviteType);
    if (responseRef['msg'] != null) {
      String postMessage = responseRef['msg'];
      if (responseRef['Invitemember'] != null) {
        dynamic inviteMember = responseRef['Invitemember'];
        String refId = inviteMember['reference_id'];
        String inviteLink = await locator<DynamicLinkService>().createMemberInviteLink(refId);
        postParams['postMessage'] = postMessage;
        postParams['inviteLink'] = inviteLink;
        postParams['user_id'] = userId;
        postParams['reference_id'] = refId;

        response = await apiService.inviteNewUser(postParams);
      }
    }

    setBusy(false);
  }

  Future getCountries() async {
    countries = await apiService.getCountries();
  }
  // Future inviteContactNewUser(String name, String email, String mobile) async {
  //   setBusy(true);
  //   final response;
  //   String userId = preferencesService.userId;
  //   Map<String, dynamic> postParams = {};
  //   final response_ref = await apiService.getInviteMemberRefId(userId);
  //   if (response_ref['msg'] != null) {
  //     String postMessage = response_ref['msg'];
  //     if (response_ref['Invitemember'] != null) {
  //       dynamic inviteMember = response_ref['Invitemember'];
  //       String refId = inviteMember['reference_id'];
  //       String inviteLink = await locator<DynamicLinkService>().createMemberInviteLink(refId);
  //       postParams['postMessage'] = postMessage;
  //       postParams['inviteLink'] = inviteLink;
  //       postParams['name'] = name;

  //       response = await apiService.inviteNewContactUser(mobile, email, postParams);
  //     }
  //   }

  //   setBusy(false);
  // }

  //
}
