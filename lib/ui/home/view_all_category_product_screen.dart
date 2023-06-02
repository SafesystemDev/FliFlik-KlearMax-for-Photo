import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:foodie_customer/AppGlobal.dart';
import 'package:foodie_customer/constants.dart';
import 'package:foodie_customer/main.dart';
import 'package:foodie_customer/model/FavouriteModel.dart';
import 'package:foodie_customer/model/VendorCategoryModel.dart';
import 'package:foodie_customer/model/VendorModel.dart';
import 'package:foodie_customer/services/FirebaseHelper.dart';
import 'package:foodie_customer/services/helper.dart';
import 'package:foodie_customer/ui/auth/AuthScreen.dart';
import 'package:geolocator/geolocator.dart';

import '../vendorProductsScreen/newVendorProductsScreen.dart';

class ViewAllCategoryProductScreen extends StatefulWidget {
  VendorCategoryModel? vendorCategoryModel;

  ViewAllCategoryProductScreen({Key? key, this.vendorCategoryModel}) : super(key: key);

  @override
  State<ViewAllCategoryProductScreen> createState() => _ViewAllCategoryProductScreenState();
}

class _ViewAllCategoryProductScreenState extends State<ViewAllCategoryProductScreen> {
  List<VendorModel> productList = [];
  bool showLoader = true;

  List<String> lstFav = [];
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
      setState(() {

      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
    getProductByCategoryId();
  }

  getProductByCategoryId() async {

    FireStoreUtils().getCategoryRestaurants(widget.vendorCategoryModel!.id.toString()).asBroadcastStream().listen((event) {
      setState(() {
        productList = event;
      });
    });

    setState(() {
      showLoader = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppGlobal.buildAppBar(context, widget.vendorCategoryModel!.title.toString()),
      body: showLoader
          ? Center(
              child: CircularProgressIndicator.adaptive(
                valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
              ),
            )
          : productList.isEmpty
              ? showEmptyState("No Item found".tr(), context)
              : ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  physics: const BouncingScrollPhysics(),
                  itemCount: productList.length,
                  itemBuilder: (context, index) {
                    return buildVendorItemData(context, productList[index]);
                  }),
    );
  }

  Widget buildVendorItemData(BuildContext context, VendorModel vendorModel) {
    double distanceInMeters = Geolocator.distanceBetween(vendorModel.latitude, vendorModel.longitude, MyAppState.selectedPosotion.latitude, MyAppState.selectedPosotion.longitude);
    double kilometer = distanceInMeters / 1000;
    double minutes = 1.2;
    double value = minutes * kilometer;
    final int hour = value ~/ 60;
    final double minute = value % 60;
    return GestureDetector(
      onTap: () async {
        push(
          context,
          NewVendorProductsScreen(vendorModel: vendorModel),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.35,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isDarkMode(context) ? const Color(DarkContainerBorderColor) : Colors.grey.shade100, width: 1),
              color: isDarkMode(context) ? const Color(DarkContainerColor) : Colors.white,
              boxShadow: [
                isDarkMode(context)
                    ? const BoxShadow()
                    : BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        blurRadius: 5,
                      ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                    child: Stack(
                  children: [
                    CachedNetworkImage(
                      imageUrl: getImageVAlidUrl(vendorModel.photo),
                      imageBuilder: (context, imageProvider) => Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                          image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                        ),
                      ),
                      placeholder: (context, url) => Center(
                          child: CircularProgressIndicator.adaptive(
                        valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
                      )),
                      errorWidget: (context, url, error) => ClipRRect(
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                        child: Image.network(
                          AppGlobal.placeHolderImage!,
                          width: MediaQuery.of(context).size.width * 0.75,
                          fit: BoxFit.contain,
                        ),
                      ),
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: GestureDetector(
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
                      ),
                    ),

                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(vendorModel.reviewsCount != 0 ? (vendorModel.reviewsSum / vendorModel.reviewsCount).toStringAsFixed(1) : 0.toString(),
                                  style: const TextStyle(
                                    fontFamily: "Poppinsm",
                                    letterSpacing: 0.5,
                                    fontSize: 12,
                                    color: Colors.white,
                                  )),
                              const SizedBox(width: 3),
                              const Icon(
                                Icons.star,
                                size: 16,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                )),
                const SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(vendorModel.title, maxLines: 1, style: TextStyle(fontFamily: "Poppinsm", fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.2)).tr(),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.location_pin,
                            color:Color(COLOR_PRIMARY),
                            size: 20,
                          ),
                          SizedBox(width: 5),
                          Expanded(
                            child: Text(vendorModel.location, maxLines: 1, style: TextStyle(fontFamily: "Poppinsm", color: isDarkMode(context) ? Colors.white : Colors.black.withOpacity(0.60))).tr(),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.timer_sharp,
                            color:Color(COLOR_PRIMARY),
                            size: 20,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            '${hour.toString().padLeft(2, "0")}h ${minute.toStringAsFixed(0).padLeft(2, "0")}m',
                            style: TextStyle(
                                fontFamily: "Poppinsm",
                                letterSpacing: 0.5,
                                color: isDarkMode(context) ? Colors.white : Colors.black.withOpacity(0.60)),
                          ),
                          SizedBox(
                            width: 10,
                          ),

                          Icon(
                            Icons.my_location_sharp,
                            color:Color(COLOR_PRIMARY),
                            size: 20,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            "${kilometer.toDouble().toStringAsFixed(decimal)} km",
                            style: TextStyle(
                                fontFamily: "Poppinsm",
                                letterSpacing: 0.5,
                                color: isDarkMode(context) ? Colors.white : Colors.black.withOpacity(0.60)),
                          ).tr(),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
