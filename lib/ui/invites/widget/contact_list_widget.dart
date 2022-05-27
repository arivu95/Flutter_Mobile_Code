import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get_connect.dart';
import 'package:share/share.dart';
import 'package:stacked/stacked.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/services/dynamic_link_service.dart';
import 'package:swarapp/services/email_validator.dart';
import 'package:swarapp/services/preferences_service.dart';
import 'package:swarapp/shared/app_colors.dart';
import 'package:swarapp/shared/flutter_overlay_loader.dart';
import 'package:swarapp/shared/screen_size.dart';
import 'package:swarapp/shared/text_styles.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:swarapp/ui/invites/widget/find_friends_model.dart';
import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

class ContactListPage extends StatefulWidget {
  @override
  _ContactListPageState createState() => _ContactListPageState();
}

const iOSLocalizedLabels = false;

class _ContactListPageState extends State<ContactListPage> {
  List<Contact>? _contacts;
  PreferencesService preferencesService = locator<PreferencesService>();
  ApiService apiService = locator<ApiService>();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  bool isContactSearch = false;
  bool isAutoValidate = false;
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  final ScrollController _scrollController = ScrollController();
  String validfield = "";
  bool isEnter = false;
  List countries = [];
  dynamic selectedCode = {};
  int min_length = 7;
  int max_length = 15;

  @override
  void initState() {
    super.initState();
    refreshContacts();
    this.loadJsonData();
  }

  Future<String> loadJsonData() async {
    var jsonText = await rootBundle.loadString('assets/countries.json');
    setState(() => countries = json.decode(jsonText));
    return 'success';
  }

  Future<void> refreshContacts() async {
    // Load without thumbnails initially.
    var contacts = (await ContactsService.getContacts(withThumbnails: false, iOSLocalizedLabels: iOSLocalizedLabels));
    setState(() {
      _contacts = contacts;
    });

    // Lazy load thumbnails after rendering initial contacts.
    for (final contact in contacts) {
      ContactsService.getAvatar(contact).then((avatar) {
        if (avatar == null) return; // Don't redraw if no change.
        setState(() => contact.avatar = avatar);
      });
    }
  }

  void updateContact() async {
    Contact ninja = _contacts!.firstWhere((contact) => contact.familyName!.startsWith("Ninja"));
    ninja.avatar = null;
    await ContactsService.updateContact(ninja);
    refreshContacts();
  }

  _openContactForm() async {
    try {
      var _ = await ContactsService.openContactForm(iOSLocalizedLabels: iOSLocalizedLabels);
      refreshContacts();
    } on FormOperationException catch (e) {
      switch (e.errorCode) {
        case FormOperationErrorCode.FORM_OPERATION_CANCELED:
        case FormOperationErrorCode.FORM_COULD_NOT_BE_OPEN:
        case FormOperationErrorCode.FORM_OPERATION_UNKNOWN_ERROR:
        default:
          print(e.errorCode);
      }
    }
  }

  Widget titleCard(BuildContext context, String title) {
    return Container(
        decoration: UIHelper.roundedBorderWithColor(10, Colors.grey.shade100),
        width: Screen.width(context) / 4,
        height: 47,
        padding: EdgeInsets.only(left: 5, right: 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title).fontSize(13).fontWeight(FontWeight.w500),
          ],
        ));
  }

  Widget addInputFieldControl(String controlName, String hintText, String Controllername) {
    return FormBuilderTextField(
        style: loginInputTitleStyle,
        name: controlName,
        controller: Controllername == 'emailController'
            ? emailController
            : Controllername == 'mobileController'
                ? mobileController
                : nameController,
        textCapitalization: TextCapitalization.sentences,
        autocorrect: false,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        onChanged: (value) {},
        decoration: InputDecoration(
          contentPadding: EdgeInsets.only(left: 5),
          hintText: hintText,
          hintStyle: loginInputHintTitleStyle,
          filled: true,
          fillColor: Colors.grey.shade100,
          enabledBorder: UIHelper.getInputBorder(1),
          focusedBorder: UIHelper.getInputBorder(1),
          focusedErrorBorder: UIHelper.getInputBorder(1),
          errorBorder: UIHelper.getInputBorder(1, borderColor: activeColor),
        ),
        validator: controlName == "email"
            ? FormBuilderValidators.compose([
                EmailValidators.email(context),
              ])
            : controlName == "mobilenumber"
                ? FormBuilderValidators.compose([
                    FormBuilderValidators.minLength(context, min_length, allowEmpty: true, errorText: "Invalid Number"),
                    FormBuilderValidators.maxLength(context, max_length, errorText: "Invalid Number"),
                  ])
                : FormBuilderValidators.compose([]),
        // inputFormatters: [
        //   if (control_name == 'mobilenumber') new WhitelistingTextInputFormatter(RegExp("[0-9]")),
        // ],
        inputFormatters: [
          // is able to enter lowercase letters

          if (controlName == 'mobilenumber') FilteringTextInputFormatter.allow(RegExp("[0-9]")),
        ],
        keyboardType: controlName == 'mobilenumber' ? TextInputType.number : null);
  }

  Future<void> _NewContactInviteDialog(BuildContext context, String mobileName, String mobileNumber, FindFriendmodel model, bool isNew) async {
    nameController = isNew ? TextEditingController() : TextEditingController(text: mobileName);
    emailController = TextEditingController();
    mobileController = isNew ? TextEditingController() : TextEditingController(text: mobileNumber);
    setState(() {
      isEnter = false;
    });
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: Container(
                    width: 400,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: FormBuilder(
                      key: _fbKey,
                      child: Column(children: [
                        Image.asset(
                          'assets/swar_logo.png',
                          width: 40,
                          height: 40,
                        ),
                        UIHelper.verticalSpaceSmall,
                        Text(
                          "New Invite",
                          textAlign: TextAlign.center,
                        ),
                        UIHelper.verticalSpaceMedium,
                        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          titleCard(context, 'Name'),
                          SizedBox(width: 8),
                          Expanded(
                              child: Container(
                            child: addInputFieldControl('name', 'Name', 'nameController'),
                          ))
                        ]),
                        UIHelper.verticalSpaceSmall,
                        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          titleCard(context, 'Email id'),
                          SizedBox(width: 8),
                          Expanded(
                              child: Container(
                            child: addInputFieldControl('email', 'Email id', 'emailController'),
                          ))
                        ]),
                        UIHelper.verticalSpaceSmall,
                        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          titleCard(context, 'Mobile no.'),
                          SizedBox(width: 8),
                          SizedBox(
                            width: 65,
                            child: FormBuilderDropdown(
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.only(left: 3),
                                  filled: true,
                                  fillColor: Colors.grey.shade100,
                                  enabledBorder: UIHelper.getInputBorder(1),
                                  focusedBorder: UIHelper.getInputBorder(1),
                                  focusedErrorBorder: UIHelper.getInputBorder(1),
                                  errorBorder: UIHelper.getInputBorder(1),
                                ),
                                name: "countryCode",
                                hint: Text('Code').fontSize(12),
                                isExpanded: true,
                                isDense: true,
                                items: countries.map<DropdownMenuItem<String>>((cc) => new DropdownMenuItem<String>(
                                          value: cc['countryCode_digits'],
                                          child: Text(cc['countryCode_digits']).textColor(Colors.black).fontSize(16),
                                        ))
                                    .toList(),
                                onChanged: (value) {
                                  for (var each in countries) {
                                    if (each['countryCode_digits'] == value) {
                                      setState(() {
                                        min_length = int.parse(each['min_length']);
                                        max_length = int.parse(each['max_length']);
                                      });
                                      _fbKey.currentState!.patchValue({'mobilenumber': mobileController.text});
                                      _fbKey.currentState!.saveAndValidate();
                                    }
                                  }
                                },
                                // onChanged: (value) {
                                //   setState(() {
                                //     selectedCode = value;
                                //     print(selectedCode);
                                //     min_length = int.parse(selectedCode['min_length']);
                                //     max_length = int.parse(selectedCode['max_length']);
                                //   });

                                // },
                                validator: mobileController.text != ""
                                    ? FormBuilderValidators.compose([
                                        FormBuilderValidators.required(context, errorText: '*Required'),
                                      ])
                                    : null),
                          ),
                          SizedBox(width: 3),
                          Expanded(
                              child: Container(
                                  child: Column(
                            children: [
                              addInputFieldControl('mobilenumber', 'Mobile Number', 'mobileController'),
                              Text('Please provide phone number without country code for eg.(0123456789)').fontSize(12).textColor(Colors.black38),
                            ],
                          )))
                        ]),
                      ]),
                    )),
                insetPadding: EdgeInsets.all(10),
                actions: <Widget>[
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          Navigator.pop(context);
                        });
                      },
                      style: ButtonStyle(
                          minimumSize: MaterialStateProperty.all(Size(120, 35)),
                          elevation: MaterialStateProperty.all(0),
                          backgroundColor: MaterialStateProperty.all(Colors.red),
                          shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)))),
                      child: Text('Cancel').textColor(Colors.white),
                    ),
                    UIHelper.horizontalSpaceSmall,
                    ElevatedButton(
                      onPressed: () async {
                        if (nameController.text == "" && emailController.text == "" && mobileController.text == "") {
                          Fluttertoast.showToast(
                              msg: "Email/ mobile number required",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.CENTER,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Color.fromRGBO(252, 84, 104, 0.52),
                              textColor: Colors.white,
                              fontSize: 12.0);
                        }
                        if (mobileController.text.contains('+') == true) {
                          Fluttertoast.showToast(
                              msg: "Please Check Your Mobile Number",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.CENTER,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Color.fromRGBO(252, 84, 104, 0.52),
                              textColor: Colors.white,
                              fontSize: 12.0);
                        } else {
                          _fbKey.currentState!.saveAndValidate();
                          print(_fbKey.currentState!.value);
                          Map<String, dynamic> newcontactnfo = Map.from(_fbKey.currentState!.value);
                          if (_fbKey.currentState!.saveAndValidate()) {
                            newcontactnfo.removeWhere((key, value) => value == '' || value == null);
                            newcontactnfo['countryCode'] = selectedCode['countryCode_digits'];
                            print("newcontactnfo-----" + newcontactnfo.toString());
                            Loader.show(context);
                            await model.inviteNewUser(newcontactnfo);
                            refreshContacts();
                            Loader.hide();
                            setState(() {
                              Navigator.pop(context);
                            });
                          }
                        }
                      },
                      style: ButtonStyle(
                          minimumSize: MaterialStateProperty.all(Size(120, 35)),
                          elevation: MaterialStateProperty.all(0),
                          backgroundColor: MaterialStateProperty.all(Colors.green),
                          shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)))),
                      child: Text('Invite Send').textColor(Colors.white),
                    ),
                  ]),
                ],
              );
            },
          );
        });
  }

  void inviteFriends() async {
    Loader.show(context);
    String userId = locator<PreferencesService>().userId;
    String inviteType = 'friend_invite';
    final response = await apiService.getInviteMemberRefId(userId, inviteType);
    Loader.hide();
    if (response['msg'] != null) {
      String postMessage = response['msg'];
      if (response['Invitemember'] != null) {
        dynamic inviteMember = response['Invitemember'];
        String refId = inviteMember['reference_id'];
        String inviteLink = await locator<DynamicLinkService>().createMemberInviteLink(refId);
        await Share.share(postMessage + ' ' + inviteLink);
      }
    }
  }

  Widget showSearchField(BuildContext context, FindFriendmodel model) {
    return SizedBox(
      height: 38,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8),
        decoration: UIHelper.roundedBorderWithColorWithShadow(8, fieldBgColor),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: SizedBox(
                height: 38,
                child: TextField(
                  controller: searchController,
                  onChanged: (value) {
                    // model.updateOnTextSearch(value);
                    model.getContact_search(value);

                    setState(() {
                      isContactSearch = true;
                    });
                  },
                  style: TextStyle(fontSize: 14),
                  decoration: new InputDecoration(
                      prefixIcon: Icon(
                        Icons.search,
                        color: activeColor,
                        size: 20,
                      ),
                      suffixIcon: searchController.text.isEmpty
                          ? SizedBox()
                          : IconButton(
                              icon: Icon(
                                Icons.cancel,
                                color: Colors.black38,
                              ),
                              onPressed: () {
                                searchController.clear();
                                model.getContact_search('');
                                setState(() {
                                  isContactSearch = true;
                                });
                                FocusManager.instance.primaryFocus!.unfocus();
                              }),
                      contentPadding: EdgeInsets.only(left: 20),
                      enabledBorder: UIHelper.getInputBorder(0, radius: 8, borderColor: Color(0x00CCCCCC)),
                      focusedBorder: UIHelper.getInputBorder(0, radius: 8, borderColor: Colors.white),
                      focusedErrorBorder: UIHelper.getInputBorder(0, radius: 8, borderColor: Colors.white),
                      errorBorder: UIHelper.getInputBorder(0, radius: 8, borderColor: Color(0xFFCCCCCC)),
                      filled: true,
                      hintStyle: new TextStyle(color: Colors.grey[800]),
                      hintText: "Search contacts....       ",
                      fillColor: fieldBgColor),
                ),
              ),
            ),
            UIHelper.horizontalSpaceSmall,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ViewModelBuilder<FindFriendmodel>.reactive(
          onModelReady: (model) async {
            //   await model.getNotification();
            //model.getMemberProfile(widget.memberId);
            await model.getCountries();
          },
          builder: (context, model, child) {
            preferencesService.deviceContactList!.value = (_contacts != null ? _contacts! : []) as List?;
            return Column(children: [
              showSearchField(context, model),
              UIHelper.verticalSpaceSmall,
              Expanded(
                  child: _contacts != null
                      ? ListTileTheme(
                          contentPadding: EdgeInsets.all(10),
                          iconColor: Colors.red,
                          textColor: Colors.black54,
                          tileColor: fieldBgColor,
                          style: ListTileStyle.list,
                          dense: true,
                          child: Scrollbar(
                            isAlwaysShown: true,
                            child: ListView.builder(
                              itemCount: isContactSearch ? model.searchBy_Contactlists.length : _contacts?.length ?? 0,
                              itemBuilder: (BuildContext context, int index) {
                                Contact c = isContactSearch ? model.searchBy_Contactlists[index] : _contacts!.elementAt(index);
                                List<dynamic> inviteList = preferencesService.userInviteListStream!.value!;
                                List<dynamic> db = preferencesService.contactusersListStream!.value!;
                                print(db.length.toString());
                                dynamic s = c.phones;
                                if (c.phones!.length > 0) {
                                  String swaruser = '';
                                  String swaruserImg = '';
                                  String k = s[0].value;
                                  dynamic selectedPerson = {};
                                  String countrycode = "";
                                  String isAccepted = '';
                                  String mobileName = c.displayName.toString();

                                  String _textSelect(String str) {
                                    str = str.replaceAll(' ', '');
                                    str = str.replaceAll('-', '');
                                    return str;
                                  }

                                  String outputMobile = _textSelect(k);

                                  if (db.length > 0) {
                                    for (var each in db) {
                                      String withoutCountrycodeMobile = '';
                                      String withCountrycodeMobile = '';
                                      if (each['mobilenumber'] != null && each['mobilenumber'] != '') {
                                        withoutCountrycodeMobile = each['mobilenumber'].toString();
                                        if (each['countryCode_digits'] != null && each['countryCode_digits'] != '') {
                                          withCountrycodeMobile = each['countryCode_digits'] + withoutCountrycodeMobile;
                                        }
                                      }

                                      if (withCountrycodeMobile == outputMobile || withoutCountrycodeMobile == outputMobile) {
                                        print("swar....person----");
                                        swaruser = 'SWAR USER';
                                        selectedPerson = each;
                                        for (var each in inviteList) {
                                          if (each['receiver_id'] != null) {
                                            if (each['receiver_id'] == selectedPerson['_id']) {
                                              if (each['is_accepted'] == true) {
                                                isAccepted = 'accepted';
                                              } else if (each['is_accepted'] == false) {
                                                isAccepted = 'requested';
                                              } else {
                                                isAccepted = 'new';
                                              }
                                            }
                                          }
                                        }

                                        if (each['azureBlobStorageLink'] != null && each['azureBlobStorageLink'] != '') {
                                          swaruserImg = '${ApiService.fileStorageEndPoint}${each['azureBlobStorageLink']}';
                                        }
                                      } else {
                                        for (var each1 in inviteList) {
                                          String withoutCountrycode = '';
                                          String withCountrycode = '';
                                          if (each1['mobilenumber'] != null && each1['mobilenumber'] != '') {
                                            withoutCountrycode = each1['mobilenumber'].toString();
                                            if (each1['countryCode'] != null && each1['countryCode'] != '') {
                                              withCountrycode = each1['countryCode'] + withoutCountrycode;
                                            }
                                          }

                                          if (withCountrycode == outputMobile || withoutCountrycode == outputMobile) {
                                            if (each1['is_accepted'] == true) {
                                              isAccepted = 'accepted';
                                            } else if (each1['is_accepted'] == false) {
                                              isAccepted = 'requested';
                                            } else {
                                              isAccepted = 'new';
                                            }
                                          }
                                        }
                                      }
                                    }
                                  }
                                  return Column(children: [
                                    index == 0
                                        ? Card(
                                            margin: EdgeInsets.all(1),
                                            child: ListTile(
                                              onTap: () {
                                                dynamic s = c.phones;
                                                String mbl = s[0].value;
                                                String _textSelect(String str) {
                                                  str = str.replaceAll(' ', '');
                                                  str = str.replaceAll('+', '');
                                                  str = str.replaceAll('-', '');
                                                  return str;
                                                }

                                                String outputMobile = _textSelect(mbl);
                                                String mobileName = c.displayName.toString();
                                                _NewContactInviteDialog(context, mobileName, outputMobile, model, true);
                                              },
                                              leading: CircleAvatar(
                                                radius: 20.0,
                                                backgroundColor: Colors.grey.shade300,
                                                child: Icon(Icons.person_add_alt_1, size: 20, color: activeColor),
                                              ),
                                              // Icon(Icons.account_circle, size: 40, color: Colors.grey),

                                              title: Text("New Contact").bold(),
                                            ),
                                          )
                                        : SizedBox(),
                                    index == 0
                                        ? Card(
                                            margin: EdgeInsets.all(1),
                                            child: ListTile(
                                              onTap: () {
                                                inviteFriends();
                                              },
                                              leading: CircleAvatar(
                                                radius: 20.0,
                                                backgroundColor: Colors.grey.shade300,
                                                child: Icon(Icons.share, size: 20, color: activeColor),
                                              ),
                                              title: Text("Invite Friends").bold(),
                                            ),
                                          )
                                        : SizedBox(),
                                    Card(
                                        margin: EdgeInsets.all(1),
                                        child: ListTile(
                                          onTap: () {},
                                          leading: Stack(
                                            children: <Widget>[
                                              swaruserImg.isNotEmpty && swaruserImg != null
                                                  ? ClipRRect(
                                                      borderRadius: BorderRadius.circular(30.0),
                                                      child: UIHelper.getImage(swaruserImg, 40, 40),
                                                    )
                                                  : CircleAvatar(
                                                      child: Text(c.initials()).textColor(Colors.white),
                                                      backgroundColor: Color(0xFFC4165D),
                                                    ),
                                              swaruser.isEmpty
                                                  ? SizedBox()
                                                  : Positioned(
                                                      child: Container(
                                                          padding: EdgeInsets.all(1),
                                                          color: Colors.white,
                                                          child: Image.asset(
                                                            'assets/swar_logo.png',
                                                            width: 13,
                                                            height: 13,
                                                          )),
                                                      bottom: -1,
                                                      right: -1,
                                                    ),
                                            ],
                                          ),
                                          title: Text(c.displayName ?? "").bold(),
                                          trailing: isAccepted == 'accepted'
                                              ? Text('Friend').textColor(Colors.green.shade500).bold()
                                              : isAccepted == 'requested'
                                                  ? Text('Requested').bold()
                                                  : ElevatedButton(
                                                      onPressed: () async {
                                                        if (swaruser.isNotEmpty) {
                                                          print(selectedPerson['_id']);
                                                          String o = selectedPerson['_id'];
                                                          Loader.show(context);
                                                          await model.inviteSwarUser(selectedPerson['_id']);
                                                          Loader.hide();
                                                        } else {
                                                          String mbl = s[0].value;
                                                          String _textSelect(String str) {
                                                            str = str.replaceAll(' ', '');
                                                            str = str.replaceAll('+', '');
                                                            str = str.replaceAll('-', '');
                                                            return str;
                                                          }

                                                          String outputMobile = _textSelect(mbl);

                                                          await _NewContactInviteDialog(context, mobileName, outputMobile, model, false);
                                                        }
                                                        //print(k);
                                                      },
                                                      child: Text('Invite').textColor(Colors.white),
                                                      style: ButtonStyle(
                                                          minimumSize: MaterialStateProperty.all(Size(90, 28)),
                                                          elevation: MaterialStateProperty.all(0),
                                                          backgroundColor: MaterialStateProperty.all(Colors.green),
                                                          shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))))),
                                        )),
                                  ]);
                                } else {
                                  return SizedBox();
                                }
                              },
                            ),
                          ))
                      : Center(
                          child: CircularProgressIndicator(),
                        ))
            ]);
          },
          viewModelBuilder: () => FindFriendmodel(),
        ),
        // Card(
        //     margin: EdgeInsets.all(5),
        //     child: ListTile(
        //       onTap: () {},
        //       leading: Icon(Icons.account_circle, size: 40, color: Colors.grey),
        //       title: Text("New Contact"),
        //     )),
      ),
    );
  }

  void contactOnDeviceHasBeenUpdated(Contact contact) {
    this.setState(() {
      var id = _contacts!.indexWhere((c) => c.identifier == contact.identifier);
      _contacts![id] = contact;
    });
  }
}
