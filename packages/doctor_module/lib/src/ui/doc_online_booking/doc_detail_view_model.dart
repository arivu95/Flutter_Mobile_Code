import 'package:stacked/stacked.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/services/preferences_service.dart';

class DocDetailmodel extends BaseViewModel {
  PreferencesService preferencesService = locator<PreferencesService>();
  ApiService apiService = locator<ApiService>();
  dynamic doctor_Info = {};
  dynamic doctor_details = {};
  String img_url = '';
  String coverimg_url = '';
  String get_id = '';

  Future getUserProfile() async {
    setBusy(true);
    String docId = preferencesService.selected_doctor_id;
    doctor_Info = await apiService.getDoctorProfile(docId);
    setBusy(false);
  }

  Future getUserdetail() async {
    setBusy(true);
    String getId = preferencesService.selected_doctor_info_id;
    doctor_details = await apiService.getProfile(getId);
    setBusy(false);
  }
}
