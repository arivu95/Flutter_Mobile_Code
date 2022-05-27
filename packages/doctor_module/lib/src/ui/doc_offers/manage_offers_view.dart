import 'package:doctor_module/src/ui/doc_offers/manage_offers_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/services/preferences_service.dart';
import 'package:swarapp/shared/app_bar.dart';
import 'package:swarapp/shared/app_colors.dart';
import 'package:swarapp/shared/app_doctorprofile_bar.dart';
import 'package:swarapp/shared/custom_dialog_box.dart';
import 'package:swarapp/shared/flutter_overlay_loader.dart';
import 'package:swarapp/shared/image_cropper.dart';
import 'package:swarapp/shared/screen_size.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:stacked_services/stacked_services.dart';
import 'package:flutter/material.dart';
import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:stacked/stacked.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'dart:math' as math;
import 'package:fluttertoast/fluttertoast.dart';

// import 'package:money_converter/Currency.dart';
// import 'package:money_converter/money_converter.dart';

class ManageOffersView extends StatefulWidget {
  dynamic offerdata;
  bool newoffer;
  ManageOffersView({Key? key, this.offerdata, required this.newoffer}) : super(key: key);
  @override
  _ManageOffersViewState createState() => _ManageOffersViewState();
}

class _ManageOffersViewState extends State<ManageOffersView> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  PreferencesService preferencesService = locator<PreferencesService>();
  //Text Editor Controller Added
  TextEditingController _docController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _imgPathController = TextEditingController();
  TextEditingController _amountController = TextEditingController();
  TextEditingController _startDateController = TextEditingController();
  TextEditingController _endDateController = TextEditingController();
  TextEditingController _saveimgPathController = TextEditingController();
  final picker = ImagePicker();
  bool addOfferEnable = false;
  bool isNewOffer = false;
  List<dynamic> currencies = [];

  //Start Date End Date Initial Value assigned.
  DateTime endStarDate = DateTime.now();
  DateTime stardate_Initial = DateTime.now();
  DateTime enddate_Initial = DateTime.now();

  @override
  void initState() {
    super.initState();
    this.loadJsonData();
  }

  Future<String> loadJsonData() async {
    var jsonText = await rootBundle.loadString('assets/currencies.json');
    setState(() => currencies = json.decode(jsonText));
    return 'success';
  }

  Widget addOfferWidet(BuildContext context, FeesandOffersModel model) {
    return Container(
        decoration: UIHelper.roundedBorderWithColor(6, Colors.white, borderColor: Colors.black12),
        padding: EdgeInsets.all(15),
        child: FormBuilder(
          key: _fbKey,
          child: Column(
            children: [
              Text('Add Offer Title').fontSize(12).textColor(Colors.black38),
              UIHelper.verticalSpaceSmall,
              Container(
                width: 150,
                child: FormBuilderTextField(
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                  name: 'title',
                  controller: _titleController,
                  textCapitalization: TextCapitalization.sentences,
                  autocorrect: false,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  onChanged: (value) {},
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.only(left: 7),
                    hintText: '   Add Offer Title',
                    hintStyle: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: UIHelper.getInputBorder(1, borderColor: Colors.black38),
                    focusedBorder: UIHelper.getInputBorder(1, borderColor: Colors.black38),
                    focusedErrorBorder: UIHelper.getInputBorder(1, borderColor: Colors.black38),
                    errorBorder: UIHelper.getInputBorder(1, borderColor: activeColor),
                  ),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(context, errorText: "*Required"),
                  ]),
                ),
              ),
              UIHelper.verticalSpaceSmall,
              Row(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                Text('Start date').fontSize(10).textColor(Colors.black38),
                Text('End date').fontSize(10).textColor(Colors.black38),
              ]),
              UIHelper.verticalSpaceTiny,
              Row(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                Container(
                    width: Screen.width(context) / 2.7,
                    child: FormBuilderDateTimePicker(
                      name: "start_date",
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      initialValue: !isNewOffer && _startDateController.text != '' ? stardate_Initial : null,
                      onChanged: (DateTime? value) {
                        setState(() {
                          Jiffy _value = Jiffy(value.toString());
                          _startDateController.text = _value.format('dd/MM/yyyy');

                          endStarDate = value!;
                        });
                      },
                      style: TextStyle(
                        fontSize: 13.0,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                      firstDate: isNewOffer ? DateTime.now() : stardate_Initial,
                      inputType: InputType.date,
                      format: DateFormat("dd MMM yyyy"),
                      decoration: InputDecoration(
                        hintText: "Start Date",
                        hintStyle: TextStyle(
                          fontSize: 13.0,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                        contentPadding: EdgeInsets.only(left: 7),
                        suffixIcon: Icon(
                          Icons.calendar_today,
                          color: Colors.black38,
                          size: 20,
                        ),
                        filled: true,
                        fillColor: Colors.white70,
                        enabledBorder: UIHelper.getInputBorder(1, borderColor: Colors.black38),
                        focusedBorder: UIHelper.getInputBorder(1, borderColor: Colors.black38),
                        focusedErrorBorder: UIHelper.getInputBorder(1, borderColor: Colors.black38),
                        errorBorder: UIHelper.getInputBorder(1, borderColor: activeColor),
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(context, errorText: "*Required"),
                      ]),
                    )),
                Container(
                    width: Screen.width(context) / 2.7,
                    child: FormBuilderDateTimePicker(
                      name: "end_date",
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      enabled: _startDateController.text != '' ? true : false,
                      initialValue: !isNewOffer && _endDateController.text != '' ? enddate_Initial : null,
                      onChanged: (DateTime? value) {
                        setState(() {
                          Jiffy _value = Jiffy(value.toString());
                          _endDateController.text = _value.format('dd/MM/yyyy');
                        });
                      },
                      style: TextStyle(
                        fontSize: 13.0,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                      initialDate: endStarDate,
                      firstDate: endStarDate,
                      inputType: InputType.date,
                      format: DateFormat("dd MMM yyyy"),
                      decoration: InputDecoration(
                        hintText: "End Date",
                        hintStyle: TextStyle(
                          fontSize: 13.0,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                        contentPadding: EdgeInsets.only(left: 7),
                        suffixIcon: Icon(
                          Icons.calendar_today,
                          color: Colors.black38,
                          size: 20,
                        ),
                        filled: true,
                        fillColor: Colors.white70,
                        disabledBorder: UIHelper.getInputBorder(1, borderColor: Colors.black38),
                        enabledBorder: UIHelper.getInputBorder(1, borderColor: Colors.black38),
                        focusedBorder: UIHelper.getInputBorder(1, borderColor: Colors.black38),
                        focusedErrorBorder: UIHelper.getInputBorder(1, borderColor: Colors.black38),
                        errorBorder: UIHelper.getInputBorder(1, borderColor: activeColor),
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(context, errorText: "*Required"),
                      ]),
                    )),
              ]),
              UIHelper.verticalSpaceSmall,
              Container(
                  child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text('Offer Description').fontSize(14).bold(),
                ],
              )),
              UIHelper.verticalSpaceSmall,
              Container(
                  padding: EdgeInsets.all(5),
                  width: Screen.width(context),
                  height: 220,
                  decoration: UIHelper.roundedBorderWithColorWithShadow(6, Colors.white60),
                  child: Column(children: [
                    FormBuilderTextField(
                      controller: _descriptionController,
                      name: 'description',
                      textCapitalization: TextCapitalization.sentences,
                      autocorrect: false,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      onChanged: (value) {},
                      maxLines: 2,
                      maxLength: 50,
                      decoration: InputDecoration.collapsed(
                        hintText: "Any Description",
                      ),
                    ),
                    UIHelper.verticalSpaceTiny,
                    _imgPathController.text.isNotEmpty
                        ? SizedBox(
                            width: Screen.width(context),
                            child: recentItem(context),
                          )
                        : SizedBox(height: 100),
                    UIHelper.verticalSpaceTiny,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(children: [
                          GestureDetector(
                              onTap: () async {
                                await getcapture(context, FileType.video);
                              },
                              child: Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: UIHelper.rightcornerRadiuswithColor(8, 8, Colors.black12),
                                  child: Image.asset(
                                    'assets/black_camera.png',
                                    width: 20,
                                    height: 20,
                                    fit: BoxFit.cover,
                                  ))),
                          SizedBox(
                            width: 10,
                          ),
                          GestureDetector(
                              onTap: () async {
                                await getpick(context);
                              },
                              child: Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: UIHelper.rightcornerRadiuswithColor(8, 8, Colors.black12),
                                  child: Image.asset(
                                    'assets/black_attach.png',
                                    width: 20,
                                    height: 20,
                                    fit: BoxFit.cover,
                                  )))
                        ]),
                      ],
                    ),
                  ])),
              UIHelper.verticalSpaceSmall,
              Container(
                  padding: EdgeInsets.all(10),
                  width: Screen.width(context),
                  decoration: UIHelper.allcornerRadiuswithbottomShadow(12, 12, 12, 12, Colors.white),
                  child: Row(children: [
                    Image.asset(
                      'assets/_wallet.png',
                      width: 25,
                      height: 25,
                      fit: BoxFit.cover,
                    ),
                    UIHelper.horizontalSpaceSmall,
                    Text('Enter the Amount: ').fontSize(12).bold(),
                    UIHelper.horizontalSpaceMedium,
                    Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(0),
                      width: 100,
                      child: FormBuilderTextField(
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                        name: 'amount',
                        controller: _amountController,
                        textCapitalization: TextCapitalization.sentences,
                        autocorrect: false,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        onChanged: (value) {},
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(left: 7),
                          hintText: ' ',
                          hintStyle: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                          prefixText: preferencesService.selectedCourrencySymbol + ' ',
                          filled: true,
                          fillColor: Colors.white,
                          enabledBorder: UIHelper.getInputBorder(1, borderColor: Colors.black38),
                          focusedBorder: UIHelper.getInputBorder(1, borderColor: Colors.black38),
                          focusedErrorBorder: UIHelper.getInputBorder(1, borderColor: Colors.black38),
                          errorBorder: UIHelper.getInputBorder(1, borderColor: activeColor),
                        ),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(context, errorText: "*Required"),
                        ]),
                        // inputFormatters: [new WhitelistingTextInputFormatter(RegExp(r'^\d+\.?\d{0,2}'))],
                        inputFormatters: [
                          // is able to enter lowercase letters
                          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                        ],
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                  ])),
              UIHelper.verticalSpaceMedium,
              Container(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                      onPressed: () async {
                        if (!isNewOffer) {
                          Loader.show(context);
                          await model.deleteOfferDetails(_docController.text);
                          Loader.hide();
                        }

                        _descriptionController.text = '';
                        _docController.text = '';
                        _titleController.text = '';
                        _imgPathController.text = '';
                        _saveimgPathController.text = '';
                        _amountController.text = '';
                        _startDateController.text = '';
                        _endDateController.text = '';
                        setState(() {
                          isNewOffer = false;
                          addOfferEnable = false;
                        });
                      },
                      child: Text('Delete Offer').bold(),
                      style: ButtonStyle(
                        minimumSize: MaterialStateProperty.all(Size(100, 40)),
                        backgroundColor: MaterialStateProperty.all(activeColor),
                      )),
                  ElevatedButton(
                      onPressed: () async {
                        dynamic postParams = {};
                        postParams['offer_title'] = _titleController.text;
                        postParams['start_date'] = _startDateController.text;
                        postParams['end_date'] = _endDateController.text;
                        postParams['offer_description_text'] = _descriptionController.text;
                        postParams['offer_amount'] = _amountController.text;

                        if (_fbKey.currentState!.saveAndValidate()) {
                          if (isNewOffer) {
                            Loader.show(context);
                            await model.addOfferData(postParams, _saveimgPathController.text);
                            Loader.hide();
                          } else {
                            postParams['offers_id'] = _docController.text;

                            Loader.show(context);
                            await model.updatefferData(postParams, _saveimgPathController.text);
                            Loader.hide();
                          }
                          _descriptionController.text = '';
                          _docController.text = '';
                          _titleController.text = '';
                          _imgPathController.text = '';
                          _saveimgPathController.text = '';
                          _amountController.text = '';
                          _startDateController.text = '';
                          _endDateController.text = '';
                          setState(() {
                            isNewOffer = false;
                            addOfferEnable = false;
                          });
                        }
                      },
                      child: Text(isNewOffer ? 'Start Offer' : 'Update Offer').bold(),
                      style: ButtonStyle(
                        minimumSize: MaterialStateProperty.all(Size(100, 40)),
                        backgroundColor: MaterialStateProperty.all(submitBtnColor),
                      )),
                ],
              ))
            ],
          ),
        ));
  }

  Widget listOfferWidget(BuildContext context, FeesandOffersModel model) {
    return model.offersList.length == 0
        ? Container(
            padding: EdgeInsets.only(top: 150),
            child: Text('No Offers'),
          )
        : ListView.separated(
            separatorBuilder: (context, index) {
              return SizedBox();
            },
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: model.offersList.length,
            itemBuilder: (context, index) {
              dynamic offerData = model.offersList[index];
              String imgUrl = '';
              String remainingdays = '';
              if (offerData['offer_description_link'] != null && offerData['offer_description_link'].length > 0) {
                imgUrl = '${ApiService.fileStorageEndPoint}${offerData['offer_description_link'][0]}';
              }

              if (offerData['start_date'] != null && offerData['start_date'] != '' && offerData['end_date'] != null && offerData['end_date'] != '') {
                var _startDate = Jiffy(offerData['start_date'], 'dd/MM/yyyy');
                var _endDate = Jiffy(offerData['end_date'], 'dd/MM/yyyy');
                String remaining = _endDate.diff(_startDate, Units.DAY).toString();
                remainingdays = 'Ending in $remaining days';
              }

              return Column(
                children: [
                  GestureDetector(
                      onTap: () async {
                        setState(() {
                          _docController.text = offerData['_id'];
                          _descriptionController.text = offerData['offer_description_text'] != null ? offerData['offer_description_text'] : '';
                          _titleController.text = offerData['offer_title'] != null ? offerData['offer_title'] : '';
                          _imgPathController.text = imgUrl;
                          _amountController.text = offerData['offer_amount'] != null ? offerData['offer_amount'] : '';
                          if (offerData['start_date'] != null && offerData['start_date'] != '') {
                            stardate_Initial = DateFormat("dd/MM/yyyy").parse(offerData['start_date']);
                            _startDateController.text = offerData['start_date'];
                          }
                          if (offerData['end_date'] != null && offerData['end_date'] != '') {
                            enddate_Initial = DateFormat("dd/MM/yyyy").parse(offerData['end_date']);
                            _endDateController.text = offerData['end_date'];
                          }
                          addOfferEnable = true;
                        });
                      },
                      child: Container(
                          decoration: UIHelper.roundedBorderWithColor(8, Colors.white, borderColor: Colors.black12),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            ClipRRect(
                                borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
                                child: imgUrl.isEmpty
                                    ? Image.asset(
                                        'assets/allopathy.png',
                                        width: Screen.width(context),
                                        height: 100,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.network(
                                        imgUrl,
                                        width: Screen.width(context),
                                        height: 100,
                                        fit: BoxFit.cover,
                                      )),
                            Container(
                              width: Screen.width(context),
                              padding: EdgeInsets.all(8),
                              decoration: UIHelper.roundedBorderWithColor(8, Colors.white, borderColor: Colors.white),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(offerData['offer_title'] != null ? offerData['offer_title'] : '').fontSize(15).bold(),
                                  Text(offerData['offer_description_text'] != null ? offerData['offer_description_text'] : '').fontSize(12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Container(
                                        alignment: Alignment.center,
                                        padding: EdgeInsets.only(left: 10, right: 5),
                                        height: 40,
                                        decoration: UIHelper.allcornerRadiuswithbottomShadow(8, 8, 8, 8, Colors.white),
                                        child: Row(
                                          children: [Text(preferencesService.selectedCourrencySymbol).bold(), SizedBox(width: 10), Text(offerData['offer_amount'] != null ? offerData['offer_amount'] : '').bold()],
                                        ),
                                      ),
                                    ],
                                  ),
                                  UIHelper.verticalSpaceTiny,
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(children: [
                                        Text(offerData['start_date'] != null ? offerData['start_date'] : '').fontSize(13),
                                        Text(offerData['end_date'] != null && offerData['end_date'] != '' ? ' to ' + offerData['end_date'] : '').fontSize(13),
                                      ]),
                                      Text(remainingdays).fontSize(10).textColor(Colors.black38),
                                    ],
                                  )
                                ],
                              ),
                            )
                          ]))),
                  UIHelper.verticalSpaceSmall,
                ],
              );
            });
  }

  Future<void> _displayTextInputDialog(BuildContext context, FeesandOffersModel model, dynamic data, String title, String amount) async {
    final _textFieldController = TextEditingController();
    void dispose() {
      _textFieldController.dispose();
      super.dispose();
    }

    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(title),
            content: TextField(
              keyboardType: TextInputType.number,
              //data['mother_weight'].toString(),
              controller: _textFieldController..text = amount,
              onChanged: (value) {
                amount = value;
                setState(() {
                  amount = value;
                });
              },
              //inputFormatters: [title == 'Discount' ? WhitelistingTextInputFormatter(RegExp("[0-9]")) : WhitelistingTextInputFormatter(RegExp(r'^\d+\.?\d{0,2}'))],
              inputFormatters: [
                // is able to enter lowercase letters
                title == 'Discount' ? FilteringTextInputFormatter.allow(RegExp("[0-9]")) : FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              decoration: InputDecoration(hintText: "Enter the $title", suffixText: title == 'Discount' ? '%' : ''),
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
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: _textFieldController,
                builder: (context, value, child) {
                  return ElevatedButton(
                      onPressed: value.text.isNotEmpty
                          ? () async {
                              title == 'Fees' ? data['fees'] = amount : data['discount'] = amount;
                              double discountValue = double.parse(data['discount'] != null && data['discount'] != '' ? data['discount'] : '0');
                              if (discountValue > 99) {
                                Fluttertoast.showToast(
                                  msg: "Invalid Discount",
                                  backgroundColor: Colors.red,
                                  gravity: ToastGravity.CENTER,
                                  textColor: Colors.white,
                                );
                              } else {
                                if (data['fees'] != null && data['fees'] != "" && data['discount'] == null || data['discount'] == "") {
                                  double feesValue = double.parse(data['fees'] != null ? data['fees'] : '0');
                                  double finalValue = feesValue;
                                  setState(() {
                                    data['final_amount'] = finalValue.toString();
                                  });
                                }

                                if (data['fees'] != null && data['fees'] != "" && data['discount'] != null && data['discount'] != "") {
                                  double feesValue = double.parse(data['fees'] != null ? data['fees'] : '0');
                                  double finalValue = feesValue - (feesValue * discountValue / 100);
                                  setState(() {
                                    data['final_amount'] = finalValue.toString();
                                  });
                                }

                                Navigator.pop(context);
                                Loader.show(context);
                                await model.updateFeesTable(data);
                                await model.getDoctorFees();
                                Loader.hide();
                              }
                            }
                          : null,
                      child: Text('Ok'),
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

  Future<void> getpick(BuildContext context) async {
    _imgPathController.text = '';
    _saveimgPathController.text = '';
    FilePickerResult result = (await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['jpg', 'jpeg', 'png']))!;
    String path = result.files.single.path!;

    if ((path.toString().contains("jpg") || path.toString().contains("jpeg") || path.toString().contains("png")) &&
        (path.toString().contains("jpg") || path.toString().contains("jpeg") || path.toString().contains("png"))) {
      await Get.to(() => ImgCropper(
          index: 0,
          imagePath: path,
          onCropComplete: (path) {
            String st = path;
            print(path);
            setState(() {
              _imgPathController.text = path;
              _saveimgPathController.text = path;
            });
          }));
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return CustomDialogBox(
              title: "Not Allowed !",
              descriptions: "Image only allowed",
              descriptions1: "",
              text: "OK",
            );
          });
    }
  }

  Future<void> getcapture(BuildContext context, FileType fileType) async {
    _imgPathController.text = '';
    _saveimgPathController.text = '';
    String path = '';
    final pickedFile = await picker.getImage(source: fileType == FileType.video ? ImageSource.camera : ImageSource.gallery, maxWidth: 480);
    if (pickedFile != null) {
      path = pickedFile.path;

      await Get.to(() => ImgCropper(
          index: 0,
          imagePath: pickedFile.path,
          onCropComplete: (path) {
            String st = path;
            print(path);
            setState(() {
              _imgPathController.text = path;
              _saveimgPathController.text = path;
            });
          }));
    }
  }

  Widget recentItem(BuildContext context) {
    String filePath = _imgPathController.text;
    String filename = filePath.split('/').last;
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: Image.file(
        File(_imgPathController.text),
        fit: BoxFit.cover,
        height: 100,
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
    );
  }

  Widget fessListWidget(BuildContext context, FeesandOffersModel model) {
    return Container(
      width: Screen.width(context),
      decoration: UIHelper.roundedBorderWithColor(6, Colors.transparent, borderColor: Colors.black12),
      child: Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            headerItem('', Color(0xFFECECEC)),
            headerItem('Fee ' + preferencesService.selectedCourrencySymbol, fieldBgColor),
            headerItem('Discount', Color(0xFFECECEC)),
            headerItem('Final ' + preferencesService.selectedCourrencySymbol, fieldBgColor),
          ],
        ),
        Container(
          color: Colors.black12,
          height: 1,
        ),
        model.servicesList.length == 0
            ? Container(
                padding: EdgeInsets.only(top: 50, bottom: 50),
                child: Text('No Services'),
              )
            : ListView.separated(
                separatorBuilder: (context, index) {
                  return SizedBox();
                },
                padding: EdgeInsets.only(top: 0),
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: model.servicesList.length,
                itemBuilder: (context, index) {
                  return addMatDataItem(
                    context,
                    index,
                    model,
                    model.servicesList[index],
                  );
                }),
      ]),
    );
  }

  Widget headerItem(String title, Color bgColor) {
    return Expanded(
      child: Container(
        height: 40,
        alignment: Alignment.center,
        color: bgColor,
        child: Text(title).bold().fontSize(11).textAlignment(TextAlign.center),
      ),
    );
  }

  Widget addMatDataItem(BuildContext context, int index, FeesandOffersModel model, dynamic data) {
    //double fees_amount = double.parse(data['fees'] != null ? data['fees'] : '0');
    //double final_amount = double.parse(data['final'] != null ? data['final'] : '0');

    String amount = data['fees'] != null ? data['fees'] : '';
    String finalAmount = data['final_amount'] != null ? data['final_amount'] : '';
    // return FutureBuilder<dynamic>(
    //     future: getAmounts(fees_amount, final_amount),
    //     builder: (context, AsyncSnapshot<dynamic> snapshot) {
    //       if (snapshot.hasData) {
    //         amount = snapshot.data['fees'].toString();
    //         finalAmount = snapshot.data['discount'].toString();
    //       }

    return Container(
      color: index % 2 == 0 ? Colors.white : fieldBgColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
              child: Container(
            // alignment: Alignment.left,
            padding: EdgeInsets.symmetric(vertical: 17),
            decoration: UIHelper.rowRightBorder(),
            child: Text('   ' + data['services_type'], textAlign: TextAlign.left).fontSize(11).fontWeight(FontWeight.w600),
          )),
          Expanded(
              child: GestureDetector(
                  onTap: () async {
                    _displayTextInputDialog(context, model, data, 'Fees', amount);
                  },
                  child: Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(vertical: 17),
                    decoration: UIHelper.rowRightBorder(),
                    child: Text(amount).fontSize(11).fontWeight(FontWeight.w600),
                  ))),
          Expanded(
              child: GestureDetector(
                  onTap: () async {
                    _displayTextInputDialog(context, model, data, 'Discount', data['discount']);
                  },
                  child: Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(vertical: 17),
                    decoration: UIHelper.rowRightBorder(),
                    child: Text(data['discount'] != '' ? data['discount'] + ' %' : '').fontSize(11).fontWeight(FontWeight.w600),
                  ))),
          Expanded(
              child: Container(
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(vertical: 17),
            decoration: UIHelper.rowRightBorder(),
            child: Text(finalAmount).fontSize(11).fontWeight(FontWeight.w600),
          )),
        ],
      ),
    );
    //  });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SwarAppDoctorBar(isProfileBar: false),
      body: SafeArea(
          top: false,
          child: ViewModelBuilder<FeesandOffersModel>.reactive(
              onModelReady: (model) async {
                Loader.show(context);
                await model.getDoctorFees();
                Loader.hide();
              },
              builder: (context, model, child) {
                return Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    width: Screen.width(context),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        UIHelper.verticalSpaceSmall,
                        UIHelper.addHeader(context, "Manage Fees and Offers", true),
                        UIHelper.verticalSpaceSmall,
                        Expanded(
                            child: SingleChildScrollView(
                          child: Column(
                            children: [
                              //UIHelper.verticalSpaceMedium,
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Fees').fontSize(14).bold(),
                                  //Text('Fee').fontSize(14).bold(),
                                  Container(
                                    width: 80,
                                    child: FormBuilderDropdown(
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.only(left: 10),
                                        filled: true,
                                        fillColor: Colors.transparent,
                                        enabledBorder: UIHelper.getInputBorder(1),
                                        focusedBorder: UIHelper.getInputBorder(1),
                                        focusedErrorBorder: UIHelper.getInputBorder(1),
                                        errorBorder: UIHelper.getInputBorder(1),
                                      ),
                                      name: "courency_code",
                                      initialValue: preferencesService.selectedCourrency,
                                      hint: Text('Code').fontSize(14).bold(),
                                      items: currencies.map<DropdownMenuItem<String>>((currencycode) => new DropdownMenuItem<String>(
                                                value: currencycode['code'],
                                                child: Text(currencycode['code']).textColor(Colors.black).fontSize(14).bold(),
                                              ))
                                          .toList(),
                                      onChanged: (value) async {
                                        for (var each in currencies) {
                                          if (each['code'] == value) {
                                            setState(() {
                                              preferencesService.selectedCourrency = each['code'];
                                              preferencesService.selectedCourrencySymbol = each['symbol'];
                                            });
                                            Loader.show(context);
                                            await model.getDoctorFees();
                                            Loader.hide();
                                          }
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              // UIHelper.verticalSpaceSmall,
                              fessListWidget(context, model),
                              UIHelper.verticalSpaceSmall,
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Offers').fontSize(14).bold(),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        addOfferEnable = true;
                                        isNewOffer = true;
                                      });
                                    },
                                    child: !addOfferEnable
                                        ? Container(
                                            alignment: Alignment.center,
                                            width: 80,
                                            height: 20,
                                            decoration: UIHelper.roundedBorderWithColor(4, activeColor),
                                            child: Text('ADD').textColor(Colors.white).fontSize(12),
                                          )
                                        : SizedBox(),
                                  ),
                                ],
                              ),
                              UIHelper.verticalSpaceSmall,
                              addOfferEnable ? addOfferWidet(context, model) : SizedBox(),
                              !addOfferEnable ? listOfferWidget(context, model) : SizedBox(),
                            ],
                          ),
                        ))
                      ],
                    ));
              },
              viewModelBuilder: () => FeesandOffersModel())),
    );
  }
}
