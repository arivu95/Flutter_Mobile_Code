import 'package:stacked/stacked.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/services/preferences_service.dart';

class FeesandOffersModel extends BaseViewModel {
  PreferencesService preferencesService = locator<PreferencesService>();
  ApiService apiService = locator<ApiService>();

  dynamic doctorDetails = {};
  String documentId = '';
  List<dynamic> servicesList = [];
  List<dynamic> offersList = [];

  Future getDoctorFees() async {
    setBusy(true);
    servicesList.clear();
    String userId = preferencesService.userId;
    final response = await apiService.getDoctorDetails(userId);

    doctorDetails = response.first;
    documentId = doctorDetails['_id'];
    if (doctorDetails['services'] != null) {
      final res = await apiService.getProfile(userId);

      for (int i = 0; i < res['doctor_services'].length; i++) {
        for (var each in doctorDetails['services']) {
          if (each['services_type'] == res['doctor_services'][i]) {
            servicesList.add(each);
          }
        }
      }

      if (servicesList.length > 0) {
        for (int i = 0; i < servicesList.length; i++) {
          if (servicesList[i]['fees'] != null && servicesList[i]['fees'] != '') {
            double amt = double.parse(servicesList[i]['fees']);
            var convertAmount = await currencyConveter('INR', preferencesService.selectedCourrency, amt);
            servicesList[i]['fees'] = convertAmount.toString();
          }

          if (servicesList[i]['final_amount'] != null && servicesList[i]['final_amount'] != '') {
            double amt = double.parse(servicesList[i]['final_amount']);
            var convertAmount = await currencyConveter('INR', preferencesService.selectedCourrency, amt);
            servicesList[i]['final_amount'] = convertAmount.toString();
          }
        }
      }
    }
    if (doctorDetails['offers'] != null) {
      offersList = doctorDetails['offers'];
      offersList.removeWhere((item) => item['active_flag'] == false);

      if (offersList.length > 0) {
        for (int i = 0; i < offersList.length; i++) {
          if (offersList[i]['offer_amount'] != null && offersList[i]['offer_amount'] != '') {
            double amt = double.parse(offersList[i]['offer_amount']);
            var convertAmount = await currencyConveter('INR', preferencesService.selectedCourrency, amt);
            offersList[i]['offer_amount'] = convertAmount.toString();
          }
        }
      }
    }

    setBusy(false);
  }

  Future currencyConveter(String from, String to, double amount) async {
    setBusy(true);
    final response = await apiService.currencyConveter(from, to, amount);
    setBusy(false);
    return response;
  }

  Future updateFeesTable(dynamic feesData) async {
    setBusy(true);
    feesData['doctor_Id'] = preferencesService.userId;
    feesData['services_id'] = feesData['_id'];
    feesData['profile_information'] = 'services';

    if (feesData['fees'] != null && feesData['fees'] != '') {
      double amt = double.parse(feesData['fees']);
      var convertAmount = await currencyConveter(preferencesService.selectedCourrency, 'INR', amt);
      feesData['fees'] = convertAmount.toString();
    }

    if (feesData['final_amount'] != null && feesData['final_amount'] != '') {
      double amt = double.parse(feesData['final_amount']);
      var convertAmount = await currencyConveter(preferencesService.selectedCourrency, 'INR', amt);
      feesData['final_amount'] = convertAmount.toString();
    }

    doctorDetails = await apiService.updateFeesTable(feesData, documentId);
    setBusy(false);
  }

  Future addOfferData(dynamic offerData, String path) async {
    setBusy(true);
    offerData['doctor_Id'] = preferencesService.userId;
    offerData['profile_information'] = 'offers';

    if (offerData['offer_amount'] != null && offerData['offer_amount'] != '') {
      double amt = double.parse(offerData['offer_amount']);
      var convertAmount = await currencyConveter(preferencesService.selectedCourrency, 'INR', amt);
      offerData['offer_amount'] = convertAmount.toString();
    }
    doctorDetails = await apiService.addOfferData(offerData, documentId, path);
    await getDoctorFees();
    setBusy(false);
  }

  Future updatefferData(dynamic offerData, String path) async {
    setBusy(true);
    offerData['doctor_Id'] = preferencesService.userId;
    offerData['profile_information'] = 'offers';
    if (offerData['offer_amount'] != null && offerData['offer_amount'] != '') {
      double amt = double.parse(offerData['offer_amount']);
      var convertAmount = await currencyConveter(preferencesService.selectedCourrency, 'INR', amt);
      offerData['offer_amount'] = convertAmount.toString();
    }
    doctorDetails = await apiService.updatefferData(offerData, documentId, path);
    await getDoctorFees();
    setBusy(false);
  }

  Future<bool> deleteOfferDetails(String dataId) async {
    setBusy(true);
    final response = await apiService.deleteOfferDetails(documentId, dataId, 'offers');
    await getDoctorFees();
    setBusy(false);
    return response;
  }
}
