import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/services/preferences_service.dart';
import 'package:swarapp/ui/startup/terms_view.dart';

class DynamicLinkService {
  final NavigationService _navigationService = locator<NavigationService>();

  Future handleDynamicLinks() async {
    // Get the initial dynamic link if the app is opened with a dynamic link
    // final PendingDynamicLinkData? data = await FirebaseDynamicLinks.instance.getInitialLink();

    // final PendingDynamicLinkData data = (await FirebaseDynamicLinks.instance.getInitialLink())!;
    final PendingDynamicLinkData? data = await FirebaseDynamicLinks.instance.getInitialLink();

    // handle link that has been retrieved
    if (data != null) {
      _handleDeepLink(data);
    }

    // Register a link callback to fire if the app is opened up from the background
    // using a dynamic link.
    FirebaseDynamicLinks.instance.onLink(onSuccess: (PendingDynamicLinkData? dynamicLink) async {
      // handle link that has been retrieved
      _handleDeepLink(dynamicLink!);
      // preferencesService.onRefreshActivityfeed!.value = preferencesService.onRefreshActivityfeed!.value! + 1;
      //  preferencesService.onRefreshActivityfeed!.onChange((val) {
      //   preferencesService.onRefreshActivityfeed!.value = preferencesService.onRefreshActivityfeed!.value! + 1;
      //   });

      //  preferencesService.onRefreshActivityfeed!.value = preferencesService.onRefreshActivityfeed!.value! + 1;
    }, onError: (OnLinkErrorException e) async {
      print('Link Failed: ${e.message}');
    });
  }

  void _handleDeepLink(PendingDynamicLinkData data) async {
    final Uri? deepLink = data.link;
    if (deepLink != null) {
      // var isPost = deepLink.pathSegments.contains('invite');
      // if (isPost) {
      //   var ref = deepLink.queryParameters['ref'];
      var isPost = deepLink.fragment.contains('invite');
      if (isPost) {
        var ref = deepLink.fragment.split('=').last;
        if (ref != null) {
          PreferencesService preferencesService = locator<PreferencesService>();
          preferencesService.RefId = ref;
          await preferencesService.setRefId('refid', ref);

          // preferencesService.onRefreshActivityfeed!.value = preferencesService.onRefreshActivityfeed!.value! + 1;
          //_navigationService.navigateTo(CreatePostViewRoute, arguments: title);
        }
      }
    }
  }

  Future<String> createMemberInviteLink(String refId) async {
    var url = Uri.parse('https://swardev.blob.core.windows.net/b2csignin/swar.png');
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://swarapp.page.link',
      link: Uri.parse('https://swarwebdev01.swardoctor.com/#/invite?ref=$refId'),
      androidParameters: AndroidParameters(
        packageName: 'com.kat.swarapp',
      ),

      // Other things to add as an example. We don't need it now
      iosParameters: IosParameters(
        bundleId: 'com.kat.swarapp',
        minimumVersion: '1.0.0',
        appStoreId: '123456789',
      ),
      googleAnalyticsParameters: GoogleAnalyticsParameters(
        campaign: 'swar-promo',
        medium: 'social',
        source: 'mail',
      ),
      itunesConnectAnalyticsParameters: ItunesConnectAnalyticsParameters(
        providerToken: '123456',
        campaignToken: 'swar-promo',
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
        title: 'Swar Doctor Friend Invite',
        imageUrl: url,
        description: 'SWAR Doctor - Safe & Secure Healthcare App: We care for you with end-to-end encrypted app for all healthcare needs. Free basic version!',
      ),
    );

    // final Uri dynamicUrl = await parameters.buildUrl();
    // return dynamicUrl.toString();
    final ShortDynamicLink shortDynamicLink = await parameters.buildShortLink();
    final Uri shortUrl = shortDynamicLink.shortUrl;
    return shortUrl.toString();
  }
}
