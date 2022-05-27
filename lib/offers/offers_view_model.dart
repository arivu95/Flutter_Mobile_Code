import 'package:stacked/stacked.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/services/api_services.dart';

class offersVieweModel extends BaseViewModel {
  ApiService apiService = locator<ApiService>();
  dynamic OfferInfo = {};

  Future getOffers() async {
    setBusy(true);
    OfferInfo = await apiService.getAdminOffersist();
    
     setBusy(false);
  }
}
