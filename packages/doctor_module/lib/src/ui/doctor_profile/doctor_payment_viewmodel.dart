import 'package:stacked/stacked.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/services/preferences_service.dart';

class DoctorPaymentInfoViewModel extends BaseViewModel {
  PreferencesService preferencesService = locator<PreferencesService>();
  ApiService apiService = locator<ApiService>();

  Future<bool> addDoctorPaymentDetails(String docId, Map<String, dynamic> postParams) async {
    setBusy(true);
    String userId = preferencesService.doctor_profile_id;
    final response = await apiService.addDoctorDetails(docId, postParams, []);
    await locator<ApiService>().getStageProfile(userId);
    setBusy(false);
    return response;
  }
}
