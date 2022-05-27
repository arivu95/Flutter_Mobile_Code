import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/app/router.dart';
import 'package:swarapp/services/call_manager.dart';
import 'package:swarapp/services/connectycube_services.dart';
import 'package:swarapp/services/iap_service.dart';
import 'package:swarapp/services/preferences_service.dart';
import 'package:swarapp/services/pushnotification_service.dart';
import 'package:swarapp/shared/app_colors.dart';
import 'package:swarapp/shared/app_static_bar.dart';
import 'package:swarapp/shared/flutter_overlay_loader.dart';
import 'package:swarapp/shared/screen_size.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swarapp/ui/subscription/subscription_view.dart';
import 'package:swarapp/ui/subscription/subscribed_view.dart';
import 'package:user_module/src/ui/user_profile/profile_view.dart';
import 'package:swarapp/services/api_services.dart';

class MoreViewNew extends StatelessWidget {
  const MoreViewNew({Key? key}) : super(key: key);

  void _getOutOfApp() async {
    if (Platform.isIOS) {
      try {
        exit(0);
      } catch (e) {
        SystemNavigator.pop(); // for IOS, not true this, you can make comment this :)
      }
    } else {
      try {
        SystemNavigator.pop(); // sometimes it cant exit app
      } catch (e) {
        exit(0); // so i am giving crash to app ... sad :(
      }
    }
  }

  void showFilePickerSheet(String type, context) {}

//   @override
//   Widget build(BuildContext context) {
//     PreferencesService preferencesService = locator<PreferencesService>();
//     NavigationService navigationService = locator<NavigationService>();
//     ConnectyCubeServices connectyCubeServices = locator<ConnectyCubeServices>();
//     IapService iapService = locator<IapService>();
//     ApiService apiService = locator<ApiService>();
//     return showModalBottomSheet(
//         context: context,
//         builder: (context) {
//           return Wrap(
//             children: const [
//               ListTile(
//                 leading: Icon(Icons.share),
//                 title: Text('Share'),
//               ),
//               ListTile(
//                 leading: Icon(Icons.link),
//                 title: Text('Get link'),
//               ),
//               ListTile(
//                 leading: Icon(Icons.edit),
//                 title: Text('Edit name'),
//               ),
//               ListTile(
//                 leading: Icon(Icons.delete),
//                 title: Text('Delete collection'),
//               ),
//             ],
//           );
//         });
//   }
// }
  @override
  Widget Modelsheets(BuildContext context) {
    return Center(
      child: ElevatedButton(
        child: const Text('showModalBottomSheet'),
        onPressed: () {
          showModalBottomSheet<void>(
            context: context,
            builder: (BuildContext context) {
              return Container(
                height: 200,
                color: Colors.amber,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Text('Modal BottomSheet'),
                      ElevatedButton(
                        child: const Text('Close BottomSheet'),
                        onPressed: () => Navigator.pop(context),
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return (ListView());
  }
}
