import 'package:stacked/stacked.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/services/preferences_service.dart';

class SubscriptionViewmodel extends BaseViewModel {
  PreferencesService preferencesService = locator<PreferencesService>();
  ApiService apiService = locator<ApiService>();
  List<dynamic> subscriptionList = [];
  dynamic basicdetails={};
  dynamic yeardetails={};
  dynamic monthdetails={};
  
  Future getSubscriptionsList() async {
    setBusy(true);
    subscriptionList = await apiService.getSubscriptionsList();
    if(subscriptionList.length>0){
    basicdetails=subscriptionList[0];
    monthdetails=subscriptionList[2];
    yeardetails=subscriptionList[1];
    }
   setBusy(false);
  }
}
