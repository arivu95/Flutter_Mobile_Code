import 'package:stacked/stacked.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/services/preferences_service.dart';

class RecentDownloadWidgetmodel extends BaseViewModel {
  PreferencesService preferencesService = locator<PreferencesService>();
  ApiService apiService = locator<ApiService>();
  List<dynamic> recentDownloads = [];

  Future getRecentDownloads() async {
    setBusy(true);
    String userId = preferencesService.userId;
    recentDownloads = await apiService.getRecentDownloads(userId);
    setBusy(false);
  }
}
