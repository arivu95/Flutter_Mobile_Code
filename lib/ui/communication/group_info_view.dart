import 'dart:io';

import 'package:connectycube_sdk/connectycube_sdk.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/services/preferences_service.dart';
import 'package:swarapp/shared/app_colors.dart';
import 'package:swarapp/shared/app_static_bar.dart';
import 'package:swarapp/shared/flutter_overlay_loader.dart';
import 'package:swarapp/shared/screen_size.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:styled_widget/styled_widget.dart';

class GroupInfoView extends StatefulWidget {
  List<CubeUser> participants;
  GroupInfoView({Key? key, required this.participants}) : super(key: key);

  @override
  _GroupInfoViewState createState() => _GroupInfoViewState();
}

class _GroupInfoViewState extends State<GroupInfoView> {
  String localPath = '';
  final picker = ImagePicker();

  TextEditingController searchController = TextEditingController();
  Widget addGroupSubjectWidget(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            showFilePickerSheet('type');
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: localPath.isNotEmpty
                ? Image.file(
                    File(localPath),
                    width: 36,
                    height: 36,
                    fit: BoxFit.cover,
                  )
                : Container(
                    color: Colors.black26,
                    width: 36,
                    height: 36,
                    child: Icon(Icons.camera_alt, color: activeColor),
                  ),
          ),
        ),
        UIHelper.horizontalSpaceSmall,
        Expanded(
          child: SizedBox(
            height: 20,
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                // model.updateOnTextSearch(value);
              },
              style: TextStyle(fontSize: 14),
              decoration: new InputDecoration(
                  hintStyle: new TextStyle(color: Colors.grey[800], fontSize: 11), hintText: "Type group subject here", fillColor: fieldBgColor),
            ),
          ),
        ),
        UIHelper.horizontalSpaceMedium,
      ],
    );
  }

  Future getImage(String type, FileType fileType) async {
    String path = '';

    final pickedFile = await picker.getImage(source: fileType == FileType.video ? ImageSource.camera : ImageSource.gallery, maxWidth: 480);
    if (pickedFile != null) {
      path = pickedFile.path;
      setState(() {
        localPath = path;
      });

      // await Get.to(() => ImageCropView(
      //     index: -1,
      //     imagePath: path,
      //     onCropComplete: (path) {
      //       setState(() {
      //         localPath = path;
      //       });
      //     }));

    }
    print(path);
  }

  void showFilePickerSheet(String type) {
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(15.0)),
        ),
        builder: (BuildContext context) {
          return Container(
            height: 200,
            child: ListView(
              children: [
                UIHelper.verticalSpaceSmall,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Text('Select a type')],
                ),
                UIHelper.verticalSpaceSmall,
                UIHelper.hairLineWidget(),
                ListTile(
                  onTap: () {
                    Get.back();
                    getImage(type, FileType.video);
                  },
                  visualDensity: VisualDensity.compact,
                  title: Text('Camera'),
                ),
                UIHelper.hairLineWidget(),
                ListTile(
                  onTap: () {
                    Get.back();
                    getImage(type, FileType.image);
                  },
                  visualDensity: VisualDensity.compact,
                  //visualDensity: VisualDensity.standard,
                  // visualDensity:VisualDensity.comfortable,
                  title: Text('Photo Library'),
                ),
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: SwarAppStaticBar(),
        backgroundColor: Colors.white,
        body: Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            width: Screen.width(context),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              UIHelper.verticalSpaceSmall,
              UIHelper.addHeader(context, "New Group", true),
              UIHelper.verticalSpaceMedium,
              addGroupSubjectWidget(context),
              UIHelper.verticalSpaceSmall,
              Text('Provide a group subject and optional group icon').fontSize(10),
              UIHelper.verticalSpaceSmall,
              Stack(
                children: [
                  Column(
                    children: [
                      UIHelper.verticalSpaceMedium,
                      Container(
                        height: Screen.height(context) / 2,
                        width: Screen.width(context),
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        decoration: UIHelper.roundedBorderWithColor(8, fieldBgColor),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Participants: ${widget.participants.length}').fontSize(11),
                            UIHelper.verticalSpaceSmall,
                            Expanded(
                              child: GridView.builder(
                                  shrinkWrap: true,
                                  itemCount: widget.participants.length,
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 4,
                                    crossAxisSpacing: 8,
                                    mainAxisSpacing: 8,
                                    // childAspectRatio: 1,
                                  ),
                                  itemBuilder: (context, index) {
                                    CubeUser user = widget.participants[index];
                                    return Container(
                                      // color: Colors.yellow,
                                      // height: 60,
                                      child: Column(
                                        children: [
                                          UIHelper.verticalSpaceTiny,
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(18),
                                            child: UIHelper.getProfileImageWithInitials(getPrivateUrlForUid(user.avatar)!, 36, 36, user.fullName!),
                                            // child: Container(
                                            //   color: Colors.black12,
                                            //   width: 36,
                                            //   height: 36,
                                            //   child: Icon(Icons.portrait),
                                            // ),
                                          ),
                                          UIHelper.verticalSpaceTiny,
                                          Text(
                                            user.fullName!,
                                            maxLines: 1,
                                          ).fontSize(10).textAlignment(TextAlign.center),
                                        ],
                                      ),
                                    );
                                  }),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          if (searchController.text.isNotEmpty) {
                            print(searchController.text);
                            FocusManager.instance.primaryFocus!.unfocus();
                            List<int> occupantsIdList = [];
                            for (var user in widget.participants) {
                              occupantsIdList.add(user.id!);
                            }

                            Loader.show(context);
                            String photo = '';
                            if (localPath.isNotEmpty) {
                              File avatarFile = File(localPath);
                              CubeFile cfile = await uploadFile(avatarFile, isPublic: true);
                              photo = cfile.getPublicUrl()!;
                            }

                            CubeDialog newDialog =
                                CubeDialog(CubeDialogType.GROUP, name: searchController.text, description: "", occupantsIds: occupantsIdList, photo: photo);

                            CubeDialog createdDialog = await createDialog(newDialog);
                            locator<PreferencesService>().isNewGroupCreated = true;
                            locator<PreferencesService>().newDialog = createdDialog;
                            Loader.hide();
                            locator<NavigationService>().popRepeated(2);

                            // createDialog(newDialog).then((createdDialog) {
                            //   // Get.back(result: {'dialog': newDialog});
                            //   // Get.u
                            //   // Get.offNamedUntil('chat_list', (route) => false);
                            //   locator<PreferencesService>().isNewGroupCreated = true;
                            //   locator<PreferencesService>().newDialog = createdDialog;
                            //   locator<NavigationService>().popRepeated(2);
                            // }).catchError((error) {
                            //   print(error);
                            // });
                          } else {
                            UIHelper.showToast('Enter group name');
                          }
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Container(
                            color: activeColor,
                            width: 36,
                            height: 36,
                            child: Icon(Icons.done, color: Colors.white),
                          ),
                        ),
                      ),
                      UIHelper.horizontalSpaceSmall,
                    ],
                  ),
                ],
              )
            ])));
  }
}
