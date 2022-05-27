import 'package:stacked/stacked.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/services/preferences_service.dart';

class OffersListViewmodel extends BaseViewModel {
  PreferencesService preferencesService = locator<PreferencesService>();
  ApiService apiService = locator<ApiService>();
  dynamic Offers = {};
  dynamic doctors_offers = {};
  dynamic selected_doctors_offers = {};
  Future getOffers() async {
    setBusy(true);
    Offers = await apiService.getoffers();
    setBusy(false);
  }

  Future getDoctorList() async {
    setBusy(true);
    String docid = preferencesService.selected_doctor_id;
    doctors_offers = await apiService.getDoctorProfile(docid);
    selected_doctors_offers = doctors_offers['offers'];
    setBusy(false);
  }
}
