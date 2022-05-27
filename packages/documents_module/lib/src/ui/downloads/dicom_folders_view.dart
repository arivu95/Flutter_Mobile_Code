import 'package:connectycube_sdk/connectycube_chat.dart';
import 'package:documents_module/src/ui/downloads/dicom_folders_viewmodel.dart';
import 'package:documents_module/src/ui/downloads/download_detail_view.dart';
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

class DicomFolderView extends StatefulWidget {
  final String categoryId;
  final String categoryTitle;
  DicomFolderView({Key? key, required this.categoryId, required this.categoryTitle}) : super(key: key);

  @override
  _DicomFolderViewState createState() => _DicomFolderViewState();
}

class _DicomFolderViewState extends State<DicomFolderView> {
  DicomFolderViewmodel modelRef = DicomFolderViewmodel();
  List<String> docIds = [];
  List<String> img_lst = [];
  List<dynamic> data_List = [];
  bool isLongPressOn = false;
  bool isHorizontalScroll = false;
  bool isEditable = false;
  String codeDialog = "";
  String valueText = "";
  String editable = "";
  DateTime currentDate = DateTime.now();
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

  //for doalog boxShadow
  Future<void> _displayTextInputDialog(BuildContext context, String filename, String docid, model) async {
    void initState() {
      super.initState();
      _textFieldController = TextEditingController(text: filename);
    }

    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Edit'),
            content: TextField(
              //controller: _textFieldController,
              controller: TextEditingController(text: filename),
              onChanged: (value) {
                setState(() {
                  valueText = value;
                });
                // _textFieldController = TextEditingController(text: filename);
              },
              decoration: InputDecoration(hintText: filename),
            ),
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
              FlatButton(
                color: Colors.green,
                textColor: Colors.white,
                child: Text('OK'),
                onPressed: () async {
                  if (valueText == "") {
                    //cursorColor: Color(0XFFFFCC00);
                    Navigator.pop(context);
                    cursorColor:
                    Colors.red;
                  } else {
                    setState(() {
                      docIds.clear();
                      Navigator.pop(context);
                    });

                    _textFieldController = TextEditingController(text: valueText);
                    _controller = TextEditingController(text: valueText);
                    locator<PreferencesService>().isReload.value == false;
                    await model.renameFile(docid, valueText);
                    model.getFilesByCategory(widget.categoryId);
                    valueText = "";
                  }
                },
              ),
            ],
          );
        });
  }

//
  Future<void> _selectDate(BuildContext context, DicomFolderViewmodel model) async {
    final DateTime? pickedDate = (await showDatePicker(context: context, cancelText: 'Clear', initialDate: currentDate, firstDate: DateTime(1900), lastDate: DateTime.now()));
    if (pickedDate != null) {
      setState(() {
        currentDate = pickedDate;
      });

      print(currentDate);
      Jiffy selectedDt = Jiffy(currentDate);
      searchController.text = '';
      model.filteredDateStr = selectedDt.format('dd MMM yyyy');
      model.sortMode = 'date';
      model.refreshView();
    } else {
      print('Cancel Picked');
      searchController.text = '';
      model.filteredDateStr = '';
      model.sortMode = 'date';
      model.refreshView();
    }
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

  Widget PdfDialog(BuildContext context, String fileUrl) {
    final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
    return Dialog(
      insetPadding: EdgeInsets.all(15),
      child: Container(
        child: Stack(
            // child: SingleChildScrollView(
            children: [
              SingleChildScrollView(
                child: SfPdfViewer.network(
                  fileUrl,
                  //'https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf',
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

  Widget showSearchField(BuildContext context, DicomFolderViewmodel model) {
    return SizedBox(
      height: 38,
      child: TextField(
        controller: searchController,
        textCapitalization: TextCapitalization.sentences,
        onChanged: (value) {
          model.updateOnTextSearch(value);
        },
        style: TextStyle(fontSize: 14),
        decoration: new InputDecoration(
            prefixIcon: Icon(
              Icons.search,
              color: Colors.grey,
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
                      model.updateOnTextSearch('');
                      FocusManager.instance.primaryFocus!.unfocus();
                    }),
            contentPadding: EdgeInsets.only(left: 20),
            enabledBorder: UIHelper.getInputBorder(1, radius: 24, borderColor: Color(0xFFCCCCCC)),
            focusedBorder: UIHelper.getInputBorder(1, radius: 24, borderColor: Color(0xFFCCCCCC)),
            focusedErrorBorder: UIHelper.getInputBorder(1, radius: 24, borderColor: Color(0xFFCCCCCC)),
            errorBorder: UIHelper.getInputBorder(1, radius: 24, borderColor: Color(0xFFCCCCCC)),
            filled: true,
            hintStyle: new TextStyle(color: Colors.grey[800]),
            hintText: "Search folders",
            fillColor: Colors.white70),
      ),
    );
  }

  void onDocSelect(String docid, String imgUrl, dynamic data) {
    if (docIds.contains(docid)) {
      docIds.remove(docid);
      img_lst.remove(imgUrl);
      data_List.remove(data);
    } else {
      docIds.add(docid);
      img_lst.add(imgUrl);
      data_List.add(data);
    }
    setState(() {});
    if (docIds.length == 0) {
      setState(() {
        isLongPressOn = false;
      });
    }
  }

  Widget recentItem(BuildContext context, int index, dynamic data, DicomFolderViewmodel model) {
    String fileName = data['fileName'] ?? '';
    if (fileName.length > 10) {
      fileName = fileName.substring(0, 9);
    }
    List imageUrls = data['azureBlobStorageLink'];
                            
    return GestureDetector(
      onTap: () async {
        String filename = imageUrls[0];
        String dicomFilename = filename.split('.DCM').first;
        await Get.to(() => DownloadDetailView(
              categoryId: widget.categoryId,
              categoryTitle: widget.categoryTitle,
              dicomfilename: dicomFilename,
            ));
      },
      child: Stack(
        children: [
          Column(
            children: [
              Image.asset(
                'assets/folder.png',
                height: 60,
                width: 80,
              ),
              UIHelper.verticalSpaceTiny,
              Padding(padding: new EdgeInsets.all(1.0), child: new Text((fileName), overflow: TextOverflow.ellipsis)),
              UIHelper.verticalSpaceTiny,
              UIHelper.horizontalSpaceSmall,
            ],
          ),
        ],
      ),
    );
  }

  Widget showHorizontalList(List<dynamic> records, DicomFolderViewmodel model) {
    return Container(
      width: Screen.width(context),
      height: 100,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemCount: records.length,
          itemBuilder: (context, index) {
            dynamic data = records[index];
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: recentItem(context, index, data, model),
            );
          }),
    );
  }

  Widget showFileList(BuildContext context, DicomFolderViewmodel model) {
    //_controller.addListener(_printValue);
    return model.fileSections.length == 0
        ? Container(
            child: Center(
              child: Text('No files found'),
            ),
          )
        : ListView.builder(
            itemCount: model.fileDates.length,
            itemBuilder: (context, index) {
              String dateStr = model.fileDates[index];
              if (model.fileSections[dateStr] == null) {
                return SizedBox();
              }
              List records = model.fileSections[dateStr]!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(dateStr).fontSize(13).fontWeight(FontWeight.w600),
                  UIHelper.verticalSpaceSmall,
                  isHorizontalScroll
                      ? showHorizontalList(records, model)
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: records.length,
                          itemBuilder: (context, index) {
                            dynamic data = records[index];
                            List imageUrls = data['azureBlobStorageLink'];
                            Jiffy date = Jiffy(data['createdAt']);
                            String filename = data['fileName'];
                            return GestureDetector(
                              onTap: () async {
                                String filename = imageUrls[0];
                                String dicomFilename = filename.split('.DCM').first;
                                await Get.to(() => DownloadDetailView(
                                      categoryId: widget.categoryId,
                                      categoryTitle: widget.categoryTitle,
                                      dicomfilename: dicomFilename,
                                    ));
                              },
                              child: Container(
                                padding: EdgeInsets.only(bottom: 10),
                                child: Row(
                                  children: [
                                    Stack(
                                      children: [
                                        Container(
                                            width: 50,
                                            height: 50,
                                            child: Image.asset(
                                              'assets/folder.png',
                                            )),
                                      ],
                                    ),
                                    UIHelper.horizontalSpaceSmall,
                                    UIHelper.verticalSpaceLarge,
                                    Flexible(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          !isEditable
                                              ? Text(filename)
                                              : TextFormField(
                                                  initialValue: filename,
                                                  textInputAction: TextInputAction.done,
                                                  controller: _controller,
                                                  onFieldSubmitted: (value) {
                                                    setState(() => {isEditable = false, filename = value});
                                                  }),
                                          // UIHelper.verticalSpaceTiny,
                                          UIHelper.horizontalSpaceMedium,
                                          Row(
                                            children: [
                                              Text(date.format('MM/dd/yyy')).fontSize(9),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    UIHelper.horizontalSpaceSmall,
                                  ],
                                ),
                              ),
                            );
                          }),
                  UIHelper.hairLineWidget()
                ],
              );
            });
  }

// child:
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: subtleColor,
        //appBar: SwarAppBar(2),
        appBar: SwarAppStaticBar(),
        resizeToAvoidBottomInset: false,
        body: ViewModelBuilder<DicomFolderViewmodel>.reactive(
            onModelReady: (model) {
              modelRef = model;
              model.getFoldersByCategory(widget.categoryId);
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
                          showSearchField(context, model),
                          UIHelper.verticalSpaceSmall,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      if (isLongPressOn) {
                                        setState(() {
                                          docIds.clear();
                                          isLongPressOn = false;
                                        });
                                        return;
                                      }
                                      Get.back();
                                    },
                                    child: Icon(
                                      Icons.arrow_back,
                                      size: 20,
                                    ),
                                  ),
                                  UIHelper.horizontalSpaceSmall,
                                 Text(widget.categoryTitle).bold().fontSize(16),
                                ],
                              ),
                              Row(
                                children: [
                                  GestureDetector(
                                    child: Image.asset('assets/calendar_icon.png'),
                                    onTap: () {
                                      _selectDate(context, model);
                                    },
                                  ),
                                  // UIHelper.horizontalSpaceSmall,
                                  PopupMenuButton(
                                    padding: EdgeInsets.zero,
                                    icon: Image.asset('assets/sort_icon.png'),
                                    onSelected: (value) {
                                      searchController.text = '';
                                      model.sortMode = value.toString();
                                      model.refreshView();
                                    },
                                    itemBuilder: (context) {
                                      return <PopupMenuEntry<String>>[
                                        const PopupMenuItem<String>(
                                          value: 'name',
                                          child: Text(
                                            'Sort by\nRecord\nName',
                                            style: TextStyle(fontSize: 13),
                                          ),
                                        ),
                                        const PopupMenuItem<String>(
                                          value: 'date',
                                          child: Text(
                                            'Sort by\nDate',
                                            style: TextStyle(fontSize: 13),
                                          ),
                                        ),
                                      ];
                                    },
                                  ),
                                  // UIHelper.horizontalSpaceSmall,
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        isHorizontalScroll = !isHorizontalScroll;
                                      });
                                    },
                                    child: isHorizontalScroll ? Image.asset('assets/list_view_icon.png') : Image.asset('assets/grid_view_icon.png'),
                                  ),
                                ],
                              )
                            ],
                          ),
                          // UIHelper.verticalSpaceSmall,
                          UIHelper.hairLineWidget(),
                          UIHelper.verticalSpaceSmall,
                          Expanded(child: showFileList(context, model)),
                          UIHelper.verticalSpaceSmall,
                        ],
                      ),
                    );
            },
            viewModelBuilder: () => DicomFolderViewmodel()));
  }
}
