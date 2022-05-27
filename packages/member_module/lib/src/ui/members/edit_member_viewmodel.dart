// TODO Implement this library.
import 'package:stacked/stacked.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/services/preferences_service.dart';

class EditMemberViewmodel extends BaseViewModel {
  PreferencesService preferencesService = locator<PreferencesService>();
  ApiService apiService = locator<ApiService>();
  List<dynamic> relationship = [];
  List<dynamic> countries = [];

  Future getRelationship() async {
    setBusy(true);
    relationship = await apiService.getRelations();
    setBusy(false);
  }

  Future getCountries() async {
    setBusy(true);
    countries = await apiService.getCountries();
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
}
