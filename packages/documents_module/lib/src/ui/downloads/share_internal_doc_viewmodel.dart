import 'package:stacked/stacked.dart';
import 'package:swarapp/app/api_utils.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/services/preferences_service.dart';
import 'package:connectycube_sdk/connectycube_sdk.dart';
class ShareInternalDocumentsViewModel extends BaseViewModel {
  PreferencesService preferencesService = locator<PreferencesService>();
  ApiService apiService = locator<ApiService>();
  List<dynamic> activeMembers = [];
  List<dynamic> selectedMembers = [];
  List<int> ccIds = [];
  List<CubeUser> sourceUsers = [];
  List<CubeUser> searchUsers = [];



  Future<void> getActiveMembers() async {
    List<dynamic> allMembers = preferencesService.memebersListStream!.value!;

    activeMembers = allMembers.where((element) {
      return element['is_user'] == true;
    }).toList();
    print(activeMembers);
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

    if (ccIds.length == 0) {
      setBusy(false);
    }
    //
  }

   Future getUserList(String search) async {
    Map<int, CubeUser> users = await getUsersByIds(ccIds.toSet());
    sourceUsers.clear();
    for (var user in users.values) {
      sourceUsers.add(user);
    }

    searchUsers = sourceUsers.toList();

    setBusy(false);
  }
  Future shareSelectedDocuments(List<String> docIds) async {
    String selectedDropdownid = preferencesService.userId;
    List<String> users = selectedMembers.map((e) {
      return e['_id'].toString();
    }).toList();
    Map<String, dynamic> postParams = {'document_id_array': docIds, 'receiver_id_array': users};
    final response = await apiService.userFileSharing(selectedDropdownid, postParams);
    print(response);
  }

  void filterUser(String value) {
    List<dynamic> allMembers = preferencesService.memebersListStream!.value!;

    if (value.isEmpty) {
      activeMembers = allMembers.where((element) {
        return element['is_user'] == true;
      }).toList();
    } else {
      activeMembers = allMembers.where((element) {
        String memberName = element['member_first_name'].toString();
        return element['is_user'] == true && memberName.contains(value);
      }).toList();
    }
    setBusy(false);
  }
}
