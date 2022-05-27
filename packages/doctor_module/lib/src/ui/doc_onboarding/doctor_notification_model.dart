import 'package:jiffy/jiffy.dart';
import 'package:stacked/stacked.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/services/preferences_service.dart';

class DoctorNotificationmodel extends BaseViewModel {
  PreferencesService preferencesService = locator<PreferencesService>();
  ApiService apiService = locator<ApiService>();
  dynamic profileInfo = {};
  dynamic notificationInfo = {};
  dynamic inviteInfo = {};
  String img_url = '';
  dynamic invite_exits = '';
  List<dynamic> sourceFileDates = [];
  //dynamic sourceFileDates;
  Map<String, List> getSections = {};
  Map<String, List> reminderSections = {};
  dynamic reminderDates = {};
  Future getNotification() async {
    setBusy(true);
    String userId = preferencesService.userId;
    //NotificationInfo = await apiService.getNotifications('61d96c9cb34ae365c03706de');
    notificationInfo = await apiService.getNotifications(userId, '61e7a9e44c559c1530e0e562');

    sourceFileDates = notificationInfo
        .map((e) {
          Jiffy j = Jiffy(e['createdAt']);
          //String dateStr = j.format('dd MMM yyyy');
          String dateStr = j.format('yyyy-MM-dd');
          //String dateStr=j.format(day)
          if (reminderSections[dateStr] == null) {
            reminderSections[dateStr] = [e];
          } else {
            reminderSections[dateStr]!.add(e);
          }
          return j.format('yyyy-MM-dd');
        })
        .toSet()
        .toList();
    // for (dynamic info in notificationInfo) {
    //   Jiffy j = Jiffy(info['createdAt']);
    //   String dateStr = j.format('dd MMM yyyy');
    //   if (reminderSections[dateStr] == null) {
    //     reminderSections[dateStr] = [info];
    //   } else {
    //     reminderSections[dateStr]!.add(info);
    //   }
    // }
    // return j.format('dd MMM yyyy');

    reminderDates = sourceFileDates;
    setBusy(false);
    // return true;
  }

  Future checkInviteExist(String inviterId) async {
    setBusy(true);
    String userId = preferencesService.userId;
    List userData = await apiService.getUsersFeedData(userId);
    userData.forEach((produit) {
      if (produit['_id'].contains(inviterId)) {
        invite_exits = "exist";
      } else {
        invite_exits = " ";
      }
      // _searchProduct.add(produit);
    });
    setBusy(false);
    return invite_exits;
  }

  Future acceptinvite(String feedId, String status) async {
    setBusy(true);
    String userId = preferencesService.userId;
    String refId = preferencesService.RefId;
    var response = await apiService.acceptinvite(userId, refId, feedId, status);
    setBusy(false);
    return response;
  }

  Future declineinvite(String feedId, String status) async {
    setBusy(true);
    String userId = preferencesService.userId;
    String refId = preferencesService.RefId;
    await apiService.acceptinvite(userId, refId, feedId, status);
    setBusy(false);
  }

  Future getRecentFriends() async {
    // setBusy(true);
    String userId = preferencesService.userId;
    await apiService.getRecentFriends(userId, "60dae3e440f5032614a8d24b");

    //memSections = recentFriends.toList();
    //recentFriends.add({});
    setBusy(false);
  }
}
