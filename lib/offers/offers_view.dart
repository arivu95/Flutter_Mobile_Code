import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:stacked/stacked.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:swarapp/offers/offers_view_model.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/shared/app_colors.dart';
import 'package:swarapp/shared/app_static_bar.dart';
import 'package:swarapp/shared/screen_size.dart';
import 'package:swarapp/shared/ui_helpers.dart';

class OffersView extends StatefulWidget {
  const OffersView({Key? key}) : super(key: key);

  @override
  State<OffersView> createState() => _OffersViewState();
}

class _OffersViewState extends State<OffersView> {
  offersVieweModel modelRef = offersVieweModel();
  String offers_img_url = '';
  Widget addHeader(BuildContext context, bool isBackBtnVisible) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Offers').fontSize(16).fontWeight(FontWeight.w600),
        ],
      ),
    );
  }

  Widget offersView(BuildContext context, offersVieweModel model) {
    return Container(
        padding: EdgeInsets.only(top: 5),
        // alignment: Alignment.center,
        // width: Screen.width(context),
        height: Screen.height(context) / 1.3, //height of TabBarView
        // decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.grey, width: 0.5))),
        child: ListView.builder(
            itemCount: model.OfferInfo.length,
            itemBuilder: (BuildContext context, int index) {
              return listOffersCard(context, model, index);
            }));
  }

  Widget listOffersCard(BuildContext context, offersVieweModel model, int index) {
    // String startDate = model.OfferInfo[index]['start_date'];
    // DateTime now = DateTime.parse(startDate);
    // Jiffy fromDate_ = Jiffy(now.toString());
    // String m = fromDate_.format('MM-dd-yyyy');
    // print(m);
// }
    // int pageCount = int.tryParse(model.OfferInfo[index]['start_date'].toString());

    //  print(pageCount.runtimeType);
    if (model.OfferInfo[index]['Offer_image'] != null) {
      offers_img_url = '${ApiService.fileStorageEndPoint}${model.OfferInfo[index]['Offer_image']}';
    }
    return Container(
      padding: EdgeInsets.only(top: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
              padding: EdgeInsets.only(left: 5, right: 5, top: 5, bottom: 5),
              width: Screen.width(context) / 1.11,
              decoration: UIHelper.allcornerRadiuswithbottomShadow(15, 15, 15, 15, Colors.white),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 3, right: 3),
                    child: Row(
                      children: [
                        Column(
                          children: [
                            Container(
                              height: 75,
                              width: 80,
                              // color: Colors.blue,
                              child: InkWell(
                                  onTap: () {
                                    // Navigator.push(
                                    //   context,
                                    //   MaterialPageRoute(builder: (context) => ManageBookingsView(date: slotDate, time: model.bookingsdata[index]["time"], doctorDetails: modelRef.datas[index])),
                                    // );
                                  },
                                  child: model.OfferInfo[index]['Offer_image'] !=null  ? ClipRRect(
                                    borderRadius: BorderRadius.all(Radius.circular(10)),
                                    child: UIHelper.getImage(offers_img_url, 80, 75),
                                  ):
                                  ClipRRect(
                                    borderRadius: BorderRadius.all(Radius.circular(10)),
                                    child: Icon(Icons.local_offer),
                                  )),
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
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      model.OfferInfo[index]['Title'] != null
                                          ? Container(width: 100, child: Text(model.OfferInfo[index]['Title'], overflow: TextOverflow.ellipsis).bold().fontSize(16))
                                          : Container(width: 100, child: Text('')),
                                      model.OfferInfo[index]['description'] != null
                                          ? Container(width: 100, child: Text(model.OfferInfo[index]['description'], overflow: TextOverflow.ellipsis).fontSize(12))
                                          : Container(
                                              width: 100,
                                              child: Text(''),
                                            ),
                                    ],
                                  ),
                                  UIHelper.horizontalSpaceLarge,
                                  Container(
                                    height: 40,
                                    width: 55,
                                    decoration: BoxDecoration(border: Border.all(width: 1, color: Colors.grey), color: Colors.white10, borderRadius: BorderRadius.circular(5)),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text('₹').bold().fontSize(18),
                                        SizedBox(
                                          width: 3,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 4),
                                          child: Text(model.OfferInfo[index]['offer_amount']).bold(),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              model.OfferInfo[index]['start_date'] != null ? Text(model.OfferInfo[index]['start_date'] + " " + "to " + model.OfferInfo[index]['end_date'], overflow: TextOverflow.ellipsis) : Text(''),
                              SizedBox(
                                height: 5,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 130),
                                child: Text(
                                  'Ending in 3 days',
                                ).fontSize(11).textColor(Colors.grey),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              )),
          UIHelper.verticalSpaceSmall,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    modelRef.getOffers();
    return Scaffold(
        appBar: SwarAppStaticBar(),
        body: Container(
          alignment: Alignment.center,
          child: SingleChildScrollView(
            // scrollDirection: Axis.vertical,
            child: ViewModelBuilder<offersVieweModel>.reactive(
              onModelReady: (model) {
                modelRef = model;
                model.getOffers();
              },
              builder: (context, model, child) {
                return model.isBusy
                    ? Container(child: Center(child: CircularProgressIndicator()))
                    : Container(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        width: Screen.width(context),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            addHeader(context, true),
                            SizedBox(
                              height: 20,
                            ),
                            offersView(context, model)
                            // Expanded(
                            //     child: Container(
                            //   child: Column(
                            //     crossAxisAlignment: CrossAxisAlignment.center,
                            //     children: [
                            //       UIHelper.verticalSpaceSmall,
                            //       UIHelper.verticalSpaceSmall,
                            //       Center(child: tabView(context)),
                            //     ],
                            //   ),
                            // ))
                          ],
                        ));
              },
              viewModelBuilder: () => offersVieweModel(),
            ),
          ),
        ));
  }
}
