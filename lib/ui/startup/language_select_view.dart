import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get/get.dart';
import 'package:stacked/stacked.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/services/preferences_service.dart';
import 'package:swarapp/shared/app_colors.dart';
import 'package:swarapp/shared/background_view.dart';
import 'package:swarapp/shared/custom_dialog_box.dart';
import 'package:swarapp/shared/screen_size.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:swarapp/ui/startup/health_provider_terms.dart';
import 'package:swarapp/ui/startup/language_select_viewmodel.dart';
import 'package:swarapp/ui/startup/terms_view.dart';
import 'package:doctor_module/src/ui/doc_signup/role_select_view.dart';
import 'package:doctor_module/src/ui/doc_signup/doc_signup_view.dart';
import 'package:doctor_module/src/ui/doc_signup/doc_terms_view.dart';
import 'package:http/http.dart' as http;

class LanguageSelectView extends StatefulWidget {
  LanguageSelectView({Key? key}) : super(key: key);

  @override
  _LanguageSelectViewState createState() => _LanguageSelectViewState();
}

class _LanguageSelectViewState extends State<LanguageSelectView> {
  dynamic selectedCountry;
  dynamic selectedLanguage;
  String getContent = '';
  String htmlcode = "";
  PreferencesService preferencesService = locator<PreferencesService>();

  Widget imageItem(String asset) {
    return Image.asset(
      asset,
      height: 28,
    );
  }

  Future getData(String roleId) async {
    try {
String contentmanagementId = "";
      if(preferencesService.login_roleId == "6128a673b71d012678336f4d"){
contentmanagementId ="62429cda6adc674ff4f245fd";
      }else{
contentmanagementId ="62429d156adc674ff4f24605";
      }
      final Uri url = Uri.parse("$endPoint/content_management?contentManagementId=$contentmanagementId");
      final response = await http.get(url);
      if (response.statusCode == 200) {
        // If the server did return a 200 OK response,
        // then parse the JSON.

        dynamic val = jsonDecode(response.body);
        print("ST" + val[0]['content'].toString());
        getContent = val[0]['content'].toString();

        //     htmlcode = """
        // $getContent
        // """;
        htmlcode = """ <b>asd<b> """;
        //return fromJson(jsonDecode(response.body));
        return;
      } else {
        // If the server did not return a 200 OK response,
        // then throw an exception.
        throw Exception('Failed to load album');
      }
    } catch (err) {
      print(err);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (selectedCountry != null) {
      print(selectedCountry['country'].toString());
      preferencesService.user_country = selectedCountry['country'].toString();
      preferencesService.user_country_id = selectedCountry['_id'].toString();
      preferencesService.user_country_degit = selectedCountry['countryCode_digits'].toString();
    }

    if (selectedLanguage != null) {
      preferencesService.language = selectedLanguage['language'].toString();
    }

    return Scaffold(
      body: BackgroundView(
        child: Container(
            child: Center(
          child: ViewModelBuilder<LanguageSelectViewmodel>.reactive(
              onModelReady: (model) async {
                await model.getCountries();
                String ccode = await preferencesService.getUserInfo('countryCode');
                if (model.countries.length > 0 && ccode.isNotEmpty) {
                  dynamic filtered = model.countries.firstWhere(
                    (element) {
                      return element['countryCode'] == ccode;
                    },
                    orElse: () {
                      return null;
                    },
                  );
                  if (filtered != null) {
                    setState(() {
                      selectedCountry = filtered;
                    });
                  }
                }

                if (model.languages.length > 0) {
                  dynamic filtered = model.languages.firstWhere(
                    (element) {
                      return element['language'] == 'English';
                    },
                    orElse: () {
                      return null;
                    },
                  );
                  if (filtered != null) {
                    setState(() {
                      selectedLanguage = filtered;
                    });
                  }
                }
              },
              builder: (context, model, child) {
                return model.isBusy
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Image.asset(
                          'assets/swar_logo.png',
                          height: 60,
                          width: 60,
                        ),
                        SizedBox(height: 70),
                        FormBuilder(
                            initialValue: {
                              'language': selectedLanguage ?? null,
                              'country': selectedCountry ?? null,
                            },
                            child: Container(
                              padding: EdgeInsets.all(12),
                              child: Column(
                                children: [
                                  Text('Select Country').fontSize(18).fontWeight(FontWeight.w800),
                                  UIHelper.verticalSpaceSmall,
                                  Container(
                                    height: 45,
                                    padding: EdgeInsets.only(left: 2),
                                    decoration: UIHelper.roundedLineBorderWithColor(12, Colors.white, 1),
                                    child: SizedBox(
                                      width: Screen.width(context) / 1.3,
                                      child: FormBuilderDropdown(
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.only(left: 10),
                                          prefixIcon: imageItem('assets/world.png'),
                                          filled: true,
                                          fillColor: Colors.white,
                                          enabledBorder: UIHelper.getInputBorder(1),
                                          focusedBorder: UIHelper.getInputBorder(1),
                                          focusedErrorBorder: UIHelper.getInputBorder(1),
                                          errorBorder: UIHelper.getInputBorder(1),
                                        ),
                                        name: "country",
                                        hint: Text('Select Country').fontSize(13),
                                        items: model.countries.map((dynamic value) {
                                          return new DropdownMenuItem(
                                            value: value,
                                            child: new Text(value['country']).fontSize(13).bold(),
                                          );
                                        }).toList(),
                                        onChanged: (value) => {
                                          setState(() {
                                            selectedCountry = value!;
                                          })
                                        },
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 40),
                                  Text('Select Language').fontSize(18).fontWeight(FontWeight.w800),
                                  UIHelper.verticalSpaceSmall,
                                  Container(
                                    height: 45,
                                    padding: EdgeInsets.only(left: 6),
                                    decoration: UIHelper.roundedLineBorderWithColor(12, Colors.white, 1),
                                    child: SizedBox(
                                      width: Screen.width(context) / 1.3,
                                      child: FormBuilderDropdown(
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.only(left: 10),
                                          prefixIcon: imageItem('assets/language.png'),
                                          filled: true,
                                          fillColor: Colors.white,
                                          enabledBorder: UIHelper.getInputBorder(1),
                                          focusedBorder: UIHelper.getInputBorder(1),
                                          focusedErrorBorder: UIHelper.getInputBorder(1),
                                          errorBorder: UIHelper.getInputBorder(1),
                                        ),
                                        name: "language",
                                        hint: Text('Select Language').fontSize(13),
                                        items: model.languages.map((dynamic value) {
                                          return new DropdownMenuItem(
                                            value: value,
                                            child: new Text(value['language']).fontSize(13).bold(),
                                          );
                                        }).toList(),
                                        onChanged: (lang) => {
                                          // setState(() {
                                          //   selectedLanguage = value!;
                                          // })
                                        },
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 70,
                                  ),
                                  ElevatedButton(
                                      onPressed: () async {
                                        if (selectedCountry == null) {
                                          showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return CustomDialogBox(
                                                  title: "Alert !",
                                                  descriptions: "Please Choose your country.",
                                                  descriptions1: "",
                                                  text: "OK",
                                                );
                                              });
                                        } else if (preferencesService.login_roleId == '6128a673b71d012678336f4d') {
                                          await getData(preferencesService.login_roleId);
                                          Get.to(() => TermsView(getcontent: getContent));
                                        } else {
                                          await getData('61e7a9e44c559c1530e0e562');
                                          Get.to(() => DocTermsView(getcontent: getContent));
                                        }
                                      },
                                      child: Text('Next').fontWeight(FontWeight.w700).fontSize(20),
                                      style: ButtonStyle(
                                        minimumSize: MaterialStateProperty.all(Size(150, 38)),
                                        backgroundColor: MaterialStateProperty.all(submitBtnColor),
                                      )),
                                ],
                              ),
                            )),
                      ]);
              },
              viewModelBuilder: () => LanguageSelectViewmodel()),
        )),
      ),
    );
  }
}
