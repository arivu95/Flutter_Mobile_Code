import 'dart:math';

import 'package:documents_module/src/ui/uploads/uploads_viewmodel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jiffy/src/jiffy.dart';
import 'package:stacked/stacked.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/app/pref_util.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/services/call_manager.dart';
import 'package:swarapp/services/connectycube_services.dart';
import 'package:swarapp/services/pushnotification_service.dart';
import 'package:swarapp/shared/app_bar.dart';
import 'package:swarapp/shared/app_colors.dart';
import 'package:swarapp/shared/app_static_bar.dart';
import 'package:swarapp/shared/custom_dialog_box.dart';
import 'package:swarapp/shared/flutter_overlay_loader.dart';
import 'package:swarapp/shared/image_cropper.dart';
import 'package:swarapp/shared/screen_size.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:user_module/src/ui/bookings/bookings_view_model.dart';
import 'package:user_module/user_module.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:jiffy/jiffy.dart';
import 'package:stacked_services/stacked_services.dart';

class ManageBookingsView extends StatefulWidget {
  dynamic doctorDetails;
  dynamic patienDetails;
  String time;
  String date;
  String doctorId;
  String patientId;
  String qualification;
  String passcode;
  ManageBookingsView(
      {Key? key, required this.doctorDetails, required this.time, required this.date, required this.doctorId, required this.patientId, required this.qualification, required this.patienDetails, required this.passcode})
      : super(key: key);

  @override
  State<ManageBookingsView> createState() => _ManageBookingsViewState();
}

class _ManageBookingsViewState extends State<ManageBookingsView> with WidgetsBindingObserver {
  BookingsViewModel modelRef = BookingsViewModel();
  TextEditingController reasonController = TextEditingController();
  String img_url = '';
  List documents_urls = [];
  String memberId = preferencesService.userId;
  Jiffy slotDate = Jiffy();
  String timeZone = '';
  ConnectyCubeServices connectyCubeServices = locator<ConnectyCubeServices>();

  void initState() {
    if (widget.patienDetails['health_issue_reason'] != null) {
      reasonController.text = widget.patienDetails['health_issue_reason'];
    }
    if (widget.patienDetails['appointment_upload_documents'] != null && widget.patienDetails['appointment_upload_documents'].length > 0) {
      for (int i = 0; i < widget.patienDetails['appointment_upload_documents'].length; i++) {
        documents_urls.add('${ApiService.fileStorageEndPoint}${widget.patienDetails['appointment_upload_documents'][i]}');
      }
    }

    super.initState();
  }

  Future getAttachNotes(String type, FileType fileType, BookingsViewModel model) async {
    if (type == "camera") {
      String path = '';
      String notes_Path = '';
      final notes_pickedFile = await picker.getImage(source: fileType == FileType.video ? ImageSource.camera : ImageSource.gallery, maxWidth: 480);

      if (notes_pickedFile != null) {
        await Get.to(() => ImgCropper(
            index: 0,
            imagePath: notes_pickedFile.path,
            onCropComplete: (path) {
              setState(() {
                notes_Path = path;
              });
            }));
        documents_urls.insert(0, notes_Path);
        Loader.show(context);
        await model.addPatientDocument(notes_Path, widget.patienDetails['_id'], reasonController.text);
        Loader.hide();
      }
    } else {
      String notes_Path = '';
      final FilePickerResult? notes_pickedFile = await FilePicker.platform.pickFiles(type: FileType.custom, allowMultiple: false, allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'xls', 'xlsx']);
      if (notes_pickedFile != null) {
        String path = notes_pickedFile.paths.last!;

        setState(() {
          notes_Path = path;
        });
        if (notes_Path.toString().contains("mp4") || notes_Path.toString().contains("mp3")) {
          return showDialog(
              context: context,
              builder: (BuildContext context) {
                return CustomDialogBox(
                  title: "Not Allowed !",
                  descriptions: "Video Files not allowed",
                  descriptions1: "",
                  text: "OK",
                );
              });
        } else {
          documents_urls.insert(0, notes_Path);
          Loader.show(context);
          await model.addPatientDocument(
            notes_Path,
            widget.patienDetails['_id'],
            reasonController.text,
          );
          Loader.hide();
          print(path);
        }
      }
    }
  }

  Widget addHeader(BuildContext context, bool isBackBtnVisible) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
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
              Text('Manage Bookings').fontSize(16).fontWeight(FontWeight.w600),
            ],
          ),
        ],
      ),
    );
  }

  Widget listofAppointmentCard(BuildContext context, BookingsViewModel model) {
    if (widget.date != null) {
      slotDate = Jiffy(widget.date);
    }
    dynamic doctorDetails = widget.doctorDetails['doctor_profile_id'];

    if (widget.doctorDetails['azureBlobStorageLink'] != null) {
      img_url = '${ApiService.fileStorageEndPoint}${widget.doctorDetails['azureBlobStorageLink']}';
      // img_url = '${ApiService.fileStorageEndPoint}${note_img.toString()}';
    }

    if (widget.patienDetails["shift"] != 'evening' && widget.patienDetails["shift"] != 'afternoon') {
      timeZone = 'AM';
    } else {
      timeZone = 'PM';
    }

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SingleChildScrollView(
            child: Container(
                padding: EdgeInsets.only(left: 5, right: 5, top: 5, bottom: 10),
                width: Screen.width(context) / 1.10,
                decoration: UIHelper.allcornerRadiuswithbottomShadow(15, 15, 15, 15, Colors.white),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(alignment: Alignment.center, width: Screen.width(context) / 2.3, child: Text('Appointment Date').fontSize(10)),
                            UIHelper.verticalSpaceSmall,
                            Container(
                                padding: EdgeInsets.only(bottom: 5),
                                alignment: Alignment.center,
                                height: 20,
                                width: Screen.width(context) / 2.3,
                                child: Text(slotDate.format('dd MMM yyyy') + ' , ' + widget.time + ' ' + timeZone).fontSize(12).bold()),
                          ],
                        ),
                        Spacer(
                          flex: 1,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(alignment: Alignment.center, width: Screen.width(context) / 2.3, child: Text('Appointment Mode').fontSize(10)),
                            UIHelper.verticalSpaceSmall,
                            Container(
                                height: 20,
                                width: Screen.width(context) / 2.3,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    FittedBox(
                                      child: widget.patienDetails['services_type'] != null
                                          ? widget.patienDetails['services_type'] == "Online"
                                              ? Container(
                                                  padding: EdgeInsets.only(bottom: 5),
                                                  alignment: Alignment.topCenter,
                                                  child: Icon(
                                                    Icons.videocam,
                                                    size: 20,
                                                  ),
                                                )
                                              : Container(
                                                  padding: EdgeInsets.only(bottom: 5),
                                                  alignment: Alignment.topCenter,
                                                  child: Image.asset(
                                                    'assets/home_visit_img.png',
                                                    fit: BoxFit.none,
                                                  ),
                                                )
                                          : Container(
                                              padding: EdgeInsets.only(bottom: 5),
                                              alignment: Alignment.topCenter,
                                              child: Image.asset(
                                                'assets/home_visit_img.png',
                                                fit: BoxFit.none,
                                              ),
                                            ),
                                    ),
                                    SizedBox(width: 3),
                                    widget.patienDetails['services_type'] != null
                                        ? widget.patienDetails['services_type'] == "Online"
                                            ? Text('Online Consultation').fontSize(12).bold()
                                            : Text(widget.patienDetails['services_type']).fontSize(12).bold()
                                        : Text(''),
                                  ],
                                )),
                          ],
                        ),
                      ],
                    ),
                    // UIHelper.verticalSpaceNormal,
                    // Spacer(
                    //   flex: 1,
                    // ),

                    Divider(
                      thickness: 1,
                      color: Colors.grey,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 3, right: 3),
                      child: Row(
                        children: [
                          Column(
                            children: [
                              Container(
                                height: 120,
                                width: 80,
                                // color: Colors.blue,
                                child: Stack(alignment: Alignment.center, children: [
                                  Positioned(
                                    width: 80,
                                    height: 120,
                                    child: Container(
                                      decoration: BoxDecoration(color: disabledColor, border: Border.all(color: disabledColor), borderRadius: BorderRadius.all(Radius.circular(5.0))),
                                      child: InkWell(
                                        child: img_url != ''
                                            ? ClipRRect(
                                                borderRadius: BorderRadius.only(topLeft: Radius.circular(5), topRight: Radius.circular(5)),
                                                child: Image.network(
                                                  img_url,
                                                  fit: BoxFit.cover,
                                                ),
                                              )
                                            : ClipRRect(
                                                borderRadius: BorderRadius.only(topLeft: Radius.circular(5), topRight: Radius.circular(5)),
                                                child: Icon(
                                                  Icons.person,
                                                  size: 50,
                                                )),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                      bottom: 0,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.blue,
                                          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(5.0), bottomRight: Radius.circular(5.0)),
                                        ),
                                        width: 80,
                                        child: Center(
                                            child: Text(
                                          'Verified',
                                          style: TextStyle(color: Colors.white),
                                        )),
                                      ))
                                ]),
                              ),
                            ],
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          // UIHelper.horizontalSpaceSmall,
                          Container(
                            padding: EdgeInsets.only(top: 5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(widget.doctorDetails['name'], overflow: TextOverflow.ellipsis).bold(),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(width: 100, child: Text(widget.doctorDetails['specialization'][0].toString(), overflow: TextOverflow.ellipsis).fontSize(12)),
                                    Container(
                                        child: Text(
                                                widget.doctorDetails['doctor_profile_id']['experience'] != null && doctorDetails['experience'].length != 0
                                                    ? doctorDetails['experience'][0]['work_experience'] + ' ' 'years'
                                                    : '',
                                                overflow: TextOverflow.ellipsis)
                                            .fontSize(12)),
                                  ],
                                ),
                                SizedBox(
                                  height: 1,
                                ),
                                Container(width: Screen.width(context) / 1.8, child: Text(widget.qualification.toString(), overflow: TextOverflow.ellipsis)),
                                SizedBox(
                                  height: 1,
                                ),
                                Row(
                                  children: [
                                    Text('Insurance', overflow: TextOverflow.ellipsis),
                                    doctorDetails['insurance'] != null && doctorDetails['insurance'].length != 0 ? Icon(Icons.done, size: 18, color: Colors.green) : Icon(Icons.cancel, size: 18, color: activeColor),
                                    UIHelper.horizontalSpaceMedium,
                                    UIHelper.horizontalSpaceSmall,
                                    Container(
                                      alignment: Alignment.center,
                                      width: 100,
                                      decoration: BoxDecoration(color: Colors.green.shade300, borderRadius: BorderRadius.circular(5), boxShadow: [
                                        BoxShadow(color: Colors.yellow.shade200, offset: Offset(1, -2), blurRadius: 5),
                                        BoxShadow(color: Colors.green.shade200, offset: Offset(-1, 2), blurRadius: 5),
                                      ]),
                                      child: Text('OTP - ' + widget.passcode.toString()).bold(),
                                    )
                                  ],
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_pin,
                                      color: locationColor,
                                      size: 20,
                                    ),
                                    Container(width: Screen.width(context) / 2, child: Text(widget.doctorDetails['address'], overflow: TextOverflow.ellipsis).bold()),
                                  ],
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  children: [
                                    Container(
                                        width: Screen.width(context) / 2.6,
                                        child: Row(
                                          children: [
                                            Container(width: 15, child: Text('₹', style: TextStyle(color: activeColor, fontSize: 16)).bold()),
                                            widget.patienDetails['fees'] != null ? Text(widget.patienDetails['fees'], style: TextStyle(fontSize: 16)).bold() : Text(''),
                                            SizedBox(
                                              width: 3,
                                            ),
                                            widget.patienDetails['isPaid'] == true
                                                ? CircleAvatar(backgroundColor: Colors.green, radius: 10, child: Icon(Icons.done, size: 18, color: Colors.white))
                                                : CircleAvatar(backgroundColor: activeColor, radius: 10, child: Icon(Icons.cancel, size: 18, color: Colors.white)),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Container(width: 35, child: Text('paid')),
                                          ],
                                        )),
                                    widget.patienDetails['isBlock'] == true
                                        ? Container(
                                            decoration: BoxDecoration(
                                              color: activeColor,
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(5.0),
                                              ),
                                            ),
                                            alignment: Alignment.center,
                                            height: 30,
                                            width: 80,
                                            child: GestureDetector(
                                              onTap: () async {
                                                String slotId = widget.patienDetails['_id'];
                                                setState(() {
                                                  userInfo['canceled_by'] = 'User';
                                                  userInfo['status'] = 'Decline';
                                                });
                                                print(userInfo);
                                                Loader.show(context);
                                                final response = await model.cancelSlot(slotId, userInfo);
                                                await model.getbookingList();
                                                print(userInfo);
                                                Loader.hide();
                                                Navigator.pop(context);
                                              },
                                              child: Text(
                                                'Cancel',
                                                style: TextStyle(color: Colors.white),
                                              ).bold(),
                                            ))
                                        : Container(
                                            decoration: BoxDecoration(
                                              color: disabledColor,
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(5.0),
                                              ),
                                            ),
                                            alignment: Alignment.center,
                                            height: 30,
                                            width: 80,
                                            child: GestureDetector(
                                              onTap: () async {
                                                //   String slotId = data['_id'];
                                                //   setState(() {
                                                //     userInfo['canceled_by'] = 'User';
                                                //     userInfo['status'] = 'Decline';
                                                //   });
                                                //   print(userInfo);
                                                //   Loader.show(context);
                                                //   final response = await model.cancelSlot(slotId, userInfo);
                                                //  await model.getbookingList();
                                                //   print(userInfo);
                                                //   Loader.hide();
                                              },
                                              child: Text(
                                                'Canceled',
                                                style: TextStyle(color: Colors.white),
                                              ).bold(),
                                            ))
                                  ],
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                )),
          ),
          UIHelper.verticalSpaceSmall,
        ],
      ),
    );
  }

  Widget reasonDetailsCard(BuildContext context, BookingsViewModel model) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: UIHelper.roundedBorderWithColorWithShadow(6, Colors.white),
      child: Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text('Prepare for this appointments').bold()],
        ),
        UIHelper.verticalSpaceTiny,
        Row(
          children: [Text('Short reason for request')],
        ),
        UIHelper.verticalSpaceTiny,
        Row(
          children: [
            Column(
              children: [
                Container(
                  width: Screen.width(context) / 1.18,
                  child: FormBuilderTextField(
                    style: TextStyle(color: Colors.black),
                    name: 'health_issue_reason',
                    autocorrect: false,
                    controller: reasonController,
                    textCapitalization: TextCapitalization.sentences,
                    onChanged: (value) async {},
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      contentPadding: EdgeInsets.only(left: 5),
                      hintText: 'Write your reason..',
                      hintStyle: TextStyle(color: Colors.black),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: disabledColor),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: disabledColor),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      focusedErrorBorder: UIHelper.getInputBorder(1),
                      errorBorder: UIHelper.getInputBorder(1),
                    ),
                    onEditingComplete: () async {
                      if (FocusScope.of(context).isFirstFocus) {
                        FocusScope.of(context).requestFocus(new FocusNode());
                      }
                      if (reasonController.text.length > 50) {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return CustomDialogBox(
                                title: "Alert !",
                                descriptions: "Only 50 characters are allowed reason",
                                descriptions1: "",
                                text: "OK",
                              );
                            });

                        return;
                      } else {
                        model.addPatientDocument('', widget.patienDetails['_id'], reasonController.text);
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
        UIHelper.verticalSpaceTiny,
        Row(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [Text('Health Records')],
        ),
        UIHelper.verticalSpaceTiny,
        Container(
          // color: Colors.blue,
          padding: EdgeInsets.only(left: 5, bottom: 15, top: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.grey,
              width: 0.5,
            ),
          ),
          height: Screen.height(context) / 3.5,
          width: Screen.width(context) / 1,
          child: Column(
            children: <Widget>[
              Expanded(
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: documents_urls.length,
                    itemBuilder: (BuildContext context, int index) {
                      String filePath = documents_urls[index];
                      String filename = filePath.split('/').last;
                      return Row(
                        children: [
                          Container(
                            padding: EdgeInsets.only(bottom: 25),
                            width: 100,
                            child: Column(
                              children: [
                                documents_urls[index] != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8.0),
                                        child: Image.file(
                                          File(documents_urls[index]),
                                          fit: BoxFit.cover,
                                          height: 80,
                                          width: 80,
                                          errorBuilder: (context, error, stackTrace) {
                                            //filename
                                            return filename.toLowerCase().contains('.pdf')
                                                ? Image.asset('assets/PDF.png')
                                                : filename.toLowerCase().contains('.docx')
                                                    ? Image.asset('assets/word_icon.png')
                                                    : filename.toLowerCase().contains('.xxls') || filename.toLowerCase().contains('.xls')
                                                        ? Image.asset('assets/excel_icon.png')
                                                        : ClipRRect(borderRadius: BorderRadius.circular(8), child: UIHelper.getImage(filePath, 80, 80));
                                          },
                                        ),
                                      )
                                    : Container(),
                                Container(
                                    child: Text(
                                  documents_urls[index].split('/').last.toString(),
                                  style: TextStyle(overflow: TextOverflow.ellipsis),
                                )),
                              ],
                            ),
                          ),
                          SizedBox(width: 5)
                        ],
                      );
                    }),
              ),
              UIHelper.horizontalSpaceLarge,
              Center(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: Colors.black12),
                    child: InkWell(
                      onTap: () {
                        getAttachNotes('camera', FileType.video, model);
                      },
                      child: Icon(
                        Icons.camera_alt,
                      ),
                    ),
                  ),
                  UIHelper.horizontalSpaceMedium,
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: Colors.black12),
                    child: InkWell(
                      onTap: () {
                        getAttachNotes('', FileType.custom, model);
                      },
                      child: Transform.rotate(
                        angle: 45 * pi / 60,
                        child: Icon(
                          Icons.attach_file,
                          size: 20,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              )),
            ],
          ),
        ),
        UIHelper.verticalSpaceSmall
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SwarAppStaticBar(),
      body: SafeArea(
          top: false,
          child: Container(
            alignment: Alignment.center,
            child: SingleChildScrollView(
              child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  width: Screen.width(context),
                  child: ViewModelBuilder<BookingsViewModel>.reactive(
                    onModelReady: (model) {
                      modelRef = model;
                      model.getPatientDocument(widget.patientId, widget.doctorId);
                    },
                    builder: (context, model, child) {
                      return
                          //  model.isBusy
                          //     ? Container(child: Center(child: CircularProgressIndicator()))
                          //     :

                          Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          addHeader(context, true),
                          SizedBox(
                            height: 20,
                          ),
                          listofAppointmentCard(context, model),
                          reasonDetailsCard(context, model) // Expanded(
                        ],
                      );
                    },
                    viewModelBuilder: () => BookingsViewModel(),
                  )),
            ),
          )),
    );
  }
}
