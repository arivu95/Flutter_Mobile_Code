import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swarapp/shared/screen_size.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:styled_widget/styled_widget.dart';

class DocCategoryWidget extends StatelessWidget {
  final Function(int) onSelectCategory;
  const DocCategoryWidget({Key? key, required this.onSelectCategory}) : super(key: key);

  Widget docTypeMenuItem(String title, Widget icon, int index) {
    return GestureDetector(
      onTap: () async {
        
        onSelectCategory(index);
        
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

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.only(left: 12, right: 12),
        child: Container(
          width: Screen.width(context),
          decoration: UIHelper.roundedBorderWithColor(8, Colors.white, borderColor: Colors.transparent),
          padding: EdgeInsets.all(12),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    Get.back();
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.arrow_back_ios,
                        size: 20,
                      ),
                      Text('Select file from categories').bold(),
                    ],
                  ),
                ),
                UIHelper.verticalSpaceSmall,
                UIHelper.hairLineWidget(),
                UIHelper.verticalSpaceSmall,
                docTypeMenuItem('Registration/Insurance', Image.asset('assets/reg_insurance_icon.png'), 0),
                UIHelper.verticalSpaceSmall,
                UIHelper.hairLineWidget(),
                UIHelper.verticalSpaceSmall,
                docTypeMenuItem('Prescription', Image.asset('assets/prescription_icon.png'), 1),
                UIHelper.verticalSpaceSmall,
                UIHelper.hairLineWidget(),
                UIHelper.verticalSpaceSmall,
                docTypeMenuItem('Lab Report', Image.asset('assets/lr_icon.png'), 2),
                UIHelper.verticalSpaceSmall,
                UIHelper.hairLineWidget(),
                UIHelper.verticalSpaceSmall,
                docTypeMenuItem('Medical Report', Image.asset('assets/mr_icon.png'), 3),
                UIHelper.verticalSpaceSmall,
                UIHelper.hairLineWidget(),
                UIHelper.verticalSpaceSmall,
                docTypeMenuItem('Others', Image.asset('assets/others_icon.png'), 4),
                UIHelper.verticalSpaceSmall,
                UIHelper.hairLineWidget(),
                UIHelper.verticalSpaceSmall,
                docTypeMenuItem('Health Record', Image.asset('assets/covid_record_icon.png'), 5),
                UIHelper.verticalSpaceSmall,
                UIHelper.hairLineWidget(),
                UIHelper.verticalSpaceSmall,
                docTypeMenuItem('Maternity & Child vaccine record', Image.asset('assets/mat_vac_icon.png'), 6),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
