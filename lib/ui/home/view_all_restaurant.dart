import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:foodie_customer/AppGlobal.dart';
import 'package:foodie_customer/constants.dart';
import 'package:foodie_customer/main.dart';
import 'package:foodie_customer/model/FavouriteModel.dart';
import 'package:foodie_customer/model/VendorModel.dart';
import 'package:foodie_customer/services/FirebaseHelper.dart';
import 'package:foodie_customer/services/helper.dart';
import 'package:foodie_customer/ui/auth/AuthScreen.dart';
import 'package:foodie_customer/ui/vendorProductsScreen/newVendorProductsScreen.dart';
import 'package:geoflutterfire/geoflutterfire.dart';

class ViewAllRestaurant extends StatefulWidget {
  const ViewAllRestaurant({Key? key}) : super(key: key);

  @override
  State<ViewAllRestaurant> createState() => _ViewAllRestaurantState();
}

class _ViewAllRestaurantState extends State<ViewAllRestaurant> {
  List<VendorModel> vendors = [];

  bool isLoading = true;

  getProducts() async {
    setState(() {
      isLoading = true;
    });
    var collectionReference = FireStoreUtils.firestore.collection(VENDORS);

    GeoFirePoint center = Geoflutterfire().point(latitude: MyAppState.selectedPosotion.latitude, longitude: MyAppState.selectedPosotion.longitude);
    String field = 'g';

    Stream<List<DocumentSnapshot>> stream = Geoflutterfire().collection(collectionRef: collectionReference).within(center: center, radius: radiusValue, field: field, strictMode: true);
    stream.listen((documentList) {
      for (var document in documentList) {
        final data = document.data() as Map<String, dynamic>;
        setState(() {
          vendors.add(VendorModel.fromJson(data));
        });
      }
    });
    setState(() {
      isLoading = false;
    });
  }

  late Future<List<FavouriteModel>> lstFavourites;

  getData() {
    if (MyAppState.currentUser != null) {
      lstFavourites = FireStoreUtils().getFavouriteRestaurant(MyAppState.currentUser!.userID);
      lstFavourites.then((event) {
        lstFav.clear();
        for (int a = 0; a < event.length; a++) {
          lstFav.add(event[a].restaurantId!);
        }
      });
    }
  }

  List<String> lstFav = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppGlobal.buildAppBar(context, "All Restaurant".tr()),
      body: Column(
        children: [
          Expanded(
            child: vendors.isEmpty
                ? Center(
                    child: const Text('No Data...').tr(),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: vendors.length,
                    itemBuilder: (context, index) =>
                        //buildVendorItem(vendors[index])

                        buildAllRestaurantsData(vendors[index]),
                  ),
          ),
          isLoading ? const CircularProgressIndicator() : Container()
        ],
      ),
    );
  }

  Widget buildAllRestaurantsData(VendorModel vendorModel) {
    return GestureDetector(
      onTap: () => push(
        context,
        NewVendorProductsScreen(vendorModel: vendorModel),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade100, width: 1),
            boxShadow: [
              isDarkMode(context)
                  ? const BoxShadow()
                  : BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      blurRadius: 5,
                    ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Stack(
                  children: [
                    CachedNetworkImage(
                      imageUrl: getImageVAlidUrl(vendorModel.photo),
                      height: 100,
                      width: 100,
                      imageBuilder: (context, imageProvider) => Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                        ),
                      ),
                      placeholder: (context, url) => Center(
                          child: CircularProgressIndicator.adaptive(
                        valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
                      )),
                      errorWidget: (context, url, error) => ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            AppGlobal.placeHolderImage!,
                            fit: BoxFit.cover,
                            cacheHeight: 100,
                            cacheWidth: 100,
                          )),
                      fit: BoxFit.cover,
                    ),
                  ],
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              vendorModel.title,
                              style: TextStyle(
                                fontFamily: "Poppinsm",
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: isDarkMode(context) ? Colors.white : Colors.black,
                              ),
                              maxLines: 1,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              if (MyAppState.currentUser == null) {
                                push(context, AuthScreen());
                              } else {
                                setState(() {
                                  if (lstFav.contains(vendorModel.id) == true) {
                                    FavouriteModel favouriteModel = FavouriteModel(restaurantId: vendorModel.id, userId: MyAppState.currentUser!.userID);
                                    lstFav.removeWhere((item) => item == vendorModel.id);
                                    FireStoreUtils().removeFavouriteRestaurant(favouriteModel);
                                  } else {
                                    FavouriteModel favouriteModel = FavouriteModel(restaurantId: vendorModel.id, userId: MyAppState.currentUser!.userID);
                                    FireStoreUtils().setFavouriteRestaurant(favouriteModel);
                                    lstFav.add(vendorModel.id);
                                  }
                                });
                              }
                            },
                            child: lstFav.contains(vendorModel.id) == true
                                ? Icon(
                                    Icons.favorite,
                                    color: Color(COLOR_PRIMARY),
                                  )
                                : Icon(
                                    Icons.favorite_border,
                                    color: isDarkMode(context) ? Colors.white38 : Colors.black38,
                                  ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      // Text("Min".tr() + " ${discountAmountTempList.isNotEmpty ? discountAmountTempList.reduce(min).toStringAsFixed(0) : 0}% " + "off".tr(),
                      //     maxLines: 1,
                      //     style: TextStyle(
                      //       fontFamily: "Poppinsm",
                      //       letterSpacing: 0.5,
                      //       color: isDarkMode(context) ? Colors.white60 : const Color(0xff555353),
                      //     )),
                      // const SizedBox(
                      //   height: 10,
                      // ),
                      Row(
                        children: [
                          Icon(
                            Icons.location_pin,
                            size: 20,
                            color: Color(COLOR_PRIMARY),
                          ),
                          Expanded(
                            child: Text(
                              vendorModel.location,
                              maxLines: 1,
                              style: TextStyle(
                                fontFamily: "Poppinsm",
                                color: isDarkMode(context) ? Colors.white70 : const Color(0xff9091A4),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 20,
                            color: Color(COLOR_PRIMARY),
                          ),
                          const SizedBox(width: 3),
                          Text(vendorModel.reviewsCount != 0 ? (vendorModel.reviewsSum / vendorModel.reviewsCount).toStringAsFixed(1) : 0.toString(),
                              style: TextStyle(
                                fontFamily: "Poppinsm",
                                letterSpacing: 0.5,
                                color: isDarkMode(context) ? Colors.white : const Color(0xff000000),
                              )),
                          const SizedBox(width: 3),
                          Text('(${vendorModel.reviewsCount.toStringAsFixed(1)})',
                              style: TextStyle(
                                fontFamily: "Poppinsm",
                                letterSpacing: 0.5,
                                color: isDarkMode(context) ? Colors.white60 : const Color(0xff666666),
                              )),
                          const SizedBox(width: 5),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    getRadius();
    getData();
  }

  getRadius() async {
    await FireStoreUtils().getRestaurantNearBy().then((value) {
      if (value != null) {
        getProducts();
      }
    });
  }
}
