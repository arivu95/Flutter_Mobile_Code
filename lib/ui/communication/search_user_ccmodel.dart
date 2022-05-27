import 'package:connectycube_sdk/connectycube_sdk.dart';
import 'package:stacked/stacked.dart';
import 'package:swarapp/app/api_utils.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/services/preferences_service.dart';

class SearchUserCCModel extends BaseViewModel {
  PreferencesService preferencesService = locator<PreferencesService>();
  ApiService apiService = locator<ApiService>();
  // List<String> memberIds = [];
  List<int> ccIds = [];
  List<CubeUser> sourceUsers = [];
  List<CubeUser> searchUsers = [];
  // bool _isDialogContinues = false;

  Future getUserList(String search) async {
    print(ccIds.length);
    Map<int, CubeUser> users = await getUsersByIds(ccIds.toSet());
    sourceUsers.clear();
    for (var user in users.values) {
      sourceUsers.add(user);
    }

    searchUsers = sourceUsers.toList();

    setBusy(false);
  }

  Future filterUser(String search) async {
    searchUsers = sourceUsers.where((element) {
      return element.fullName!.toLowerCase().contains(search.toLowerCase());
    }).toList();
    setBusy(false);
  }

  Future getRecentMembers() async {
    setBusy(true);
    String userId = preferencesService.userId;
    final members = await apiService.getRecentMembers(userId);
    final recentMembers = members.expand((i) => i).toList();

    // memberIds = recentMembers.map((e) {
    //   return 'custom_' + e['user_Id'].toString();
    // }).toList();
    // print(memberIds);
    ccIds.clear();
    for (var member in recentMembers) {
      if (member['connectycube_id'] != null) {
        ccIds.add(int.parse(member['connectycube_id'].toString()));
      }
    }
print(ccIds.length);
    if (ccIds.length == 0) {
      setBusy(false);
    }
    //
  }
}
