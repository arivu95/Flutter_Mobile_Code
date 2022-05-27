import 'package:stacked/stacked.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/services/preferences_service.dart';

class DoctorClinicViewModel extends BaseViewModel {
  PreferencesService preferencesService = locator<PreferencesService>();
  ApiService apiService = locator<ApiService>();

  
 

   Future<bool> addClinicDetails(String docId, Map<String, dynamic> postParams, List<String> docUrl, List<String> clinicUrl ) async {
    setBusy(true);
    final response = await apiService.addDoctorClinicDetails(docId, postParams, docUrl, clinicUrl);
    setBusy(false);
    return response;
  }

  Future<bool> updateDoctorClinicDetails(String docId, Map<String, dynamic> postParams, List<String> docUrl, List<String> clinicUrl ) async {
    setBusy(true);
    final response = await apiService.updateDoctorClinicDetails(docId, postParams, docUrl, clinicUrl);
    setBusy(false);
    return response;
  }

 

   Future<bool> deleteClinicDetails(String docId,String dataId) async {
    setBusy(true);
    final response = await apiService.deleteDoctorDetails(docId,dataId, 'clinic_details');
    setBusy(false);
    return response;
  }
}
