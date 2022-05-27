
import 'package:documents_module/src/ui/uploads/capture_upload_view.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/services/preferences_service.dart';
import 'package:swarapp/shared/app_colors.dart';
import 'package:swarapp/shared/custom_dialog_box.dart';
import 'package:swarapp/shared/screen_size.dart';
import 'package:swarapp/shared/text_styles.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:intl/intl.dart';

  class EditVaccinationView extends StatefulWidget {
  bool isEditMode;
  EditVaccinationView({Key? key, required this.isEditMode}) : super(key: key);
  
  
 
  @override
  _EditVaccinationViewState createState() => _EditVaccinationViewState();
}

class _EditVaccinationViewState extends State<EditVaccinationView> {
   final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
   PreferencesService preferencesService = locator<PreferencesService>();
  String selectedRadio = 'No';
  String mdRadio = 'CS';
  int _radioValue = 0;
  int value = 0;
   String isvideo='';
   List<PlatformFile>? _paths;

  void _handleRadioValueChange(String value) {
    setState(() {
      selectedRadio = value;

      switch (selectedRadio) {
        case "Yes":
          break;
        case "No":
          break;
        // case 2:
        //   break;
      }
    });
  }

  void _handleDeliveryChange(String value) {
    setState(() {
      mdRadio = value;

      switch (mdRadio) {
        case "NVD":
          break;
        case "CS":
          break;
        case "Instrumentation":
          break;
      }
    });
  }
  bool isAutoValidate = false;
  Widget addInputFormControl(String nameField, String hintText, Widget icon) {
    bool isEnabled = false;
    if (nameField == 'mobile' || nameField == 'email') {
      isEnabled = true;
    }
    return FormBuilderTextField(
        style: loginInputTitleStyle,
        name: nameField,
        autocorrect: false,
        onChanged: (value) {
          print(value);
        },
        
        decoration: InputDecoration(
          contentPadding:nameField=='attach'? 
           const EdgeInsets.symmetric(vertical: 40.0) :
           EdgeInsets.only(left: 20)
           ,
          prefixIcon: icon,
          hintText: hintText,
          hintStyle: loginInputHintTitleStyle,
          filled: true,
          fillColor: Colors.white,
          enabledBorder: UIHelper.getInputBorder(1),
          focusedBorder: UIHelper.getInputBorder(1),
          focusedErrorBorder: UIHelper.getInputBorder(1),
          errorBorder: UIHelper.getInputBorder(1),
          //contentPadding: const EdgeInsets.symmetric(vertical: 40.0),
          
        ));


         
  }

  Widget iconItem(IconData icon) {
    return Icon(
      icon,
      color: activeColor,
    );
  }

  Widget imageItem(String asset) {
    return Image.asset(
      asset,
      height: 24,
    );
  }
  //for radio onchange
 
  Widget formControls(BuildContext context) {
    Jiffy dob = Jiffy();
    String allergic = '';
    return Padding(
      padding: const EdgeInsets.only(left: 1, right: 1),
      child: Container(
        padding: EdgeInsets.all(12),
        width: Screen.width(context),
        decoration: UIHelper.roundedBorderWithColor(8, subtleColor, borderColor: Color(0xFFE2E2E2)),
        child: FormBuilder(
            initialValue: {},
            autovalidateMode: isAutoValidate ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
            key: _fbKey,
            child: Column(
              children: [
                addInputFormControl('name', 'Name', iconItem(Icons.person)),
                UIHelper.verticalSpaceSmall,
                addInputFormControl('mrecord', 'Medical Record No', imageItem('assets/reg_insurance_icon.png')),
                UIHelper.verticalSpaceSmall,
                FormBuilderDropdown(
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.only(left: 20),
                    prefixIcon: imageItem('assets/age_icon.png'),
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: UIHelper.getInputBorder(1),
                    focusedBorder: UIHelper.getInputBorder(1),
                    focusedErrorBorder: UIHelper.getInputBorder(1),
                    errorBorder: UIHelper.getInputBorder(1),
                  ),
                  name: "age",
                  hint: Text('Age'),
                  key: UniqueKey(),
                  items: ['1-2', '3-5', '6-10', '11-15', '16-21']
                      .map((cat) => DropdownMenuItem(
                            value: cat,
                            child: Text("$cat").textColor(Colors.black).fontSize(16),
                          ))
                      .toList(),
                ),
                UIHelper.verticalSpaceSmall,
                addInputFormControl('email', 'Vaccine', imageItem('assets/vaccine.png')),
                UIHelper.verticalSpaceSmall,
                Container(
                  padding: EdgeInsets.fromLTRB(12, 8, 12, 8),
                  width: Screen.width(context),
                  decoration: UIHelper.roundedBorderWithColor(8, Colors.white),
                  child: Row(
                    children: [
                      imageItem('assets/vacstatus.png'),
                      UIHelper.horizontalSpaceSmall,
                      Text('Vaccine Status').textColor(Color(0xFF8D8D8D)),
                      Expanded(child: SizedBox()),
                      Radio(
                        value: 'No',
                        visualDensity: VisualDensity.compact,
                        groupValue: selectedRadio,
                        onChanged: (value) {
                          _handleRadioValueChange('No');
                        },
                       
                       // onChanged: _handleRadioValueChange(No),
                        activeColor: activeColor,
                      ),
                      Text('No'),
                      // UIHelper.horizontalSpaceSmall,
                      Radio(
                        value: 'Yes',
                        visualDensity: VisualDensity.compact,
                        groupValue: selectedRadio,
                         onChanged: (value) {
                          _handleRadioValueChange('Yes');
                        },
                        activeColor: activeColor,
                      ),
                      Text('Yes'),
                    ],
                  ),
                ),
                UIHelper.verticalSpaceSmall,
                Theme(
                  data: ThemeData.light().copyWith(
                      colorScheme: ColorScheme.light(
                    primary: activeColor, //constant Color(0xFF16A5A6)
                  )),
                  child: FormBuilderDateTimePicker(
                  // initialDate: beginDate.add(Duration(days: 1)),
                  name: "vacc_given_date",
                  //firstDate: beginDate.add(Duration(days: 1)),
                  // lastDate: beginDate.add(Duration(days: 14)),
                   //lastDate: DateTime(DateTime.now().year - 18,DateTime.now().month,DateTime.now().day),
                   initialDate:DateTime(DateTime.now().year ,DateTime.now().month, DateTime.now().day),
                   firstDate:DateTime(1900),
                  // lastDate: DateTime(DateTime.now().year - 18,DateTime.now().month,DateTime.now().day),
                  //lastDate: DateTime.now(),
                  inputType: InputType.date,
                  format: DateFormat("MM/dd/yyyy"),
                  // validators: [FormBuilderValidators.required()],
                  decoration: InputDecoration(
                    hintText: "Vaccine given date",
                    contentPadding: EdgeInsets.only(left: 20),
                     prefixIcon: imageItem('assets/vacdate.png'),
                        suffixIcon: Icon(
                          Icons.calendar_today,
                          color: activeColor,
                        ),
                    filled: true,
                    fillColor: Colors.white70,
                    enabledBorder: UIHelper.getInputBorder(1),
                    focusedBorder: UIHelper.getInputBorder(1),
                    focusedErrorBorder: UIHelper.getInputBorder(1),
                    errorBorder: UIHelper.getInputBorder(1, borderColor: activeColor),
                    // hintText: "Date of Birth",
                  ),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(context),
                  ]),
                ),

                ),
                UIHelper.verticalSpaceSmall,
                Theme(
                  data: ThemeData.light().copyWith(
                      colorScheme: ColorScheme.light(
                    primary: activeColor, //constant Color(0xFF16A5A6)
                  )),
                child: FormBuilderDateTimePicker(
                  // initialDate: beginDate.add(Duration(days: 1)),
                  name: "dob",
                  //firstDate: beginDate.add(Duration(days: 1)),
                  // lastDate: beginDate.add(Duration(days: 14)),
                   //lastDate: DateTime(DateTime.now().year - 18,DateTime.now().month,DateTime.now().day),
                   initialDate:DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
                   firstDate:DateTime(1900),
                  // lastDate: DateTime(DateTime.now().year - 18,DateTime.now().month,DateTime.now().day),
                  lastDate: DateTime.now(),
                  inputType: InputType.date,
                  format: DateFormat("MM/dd/yyyy"),
                  // validators: [FormBuilderValidators.required()],
                  decoration: InputDecoration(
                    hintText: 'Date of Birth',
                    contentPadding: EdgeInsets.only(left: 20),
                     suffixIcon: Icon(
                          Icons.calendar_today,
                          color: activeColor,
                        ),
                    prefixIcon: imageItem('assets/bi_calendar.png'),
                    filled: true,
                    fillColor: Colors.white70,
                    enabledBorder: UIHelper.getInputBorder(1),
                    focusedBorder: UIHelper.getInputBorder(1),
                    focusedErrorBorder: UIHelper.getInputBorder(1),
                    errorBorder: UIHelper.getInputBorder(1, borderColor: activeColor),
                    // hintText: "Date of Birth",
                  ),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(context),
                  ]),
                ),
                ),

                UIHelper.verticalSpaceSmall,
                addInputFormControl('gage', 'Gestational Age', imageItem('assets/age_icon.png')),
                UIHelper.verticalSpaceSmall,
                Container(
                  padding: EdgeInsets.fromLTRB(12, 2, 12, 2),
                  width: Screen.width(context),
                  decoration: UIHelper.roundedBorderWithColor(8, Colors.white),
                  child: Row(
                    children: [
                      imageItem('assets/delivery.png'),
                      UIHelper.horizontalSpaceSmall,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Mode of delivery ').textColor(Color(0xFF8D8D8D)),
                          Row(
                            children: [
                              SizedBox(
                                width: 24,
                                child: Radio(
                                  value: 'NVD',
                                  visualDensity: VisualDensity.compact,
                                  groupValue: mdRadio,
                                    onChanged: (value) {
                                  _handleDeliveryChange('NVD');
                                  },
                                  activeColor: activeColor,
                                ),
                              ),
                              Text('NVD').fontSize(12),
                              UIHelper.horizontalSpaceSmall,
                              SizedBox(
                                width: 24,
                                child: Radio(
                                  value: 'CS',
                                  visualDensity: VisualDensity.compact,
                                  groupValue: mdRadio,
                                  onChanged: (value) {
                                  _handleDeliveryChange('CS');
                                  },
                                  activeColor: activeColor,
                                ),
                              ),
                              Text('CS').fontSize(12),
                              UIHelper.horizontalSpaceSmall,
                              SizedBox(
                                width: 24,
                                child: Radio(
                                  value: 'Instrumentation',
                                  visualDensity: VisualDensity.compact,
                                  groupValue: mdRadio,
                                  onChanged: (value) {
                                  _handleDeliveryChange('Instrumentation');
                                  },
                                  activeColor: activeColor,
                                ),
                              ),
                              Text('Instrumentation').fontSize(12),
                            ],
                          )
                        ],
                      )
                    ],
                  ),
                ),
                UIHelper.verticalSpaceSmall,
                addInputFormControl('gage', 'APGAR Score', imageItem('assets/apgr_rec_icon.png')),
                UIHelper.verticalSpaceSmall,
                addInputFormControl('mobile', 'Birth Weight', imageItem('assets/bweight.png')),
                UIHelper.verticalSpaceSmall,
                addInputFormControl('alternatemobilenumber', 'Length at birth', imageItem('assets/lb.png')),
                UIHelper.verticalSpaceSmall,
                // // addInputFormControl('address', 'Address', Icons.location_on),
                // //GestureDetector( onTap: () async { await Get.to(() => ProfileView()); setState(() {}); },z
                addInputFormControl('country', 'Head Circumference', imageItem('assets/head_cir.png')),
                UIHelper.verticalSpaceSmall,
                addInputFormControl('state', 'TSH', imageItem('assets/tsh.png')),
                UIHelper.verticalSpaceSmall,
                addInputFormControl('city', 'G6PD', imageItem('assets/g6pd.png')),
                UIHelper.verticalSpaceSmall,
                addInputFormControl('zipcode', 'Baby Blood Group', imageItem('assets/bbgroup.png')),
                UIHelper.verticalSpaceSmall,
                addInputFormControl('allergicto', 'Mother\'s Blood Group', imageItem('assets/mbgroup.png')),
                 UIHelper.verticalSpaceSmall,
               // addInputFormControl('attach', 'Attach Record', iconItem(Icons.person)),
               FormBuilderTextField(
                      style: loginInputTitleStyle,
                      name: "attach",
                      autocorrect: false,
                      // onChanged: (value) {
                      //   print(value);
                      // },
                      onTap: () async {
                              bool isVideo=false;
                              try {
                               
                                preferencesService.paths.clear();
                                 preferencesService.paths = [];
                                 _paths =
                                   (await FilePicker.platform.pickFiles(type: FileType.custom,allowMultiple:true, allowedExtensions: ['pdf', 'doc','docx','jpg','xls','xlsx']))
                                  ?.files;
                                  if(_paths!.length<6){
                                    for(int k=0;k<_paths!.length;k++){
                                       print('pick __________VIDEO_______FILE______'+_paths![k].path!.toString());
                                       if(_paths![k].path!.toString().contains("mp4")||_paths![k].path!.toString().contains("mp3")){
                                       setState(() {
                                            isvideo = "yes";
                                          });
                                         print('______________________________MP4444444444444444444');
                                          showDialog(context: context,
                                            builder: (BuildContext context){
                                            return CustomDialogBox(
                                              title: "Not Allowed !",
                                              descriptions: "Video Files not allowed",
                                              descriptions1: "",
                                              text: "OK",
                                            );
                                            });
                                            setState(() {
                                            isvideo = "";
                                          });
                                         return;
                                       }else{
                                        setState(() {
                                            isvideo = "no";
                                          });
                                       preferencesService.paths.insert(0,_paths![k].path!);
                                    }
                                    }
                                    //for return to page, while choose video file
                                   if (isvideo=="no"){
                                     print("_____________________"+isVideo.toString());
                                      await Get.to(() => CaptureUploadView(camera_mode: "Attach"));
                                     // model.getRecentUploads();
                                    }else if(isvideo =="yes"){
                                      showDialog(context: context,
                                            builder: (BuildContext context){
                                            return CustomDialogBox(
                                              title: "Not Allowed !",
                                              descriptions: "Video Files not allowed",
                                              descriptions1: "",
                                              text: "OK",
                                            );
                                            });
                                            setState(() {
                                            isvideo = "";
                                          });

                                    }
                                     }else{
                                        showDialog(context: context,
                                            builder: (BuildContext context){
                                            return CustomDialogBox(
                                              title: "Not Allowed !",
                                              descriptions: "Files can be allowed within 5",
                                              descriptions1: "",
                                              text: "OK",
                                            );
                                            });
                                            setState(() {
                                            isvideo = "";
                                          });
                                     }
                              } catch (e) {
                                print(e.toString());
                              }
                            },
                        decoration: InputDecoration(
                        contentPadding: 
                        const EdgeInsets.symmetric(vertical: 40.0),
                        prefixIcon:imageItem('assets/attach_member.png'),
                        suffixIcon:imageItem('assets/attach_member_icon.png'),
                        hintText:"Attach Record",
                        hintStyle: loginInputHintTitleStyle,
                        filled: true,
                        fillColor: Colors.white,
                        enabledBorder: UIHelper.getInputBorder(1),
                        focusedBorder: UIHelper.getInputBorder(1),
                        focusedErrorBorder: UIHelper.getInputBorder(1),
                        errorBorder: UIHelper.getInputBorder(1),
                        //contentPadding: const EdgeInsets.symmetric(vertical: 40.0),
                        
                      ),
                        
                            // onTap: () async {
                            //     if(nameField == 'attach'){
                            //       print('attache________________');
                            //     }

                            // })
                            ),
                UIHelper.verticalSpaceMedium,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          Get.back(result: {'refresh': false});
                        },
                        child: Text('CANCEL').textColor(Colors.white),
                        style: ButtonStyle(
                            minimumSize: MaterialStateProperty.all(Size(80, 32)),
                            elevation: MaterialStateProperty.all(0),
                            backgroundColor: MaterialStateProperty.all(activeColor),
                            shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))),
                    ElevatedButton(
                        onPressed: () async {},
                        child: Text('SAVE'),
                        style: ButtonStyle(
                            minimumSize: MaterialStateProperty.all(Size(80, 32)),
                            backgroundColor: MaterialStateProperty.all(Colors.green),
                            shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))),
                  ],
                ),
              ],
            )),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        // appBar: SwarAppBar(),
        body: Container(
            padding: EdgeInsets.symmetric(horizontal: 12),
            width: Screen.width(context),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              UIHelper.verticalSpaceMedium,
              UIHelper.addHeader(context, "Edit Vaccination", true),
              UIHelper.verticalSpaceSmall,
              Expanded(
                  child: SingleChildScrollView(
                child: Column(
                  children: [formControls(context), UIHelper.verticalSpaceMedium],
                ),
              ))
            ])));
  }
}
