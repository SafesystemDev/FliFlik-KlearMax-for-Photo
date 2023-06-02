import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:foodie_customer/model/VendorModel.dart';
import 'package:foodie_customer/services/helper.dart';

class ServicesScreen extends StatefulWidget {
  final VendorModel vendorModel;

  ServicesScreen({Key? key, required this.vendorModel}) : super(key: key);

  @override
  _ServicesScreenState createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  late VendorModel vendormodel;

  @override
  void initState() {
    super.initState();
    vendormodel = widget.vendorModel;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(color: Colors.transparent, border: Border.all(style: BorderStyle.none)),
        child: Column(children: [
          InkWell(
              onTap: () => Navigator.pop(context),
              child: Container(
                height: 40,
                decoration: BoxDecoration(border: Border.all(color: Colors.white, width: 0.3), color: Colors.transparent, shape: BoxShape.circle),

                // radius: 20,
                child: Center(
                  child: Icon(
                    Icons.close,
                    color: isDarkMode(context) ? Colors.black : Colors.white,
                  ),
                ),
              )),
          SizedBox(
            height: 20,
          ),
          Expanded(
              child: Stack(children: [
            Positioned(
                top: 20,
                child: Container(
                    height: MediaQuery.of(context).size.height * 0.76,
                    width: MediaQuery.of(context).size.width * 1,
                    decoration: BoxDecoration(
                      color: isDarkMode(context) ? Colors.grey[900] : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                      ),
                    ),
                    child: Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: SingleChildScrollView(
                            child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                          Text(
                            "Services".tr(),
                            style: TextStyle(fontSize: 18, color: isDarkMode(context) ? Color(0xffFFFFFF) : Color(0XFF000000), fontFamily: "Poppinsm"),
                          ),
                          Container(
                            height: MediaQuery.of(context).size.height,
                            margin: EdgeInsets.all(8),
                            child: AlignedGridView.count(
                              crossAxisCount: 2,
                              shrinkWrap: true,
                              mainAxisSpacing: 2,
                              crossAxisSpacing: 2,
                              itemCount: vendormodel.filters.length,
                              itemBuilder: (BuildContext context, int index) {
                                if (vendormodel.filters.values.elementAt(index) != "Yes") {
                                  return Container();
                                } else {
                                  return Container(
                                      height: 125,
                                      alignment: Alignment.center,
                                      margin: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(color: isDarkMode(context) ? Colors.grey.shade900 : Colors.grey.shade100, width: 0.1),
                                          boxShadow: [
                                            BoxShadow(
                                              color: isDarkMode(context) ? Colors.grey.shade800 : Colors.grey.shade200,
                                              blurRadius: 4.0,
                                              spreadRadius: 0.6,
                                              offset: Offset(0.2, 0.2),
                                            ),
                                          ],
                                          color: isDarkMode(context) ? Colors.black : Colors.white),
                                      child: SingleChildScrollView(
                                        child: Column(
                                          children: [
                                            Container(
                                              padding: EdgeInsets.only(top: 5),
                                              alignment: Alignment.center,
                                              height: 30.5,
                                              child: Image(
                                                image: AssetImage(vendormodel.filters.keys.elementAt(index) == 'Cuisine'
                                                    ? 'assets/images/vegetarian.png'
                                                    : vendormodel.filters.keys.elementAt(index) == 'Free Wi-Fi'
                                                        ? 'assets/images/free_wifi.png'
                                                        : vendormodel.filters.keys.elementAt(index) == 'Good for Breakfast'
                                                            ? 'assets/images/good_for_breakfast.png'
                                                            : vendormodel.filters.keys.elementAt(index) == 'Good for Dinner'
                                                                ? 'assets/images/good_for_dinner.png'
                                                                : vendormodel.filters.keys.elementAt(index) == 'Good for Lunch'
                                                                    ? 'assets/images/good_for_lunch.png'
                                                                    : vendormodel.filters.keys.elementAt(index) == 'Live Music'
                                                                        ? 'assets/images/live_music.png'
                                                                        : vendormodel.filters.keys.elementAt(index) == 'Outdoor Seating'
                                                                            ? 'assets/images/outdoor_seating.png'
                                                                            : vendormodel.filters.keys.elementAt(index) == 'Takes Reservations'
                                                                                ? 'assets/images/take_reservation.png'
                                                                                : 'assets/images/vegetarian.png'),
                                                // height: 10,
                                              ),
                                            ),
                                            SizedBox(height: 15),
                                            Container(
                                              alignment: Alignment.center,
                                              height: 50.5,
                                              width: 123,
                                              child: Text(vendormodel.filters.keys.elementAt(index),
                                                      textAlign: TextAlign.center, style: TextStyle(color: isDarkMode(context) ? Colors.grey.shade300 : Color(0XFF333333), fontFamily: "Poppinsl"))
                                                  .tr(),
                                            ),
                                          ],
                                        ),
                                      ));
                                }
                              },
                            ),
                          ),
                          // Container(
                          //   height: MediaQuery.of(context).size.height,
                          //   margin: EdgeInsets.all(8),
                          //   child: StaggeredGridView.countBuilder(
                          //     crossAxisCount: 2,
                          //     staggeredTileBuilder: (int index) => StaggeredTile.fit(1),
                          //     shrinkWrap: true,
                          //     itemCount: vendormodel.filters.length,
                          //     itemBuilder: (BuildContext context, int index) {
                          //       if (vendormodel.filters.values.elementAt(index) != "Yes") {
                          //         return Container();
                          //       } else {
                          //         return Container(
                          //             height: 125,
                          //             alignment: Alignment.center,
                          //             margin: EdgeInsets.all(10),
                          //             decoration: BoxDecoration(
                          //                 borderRadius: BorderRadius.circular(10),
                          //                 border: Border.all(color: Colors.grey.shade100, width: 0.1),
                          //                 boxShadow: [
                          //                   BoxShadow(
                          //                     color: Colors.grey.shade200,
                          //                     blurRadius: 4.0,
                          //                     spreadRadius: 0.6,
                          //                     offset: Offset(0.2, 0.2),
                          //                   ),
                          //                 ],
                          //                 color: Colors.white),
                          //             child: SingleChildScrollView(
                          //               child: Column(
                          //                 children: [
                          //                   Container(
                          //                     padding: EdgeInsets.only(top: 5),
                          //                     alignment: Alignment.center,
                          //                     height: 30.5,
                          //                     child: Image(
                          //                       image: AssetImage(vendormodel.filters.keys.elementAt(index) == 'Cuisine'
                          //                           ? 'assets/images/vegetarian.png'
                          //                           : vendormodel.filters.keys.elementAt(index) == 'Free Wi-Fi'
                          //                               ? 'assets/images/free_wifi.png'
                          //                               : vendormodel.filters.keys.elementAt(index) == 'Good for Breakfast'
                          //                                   ? 'assets/images/good_for_breakfast.png'
                          //                                   : vendormodel.filters.keys.elementAt(index) == 'Good for Dinner'
                          //                                       ? 'assets/images/good_for_dinner.png'
                          //                                       : vendormodel.filters.keys.elementAt(index) == 'Good for Lunch'
                          //                                           ? 'assets/images/good_for_lunch.png'
                          //                                           : vendormodel.filters.keys.elementAt(index) == 'Live Music'
                          //                                               ? 'assets/images/live_music.png'
                          //                                               : vendormodel.filters.keys.elementAt(index) == 'Outdoor Seating'
                          //                                                   ? 'assets/images/outdoor_seating.png'
                          //                                                   : vendormodel.filters.keys.elementAt(index) ==
                          //                                                           'Takes Reservations'
                          //                                                       ? 'assets/images/take_reservation.png'
                          //                                                       : 'assets/images/vegetarian.png'),
                          //                       // height: 10,
                          //                     ),
                          //                   ),
                          //                   SizedBox(height: 15),
                          //                   Container(
                          //                     alignment: Alignment.center,
                          //                     height: 50.5,
                          //                     width: 123,
                          //                     child: Text(vendormodel.filters.keys.elementAt(index),
                          //                             textAlign: TextAlign.center,
                          //                             style: TextStyle(color: Color(0XFF333333), fontFamily: "Poppinsl"))
                          //                         .tr(),
                          //                   ),
                          //                 ],
                          //               ),
                          //             ));
                          //       }
                          //     },
                          //   ),
                          // ),
                        ])))))
          ]))
        ]));
  }
}
