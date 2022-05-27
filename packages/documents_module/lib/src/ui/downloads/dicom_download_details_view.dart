
import 'package:connectycube_sdk/connectycube_chat.dart';
import 'package:documents_module/src/ui/downloads/download_detail_viewmodel.dart';
import 'package:documents_module/src/ui/downloads/share_internal_doc_view.dart';
import 'package:documents_module/src/ui/medical_records/covid_record_view.dart';
import 'package:documents_module/src/ui/medical_records/vacc_mat_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:share/share.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/app/pref_util.dart';
import 'package:swarapp/services/preferences_service.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/shared/app_bar.dart';
import 'package:swarapp/shared/app_colors.dart';
import 'package:swarapp/shared/app_static_bar.dart';
import 'package:swarapp/shared/flutter_overlay_loader.dart';
import 'package:swarapp/shared/inappbrowser.dart';
import 'package:swarapp/shared/pdf_viewer.dart';
import 'package:swarapp/shared/screen_size.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:pinch_zoom/pinch_zoom.dart';
import 'package:swarapp/shared/custom_dialog_box.dart';
import 'package:swarapp/services/connectycube_services.dart';
import 'package:swarapp/ui/startup/terms_view.dart';
import 'package:connectycube_sdk/connectycube_sdk.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:member_module/src/ui/members/widgets/video_player_widget.dart';

class DicomDownloadDetailView extends StatefulWidget {
  final String categoryId;
  final String categoryTitle;
  final String dicomfilename;
  DicomDownloadDetailView({Key? key, required this.categoryId, required this.categoryTitle, required this.dicomfilename}) : super(key: key);

  @override
  _DownloadDetailViewState createState() => _DownloadDetailViewState();
}

class _DownloadDetailViewState extends State<DicomDownloadDetailView> {
  DownloadDetailViewmodel modelRef = DownloadDetailViewmodel();

  bool isHorizontalScroll = false;

  TextEditingController searchController = TextEditingController();
  TextEditingController _controller = TextEditingController();
  TextEditingController _textFieldController = TextEditingController();
  PageController sliderController = PageController(initialPage: 0, keepPage: false);
  late CubeUser? currentUser;
  ConnectyCubeServices connectyCubeServices = locator<ConnectyCubeServices>();
  List getAlertmessage = [];
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

  void getChatDialogs() async {
    currentUser = await SharedPrefs.getUser();
    await connectyCubeServices.getCubeDialogs();
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

// @override
  Widget ImageDialog(BuildContext context, String fileUrl, List imageList) {
    return Dialog(
        backgroundColor: Color.fromRGBO(105, 105, 105, 0.5),
        insetPadding: EdgeInsets.all(15),
        child: Container(
          child: Stack(
            // child: SingleChildScrollView(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: PageView.builder(
                    controller: sliderController,
                    itemCount: imageList.length,
                    itemBuilder: (context, position) {
                      return PinchZoom(
                        // image:DecorationImage(),
                        // image: Image.network(file_url),
                        image: Image.network(imageList[position]),
                        zoomedBackgroundColor: Colors.black.withOpacity(0.5),
                        resetDuration: const Duration(milliseconds: 100),
                        maxScale: 2.5,
                        onZoomStart: () {
                          print('Start zooming');
                        },
                        onZoomEnd: () {
                          print('Stop zooming');
                        },
                      );
                    }),
              ),
              Positioned(
                right: 10.0,
                top: 10.5,
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

  Widget recentItem(BuildContext context, int index, dynamic data, DownloadDetailViewmodel model) {
    String docid = data['_id'];
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

    return GestureDetector(
      onLongPress: () {},
      onTap: () async {
        (imgUrl.toLowerCase().contains('.pdf'))
            ?
            //  await showDialog(
            //     context: context,
            //     builder: (_) => PdfDialog(context, img_url),
            //   )
            await Get.to(() => PdfViewr(url: imgUrl, file_name: fileName))
            : (imgUrl.toLowerCase().contains('.docx')) || (imgUrl.toLowerCase().contains('.xxls')) || (imgUrl.toLowerCase().contains('.xls'))
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
                        builder: (_) {
                          int pageIndex = model.imageUrls.indexOf(imgUrl);
                          if (pageIndex > 0) {
                            sliderController = PageController(initialPage: pageIndex, keepPage: false);
                          }
                          return ImageDialog(context, imgUrl, model.imageUrls);
                        });
      },
      child: Stack(
        children: [
          Column(
            children: [
              imgUrl.toLowerCase().contains('.docx')
                  ? Image.asset(
                      'assets/word_icon.png',
                      fit: BoxFit.none,
                      height: 60,
                      width: 80,
                    )
                  : imgUrl.toLowerCase().contains('.pdf')
                      ? Image.asset(
                          'assets/PDF.png',
                          fit: BoxFit.none,
                          height: 60,
                          width: 80,
                        )
                      : imgUrl.toLowerCase().contains('.xxls') || imgUrl.toLowerCase().contains('.xlsx')
                          ? Image.asset(
                              'assets/excel_icon.png',
                              fit: BoxFit.none,
                              height: 60,
                              width: 80,
                            )
                          // : img_url.toLowerCase().contains('.mp4')
                          //     ? ClipRRect(child: UIHelper.getThumbnailImage(thumbnail_preview, 60, 60))
                          : imgUrl.toLowerCase().contains('.mp4')
                              ? thumbnailPreview != "" && thumbnailPreview != null
                                  ? ClipRRect(child: UIHelper.getThumbnailImage(thumbnailPreview, 60, 60))
                                  : Container(child: Center(child: Icon(Icons.smart_display, size: 60, color: Colors.grey)))
                              : ClipRRect(child: UIHelper.getImage(imgUrl, 80, 60)),
              UIHelper.verticalSpaceTiny,
              // Text(fileName).fontSize(11),
              Padding(
                  padding: new EdgeInsets.all(1.0),
                  // child: new Text(fileName).fontSize(11),
                  child: new Text((fileName), overflow: TextOverflow.ellipsis)),
              UIHelper.verticalSpaceTiny,
              // Text(date.format('dd/MM/yyy')).fontSize(9),
              UIHelper.horizontalSpaceSmall,
              // GestureDetector(
              //   child: Icon(
              //     Icons.edit,
              //     size: 12,
              //     color: activeColor,
              //   ),
              //   onTap: () {},
              // ),
            ],
          ),
        ],
      ),
    );
  }

  Widget showHorizontalList(List<dynamic> records, DownloadDetailViewmodel model) {
    return Container(
      width: Screen.width(context),
      height: 100,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemCount: records.length,
          itemBuilder: (context, index) {
            dynamic data = records[index];
            String docid = data['_id'];
            // String img_url = data['img_url'] ?? '';
            List imageUrls = data['azureBlobStorageLink'];
            String imgUrl = '';
            if (imageUrls.length > 0) {
              // img_url = imageUrls.first.toString();
              imgUrl = '${ApiService.fileStorageEndPoint}${imageUrls.first.toString()}';
            }

            String filename = data['fileName'];
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: recentItem(context, index, data, model),
            );
          }),
    );
  }

  Widget showFileList(BuildContext context, DownloadDetailViewmodel model) {
    //_controller.addListener(_printValue);
    return model.dicomFiles.length == 0
        ? Container(
            child: Center(
              child: Text('No files found'),
            ),
          )
        : Column(
            children: [
              isHorizontalScroll
                  ? showHorizontalList(model.dicomFiles, model)
                  : Expanded(
                      child: ListView.builder(
                          shrinkWrap: true,
                          // physics: NeverScrollableScrollPhysics(),
                          itemCount: model.dicomFiles.length,
                          itemBuilder: (context, index) {
                            String data = model.dicomFiles[index];
                            String imgUrl = '${ApiService.fileStorageEndPoint}${widget.categoryTitle + '/'}${data.toString()}';

                            return GestureDetector(
                              onTap: () async {
                                await showDialog(
                                    context: context,
                                    builder: (_) {
                                      return ImageDialog(context, imgUrl, [imgUrl]);
                                    });
                              },
                              child: Container(
                                padding: EdgeInsets.only(bottom: 10),
                                child: Row(
                                  children: [
                                    Stack(
                                      children: [
                                        Container(
                                          width: 46,
                                          height: 50,
                                          child: ClipRRect(child: UIHelper.getImage(imgUrl, 46, 0)),
                                        ),
                                      ],
                                    ),
                                    UIHelper.horizontalSpaceSmall,
                                    UIHelper.verticalSpaceLarge,
                                    Flexible(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(data),
                                          UIHelper.horizontalSpaceMedium,
                                          Row(
                                            children: [
                                              // Text(date.format('MM/dd/yyy')).fontSize(9),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    UIHelper.horizontalSpaceSmall,
                                    // GestureDetector(
                                    //   child: Icon(
                                    //     Icons.edit,
                                    //     size: 16,
                                    //     color: activeColor,
                                    //   ),
                                    //   onTap: () {
                                    //     //setState(()=>{isEditable});
                                    //     //docIds.setState
                                    //     // setState(()=>{isEditable=true});
                                    //     //     _displayTextInputDialog(context, filename, docid, model);
                                    //   },
                                    // ),
                                  ],
                                ),
                              ),
                            );
                          })),
            ],
          );
  }

  Widget showVerticalCategoryButtons(DownloadDetailViewmodel model) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton(
            onPressed: () async {
              // Get.to(() => SubscriptionView());
              await Get.to(() => VaccineMaternityListView(cat_Type: "Child Records"));
              model.getDicomFilesByCategory(widget.categoryId, widget.dicomfilename);
            },
            child: Text('Manage Child Records', style: TextStyle(fontWeight: FontWeight.w500)).textColor(Colors.black),
            style: ButtonStyle(
              minimumSize: MaterialStateProperty.all(Size(160, 36)),
              backgroundColor: MaterialStateProperty.all(Color(0xFFe7e7e7)),
            )),
        ElevatedButton(
            onPressed: () async {
              await Get.to(() => VaccineMaternityListView(cat_Type: "Maternity"));
              model.getDicomFilesByCategory(widget.categoryId, widget.dicomfilename);
            },
            child: Text(' Manage  Maternity  Records', style: TextStyle(fontWeight: FontWeight.w500)).textColor(Colors.black),
            style: ButtonStyle(minimumSize: MaterialStateProperty.all(Size(160, 36)), backgroundColor: MaterialStateProperty.all(Color(0xFFe7e7e7)))),
        UIHelper.verticalSpaceLarge
      ],
    );
  }

// child:
  @override
  Widget build(BuildContext context) {
    if (locator<PreferencesService>().isReload.value == true) {
      widget.categoryId == "62034da4347bca06a597c2ea" ? modelRef.getDicomFilesByCategory(widget.categoryId, widget.dicomfilename) : modelRef.getFilesByCategory(widget.categoryId);
      locator<PreferencesService>().isReload.value = false;
    }
    getAlertmessage = preferencesService.alertContentList!.where((msg) => msg['type'] == "Document_download").toList();
    return Scaffold(
        backgroundColor: subtleColor,
        //appBar: SwarAppBar(2),
        appBar: SwarAppStaticBar(),
        resizeToAvoidBottomInset: false,
        body: ViewModelBuilder<DownloadDetailViewmodel>.reactive(
            onModelReady: (model) {
              modelRef = model;
              model.getDicomFilesByCategory(widget.categoryId, widget.dicomfilename);
            },
            builder: (context, model, child) {
              return model.isBusy
                  ? Center(
                      child: UIHelper.swarPreloader(),
                    )
                  : Container(
                      padding: EdgeInsets.only(left: 16, right: 16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  UIHelper.verticalSpaceMedium,
                                  // Text(" " + preferencesService.dropdown_user_name).textColor(Colors.black).bold().fontSize(16),
                                  // Text(" " + preferencesService.dropdownuserName.value!).textColor(Colors.black).bold().fontSize(16),
                                  Container(
                                      child: StreamBuilder<String?>(
                                          stream: locator<PreferencesService>().userName.outStream,
                                          builder: (context, snapshotname) =>
                                              // !snapshotname.hasData || snapshotname.data == '' ? Text(preferencesService.dropdown_user_name).textColor(Colors.black).bold() : Text(snapshotname.data!).textColor(Colors.black).bold(),
                                              //Text(preferencesService.dropdownuserName.value!).textColor(Colors.black).bold())),
                                              Text(preferencesService.dropdown_user_name).textColor(Colors.black).bold())),
                                ],
                              )
                            ],
                          ),
                          UIHelper.verticalSpaceMedium,
                          Row(children: [
                            GestureDetector(
                              onTap: () {
                                Get.back();
                              },
                              child: Icon(
                                Icons.arrow_back,
                                size: 20,
                              ),
                            ),
                            UIHelper.horizontalSpaceSmall,
                            Text(widget.categoryTitle).bold().fontSize(12),
                          ]),
                          UIHelper.verticalSpaceSmall,
                          // UIHelper.verticalSpaceSmall,
                          UIHelper.hairLineWidget(),
                          UIHelper.verticalSpaceSmall,
                          Expanded(child: showFileList(context, model)),
                          UIHelper.verticalSpaceSmall,
                        ],
                      ),
                    );
            },
            viewModelBuilder: () => DownloadDetailViewmodel()));
  }
}
