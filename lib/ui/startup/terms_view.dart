import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:stacked/stacked.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/shared/app_colors.dart';
import 'package:swarapp/shared/screen_size.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:swarapp/ui/startup/signup_view.dart';
import 'package:swarapp/services/preferences_service.dart';
import 'package:swarapp/ui/startup/terms_viewmodel.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/app/router.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
PreferencesService preferencesService = locator<PreferencesService>();
NavigationService navigationService = locator<NavigationService>();

class TermsView extends StatefulWidget {
   final String? getcontent;
  TermsView({Key? key, this.getcontent}) : super(key: key);

  @override
  State<TermsView> createState() => _TermsViewState();
}

class _TermsViewState extends State<TermsView> {
  final GlobalKey webViewKey = GlobalKey();

  String url = "";
  String getContent = '';
  double progress = 0;
  String htmlcode = "";
  String ck = "<b>new</b>";
  InAppWebViewController? webViewController;

  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        useShouldOverrideUrlLoading: true,
        mediaPlaybackRequiresUserGesture: false,
      ),
      android: AndroidInAppWebViewOptions(
          // useHybridComposition: true,
          ),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
      ));



  @override
  Widget build(BuildContext context) {
       ck = widget.getcontent!;
    return Scaffold(
      body: SafeArea(
        // child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(10),
          width: Screen.width(context),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Terms & Conditions').fontWeight(FontWeight.w700).fontSize(18).textColor(activeColor),
                UIHelper.verticalSpaceMedium,
                Expanded(
                  child: SingleChildScrollView(
                  child: Stack(
                    children: [
                       Container(
                                  padding: EdgeInsets.all(14),
                                  child: HtmlWidget(
                                    //to show HTML as widget.
                                    // widget.getcontent!,
                                    ck,
                                    webView: true,
                                  ),
                                ),
                     
                      // InAppWebView(
                      //   key: webViewKey,
                      //   initialUrlRequest: URLRequest(url: Uri.parse(ck)),
                      //   initialOptions: options,
                      //   onWebViewCreated: (controller) {
                      //     webViewController = controller;
                      //   },
                      //   onLoadStart: (controller, url) {},
                      //   onProgressChanged: (controller, progress) {
                      //     setState(() {
                      //       this.progress = progress / 100;
                      //     });
                      //   },
                      //   androidOnPermissionRequest: (controller, origin, resources) async {
                      //     return PermissionRequestResponse(resources: resources, action: PermissionRequestResponseAction.GRANT);
                      //   },
                      // ),
                      progress < 1.0 ? LinearProgressIndicator(value: progress) : Container(),
                    ],
                  ),
                  )
                ),
                UIHelper.verticalSpaceSmall,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          Get.back();
                        },
                        child: Text('Decline').fontWeight(FontWeight.w600),
                        style: ButtonStyle(
                          minimumSize: MaterialStateProperty.all(Size(120, 36)),
                          backgroundColor: MaterialStateProperty.all(activeColor),
                        )),
                    ViewModelBuilder<tearmsViewmodel>.reactive(
                        builder: (context, model, child) {
                          return ElevatedButton(
                            onPressed: () async {
                              print(preferencesService.memberId);
                              if (preferencesService.memberId != '') {
                                await model.memberlogin_check(preferencesService.memberId);
                                if (model.memberloginInfo != null) {
                                  navigationService.clearStackAndShow(RoutePaths.Dashboard);
                                }
                              } else if (preferencesService.login_roleId == '6128a673b71d012678336f4d') {
                                Get.to(() => SignupView());
                              }
                            },
                            child: Text('Accept').fontWeight(FontWeight.w600),
                            style: ButtonStyle(
                              minimumSize: MaterialStateProperty.all(Size(120, 36)),
                              backgroundColor: MaterialStateProperty.all(Colors.green),
                            ),
                          );
                        },
                        viewModelBuilder: () => tearmsViewmodel()),
                  ],
                )
              ],
            ),
          ),
        ),

        //),
      ),
    );
  }
}
