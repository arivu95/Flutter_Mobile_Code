import 'package:stacked/stacked.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/services/pushnotification_service.dart';

class ChatListViewModel extends BaseViewModel {
      ApiService apiService = locator<ApiService>();
    List<dynamic> recentFriends = [];


      Future getRecentFriends() async {
    // setBusy(true);
    String userId = preferencesService.userId;
    List friends = await apiService.getRecentFriends(userId, "60dae3e440f5032614a8d24b");
    recentFriends.clear();
    if (friends.length > 0) {
      recentFriends = friends.expand((i) => i).toList();
      // for (List friend in friends) {
      //   if (friend.length > 0) {
      //     recentFriends.add(friend[0]);
      //   }
      // }
    }
    //memSections = recentFriends.toList();
    //recentFriends.add({});
    setBusy(false);
  }


}