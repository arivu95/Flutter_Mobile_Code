import 'package:documents_module/src/ui/downloads/dicom_folders_view.dart';
import 'package:documents_module/src/ui/downloads/download_detail_view.dart';
import 'package:documents_module/src/ui/downloads/downloads_viewmodel.dart';
import 'package:documents_module/src/ui/downloads/widgets/recent_download_widget.dart';
import 'package:flutter/material.dart';
import 'package:documents_module/src/ui/uploads/uploads_view.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:pinch_zoom/pinch_zoom.dart';
import 'package:stacked/stacked.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/frideos/extended_asyncwidgets.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/services/preferences_service.dart';
import 'package:swarapp/shared/app_static_bar.dart';
import 'package:swarapp/shared/inappbrowser.dart';
import 'package:swarapp/shared/pdf_viewer.dart';
import 'package:swarapp/shared/screen_size.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:swarapp/ui/startup/terms_view.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:member_module/src/ui/members/widgets/video_player_widget.dart';

class DownloadsView extends StatefulWidget {
  const DownloadsView({Key? key}) : super(key: key);

  @override
  _DownloadsViewState createState() => _DownloadsViewState();
}

class _DownloadsViewState extends State<DownloadsView> {
  final GlobalKey<RecentDownloadWidgetState> _key = GlobalKey();
  DownloadsViewmodel? modelRef;
  bool isReloaded = true;
  dynamic selectedMembers;
  String dropdown_member_id = "";
  dynamic membersList;
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();

  final MyInAppBrowser browser = new MyInAppBrowser();
  var options = InAppBrowserClassOptions(
      crossPlatform: InAppBrowserOptions(hideUrlBar: false),
      inAppWebViewGroupOptions: InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(
              javaScriptEnabled: true,
              clearCache: true,
              useShouldInterceptAjaxRequest: true,
              useShouldOverrideUrlLoading: true,
              useShouldInterceptFetchRequest: true,
              javaScriptCanOpenWindowsAutomatically: true,
              allowFileAccessFromFileURLs: true,
              allowUniversalAccessFromFileURLs: true)));

  Widget PdfDialog(BuildContext context, String fileUrl) {
    return Dialog(
      insetPadding: EdgeInsets.all(15),
      child: Container(
        child: Stack(
            // child: SingleChildScrollView(
            children: [
              SingleChildScrollView(
                child: SfPdfViewer.network(
                  fileUrl,
                  key: _pdfViewerKey,
                ),
              ),
              Positioned(
                right: 0.0,
                //top: 0.5,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: CircleAvatar(
                      radius: 14.0,
                      backgroundColor: Colors.red,
                      child: Icon(Icons.close, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ]),
      ),
    );
  }

  void launchExternalDoc(String url) async {
    try {
      //bool status = await launch(url, forceWebView: true, enableJavaScript: true);
      //print('>>>>>> ' + status.toString());
      browser.openUrlRequest(urlRequest: URLRequest(url: Uri.parse(url)), options: options);
    } catch (e) {
      print('ExEXEXEX');
      print(e.toString());
    }
  }

  Widget ImageDialog(BuildContext context, String fileUrl) {
    return Dialog(
        backgroundColor: Color.fromRGBO(105, 105, 105, 0.5),
        insetPadding: EdgeInsets.all(15),
        child: Container(
          child: Stack(
            // child: SingleChildScrollView(
            children: [
              PinchZoom(
                // image:DecorationImage(),
                image: Image.network(fileUrl),
                zoomedBackgroundColor: Colors.black.withOpacity(0.5),
                resetDuration: const Duration(milliseconds: 100),
                maxScale: 2.5,
                onZoomStart: () {
                  print('Start zooming');
                },
                onZoomEnd: () {
                  print('Stop zooming');
                },
              ),
              Positioned(
                right: 0.0,
                top: 0.5,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Align(
                    alignment: Alignment.topRight,
                    child: CircleAvatar(
                      radius: 14.0,
                      backgroundColor: Colors.red,
                      child: Icon(Icons.close, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  Widget docTypeMenuItem(String title, Widget icon, int index) {
    return GestureDetector(
      onTap: () async {
        String catId = modelRef!.getCategoryId(index);
        if (catId.isNotEmpty) {
          await Get.to(() => DownloadDetailView(
                categoryId: catId,
                categoryTitle: title,
                dicomfilename: '',
              ));
          setState(() {
            isReloaded = false;
          });
          Future.delayed(Duration(milliseconds: 500), () {
            setState(() {
              isReloaded = true;
            });
          });
        }
      },
      child: Row(
        children: [
          UIHelper.horizontalSpaceSmall,
          icon,
          UIHelper.horizontalSpaceSmall,
          Expanded(child: Text(title)),
          Icon(
            Icons.arrow_forward_ios,
            size: 14,
            color: Colors.black45,
          ),
          UIHelper.horizontalSpaceSmall,
        ],
      ),
    );
  }

  Widget dicomFileMenu(String title, Widget icon, int index) {
    return GestureDetector(
      onTap: () async {
        String catId = modelRef!.getCategoryId(index);
        if (catId.isNotEmpty) {
          await Get.to(() => DicomFolderView(
                categoryId: catId,
                categoryTitle: title,
              ));
          setState(() {
            isReloaded = false;
          });
          Future.delayed(Duration(milliseconds: 500), () {
            setState(() {
              isReloaded = true;
            });
          });
        }
      },
      child: Row(
        children: [
          UIHelper.horizontalSpaceSmall,
          icon,
          UIHelper.horizontalSpaceSmall,
          Expanded(child: Text(title)),
          Icon(
            Icons.arrow_forward_ios,
            size: 14,
            color: Colors.black45,
          ),
          UIHelper.horizontalSpaceSmall,
        ],
      ),
    );
  }

////================GET RECENT DOCUMENT==========

  Widget recentItem(BuildContext context, int index, dynamic data) {
    String fileName = data['fileName'] ?? '';
    String thumbnail = data['thumbnail_link'] ?? '';
    String thumbnailPreview = '';
    if (fileName.length > 10) {
      fileName = fileName.substring(0, 9);
    }
    if (thumbnail != null && thumbnail != "") {
      thumbnailPreview = '${ApiService.fileStorageEndPoint}$thumbnail';
    }
    Jiffy date = Jiffy(data['createdAt']);
    String imgUrl = '';
    List imageUrls = data['azureBlobStorageLink'];

    if (imageUrls.length > 0) {
      imgUrl = '${ApiService.fileStorageEndPoint}${imageUrls.first.toString()}';
    }
    print('isajd --------' + imgUrl);
    return GestureDetector(
      onTap: () async {
        (imgUrl.toLowerCase().contains('.pdf'))
            ? await Get.to(() => PdfViewr(url: imgUrl, file_name: fileName))
            : (imgUrl.toLowerCase().contains('.docx')) || (imgUrl.toLowerCase().contains('.xls')) || (imgUrl.toLowerCase().contains('.xlsx'))
                ? launchExternalDoc('https://docs.google.com/viewer?url=$imgUrl&time=${DateTime.now()}')
                : imgUrl.contains('.mp4')
                    ? await showGeneralDialog(
                        context: context,
                        pageBuilder: (BuildContext buildContext, Animation animation, Animation secondaryAnimation) {
                          return VideoPlayerWidget(
                            videoUrl: imgUrl,
                          );
                        })
                    : await showDialog(
                        context: context,
                        builder: (_) => ImageDialog(context, imgUrl),
                      );
      },
      child: Column(
        //return Column(
        children: [
          imgUrl.toLowerCase().contains('.docx')
              ? Image.asset(
                  'assets/word_icon.png',
                  fit: BoxFit.none,
                  height: 60,
                  // width: 80,
                )
              : imgUrl.toLowerCase().contains('.pdf')
                  ? Image.asset(
                      'assets/PDF.png',
                      fit: BoxFit.none,
                      height: 60,
                      // width: 80,
                    )
                  : imgUrl.toLowerCase().contains('.xlsx') || imgUrl.toLowerCase().contains('.xls')
                      ? Image.asset(
                          'assets/excel_icon.png',
                          fit: BoxFit.none,
                          height: 60,
                          // width: 80,
                        )
                      : imgUrl.toLowerCase().contains('.mp4')
                          ?
                          //Container(child: Center(child: Icon(Icons.smart_display, size: 60, color: Colors.grey)))
                          // ClipRRect(child: UIHelper.getImage(thumbnail_preview, 60, 60))
                          // ClipRRect(child: UIHelper.getThumbnailImage(thumbnail_preview, 60, 60))

                          thumbnailPreview != "" && thumbnailPreview != null
                              ? ClipRRect(child: UIHelper.getThumbnailImage(thumbnailPreview, 60, 60))
                              : Container(child: Center(child: Icon(Icons.smart_display, size: 60, color: Colors.grey)))
                          : ClipRRect(child: UIHelper.getImage(imgUrl, 60, 60)),
          UIHelper.verticalSpaceTiny,
          Text(fileName).fontSize(11),
          UIHelper.verticalSpaceTiny,
          Text(date.format('MM/dd/yyy')).fontSize(9),
        ],
      ),
    );
  }

  double sideLength = 50;
//================get recent documents===========
  Widget showUploadDownloads(BuildContext context, DownloadsViewmodel model) {
    return StreamedWidget(
        stream: preferencesService.recentdocListStream!.outStream!,
        builder: (context, snapshot) {
          List<dynamic> recentList = preferencesService.recentdocListStream!.value!;
          return recentList.length > 0
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //Text('Recent Documents').fontWeight(FontWeight.w500),
                    Padding(
                      padding: EdgeInsets.only(left: 18, right: 12),
                      child: Text(' Recent Documents').fontWeight(FontWeight.w500).bold(),
                    ),
                    UIHelper.verticalSpaceSmall,
                    model.isBusy
                        ? Container(
                            height: 100,
                            child: Center(
                              child: UIHelper.swarPreloader(),
                            ),
                          )
                        : Container(
                            width: Screen.width(context),
                            height: 100,
                            padding: EdgeInsets.only(left: 18, right: 12),
                            child: ListView.builder(
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                itemCount: recentList.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    decoration: UIHelper.roundedBorderWithColor(8, Color(0xFFEFEFEF)),
                                    margin: EdgeInsets.only(right: 8),
                                    width: 80,
                                    // height: 84,
                                    child: recentItem(context, index, recentList[index]),
                                  );
                                }),
                          ),
                    UIHelper.hairLineWidget(),
                  ],
                )
              : Column();
        });
  }

  Widget TitleField(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 10, right: 10),
      child: Row(children: [
        GestureDetector(
          onTap: () async {
            // final BottomNavigationBar navigationBar = locator<PreferencesService>().bottomTab_globalKey.currentWidget as BottomNavigationBar;
            // navigationBar.onTap!(0);
            Get.back();
          },
          child: Icon(
            Icons.arrow_back,
          ),
        ),
        UIHelper.horizontalSpaceSmall,
        Text('View / Downloads').fontSize(15).bold(),
      ]),
    );
  }

//================END= RECENT DOCUMENT==========
  Widget showSearchField(BuildContext context, DownloadsViewmodel model) {
    return StreamedWidget(
        stream: preferencesService.memebersListStream!.outStream!,
        builder: (context, snapshot) {
          List<dynamic> members = preferencesService.memebersListStream!.value!;
          return Row(
            children: [
              Text('    Hi').fontSize(18).padding(left: 1, right: 1),
              UIHelper.horizontalSpaceSmall,
              members.length > 1
                  ? DropdownButton(
                      //value: preferencesService.dropdown_user_id != null || preferencesService.dropdown_user_id != "" ? preferencesService.dropdown_user_id : model.selectedMembers,
                      //  value: model.selectedMembers,
                      value: preferencesService.dropdown_user_id,
                      items: members.map((e) {
                        return new DropdownMenuItem(
                          value: e['_id'],
                          child: new Text(e['member_first_name']).fontSize(18).bold(),
                          //child: new Text("newmem").fontSize(13),
                        );
                      }).toList(),
                      onChanged: (value) {
                        print(value);
                        //model.getMembersList(false);
                        setState(() {
                          model.selectedMembers = value.toString();
                          preferencesService.dropdown_user_id = value.toString();
                          //isChange = true;
                        });
                        model.getRecentUploads();
                        int found = members.indexWhere((val) => val['_id'] == model.selectedMembers);
                        print(found); // Output you will get is 1
                        String selectedMemberName = members[found]['member_first_name'];
                        String selectedMemberDob = members[found]['date_of_birth'];
                        String selectedMemberAge = members[found]['age'].toString();
                        print(selectedMemberName);
                        setState(() {
                          model.selectedMemberName = selectedMemberName;
                          model.selectedMemberDob = selectedMemberDob;
                          model.selectedMemberAge = selectedMemberAge;
                          //preferencesService.dropdown_user_id=
                          // isChange = true;
                        });
                        dropdown_member_id = model.selectedMembers;
                        //  preferencesService.dropdown_user_id = model.selectedMembers;
                        preferencesService.dropdown_user_name = model.selectedMemberName;
                        preferencesService.dropdownuserName.value = model.selectedMemberName.toString();
                        preferencesService.dropdown_user_dob = model.selectedMemberDob;
                        preferencesService.dropdown_user_age = model.selectedMemberAge;
                        // print('selected Membr ID IS-------------' +model.listmembers.first['age'].toString());
                      })
                  : Text(members.length > 0 ? members[0]['member_first_name'].toString() : preferencesService.userInfo['name']).fontSize(18).bold()
            ],
          );
        });
  }

  Future reloadMemberList() async {
    await modelRef!.getMembersList(false);
    setState(() {
      membersList = modelRef!.listmembers.toList();
      //modelRef.selectedMembers
    });
  }

  Widget showDoctypeMenu(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 12),
      child: Container(
        width: Screen.width(context),
        decoration: UIHelper.roundedBorderWithColor(8, Colors.white, borderColor: Colors.grey.shade400),
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            // UIHelper.verticalSpaceSmall,
            docTypeMenuItem('Registration/Insurance', Image.asset('assets/reg_insurance_icon.png'), 0),
            //UIHelper.verticalSpaceSmall,
            UIHelper.hairLineWidget(),
            UIHelper.verticalSpaceSmall,
            docTypeMenuItem('Prescription', Image.asset('assets/prescription_icon.png'), 1),
            //UIHelper.verticalSpaceSmall,
            UIHelper.hairLineWidget(),
            UIHelper.verticalSpaceSmall,
            docTypeMenuItem('Lab Report', Image.asset('assets/lr_icon.png'), 2),
            //UIHelper.verticalSpaceSmall,
            UIHelper.hairLineWidget(),
            UIHelper.verticalSpaceSmall,
            docTypeMenuItem('Medical Report', Image.asset('assets/mr_icon.png'), 3),
            //UIHelper.verticalSpaceSmall,
            UIHelper.hairLineWidget(),
            UIHelper.verticalSpaceSmall,
            docTypeMenuItem('Others', Image.asset('assets/others_icon.png'), 4),
            //UIHelper.verticalSpaceSmall,
            //UIHelper.hairLineWidget(),
            //UIHelper.verticalSpaceSmall,
            // dicomFileMenu('Dicom Viewer', Image.asset('assets/dicom.png'), 7),
            // UIHelper.verticalSpaceSmall,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (locator<PreferencesService>().isDownloadReload.value == true) {
      locator<PreferencesService>().isDownloadReload.value = false;
      if (modelRef != null) modelRef!.getMembersList(false);
    }

    return Scaffold(
      // backgroundColor: subtleColor,
      //appBar: SwarAppBar(1),
      appBar: SwarAppStaticBar(),
      body: Container(
        child: ViewModelBuilder<DownloadsViewmodel>.reactive(
            onModelReady: (model) async {
              modelRef = model;
              model.init();
              await modelRef!.getMembersList(true);
            },
            builder: (context, model, child) {
              return Column(
                children: [
                  UIHelper.verticalSpaceSmall,
                  UIHelper.horizontalSpaceSmall,
                  // model.isBusy
                  //     ?
                  //     //CircularProgressIndicator()
                  //     Center(
                  //         child: CircularProgressIndicator(),
                  //       )
                  //     :
                  TitleField(context),
                  UIHelper.verticalSpaceSmall,
                  showSearchField(context, model),
                  UIHelper.verticalSpaceSmall,
                  model.isBusy ? CircularProgressIndicator() : showUploadDownloads(context, model),
                  // Future.delayed(Duration(milliseconds: 500), () {
                  //                   setState(() {
                  //                     isReloaded = true;
                  //                   });

                  //UIHelper.verticalSpaceSmall,
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Image.asset('assets/always_care.png'),
                          UIHelper.verticalSpaceMedium,
                          showDoctypeMenu(context),
                          UIHelper.verticalSpaceSmall,
                          Padding(
                            padding: const EdgeInsets.only(left: 12, right: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                    child: GestureDetector(
                                  onTap: () async {
                                    String catId = modelRef!.getCategoryId(5);
                                    if (catId.isNotEmpty) {
                                      // Get.to(() =>
                                      //  CovidRecordView(categoryId: catId));
                                      await Get.to(() => DownloadDetailView(
                                            categoryId: catId,
                                            categoryTitle: 'C.DOC',
                                            dicomfilename: '',
                                          ));
                                      // preferencesService.onRefreshRecentDocumentOnDownload!.value = false;
                                      model.getRecentUploads();
                                    }
                                  },
                                  child: Container(
                                    height: 54,
                                    padding: EdgeInsets.all(6),
                                    decoration: UIHelper.roundedBorderWithColorWithShadow(8, Colors.white),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [Image.asset('assets/covid_record_icon.png'), UIHelper.horizontalSpaceMedium, Flexible(child: Text('C.DOC').fontSize(12).fontWeight(FontWeight.w600))],
                                    ),
                                  ),
                                )),
                                UIHelper.horizontalSpaceSmall,
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      String catId = modelRef!.getCategoryId(6);
                                      if (catId.isNotEmpty) {
                                        // Get.to(
                                        //     () => VaccineMaternityListView());

                                        Get.to(() => DownloadDetailView(
                                              categoryId: catId,
                                              categoryTitle: 'Maternity & Child vaccine record',
                                              dicomfilename: '',
                                            ));
                                      }
                                    },
                                    child: Container(
                                      height: 54,
                                      padding: EdgeInsets.all(6),
                                      // width: Screen.width(context) / 2 - 20,
                                      decoration: UIHelper.roundedBorderWithColorWithShadow(8, Colors.white),
                                      child: Row(
                                        children: [
                                          Image.asset('assets/mat_vac_icon.png'),
                                          UIHelper.horizontalSpaceSmall,
                                          // Flexible(
                                          //     child: Text(
                                          //             'Maternity & child\nvaccine record')
                                          //         .fontSize(12)
                                          //         .fontWeight(FontWeight.w600))
                                          Flexible(child: Text('Maternity & Child\nvaccine record', overflow: TextOverflow.ellipsis).fontSize(12).fontWeight(FontWeight.w600))
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          UIHelper.verticalSpaceMedium,
                        ],
                      ),
                    ),
                  )
                ],
              );
            },
            viewModelBuilder: () => DownloadsViewmodel()),
      ),
    );
  }
}
