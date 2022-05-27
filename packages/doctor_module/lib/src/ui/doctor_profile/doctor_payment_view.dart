import 'package:doctor_module/src/ui/doctor_profile/doctor_payment_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/services/preferences_service.dart';
import 'package:swarapp/shared/app_doctorprofile_bar.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:swarapp/shared/flutter_overlay_loader.dart';
import 'package:swarapp/shared/screen_size.dart';
import 'package:swarapp/shared/text_styles.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:get/get.dart';
import 'package:swarapp/shared/custom_multiselect_dropdown.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:swarapp/shared/app_colors.dart';
import 'package:stacked/stacked.dart';

class DoctorPaymentView extends StatefulWidget {
  dynamic payment_data;
  DoctorPaymentView({
    Key? key,
    this.payment_data,
  }) : super(key: key);
  @override
  _DoctorPaymentViewState createState() => _DoctorPaymentViewState();
}

class _DoctorPaymentViewState extends State<DoctorPaymentView> {
  PreferencesService preferencesService = locator<PreferencesService>();
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  bool insurance = false;
  List<String> insuranceList = [
    'Care Health Insurance',
    'Magma HDI Health Insurance',
    'The Oriental Insurance Company',
    'New India General Insurance',
    'Bajaj Allianz General Insurance',
    'Max Bupa Health Insurance',
    'Navi General Insurance',
    'HDFC ERGO General Insurance',
    'Manipal Cigna Health Insurance',
    'Edelweiss General Insurance',
    'National Insurance Company',
    'Future Generali General Insurance',
    'Royal Sundaram General Insurance',
    'Liberty General Insurance',
    'ICICI Lombard General Insurance',
    'Star Health Insurance',
    'United India Insurance Company',
    'Reliance General Insurance',
    'Tata AIG General Insurance',
    'Bharti AXA General Insurance',
    'Kotak Mahindra General Insurance',
    'Acko General Insurance',
    'Aditya Birla Health Insurance',
    'Universal Sompo General Insurance',
    'SBI General Insurance',
    'Go Digit General Insurance',
    'Cholamandalam MS General Insurance',
  ];

  List<String> methodList = ['Debit card', 'credit card', 'Netbanking', 'UPI', 'Cash'];
  List<String> selected_insurance = [];
  List<String> selected_payments = [];
  void initState() {
    super.initState();
    setState(() {
      if (widget.payment_data['insurance_checkbox'] != null) {
        if (widget.payment_data['insurance_checkbox'] == "true") {
          insurance = true;
        }
      }
      if (widget.payment_data['insurance'] != null) {
        if (widget.payment_data['insurance'].length > 0) {
          selected_insurance = new List<String>.from(widget.payment_data['insurance']);
        }
      }

      if (widget.payment_data['payment'] != null) {
        if (widget.payment_data['payment'].length > 0) {
          selected_payments = new List<String>.from(widget.payment_data['payment']);
        }
      }
    });
  }

  Widget titleCard(BuildContext context, String title) {
    return Container(
        decoration: UIHelper.roundedBorderWithColor(10, Colors.white),
        width: Screen.width(context) / 3.3,
        height: 47,
        padding: EdgeInsets.only(left: 5, right: 2, top: 2, bottom: 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title).fontSize(13).fontWeight(FontWeight.w500),
          ],
        ));
  }

  Widget addInputFieldControl(String controlName, String hintText, bool numberOnly) {
    return FormBuilderTextField(
      style: loginInputTitleStyle,
      name: controlName,
      autocorrect: false,
      textCapitalization: TextCapitalization.sentences,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      onChanged: (value) {},
      decoration: InputDecoration(
        contentPadding: EdgeInsets.only(left: 5),
        hintText: hintText,
        hintStyle: loginInputHintTitleStyle,
        filled: true,
        fillColor: Colors.white,
        enabledBorder: UIHelper.getInputBorder(1),
        focusedBorder: UIHelper.getInputBorder(1),
        focusedErrorBorder: UIHelper.getInputBorder(1),
        errorBorder: UIHelper.getInputBorder(1, borderColor: activeColor),
      ),
      inputFormatters: [
        // control_name == 'account_number'
        //     ? new FilteringTextInputFormatter.allow(RegExp("[0-9]"))
        //     : control_name == "ifsc_code"
        //         ? new FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9]"))
        //         : new FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9 ]")),

        controlName == 'account_number'
            ? new FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9]"))
            : controlName == "ifsc_code"
                ? new FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9]"))
                : new FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9]")),
      ],
      validator: controlName == "account_number"
          ? FormBuilderValidators.compose([
              FormBuilderValidators.minLength(context, 1, allowEmpty: true, errorText: "Invalid account number"),
              FormBuilderValidators.maxLength(context, 50, errorText: "Invalid account number"),
            ])
          : controlName == "ifsc_code"
              ? FormBuilderValidators.compose([
                  FormBuilderValidators.minLength(context, 1, allowEmpty: true, errorText: "Invalid Ifsc Code"),
                  FormBuilderValidators.maxLength(context, 50, errorText: "Invalid Ifsc Code"),
                ])
              : FormBuilderValidators.compose([]),
      keyboardType: numberOnly ? TextInputType.number : TextInputType.text,
    );
  }

  Widget paymentInfoSection(BuildContext context, DoctorPaymentInfoViewModel model) {
    return Container(
        padding: EdgeInsets.all(10),
        decoration: UIHelper.rightcornerRadiuswithColor(8, 8, Color(0xFFF5F3F3)),
        child: FormBuilder(
          key: _fbKey,
          initialValue: {
            'bank_name': widget.payment_data['bank_name'] ?? '',
            'account_number': widget.payment_data['account_number'] ?? '',
            'ifsc_code': widget.payment_data['ifsc_code'] ?? '',
          },
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            FormBuilderCheckbox(
              name: 'insurance_checkbox',
              initialValue: insurance,
              activeColor: Colors.transparent,
              checkColor: Colors.black,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.only(left: 5),
                enabledBorder: UIHelper.getInputBorder(1),
                focusedBorder: UIHelper.getInputBorder(1),
                focusedErrorBorder: UIHelper.getInputBorder(1),
                errorBorder: UIHelper.getInputBorder(1, borderColor: activeColor),
              ),
              title: Text('Insurance'),
              onChanged: (value) {
                setState(() {
                  if (value!) {
                    insurance = true;
                  } else {
                    insurance = false;
                  }
                });
              },
            ),
            insurance
                ? Column(
                    children: [
                      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        titleCard(context, 'Insurance '),
                        SizedBox(width: 5),
                        Expanded(
                          child: DropDownMultiSelect(
                            onChanged: (List<String> x) {
                              setState(() {
                                selected_insurance = x;
                              });
                            },
                            options: insuranceList,
                            selectedValues: selected_insurance,
                            whenEmpty: 'Insurance',
                          ),
                        )
                      ]),
                      UIHelper.verticalSpaceTiny,
                      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        titleCard(context, 'Payment modes'),
                        SizedBox(width: 5),
                        Expanded(
                          child: DropDownMultiSelect(
                            onChanged: (List<String> x) {
                              setState(() {
                                selected_payments = x;
                              });
                            },
                            options: methodList,
                            selectedValues: selected_payments,
                            whenEmpty: 'Payment methods',
                          ),
                        )
                      ]),
                    ],
                  )
                : SizedBox(),
            UIHelper.verticalSpaceTiny,
            UIHelper.verticalSpaceMedium,
            Text('Bank Details').fontWeight(FontWeight.w600),
            UIHelper.verticalSpaceSmall,
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              titleCard(context, 'Bank name'),
              SizedBox(width: 5),
              Expanded(
                child: Container(child: addInputFieldControl('bank_name', 'Bank name', false)),
              ),
            ]),
            UIHelper.verticalSpaceTiny,
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              titleCard(context, 'Account No.'),
              SizedBox(width: 5),
              Expanded(
                child: Container(child: addInputFieldControl('account_number', 'Account No.', false)),
              ),
            ]),
            UIHelper.verticalSpaceTiny,
            UIHelper.verticalSpaceTiny,
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              titleCard(context, 'Ifsc Code'),
              SizedBox(width: 5),
              Expanded(
                child: Container(child: addInputFieldControl('ifsc_code', 'Ifsc Code', false)),
              ),
            ]),
            UIHelper.verticalSpaceMedium,
          ]),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SwarAppDoctorBar(isProfileBar: true),
      backgroundColor: Colors.white,
      body: ViewModelBuilder<DoctorPaymentInfoViewModel>.reactive(
          onModelReady: (model) async {},
          builder: (context, model, child) {
            return SafeArea(
                top: false,
                child: Container(
                    padding: EdgeInsets.only(left: 12, right: 12),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                      UIHelper.verticalSpaceSmall,
                      UIHelper.addHeader(context, "Profile", true),
                      UIHelper.verticalSpaceMedium,
                      Text('Payment').fontWeight(FontWeight.w600),
                      UIHelper.verticalSpaceSmall,
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              UIHelper.verticalSpaceSmall,
                              paymentInfoSection(context, model),
                              UIHelper.verticalSpaceSmall,
                              UIHelper.verticalSpaceSmall,
                            ],
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                              onPressed: () async {
                                bool isValue = false;
                                if (_fbKey.currentState!.saveAndValidate()) {
                                  Map<String, dynamic> postParams = Map.from(_fbKey.currentState!.value);
                                  postParams['profile_information'] = "payment";
                                  if (insurance == false) {
                                    postParams['insurance'] = [];
                                    postParams['payment'] = [];
                                  } else {
                                    postParams['insurance'] = selected_insurance;
                                    postParams['payment'] = selected_payments;
                                  }
                                  print(postParams);
                                  Loader.show(context);
                                  await model.addDoctorPaymentDetails(widget.payment_data['_id'], postParams);
                                  Loader.hide();
                                  //Get.back();
                                  Get.back(result: {'refresh': true});
                                }
                              },
                              child: Text('Save').bold(),
                              style: ButtonStyle(
                                minimumSize: MaterialStateProperty.all(Size(220, 36)),
                                backgroundColor: MaterialStateProperty.all(Color(0xFF00C064)),
                              )),
                        ],
                      ),
                      UIHelper.verticalSpaceMedium
                    ])));
          },
          viewModelBuilder: () => DoctorPaymentInfoViewModel()),
    );
  }
}
