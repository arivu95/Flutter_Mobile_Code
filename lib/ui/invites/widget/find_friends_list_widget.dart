import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';
import 'package:stacked/stacked.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/services/preferences_service.dart';
import 'package:swarapp/shared/app_colors.dart';
import 'package:swarapp/shared/flutter_overlay_loader.dart';
import 'package:swarapp/shared/screen_size.dart';
import 'package:swarapp/shared/text_styles.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:swarapp/ui/invites/widget/find_friends_model.dart';

class FindFriendListPage extends StatefulWidget {
  final bool searchby;
  FindFriendListPage({Key? key, required this.searchby}) : super(key: key);
  @override
  _FindFriendListPageState createState() => _FindFriendListPageState();
}

const iOSLocalizedLabels = false;

class _FindFriendListPageState extends State<FindFriendListPage> {
  List<Contact>? _contacts;
  PreferencesService preferencesService = locator<PreferencesService>();

  @override
  void initState() {
    super.initState();
    refreshContacts();
  }

  Future<void> refreshContacts() async {
    // Load without thumbnails initially.
    var contacts = (await ContactsService.getContacts(withThumbnails: false, iOSLocalizedLabels: iOSLocalizedLabels));
//      var contacts = (await ContactsService.getContactsForPhone("8554964652"))
//          ;
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

  Future<void> _displayInviteDialog(BuildContext context, dynamic data, String mobileName) async {
    String motherWeight = data['mobilenumber'] != null ? data['mobilenumber'].toString() : '';
    final _textFieldController = TextEditingController();
    String imgUrl = "";
    if (data['azureBlobStorageLink'] != null) {
      imgUrl = '${ApiService.fileStorageEndPoint}${data['azureBlobStorageLink']}';
    }
    void dispose() {
      _textFieldController.dispose();
      super.dispose();
    }

    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                imgUrl == '' || imgUrl.contains('null')
                    ? Container(
                        // decoration: UIHelper.roundedBorderWithColor(15, Colors.blue),
                        // child: Icon(Icons.portrait),
                        child: Icon(Icons.account_circle, size: 50, color: Colors.grey),
                        width: 60,
                        height: 60,
                      )
                    : ClipRRect(borderRadius: BorderRadius.circular(20.0), child: UIHelper.getImage(imgUrl, 60, 60)),
                UIHelper.horizontalSpaceSmall,
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //Text(memberinfo['name'] ?? '').fontSize(15).fontWeight(FontWeight.w500),
                    Text(mobileName).fontSize(15).fontWeight(FontWeight.w500),
                    UIHelper.verticalSpaceTiny,

                    TextField(
                      keyboardType: TextInputType.number,
                      //data['mother_weight'].toString(),
                      // controller: _textFieldController..text = motherWeight,
                      onChanged: (value) {
                        // print("jbj" + value);
                        // motherWeight = value;
                        // setState(() {
                        //   motherWeight = value;
                        // });
                      },
                      // inputFormatters: [
                      //   new WhitelistingTextInputFormatter(RegExp(r'^(\d+)?\.?\d{0,2}')),
                      // ],
                      inputFormatters: [
                        // is able to enter lowercase letters

                        FilteringTextInputFormatter.allow(RegExp(r'^(\d+)?\.?\d{0,2}')),
                      ],
                      decoration: InputDecoration(hintText: "Email"),
                    ),

                    TextField(
                      keyboardType: TextInputType.number,
                      //data['mother_weight'].toString(),
                      controller: _textFieldController..text = motherWeight,
                      onChanged: (value) {
                        print("jbj" + value);
                        motherWeight = value;
                        setState(() {
                          motherWeight = value;
                        });
                      },
                      // inputFormatters: [
                      //   new WhitelistingTextInputFormatter(RegExp(r'^(\d+)?\.?\d{0,2}')),
                      // ],
                      inputFormatters: [
                        // is able to enter lowercase letters

                        FilteringTextInputFormatter.allow(RegExp(r'^(\d+)?\.?\d{0,2}')),
                      ],
                      decoration: InputDecoration(hintText: "Mobile Number"),
                    ),
                  ],
                )),
              ],
            ),
            insetPadding: EdgeInsets.all(10),
            actions: <Widget>[
              FlatButton(
                color: Colors.red,
                textColor: Colors.white,
                child: Text('CANCEL'),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: _textFieldController,
                builder: (context, value, child) {
                  return ElevatedButton(
                      onPressed: value.text.isNotEmpty
                          ? () async {
                              // print(_textFieldController.text);
                              // Navigator.pop(context);
                              // await model.updateMaternityInfo(_textFieldController.text, data, data['_id']);
                            }
                          : null,
                      child: Text('Send Invite'),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.resolveWith((states) {
                          if (!states.contains(MaterialState.disabled)) {
                            return Colors.green;
                          }
                          return Colors.black12;
                        }),
                      ));
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    //List<dynamic> db_user_list = preferencesService.usersListStream!.value!;
    return Scaffold(
      body: SafeArea(
        child: ViewModelBuilder<FindFriendmodel>.reactive(
          onModelReady: (model) async {
            //   await model.getNotification();
            //model.getMemberProfile(widget.memberId);
          },
          builder: (context, model, child) {
            List<dynamic> dbUserList = widget.searchby ? model.searchBy_lists : preferencesService.usersListStream!.value!;
            return dbUserList != null
                ? ListTileTheme(
                    contentPadding: EdgeInsets.all(10),
                    iconColor: Colors.red,
                    textColor: Colors.black54,
                    tileColor: fieldBgColor,
                    style: ListTileStyle.list,
                    dense: true,
                    child: ListView.builder(
                      itemCount: dbUserList.length ?? 0,
                      itemBuilder: (BuildContext context, int index) {
                        // Contact c = db_user_list!.elementAt(index);
                        dynamic getUserData = dbUserList.elementAt(index);
                        String imgUrl = "";
                        if (getUserData['azureBlobStorageLink'] != null) {
                          imgUrl = '${ApiService.fileStorageEndPoint}${getUserData['azureBlobStorageLink']}';
                        }
                        return Column(children: [
                          Card(
                              margin: EdgeInsets.all(5),
                              child: ListTile(
                                onTap: () {},
                                leading: imgUrl == '' || imgUrl.contains('null')
                                    ? Container(
                                        // decoration: UIHelper.roundedBorderWithColor(15, Colors.blue),
                                        // child: Icon(Icons.portrait),
                                        child: Icon(Icons.account_circle, size: 50, color: Colors.grey),
                                        width: 60,
                                        height: 60,
                                      )
                                    : Container(
                                        // decoration: UIHelper.roundedBorderWithColor(15, Colors.blue),
                                        // child: Icon(Icons.portrait),
                                        child: ClipRRect(borderRadius: BorderRadius.circular(40.0), child: UIHelper.getImage(imgUrl, 35, 50)),
                                        width: 60,
                                        height: 60,
                                      ),
                                title: Text(getUserData['name']),
                                trailing: ElevatedButton(
                                    onPressed: () async {
                                      // finalList<dynamic> db = preferencesService.usersListStream!.value!;
                                      // dynamic s = c.phones;
                                      // dynamic selected_person = {};
                                      String receiverId = getUserData['_id'];
                                      Loader.show(context);
                                      await model.inviteSwarUser(receiverId);
                                      Loader.hide();
                                    },
                                    child: Text('Invite').textColor(Colors.white),
                                    style: ButtonStyle(
                                        minimumSize: MaterialStateProperty.all(Size(90, 28)),
                                        elevation: MaterialStateProperty.all(0),
                                        backgroundColor: MaterialStateProperty.all(Colors.green),
                                        shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))))),
                              )),
                        ]);
                      },
                    ),
                  )
                : Center(
                    child: CircularProgressIndicator(),
                  );
          },
          viewModelBuilder: () => FindFriendmodel(),
        ),
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
//}

// class ContactDetailsPage extends StatelessWidget {
//   ContactDetailsPage(this._contact, {required this.onContactDeviceSave});

//   final Contact _contact;
//   final Function(Contact) onContactDeviceSave;

//   _openExistingContactOnDevice(BuildContext context) async {
//     try {
//       var contact = await ContactsService.openExistingContact(_contact, iOSLocalizedLabels: false);
//       if (onContactDeviceSave != null) {
//         onContactDeviceSave(contact);
//       }
//       Navigator.of(context).pop();
//     } on FormOperationException catch (e) {
//       switch (e.errorCode) {
//         case FormOperationErrorCode.FORM_OPERATION_CANCELED:
//         case FormOperationErrorCode.FORM_COULD_NOT_BE_OPEN:
//         case FormOperationErrorCode.FORM_OPERATION_UNKNOWN_ERROR:
//         default:
//           print(e.toString());
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(_contact.displayName ?? ""),
//         actions: <Widget>[
// //          IconButton(
// //            icon: Icon(Icons.share),
// //            onPressed: () => shareVCFCard(context, contact: _contact),
// //          ),
//           IconButton(
//             icon: Icon(Icons.delete),
//             onPressed: () => ContactsService.deleteContact(_contact),
//           ),
//           IconButton(
//             icon: Icon(Icons.update),
//             onPressed: () => Navigator.of(context).push(
//               MaterialPageRoute(
//                 builder: (context) => UpdateContactsPage(
//                   contact: _contact,
//                 ),
//               ),
//             ),
//           ),
//           IconButton(icon: Icon(Icons.edit), onPressed: () => _openExistingContactOnDevice(context)),
//         ],
//       ),
//       body: SafeArea(
//         child: ListView(
//           children: <Widget>[
//             ListTile(
//               title: Text("Name"),
//               trailing: Text(_contact.givenName ?? ""),
//             ),
//             ListTile(
//               title: Text("Middle name"),
//               trailing: Text(_contact.middleName ?? ""),
//             ),
//             ListTile(
//               title: Text("Family name"),
//               trailing: Text(_contact.familyName ?? ""),
//             ),
//             ListTile(
//               title: Text("Prefix"),
//               trailing: Text(_contact.prefix ?? ""),
//             ),
//             ListTile(
//               title: Text("Suffix"),
//               trailing: Text(_contact.suffix ?? ""),
//             ),
//             // ListTile(
//             //   title: Text("Birthday"),
//             //   trailing: Text(_contact.birthday != null ? DateFormat('dd-MM-yyyy').format(_contact.birthday) : ""),
//             // ),
//             ListTile(
//               title: Text("Company"),
//               trailing: Text(_contact.company ?? ""),
//             ),
//             ListTile(
//               title: Text("Job"),
//               trailing: Text(_contact.jobTitle ?? ""),
//             ),
//             ListTile(
//               title: Text("Account Type"),
//               trailing: Text((_contact.androidAccountType != null) ? _contact.androidAccountType.toString() : ""),
//             ),
//             AddressesTile(_contact.postalAddresses),
//             ItemsTile("Phones", _contact.phones),
//             ItemsTile("Emails", _contact.emails)
//           ],
//         ),
//       ),
//     );
//   }
// }

// class AddressesTile extends StatelessWidget {
//   AddressesTile(this._addresses);

//   final List<PostalAddress> _addresses;

//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: <Widget>[
//         ListTile(title: Text("Addresses")),
//         Column(
//           children: [
//             for (var a in _addresses)
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                 child: Column(
//                   children: <Widget>[
//                     ListTile(
//                       title: Text("Street"),
//                       trailing: Text(a.street ?? ""),
//                     ),
//                     ListTile(
//                       title: Text("Postcode"),
//                       trailing: Text(a.postcode ?? ""),
//                     ),
//                     ListTile(
//                       title: Text("City"),
//                       trailing: Text(a.city ?? ""),
//                     ),
//                     ListTile(
//                       title: Text("Region"),
//                       trailing: Text(a.region ?? ""),
//                     ),
//                     ListTile(
//                       title: Text("Country"),
//                       trailing: Text(a.country ?? ""),
//                     ),
//                   ],
//                 ),
//               ),
//           ],
//         ),
//       ],
//     );
//   }
// }

// class ItemsTile extends StatelessWidget {
//   ItemsTile(this._title, this._items);

//   final List<Item> _items;
//   final String _title;

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: <Widget>[
//         ListTile(title: Text(_title)),
//         Column(
//           children: [
//             for (var i in _items)
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                 child: ListTile(
//                   title: Text(i.label ?? ""),
//                   trailing: Text(i.value ?? ""),
//                 ),
//               ),
//           ],
//         ),
//       ],
//     );
//   }
// }

// class AddContactPage extends StatefulWidget {
//   @override
//   State<StatefulWidget> createState() => _AddContactPageState();
// }

// class _AddContactPageState extends State<AddContactPage> {
//   Contact contact = Contact();
//   PostalAddress address = PostalAddress(label: "Home");
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Add a contact"),
//         actions: <Widget>[
//           TextButton(
//             onPressed: () {
//               _formKey.currentState!.save();
//               contact.postalAddresses = [address];
//               ContactsService.addContact(contact);
//               Navigator.of(context).pop();
//             },
//             child: Icon(Icons.save, color: Colors.white),
//           )
//         ],
//       ),
//       body: Container(
//         padding: EdgeInsets.all(12.0),
//         child: Form(
//           key: _formKey,
//           child: ListView(
//             children: <Widget>[
//               TextFormField(
//                 decoration: const InputDecoration(labelText: 'First name'),
//                 onSaved: (v) => contact.givenName = v,
//               ),
//               TextFormField(
//                 decoration: const InputDecoration(labelText: 'Middle name'),
//                 onSaved: (v) => contact.middleName = v,
//               ),
//               TextFormField(
//                 decoration: const InputDecoration(labelText: 'Last name'),
//                 onSaved: (v) => contact.familyName = v,
//               ),
//               TextFormField(
//                 decoration: const InputDecoration(labelText: 'Prefix'),
//                 onSaved: (v) => contact.prefix = v,
//               ),
//               TextFormField(
//                 decoration: const InputDecoration(labelText: 'Suffix'),
//                 onSaved: (v) => contact.suffix = v,
//               ),
//               TextFormField(
//                 decoration: const InputDecoration(labelText: 'Phone'),
//                 onSaved: (v) => contact.phones = [Item(label: "mobile", value: v)],
//                 keyboardType: TextInputType.phone,
//               ),
//               TextFormField(
//                 decoration: const InputDecoration(labelText: 'E-mail'),
//                 onSaved: (v) => contact.emails = [Item(label: "work", value: v)],
//                 keyboardType: TextInputType.emailAddress,
//               ),
//               TextFormField(
//                 decoration: const InputDecoration(labelText: 'Company'),
//                 onSaved: (v) => contact.company = v,
//               ),
//               TextFormField(
//                 decoration: const InputDecoration(labelText: 'Job'),
//                 onSaved: (v) => contact.jobTitle = v,
//               ),
//               TextFormField(
//                 decoration: const InputDecoration(labelText: 'Street'),
//                 onSaved: (v) => address.street = v,
//               ),
//               TextFormField(
//                 decoration: const InputDecoration(labelText: 'City'),
//                 onSaved: (v) => address.city = v,
//               ),
//               TextFormField(
//                 decoration: const InputDecoration(labelText: 'Region'),
//                 onSaved: (v) => address.region = v,
//               ),
//               TextFormField(
//                 decoration: const InputDecoration(labelText: 'Postal code'),
//                 onSaved: (v) => address.postcode = v,
//               ),
//               TextFormField(
//                 decoration: const InputDecoration(labelText: 'Country'),
//                 onSaved: (v) => address.country = v,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class UpdateContactsPage extends StatefulWidget {
//   UpdateContactsPage({required this.contact});

//   final Contact contact;

//   @override
//   _UpdateContactsPageState createState() => _UpdateContactsPageState();
// }

// class _UpdateContactsPageState extends State<UpdateContactsPage> {
//   Contact? contact;
//   PostalAddress address = PostalAddress(label: "Home");
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

//   @override
//   void initState() {
//     super.initState();
//     contact = widget.contact;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         padding: EdgeInsets.all(12.0),
//         child: Form(
//           key: _formKey,
//           child: ListView(
//             children: <Widget>[
//               TextFormField(
//                 initialValue: contact!.givenName ?? "",
//                 decoration: const InputDecoration(labelText: 'First name'),
//                 onSaved: (v) => contact!.givenName = v,
//               ),
//               TextFormField(
//                 initialValue: contact!.middleName ?? "",
//                 decoration: const InputDecoration(labelText: 'Middle name'),
//                 onSaved: (v) => contact!.middleName = v,
//               ),
//               // TextFormField(
//               //   initialValue: contact.familyName ?? "",
//               //   decoration: const InputDecoration(labelText: 'Last name'),
//               //   onSaved: (v) => contact.familyName = v,
//               // ),
//               // TextFormField(
//               //   initialValue: contact.prefix ?? "",
//               //   decoration: const InputDecoration(labelText: 'Prefix'),
//               //   onSaved: (v) => contact.prefix = v,
//               // ),
//               // TextFormField(
//               //   initialValue: contact.suffix ?? "",
//               //   decoration: const InputDecoration(labelText: 'Suffix'),
//               //   onSaved: (v) => contact.suffix = v,
//               // ),
//               TextFormField(
//                 decoration: const InputDecoration(labelText: 'Phone'),
//                 onSaved: (v) => contact!.phones = [Item(label: "mobile", value: v)],
//                 keyboardType: TextInputType.phone,
//               ),
//               TextFormField(
//                 decoration: const InputDecoration(labelText: 'E-mail'),
//                 onSaved: (v) => contact!.emails = [Item(label: "work", value: v)],
//                 keyboardType: TextInputType.emailAddress,
//               ),
//               TextFormField(
//                 initialValue: contact!.company ?? "",
//                 decoration: const InputDecoration(labelText: 'Company'),
//                 onSaved: (v) => contact!.company = v,
//               ),
//               TextFormField(
//                 initialValue: contact!.jobTitle ?? "",
//                 decoration: const InputDecoration(labelText: 'Job'),
//                 onSaved: (v) => contact!.jobTitle = v,
//               ),
//               TextFormField(
//                 initialValue: address.street ?? "",
//                 decoration: const InputDecoration(labelText: 'Street'),
//                 onSaved: (v) => address.street = v,
//               ),
//               TextFormField(
//                 initialValue: address.city ?? "",
//                 decoration: const InputDecoration(labelText: 'City'),
//                 onSaved: (v) => address.city = v,
//               ),
//               TextFormField(
//                 initialValue: address.region ?? "",
//                 decoration: const InputDecoration(labelText: 'Region'),
//                 onSaved: (v) => address.region = v,
//               ),
//               TextFormField(
//                 initialValue: address.postcode ?? "",
//                 decoration: const InputDecoration(labelText: 'Postal code'),
//                 onSaved: (v) => address.postcode = v,
//               ),
//               TextFormField(
//                 initialValue: address.country ?? "",
//                 decoration: const InputDecoration(labelText: 'Country'),
//                 onSaved: (v) => address.country = v,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
