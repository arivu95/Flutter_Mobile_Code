import 'package:connectycube_sdk/connectycube_chat.dart';
import 'package:connectycube_sdk/connectycube_sdk.dart';
import 'package:documents_module/src/ui/downloads/share_internal_doc_viewmodel.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:swarapp/shared/app_colors.dart';
import 'package:swarapp/shared/app_static_bar.dart';
import 'package:swarapp/shared/custom_dialog_box.dart';
import 'package:swarapp/shared/flutter_overlay_loader.dart';
import 'package:swarapp/shared/screen_size.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:swarapp/ui/startup/terms_view.dart';

import 'download_detail_viewmodel.dart';

class ShareInternalDocumentsView extends StatefulWidget {
  final List<String> docIds;
  final String categoryId;
  final dynamic dataList;
  final dynamic userListId;
//  ShareInternalDocumentsView({Key? key, required this.docIds, required this.fileUrl, required this.dataList}) : super(key: key);
  ShareInternalDocumentsView({Key? key, required this.docIds, required this.dataList, required this.categoryId, required this.userListId}) : super(key: key);

  @override
  _ShareInternalDocumentsViewState createState() => _ShareInternalDocumentsViewState();
}

class _ShareInternalDocumentsViewState extends State<ShareInternalDocumentsView> {
  TextEditingController searchController = TextEditingController();

  String names = '';
  List<CubeUser> selectedGroupUsers = [];
  List<CubeDialog> selectedcubeDialogs = [];
  List<String> listIds = [];
  List<int> indexIds = [];
  List<String> dialodIds = [];
  late bool isLoading;
  String? imageUrl;
  File? imageFile;
  bool isfriend = false;
  void updateNameList(ShareInternalDocumentsViewModel model) {
    List selectedNames = model.selectedMembers.map((e) {
      return e['member_first_name'];
    }).toList();
    setState(() {
      names = selectedNames.join(', ');
    });
  }

  Widget showSearchField(BuildContext context, ShareInternalDocumentsViewModel model) {
    return SizedBox(
      height: 38,
      child: TextField(
        controller: searchController,
        textCapitalization: TextCapitalization.sentences,
        onChanged: (value) {
          model.filterUser(value);
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
                      searchController.text = '';
                      model.filterUser('');
                      FocusManager.instance.primaryFocus!.unfocus();
                    }),
            contentPadding: EdgeInsets.only(left: 20),
            enabledBorder: UIHelper.getInputBorder(1, radius: 24, borderColor: Color(0xFFCCCCCC)),
            focusedBorder: UIHelper.getInputBorder(1, radius: 24, borderColor: Color(0xFFCCCCCC)),
            focusedErrorBorder: UIHelper.getInputBorder(1, radius: 24, borderColor: Color(0xFFCCCCCC)),
            errorBorder: UIHelper.getInputBorder(1, radius: 24, borderColor: Color(0xFFCCCCCC)),
            filled: true,
            hintStyle: new TextStyle(color: Colors.grey[800]),
            hintText: "Search",
            fillColor: Colors.white70),
      ),
    );
  }

  Future uploadImageFileCustom(bool isDocument, String path, List<CubeDialog> selectedcubeDialogs) async {
    File docPath = File(path);
    uploadFile(docPath, isPublic: true, onProgress: (progress) {
      log("uploadImageFile progress= $progress");
    }).then((cubeFile) {
      var url = cubeFile.getPublicUrl();
      //attachment.name = cubeFile.name;
      for (var dialg in selectedcubeDialogs) {
        onSendChatAttachment(url, isDocument, cubeFile, dialg);
      }
      setState(() {
        isLoading = false;
        // Loader.hide();
      });
    }).catchError((ex) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: 'This file is not an image');
    });
  }

  //void onSendChatAttachment(String? url, bool isDocument, CubeFile cubeFile,List<CubeDialog> _cubeDialog) async {
  void onSendChatAttachment(String? url, bool isDocument, CubeFile cubeFile, CubeDialog _cubeDialog) async {
    if (isDocument) {
      final attachment = CubeAttachment();
      attachment.id = cubeFile.hashCode.toString();
      // attachment.type = CubeAttachmentType.AUDIO_TYPE;
      attachment.name = cubeFile.name;
      attachment.contentType = cubeFile.contentType;
      attachment.url = url;
      attachment.height = 200;
      attachment.width = 200;
      final message = createCubeMsg();
      message.body = "Attachment";
      message.attachments = [attachment];
      // for(var dialg in _cubeDialog ){
      //   onSendMessage(message,dialg);
      // }
      //  Future.forEach(_cubeDialog, (CubeDialog dialg) async {
      onSendMessage(message, _cubeDialog);
      // });

      return;
    }
    var decodedImage;
    if (imageFile != null) decodedImage = await decodeImageFromList(imageFile!.readAsBytesSync());

    final attachment = CubeAttachment();
    attachment.id = cubeFile.hashCode.toString();
    attachment.type = CubeAttachmentType.IMAGE_TYPE;
    attachment.contentType = cubeFile.contentType;
    attachment.url = url;
    attachment.height = decodedImage != null ? decodedImage.height : attachment.height;
    attachment.width = decodedImage != null ? decodedImage.width : attachment.width;
    final message = createCubeMsg();
    message.body = "Attachment";
    message.attachments = [attachment];
    //  Future.forEach(_cubeDialog, (CubeDialog dialg) async {
    //      onSendMessage(message,dialg);
    //     });
    onSendMessage(message, _cubeDialog);
    // for(var dialg in _cubeDialog ){
    //     onSendMessage(message,dialg);
    //   }
  }

  CubeMessage createCubeMsg() {
    var message = CubeMessage();

    message.dateSent = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    message.markable = true;
    message.saveToHistory = true;

    return message;
  }

  void onSendMessage(CubeMessage message, CubeDialog _cubeDialog) async {
    log("onSendMessage message= $message");
    await _cubeDialog.sendMessage(message);
    //message.senderId = _cubeUser.id;
    message.senderId = _cubeDialog.userId;
    // addMessageToListView(message);
    // listScrollController.animateTo(0.0, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
  }

//it may need -old widget
  Widget getBubbleItem(CubeDialog dialog, DownloadDetailViewmodel model, bool isactive) {
    print(model.ccIds);
    List getOppid = dialog.occupantsIds!;
    List currentUsers = widget.userListId;
    // current_users.remove(cubeDialog.userId);
    print(preferencesService.userInfo['connectycube_id'].toString());
    getOppid.remove(preferencesService.userInfo['connectycube_id']);
    //  getOppid.remove('4836146');
    print(currentUsers);
    bool isExits = false;
    int i = 0;
    while (i < currentUsers.length) {
      print(i);
      if (currentUsers[i] == getOppid[0]) {
        isactive = true;
        break;
      }
      i++;
    }

    print(isactive);
    return isactive
        ? GestureDetector(
            onTap: () {
              // if (widget.isGroup) {
              setState(() {
                if (listIds.contains(dialog.dialogId)) {
                  // dialodIds.remove(dialog.dialogId);
                  listIds.remove(dialog.dialogId);
                  selectedcubeDialogs.remove(dialog);
                  // selectedGroupUsers.remove(dialog);
                } else {
                  //  dialog.deliverMessage(message)
                  selectedcubeDialogs.add(dialog);
                  listIds.add(dialog.dialogId!);

                  //  selectedGroupUsers.add(dialog.getUser());
                  //dialodIds.add(dialog.dialogId!);
                }
              });
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: UIHelper.getProfileImageWithInitials(dialog.type == 2 ? dialog.photo! : getPrivateUrlForUid(dialog.photo)!, 36, 36, dialog.name!),
                    ),
                    listIds.contains(dialog.dialogId)
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Container(
                              color: activeColor,
                              width: 36,
                              height: 36,
                              child: Icon(Icons.done, color: Colors.white),
                            ),
                          )
                        : SizedBox(),
                  ],
                ),
                UIHelper.horizontalSpaceSmall,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    UIHelper.verticalSpaceSmall,
                    Text(dialog.name!).fontSize(14).fontWeight(FontWeight.w600),
                    UIHelper.verticalSpaceMedium,
                    Container(
                      height: 1,
                      color: Colors.black12,
                      width: Screen.width(context) - 100,
                    ),
                    UIHelper.verticalSpaceSmall,
                  ],
                )
              ],
            ),
          )
        : Container();
  }

  Widget getBubbleRow(CubeUser user) {
    return GestureDetector(
      onTap: () async {
        print(user.id);
        if (listIds.contains(user.id.toString())) {
          setState(() {
            listIds = [];
            indexIds = [];
          });
        } else {
          setState(() {
            listIds = [user.id.toString()];
            indexIds = [user.id!];
          });
        }
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: UIHelper.getProfileImageWithInitials(getPrivateUrlForUid(user.avatar)!, 36, 36, user.fullName!),
              ),
              listIds.contains(user.id.toString())
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        color: activeColor,
                        width: 36,
                        height: 36,
                        child: Icon(Icons.done, color: Colors.white),
                      ),
                    )
                  : SizedBox(),
            ],
          ),
          UIHelper.horizontalSpaceSmall,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UIHelper.verticalSpaceSmall,
              Text(user.fullName!).fontSize(14).fontWeight(FontWeight.w600),
              UIHelper.verticalSpaceMedium,
              Container(
                height: 1,
                color: Colors.black12,
                width: Screen.width(context) - 100,
              ),
              UIHelper.verticalSpaceSmall,
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        //appBar: SwarAppBar(2),
        appBar: SwarAppStaticBar(),
        body: Container(
            padding: EdgeInsets.only(left: 16, right: 16),
            child: ViewModelBuilder<DownloadDetailViewmodel>.reactive(
                onModelReady: (model) async {
                  // model.getActiveMembers();
                  // model.getUserList('');
                  //model.getRecentMembers();
                  await model.getRecentMembers();
                  if (model.ccIds.length > 0) {
                    await model.getUserList('');
                  }
                  //  model.getRecentMembers();
                  // if (model.ccIds.length > 0) {
                  //   await model.getUserList('');
                  // }
                },
                builder: (context, model, child) {
                  print(model.sourceUsers.toString());
                  return Column(children: [
                    UIHelper.addHeader(context, "Share Document", true),
                    UIHelper.verticalSpaceSmall,
                    // showSearchField(context, model),
                    UIHelper.verticalSpaceSmall,
                    Expanded(
                        child: Container(
                            decoration: UIHelper.roundedBorderWithColor(8, subtleColor),
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            // color: Colors.yellow,
                            child: !model.isBusy
                                ? model.searchUsers.length > 0
                                    ? ListView.builder(
                                        itemCount: model.searchUsers.length,
                                        itemBuilder: (context, index) {
                                          return getBubbleRow(model.searchUsers[index]);
                                          // return getRowItem(context, model.activeMembers[index], model);
                                        })
                                    : Center(
                                        child: Text("No members added"),
                                      )
                                : Center(
                                    child: CircularProgressIndicator(),
                                  ))),
                    // UIHelper.verticalSpaceSmall,
                    Container(
                      padding: EdgeInsets.all(8),
                      width: Screen.width(context) - 30,
                      decoration: UIHelper.roundedBorderWithColor(8, Colors.black12),
                      child: Stack(
                        children: [
                          Row(
                            children: [
                              Expanded(child: Text(names).fontSize(12).fontWeight(FontWeight.w500)),
                              GestureDetector(
                                onTap: () async {
                                  if (listIds.length == 0) {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return CustomDialogBox(
                                            title: "Alert !",
                                            descriptions: "Please select any user",
                                            descriptions1: "",
                                            text: "OK",
                                          );
                                        });
                                  } else {
                                    if (listIds.length > 0) {
                                      Loader.show(context);
                                      print(widget.dataList);
                                      model.getFilesByCategory(widget.categoryId);
                                      List<String> getFileList = await model.downloadDocs(widget.docIds, widget.dataList);
                                      // List<String>get_file=widget.dataList['img_url'];
                                      print(getFileList.toString());

                                      CubeDialog newDialog = CubeDialog(CubeDialogType.PRIVATE, occupantsIds: indexIds);
                                      createDialog(newDialog).then((createdDialog) {
                                        selectedcubeDialogs.add(newDialog);
                                      }).catchError((error) {
                                        // Loader.hide();
                                        print(error);
                                      });

                                      setState(() {
                                        isLoading = true;
                                      });
                                      Future.forEach(getFileList, (dynamic file) async {
                                        bool isDoc = file.toString().toLowerCase().contains('.jpg') || file.toString().toLowerCase().contains('.png') ? false : true;
                                        await uploadImageFileCustom(isDoc, file, selectedcubeDialogs);
                                      });
                                      Loader.hide();
                                      // widget.onFilesSelected(filesList);
                                      Get.back();
                                    }
                                  }
                                },
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: UIHelper.roundedBorderWithColor(16, activeColor),
                                  child: Icon(Icons.send, color: Colors.white),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    UIHelper.verticalSpaceSmall,
                  ]);
                },
                viewModelBuilder: () => DownloadDetailViewmodel())));
  }
}
