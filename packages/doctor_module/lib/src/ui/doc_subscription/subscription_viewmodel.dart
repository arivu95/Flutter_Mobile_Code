import 'package:stacked/stacked.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/services/preferences_service.dart';

class DocSubscriptionViewmodel extends BaseViewModel {
  PreferencesService preferencesService = locator<PreferencesService>();
  ApiService apiService = locator<ApiService>();
  List<dynamic> subscriptionList = [];
  List<String> subscriptionAmount = [];

  Future getSubscriptionsList() async {
    setBusy(true);
    subscriptionList = await apiService.getSubscriptionsList();
    if (subscriptionList.length > 0) {
      for (int i = 0; i < subscriptionList.length; i++) {
        if (i > 2) {
          subscriptionAmount.add(subscriptionList[i]['amount']);
        }
      }
    }
    print(subscriptionAmount.toString());
    setBusy(false);
  }
}
