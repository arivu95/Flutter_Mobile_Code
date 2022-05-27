import 'package:doctor_module/doctor_module.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:stacked/stacked.dart';
import 'package:swarapp/shared/app_colors.dart';
import 'package:swarapp/shared/bullet_list.dart';
import 'package:swarapp/shared/screen_size.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:swarapp/services/preferences_service.dart';
import 'package:swarapp/ui/startup/terms_viewmodel.dart';
import 'package:swarapp/app/locator.dart';
import 'package:stacked_services/stacked_services.dart';
import 'health_provider_signup_view.dart';

PreferencesService preferencesService = locator<PreferencesService>();
NavigationService navigationService = locator<NavigationService>();

class HealthTermsView extends StatelessWidget {
  const HealthTermsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
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
                      child: Column(children: [
                    Text('''   Our SWAR Doctor LLC, on behalf of itself under the brand "SWAR Doctor", is the author and publisher of the mobile application and website. SWAR Doctor LLC owns and operates the services provided through the Website and mobile applications.  “We” refers to SWAR Doctor LLC
                        ''',
                            textAlign: TextAlign.justify, style: TextStyle(height: 1.8))
                        .fontSize(13),
                    BulletList([
                      'We have designed this app and website as a platform for individual healthcare providers, intuitions, organizations, common people, specialist, and the like in the field of healthcare to integrate with each other and make quality healthcare equitably available for all.',
                      'All your document & chat shall be encrypted and stored to ensure data privacy.',
                      'Information and our services are based on the cloud storage provided by specialist companies',
                      'Our philosophy is, “healthcare redefined by the people for the people”. All users of this application or website unconditionally take the pledge to serve the humankind, always furnish genuine / accurate information and use our services',
                      'SWAR Doctor LLC IS A TECHNOLOGY ORGANIZATION. NOT A HEALTHCARE PROVIDER',
                      'To make our state of art services available for all, the basic version with limited functions shall be made available free with storage of 200MB data. Continuation of free service is at complete discretion of SWAR Doctor LLC.',
                      'SWAR Doctor LLC encourages to use paid service to ensure seamless and complete experience',
                      'The service${"'"}s content that you obtain or receive from SWAR Doctor LLC, and its website, mobile application, employees, associates, content mangers, marketing agencies, promotional content, media, social media,  contractors, partners, sponsors, advertisers, licensors or otherwise through the services is for informational purposes only.',
                      'Your access to use of the App & Website and the Services will be solely at the discretion of SWAR Doctor LLC.',
                    ]),
                    UIHelper.verticalSpaceSmall,
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: Text(
                              "      By downloading or accessing the app to use the Services, you irrevocably accept all the conditions stipulated in this Agreement, the Subscription Terms of Service and Privacy Policy, as available on the app & website (swardoctor.com), and agree to abide by all. In case of discrepancy, the most stringent as interpreted by SWAR Doctor LLC shall apply.",
                              textAlign: TextAlign.justify,
                              style: TextStyle(height: 1.8))
                          .fontSize(13),
                    ),
                  ])),
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
                              //  Get.to(() => DoctorProfileView());
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
      ),
    );
  }
}
