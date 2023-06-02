import 'package:cached_network_image/cached_network_image.dart';
// ignore: implementation_imports
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:foodie_customer/AppGlobal.dart';
import 'package:foodie_customer/main.dart';
import 'package:foodie_customer/model/VendorModel.dart';
import 'package:foodie_customer/services/FirebaseHelper.dart';
import 'package:foodie_customer/services/helper.dart';
import 'package:foodie_customer/ui/vendorProductsScreen/newVendorProductsScreen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../constants.dart';

class ViewAllNewArrivalRestaurantScreen extends StatefulWidget {
  const ViewAllNewArrivalRestaurantScreen({Key? key, this.isPageCallForDineIn = false, this.isPageCallForPopular = false}) : super(key: key);

  @override
  _ViewAllNewArrivalRestaurantScreenState createState() => _ViewAllNewArrivalRestaurantScreenState();

  final bool? isPageCallForPopular;
  final bool? isPageCallForDineIn;
}

class _ViewAllNewArrivalRestaurantScreenState extends State<ViewAllNewArrivalRestaurantScreen> {
  Stream<List<VendorModel>>? vendorsFuture;
  final fireStoreUtils = FireStoreUtils();
  Stream<List<VendorModel>>? lstNewArrivalRestaurant;
  var position = LatLng(23.12, 70.22);
  bool showLoader = true;
  List<VendorModel> newArrivalLst = [];

  @override
  void initState() {

    super.initState();
    _getUserLocation();
    fireStoreUtils.getRestaurantNearBy().whenComplete(() {
      setState(() {
        if (widget.isPageCallForDineIn!) {
          if (widget.isPageCallForPopular!) {
            lstNewArrivalRestaurant = fireStoreUtils.getPopularsVendors(path: "isDineIn").asBroadcastStream();
          } else {
            lstNewArrivalRestaurant = fireStoreUtils.getVendorsForNewArrival(path: "isDineIn").asBroadcastStream();
          }
        } else {
          lstNewArrivalRestaurant = fireStoreUtils.getVendorsForNewArrival().asBroadcastStream();
        }
        showLoader = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppGlobal.buildAppBar(context, widget.isPageCallForPopular! ? "Popular Restaurants" : "New Arrival Restaurants"),
        body: Container(
            color: isDarkMode(context) ? Color(DARK_VIEWBG_COLOR) : Colors.white,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
            child: StreamBuilder<List<VendorModel>>(
                stream: lstNewArrivalRestaurant,
                initialData: [],
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting)
                    return Center(
                      child: CircularProgressIndicator.adaptive(
                        valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
                      ),
                    );

                  if (snapshot.hasData || (snapshot.data?.isNotEmpty ?? false)) {
                    newArrivalLst = snapshot.data!;

                    return Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                        child: showLoader
                            ? Center(
                                child: CircularProgressIndicator.adaptive(
                                  valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                scrollDirection: Axis.vertical,
                                physics: BouncingScrollPhysics(),
                                itemCount: newArrivalLst.length,
                                itemBuilder: (context, index) => buildPopularsItem(newArrivalLst[index])));
                  } else {
                    return showEmptyState('No Restaurant found'.tr(), context);
                  }
                })));
  }

  Widget buildPopularsItem(VendorModel vendorModel) {
    return GestureDetector(
      onTap: () => push(
        context,
        NewVendorProductsScreen(vendorModel: vendorModel),
      ),
      child: Container(
        height: 260,
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isDarkMode(context) ? Colors.grey.shade900 : Colors.grey.shade100, width: 0.1),
            boxShadow: [
              isDarkMode(context)
                  ? BoxShadow()
                  : BoxShadow(
                      color: isDarkMode(context) ? Colors.grey.shade600 : Colors.grey.shade400,
                      blurRadius: 8.0,
                      spreadRadius: 1.2,
                      offset: Offset(0.2, 0.2),
                    ),
            ],
            color: isDarkMode(context) ? Color(DARK_CARD_BG_COLOR) : Colors.white),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
                child: CachedNetworkImage(
              imageUrl: getImageVAlidUrl(vendorModel.photo),
              imageBuilder: (context, imageProvider) => Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                ),
              ),
              placeholder: (context, url) => Center(
                  child: CircularProgressIndicator.adaptive(
                valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
              )),
              errorWidget: (context, url, error) => ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    AppGlobal.placeHolderImage!,
                    fit: BoxFit.cover,
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                  )),
              fit: BoxFit.cover,
            )),
            SizedBox(height: 8),
            Container(
              margin: EdgeInsets.fromLTRB(15, 0, 5, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(vendorModel.title,
                            maxLines: 1,
                            style: TextStyle(
                              fontFamily: "Poppinssm",
                              letterSpacing: 0.5,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode(context) ? Colors.white : Color(0xff000000),
                            )).tr(),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, bottom: 0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star,
                                  size: 20,
                                  color: Color(COLOR_PRIMARY),
                                ),
                                SizedBox(width: 3),
                                Text(vendorModel.reviewsCount != 0 ? '${(vendorModel.reviewsSum / vendorModel.reviewsCount).toStringAsFixed(1)}' : 0.toString(),
                                    style: TextStyle(
                                      fontFamily: "Poppinssr",
                                      fontWeight: FontWeight.bold,
                                      color: isDarkMode(context) ? Color(DARK_GREY_TEXT_COLOR) : Color(0xff666666),
                                    )),
                                SizedBox(width: 3),
                                Text("(${vendorModel.reviewsCount})",
                                    style: TextStyle(
                                      fontFamily: "Poppinssr",
                                      letterSpacing: 0.5,
                                      color: isDarkMode(context) ? Color(DARK_GREY_TEXT_COLOR) : Color(0xff666666),
                                    )),
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ImageIcon(
                        AssetImage('assets/images/location3x.png'),
                        size: 15,
                        color: Color(0xff555353),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 5, right: 5),
                          child: Text(vendorModel.location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: "Poppinssr",
                                letterSpacing: 0.5,
                                color: isDarkMode(context) ? Color(DARK_GREY_TEXT_COLOR) : Color(0xff555353),
                              )),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: Row(
                          children: [
                            Container(
                              height: 5,
                              width: 5,
                              decoration: new BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDarkMode(context) ? Color(DARK_GREY_TEXT_COLOR) : Color(0xff555353),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 10, right: 10),
                              child: Text(getKm(vendorModel.latitude, vendorModel.longitude)! + " km",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: "Poppinssr",
                                    color: isDarkMode(context) ? Color(DARK_GREY_TEXT_COLOR) : Color(0xff555353),
                                  )),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void _getUserLocation() async {
    setState(() {
      position = LatLng(MyAppState.selectedPosotion.latitude, MyAppState.selectedPosotion.longitude);
    });
  }

  @override
  void dispose() {

    fireStoreUtils.closeNewArrivalStream();
    super.dispose();
  }

  String? getKm(double latitude, double longitude) {
    double distanceInMeters = Geolocator.distanceBetween(latitude, longitude, position.latitude, position.longitude);
    double kilometer = distanceInMeters / 1000;
    print("KiloMeter$kilometer");

    double minutes = 1.2;
    double value = minutes * kilometer;
    final int hour = value ~/ 60;
    final double minute = value % 60;
    print('${hour.toString().padLeft(2, "0")}:${minute.toStringAsFixed(0).padLeft(2, "0")}');
    return kilometer.toStringAsFixed(2).toString();
  }
}
