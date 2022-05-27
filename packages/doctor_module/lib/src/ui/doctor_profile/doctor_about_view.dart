import 'package:doctor_module/src/ui/doctor_profile/doctor_about_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:swarapp/shared/app_doctorprofile_bar.dart';
import 'package:swarapp/shared/flutter_overlay_loader.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:stacked/stacked.dart';
import 'package:get/get.dart';

class DoctorAboutView extends StatefulWidget {
  dynamic personal_data;
  DoctorAboutView({
    Key? key,
    this.personal_data,
  }) : super(key: key);

  @override
  _DoctorAboutViewState createState() => _DoctorAboutViewState();
}

class _DoctorAboutViewState extends State<DoctorAboutView> {
  TextEditingController _controller = TextEditingController();
  void initState() {
    super.initState();
    setState(() {
      if (widget.personal_data['aboutme'] != null) {
        _controller.text = widget.personal_data['aboutme'];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SwarAppDoctorBar(isProfileBar: true),
      backgroundColor: Color(0xFFE5E5E5),
      body: ViewModelBuilder<DoctorAoutViewModel>.reactive(
          onModelReady: (model) async {},
          builder: (context, model, child) {
            return SafeArea(
                top: false,
                child: Container(
                    padding: EdgeInsets.only(left: 12, right: 12),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                      UIHelper.verticalSpaceSmall,
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                        child: UIHelper.addHeader(context, "Profile", true),
                      ),
                      UIHelper.verticalSpaceMedium,
                      Text('About'),
                      UIHelper.verticalSpaceSmall,
                      Container(
                        decoration: UIHelper.roundedBorderWithColorWithShadow(6, Colors.white),
                        padding: EdgeInsets.all(12),
                        child: TextField(
                          controller: _controller,
                          maxLines: 6,
                          maxLength: 500,
                          decoration: InputDecoration.collapsed(hintText: "Describe about your self"),
                        ),
                      ),
                      Expanded(child: SizedBox()),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                              onPressed: () async {
                                Loader.show(context);
                                await model.updateAboutme(_controller.text);
                                Loader.hide();
                                Get.back();
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
          viewModelBuilder: () => DoctorAoutViewModel()),
    );
  }
}
