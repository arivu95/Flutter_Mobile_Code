import 'package:connectycube_sdk/connectycube_chat.dart';
import 'package:connectycube_sdk/connectycube_sdk.dart';
import 'package:flutter/material.dart';
import 'package:swarapp/shared/app_static_bar.dart';
import 'package:swarapp/shared/flutter_overlay_loader.dart';
import 'package:swarapp/shared/screen_size.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:swarapp/shared/app_colors.dart';
import 'package:get/get.dart';

class GroupListView extends StatefulWidget {
  final CubeDialog groupDialog;
  GroupListView({Key? key, required this.groupDialog}) : super(key: key);

  @override
  _GroupListViewState createState() => _GroupListViewState();
}

class _GroupListViewState extends State<GroupListView> {
  final picker = ImagePicker();
  String localPath = '';
  String network_img_url = '';
  List<CubeUser> members = [];

  @override
  void initState() {
    super.initState();
    if (widget.groupDialog.photo!.isNotEmpty) {
      setState(() {
        network_img_url = widget.groupDialog.photo!;
      });
    }
    print(widget.groupDialog.photo);
    getGroupMembers();
  }

  Future getGroupMembers() async {
    PagedResult<CubeUser>? result = await getAllUsersByIds(widget.groupDialog.occupantsIds!.toSet());
    if (result!.totalEntries! > 0) {
      List<CubeUser> users = result.items;
      print(users.toString());
      setState(() {
        // names = nm.join(', ');
        members = users.toList();
      });
    }
  }

  Future uploadGroupImage() async {
    Loader.show(context);
    File avatarFile = File(localPath);
    CubeFile cfile = await uploadFile(avatarFile, isPublic: true);
    String dialogId = widget.groupDialog.dialogId!;

    await updateDialog(dialogId, {'photo': cfile.getPublicUrl()!});
    setState(() {
      network_img_url = cfile.getPublicUrl()!;
      widget.groupDialog.photo = network_img_url;
    });

    Loader.hide();
  }

  Future getImage(String type, FileType fileType) async {
    String path = '';
    final pickedFile = await picker.getImage(source: fileType == FileType.video ? ImageSource.camera : ImageSource.gallery, maxWidth: 480);
    if (pickedFile != null) {
      path = pickedFile.path;
      setState(() {
        localPath = path;
      });
      uploadGroupImage();
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
                  title: Text('Photo Library'),
                ),
              ],
            ),
          );
        });
  }

  Widget profileIcon(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showFilePickerSheet('type');
      },
      // print( widget.groupDialog.photo);
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(30.0),
            child: localPath.isNotEmpty
                ? Image.file(
                    File(localPath),
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  )
                // : network_img_url == ''
                : widget.groupDialog.photo == ''
                    ? Container(
                        color: subtleColor,
                        child: Icon(
                          Icons.camera_alt,
                          size: 30,
                          color: Colors.black38,
                        ),
                        width: 60,
                        height: 60,
                      )
                    : UIHelper.getImage(network_img_url, 60, 60),
          ),
          Icon(
            Icons.edit,
            size: 16,
            color: activeColor,
          ),
          SizedBox(
            width: 5,
          ),
        ],
      ),
    );
  }

  Widget getBubbleItem(CubeUser user) {
    String avatarUrl = '';
    if (user.avatar != null) {
      avatarUrl = user.avatar!;
    }
    return GestureDetector(
      onTap: () async {},
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8),
        // width: Screen.width(context) - 50,
        color: Colors.transparent,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: UIHelper.getProfileImageWithInitials(getPrivateUrlForUid(avatarUrl)!, 36, 36, user.fullName!),
            ),
            UIHelper.horizontalSpaceSmall,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.fullName! ?? '').fontSize(14).fontWeight(FontWeight.w600),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
  // widget.groupDialog.photo

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: SwarAppStaticBar(),
        //body: SafeArea(
        body: Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            width: Screen.width(context),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              UIHelper.verticalSpaceSmall,
              UIHelper.addHeader(context, widget.groupDialog.name!, true),
              UIHelper.verticalSpaceMedium,
              UIHelper.verticalSpaceMedium,
              profileIcon(context),
              UIHelper.verticalSpaceMedium,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Members').bold(),
                ],
              ),
              UIHelper.verticalSpaceSmall,
              UIHelper.hairLineWidget(),
              Expanded(
                child: ListView.separated(
                    separatorBuilder: (context, index) {
                      return Container(
                        height: 1,
                        color: Colors.black12,
                      );
                    },
                    padding: EdgeInsets.only(top: 0),
                    shrinkWrap: true,
                    itemCount: members.length,
                    itemBuilder: (context, index) {
                      return getBubbleItem(members[index]);
                    }),
              )
            ])));
  }
}
