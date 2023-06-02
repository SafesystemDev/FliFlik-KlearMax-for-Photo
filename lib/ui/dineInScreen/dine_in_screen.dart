import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:foodie_customer/AppGlobal.dart';
import 'package:foodie_customer/constants.dart';
import 'package:foodie_customer/main.dart';
import 'package:foodie_customer/model/AddressModel.dart';
import 'package:foodie_customer/model/FavouriteModel.dart';
import 'package:foodie_customer/model/ProductModel.dart';
import 'package:foodie_customer/model/User.dart';
import 'package:foodie_customer/model/VendorCategoryModel.dart';
import 'package:foodie_customer/model/VendorModel.dart';
import 'package:foodie_customer/services/FirebaseHelper.dart';
import 'package:foodie_customer/services/helper.dart';
import 'package:foodie_customer/ui/categoryDetailsScreen/CategoryDetailsScreen.dart';
import 'package:foodie_customer/ui/cuisinesScreen/CuisinesScreen.dart';
import 'package:foodie_customer/ui/dineInScreen/dine_in_restaurant_details_screen.dart';
import 'package:foodie_customer/ui/home/CurrentAddressChangeScreen.dart';
import 'package:foodie_customer/ui/home/view_all_new_arrival_restaurant_screen.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' as loc;
import 'package:permission_handler/permission_handler.dart';
import 'package:place_picker/entities/entities.dart';
import 'package:place_picker/widgets/place_picker.dart';

class DineInScreen extends StatefulWidget {
  final User? user;

  const DineInScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<DineInScreen> createState() => _DineInScreenState();
}

class _DineInScreenState extends State<DineInScreen> {
  loc.Location location = new loc.Location();
  String? currentLocation = "", name = "";
  final fireStoreUtils = FireStoreUtils();

  Stream<List<VendorModel>>? lstVendor;
  Stream<List<VendorModel>>? lstAllRestaurant;
  Stream<List<VendorModel>>? lstNewArrivalRestaurant;
  Stream<List<VendorModel>>? lstPopularRestaurant;
  late Future<List<FavouriteModel>> lstFavourites;
  late Future<List<VendorCategoryModel>> cuisinesFuture;
  List<String> lstFav = [];
  List<VendorModel> newArrivalLst = [];
  List<VendorModel> restaurantAllLst = [];
  List<VendorModel> popularRestaurantLst = [];
  List<VendorModel> lstNearByFood = [];
  bool showLoader = true;
  late Future<List<ProductModel>> productsFuture;
  List<VendorModel> vendors = [];
  VendorModel? popularNearFoodVendorModel;

  _getLocation() async {
    if (MyAppState.selectedPosotion.longitude == 0 && MyAppState.selectedPosotion.latitude == 0) {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high).whenComplete(() {});
      MyAppState.selectedPosotion = position;
    }

    List<Placemark> placeMarks = await placemarkFromCoordinates(MyAppState.selectedPosotion.latitude, MyAppState.selectedPosotion.longitude);
    Placemark placeMark = placeMarks[0];
    setState(() {
      currentLocation = placeMark.name.toString() +
          ", " +
          placeMark.subLocality.toString() +
          ", " +
          placeMark.locality.toString() +
          ", " +
          placeMark.administrativeArea.toString() +
          ", " +
          placeMark.postalCode.toString() +
          ", " +
          placeMark.country.toString();
    });
    if (MyAppState.currentUser != null) {
      AddressModel userAddress = AddressModel(
          name: MyAppState.currentUser!.fullName(),
          postalCode: placeMark.postalCode.toString(),
          line1: placeMark.name.toString() + ", " + placeMark.subLocality.toString(),
          line2: placeMark.administrativeArea.toString(),
          country: placeMark.country.toString(),
          city: placeMark.locality.toString(),
          location: MyAppState.currentUser!.location,
          email: MyAppState.currentUser!.email);
      MyAppState.currentUser!.shippingAddress = userAddress;
      await FireStoreUtils.updateCurrentUserAddress(userAddress);
    }
  }

  bool isLocationPermissionAllowed = false;

  getLoc() async {
    bool _serviceEnabled;

    _serviceEnabled = await location.requestService();
    if (_serviceEnabled) {
      var status = await Permission.location.status;
      if (status.isDenied) {
        if (Platform.isIOS) {
          status = await Permission.locationWhenInUse.request();
        } else {
          status = await Permission.location.request();
        }

        if (status.isGranted) {
          _getLocation();
          getData();
        } else if (status.isPermanentlyDenied) {
          if (Platform.isIOS) {
            openAppSettings();
          } else {
            await Permission.contacts.shouldShowRequestRationale;
            if (status.isPermanentlyDenied) {
              getTempLocation();
            }
          }
        }
      } else if (status.isRestricted) {
        getTempLocation();
      } else if (status.isPermanentlyDenied) {
        if (Platform.isIOS) {
          openAppSettings();
        } else {
          await Permission.contacts.shouldShowRequestRationale;
        }
      } else {
        _getLocation();
        getData();
      }
      return;
    } else {
      getTempLocation();
    }
    //_currentPosition = await location.getLocation();
  }

  @override
  void initState() {
    super.initState();
    getLoc();
    cuisinesFuture = fireStoreUtils.getCuisines();
  }

  void dispose() {
    FireStoreUtils().closeDineInStream();
    super.dispose();
  }

  void getData() {
    fireStoreUtils.getRestaurantNearBy().whenComplete(() {
      lstVendor = fireStoreUtils.getVendors1(path: "isDineIn").asBroadcastStream();
      lstAllRestaurant = fireStoreUtils.getAllDineInRestaurants().asBroadcastStream();
      lstNewArrivalRestaurant = fireStoreUtils.getVendorsForNewArrival(path: "isDineIn").asBroadcastStream();
      lstPopularRestaurant = fireStoreUtils.getPopularsVendors(path: "isDineIn").asBroadcastStream();
      if (MyAppState.currentUser != null) {
        lstFavourites = fireStoreUtils.getFavouriteRestaurant(MyAppState.currentUser!.userID);
        lstFavourites.then((event) {
          lstFav.clear();
          for (int a = 0; a < event.length; a++) {
            lstFav.add(event[a].restaurantId!);
          }
        });
        name = toBeginningOfSentenceCase(widget.user!.firstName);
      }
      lstVendor!.listen((event) {
        setState(() {
          vendors.addAll(event);
        });
        restaurantAllLst.clear();
        restaurantAllLst.addAll(event);
        for (int a = 0; a < restaurantAllLst.length; a++) {
          if ((restaurantAllLst[a].reviewsSum / restaurantAllLst[a].reviewsCount) >= 4.0) {
            popularRestaurantLst.add(restaurantAllLst[a]);
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isLocationAvail = (MyAppState.selectedPosotion.latitude == 0 && MyAppState.selectedPosotion.longitude == 0);
    return Scaffold(
      backgroundColor: isDarkMode(context) ? Color(DARK_COLOR) : Color(0xffFFFFFF),
      body: isLocationAvail
          ? showEmptyState("notHaveYourLocation", context, description: "locationSearchingRestaurants".tr(), action: () async {
              LocationResult result = await Navigator.of(context).push(MaterialPageRoute(builder: (context) => PlacePicker(GOOGLE_API_KEY)));

              setState(() {
                MyAppState.selectedPosotion = Position.fromMap({'latitude': result.latLng!.latitude, 'longitude': result.latLng!.longitude});

                currentLocation = result.formattedAddress;
                getData();
              });
            }, buttonTitle: 'Select'.tr())
          : SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          color: Color(COLOR_PRIMARY),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Expanded(
                          child: Text(currentLocation.toString(), maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: Color(COLOR_PRIMARY), fontFamily: "Poppinsr")).tr(),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.of(context)
                                .push(PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) => CurrentAddressChangeScreen(),
                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                return child;
                              },
                            ))
                                .then((value) {
                              if (value != null) {
                                setState(() {
                                  currentLocation = value;
                                  getData();
                                });
                              }
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                            decoration: BoxDecoration(borderRadius: new BorderRadius.circular(10), color: Colors.black12, boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset: Offset(0, 3), // changes position of shadow
                              ),
                            ]),
                            child: Text("Change", style: TextStyle(fontSize: 14, color: Color(COLOR_PRIMARY), fontFamily: "Poppinsr")).tr(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 5, left: 10),
                    child: Text("Find your restaurant", style: TextStyle(fontSize: 24, color: isDarkMode(context) ? Colors.white : Color(0xFF333333), fontFamily: "Poppinssb")).tr(),
                  ),
                  buildDineInTitleRow(
                    titleValue: "Categories".tr(),
                    onClick: () {
                      push(
                        context,
                        CuisinesScreen(
                          isPageCallFromHomeScreen: true,
                          isPageCallForDineIn: true,
                        ),
                      );
                    },
                  ),
                  Container(
                    color: isDarkMode(context) ? Color(DARK_COLOR) : Color(0xffFFFFFF),
                    child: FutureBuilder<List<VendorCategoryModel>>(
                        future: cuisinesFuture,
                        initialData: [],
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting)
                            return Center(
                              child: CircularProgressIndicator.adaptive(
                                valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
                              ),
                            );

                          if (snapshot.hasData || (snapshot.data?.isNotEmpty ?? false)) {
                            return Container(
                                height: 150,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: snapshot.data!.length >= 15 ? 15 : snapshot.data!.length,
                                  itemBuilder: (context, index) {
                                    return buildCategoryItem(snapshot.data![index]);
                                  },
                                ));
                          } else {
                            return showEmptyState('No Categories'.tr(), context);
                          }
                        }),
                  ),
                  buildDineInTitleRow(
                    titleValue: "New Arrivals",
                    onClick: () {
                      push(
                          context,
                          ViewAllNewArrivalRestaurantScreen(
                            isPageCallForDineIn: true,
                          ));
                    },
                  ),
                  StreamBuilder<List<VendorModel>>(
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
                              height: MediaQuery.of(context).size.height * 0.32,
                              margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  physics: BouncingScrollPhysics(),
                                  itemCount: newArrivalLst.length >= 15 ? 15 : newArrivalLst.length,
                                  itemBuilder: (context, index) => buildNewArrivalItem(newArrivalLst[index])));
                        } else {
                          return showEmptyState('No Restaurant found'.tr(), context);
                        }
                      }),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: buildDineInTitleRow(
                      titleValue: "Popular Restaurants".tr(),
                      onClick: () {
                        push(
                            context,
                            ViewAllNewArrivalRestaurantScreen(
                              isPageCallForDineIn: true,
                              isPageCallForPopular: true,
                            ));
                      },
                    ),
                  ),
                  StreamBuilder<List<VendorModel>>(
                      stream: lstPopularRestaurant,
                      initialData: [],
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting)
                          return Center(
                            child: CircularProgressIndicator.adaptive(
                              valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
                            ),
                          );

                        if (snapshot.hasData || (snapshot.data?.isNotEmpty ?? false)) {
                          lstNearByFood = snapshot.data!;

                          return Container(
                              height: MediaQuery.of(context).size.height * 0.32,
                              margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                              child: lstNearByFood.isEmpty
                                  ? showEmptyState('No Restaurant found'.tr(), context)
                                  : ListView.builder(
                                      shrinkWrap: true,
                                      scrollDirection: Axis.horizontal,
                                      physics: BouncingScrollPhysics(),
                                      itemCount: lstNearByFood.length >= 15 ? 15 : lstNearByFood.length,
                                      itemBuilder: (context, index) => buildNewArrivalItem(lstNearByFood[index])));
                        } else {
                          return showEmptyState('No Restaurant found'.tr(), context);
                        }
                      }),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: buildDineInTitleRow(
                      titleValue: "All Restaurants around you",
                      onClick: () {},
                      isViewAll: true,
                    ),
                  ),
                  Builder(builder: (context) {
                    return StreamBuilder<List<VendorModel>>(
                        stream: lstAllRestaurant,
                        initialData: [],
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting)
                            return Center(
                              child: CircularProgressIndicator.adaptive(
                                valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
                              ),
                            );

                          if (snapshot.hasData || (snapshot.data?.isNotEmpty ?? false)) {
                            vendors.clear();
                            vendors.addAll(snapshot.data!);
                            return Container(
                              width: MediaQuery.of(context).size.width,
                              margin: EdgeInsets.fromLTRB(10, 0, 0, 10),
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.vertical,
                                  physics: BouncingScrollPhysics(),
                                  itemCount: vendors.length,
                                  itemBuilder: (context, index) => buildAllRestaurantsData(vendors[index])),
                            );
                          } else {
                            return showEmptyState('No Restaurant found'.tr(), context);
                          }
                        });
                  }),
                ],
              ),
            ),
    );
  }

  Future<void> getTempLocation() async {
    if (MyAppState.currentUser == null && MyAppState.selectedPosotion.longitude != 0 && MyAppState.selectedPosotion.latitude != 0) {
      List<Placemark> placemarks = await placemarkFromCoordinates(MyAppState.selectedPosotion.latitude, MyAppState.selectedPosotion.longitude);
      Placemark placeMark = placemarks[0];
      setState(() {
        currentLocation = placeMark.name.toString() +
            ", " +
            placeMark.subLocality.toString() +
            ", " +
            placeMark.locality.toString() +
            ", " +
            placeMark.administrativeArea.toString() +
            ", " +
            placeMark.postalCode.toString() +
            ", " +
            placeMark.country.toString();
      });
      getData();
    }
    if (MyAppState.currentUser != null) {
      if (MyAppState.currentUser!.location.latitude != 0 &&
          MyAppState.currentUser!.location.longitude != 0) {
        MyAppState.selectedPosotion = Position.fromMap({'latitude': MyAppState.currentUser!.location.latitude, 'longitude': MyAppState.currentUser!.location.longitude});
        List<Placemark> placemarks = await placemarkFromCoordinates(MyAppState.selectedPosotion.latitude, MyAppState.selectedPosotion.longitude);
        Placemark placeMark = placemarks[0];
        setState(() {
          currentLocation = placeMark.name.toString() +
              ", " +
              placeMark.subLocality.toString() +
              ", " +
              placeMark.locality.toString() +
              ", " +
              placeMark.administrativeArea.toString() +
              ", " +
              placeMark.postalCode.toString() +
              ", " +
              placeMark.country.toString();
        });
        getData();
      }
      setState(() {});
    }
  }

  buildCategoryItem(VendorCategoryModel cuisineModel) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () {
          push(
              context,
              CategoryDetailsScreen(
                category: cuisineModel,
                isDineIn: true,
              ));
        },
        child: Container(
          width: MediaQuery.of(context).size.width * 0.23,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CachedNetworkImage(
                imageUrl: getImageVAlidUrl(cuisineModel.photo.toString()),
                imageBuilder: (context, imageProvider) => Container(
                  height: MediaQuery.of(context).size.height * 0.11,
                  width: MediaQuery.of(context).size.width * 0.22,
                  decoration: BoxDecoration(border: Border.all(width: 4, color: Color(COLOR_PRIMARY)), borderRadius: BorderRadius.circular(25)),
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(
                          width: 4,
                          color: isDarkMode(context) ? Color(DARK_COLOR) : Color(0xffE0E2EA),
                        ),
                        borderRadius: BorderRadius.circular(30)),
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          )),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(
                      AppGlobal.placeHolderImage!,
                      fit: BoxFit.cover,
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                    )),
                placeholder: (context, url) => ClipOval(
                  child: Container(
                    // padding: EdgeInsets.only(top: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(75 / 1)),
                      border: Border.all(
                        color: Color(COLOR_PRIMARY),
                        style: BorderStyle.solid,
                        width: 2.0,
                      ),
                    ),
                    width: 75,
                    height: 75,
                    child: Icon(
                      Icons.fastfood,
                      color: Color(COLOR_PRIMARY),
                    ),
                  ),
                ),
              ),
              // displayCircleImage(model.photo, 90, false),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(cuisineModel.title.toString(),
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isDarkMode(context) ? Colors.white : Color(0xFF000000),
                      fontFamily: "Poppinsr",
                    )).tr(),
              )
            ],
          ),
        ),
      ),
    );
  }

  buildNewArrivalItem(VendorModel vendorModel) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: GestureDetector(
        onTap: () {
          push(
            context,
            DineInRestaurantDetailsScreen(vendorModel: vendorModel),
          );
        },
        child: Container(
          width: MediaQuery.of(context).size.width * 0.60,
          child: Container(
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
              children: [
                Expanded(
                    child: CachedNetworkImage(
                  imageUrl: getImageVAlidUrl(vendorModel.photo),
                  width: MediaQuery.of(context).size.width * 0.75,
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
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        placeholderImage,
                        width: MediaQuery.of(context).size.width * 0.75,
                        fit: BoxFit.fitWidth,
                      )),
                  fit: BoxFit.cover,
                )),
                SizedBox(height: 8),
                Container(
                  margin: EdgeInsets.fromLTRB(15, 0, 5, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(vendorModel.title,
                          maxLines: 1,
                          style: TextStyle(
                            fontFamily: "Poppinssm",
                            letterSpacing: 0.5,
                            color: isDarkMode(context) ? Colors.white : Color(0xff000000),
                          )).tr(),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ImageIcon(
                            AssetImage('assets/images/location3x.png'),
                            size: 15,
                            color: isDarkMode(context) ? Colors.white60 : Color(0xff9091A4),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Expanded(
                            child: Text(vendorModel.location,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: "Poppinssr",
                                  letterSpacing: 0.5,
                                  color: isDarkMode(context) ? Colors.grey.shade400 : Color(0xff555353),
                                )),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: Row(
                              children: [
                                Container(
                                  height: 5,
                                  width: 5,
                                  decoration: new BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isDarkMode(context) ? Colors.grey.shade300 : Color(0xff555353),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 10.0),
                                  child: Text(getKm(vendorModel.latitude, vendorModel.longitude)! + " km",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontFamily: "Poppinssr",
                                        color: isDarkMode(context) ? Colors.grey.shade300 : Color(0xff555353),
                                      )),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, bottom: 10),
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
                                      letterSpacing: 0.5,
                                      color: isDarkMode(context) ? Colors.white : Color(0xff000000),
                                    )),
                                SizedBox(width: 3),
                                Text('(${vendorModel.reviewsCount.toStringAsFixed(1)})',
                                    style: TextStyle(
                                      fontFamily: "Poppinssr",
                                      letterSpacing: 0.5,
                                      color: isDarkMode(context) ? Colors.white60 : Color(0xff666666),
                                    )),
                              ],
                            ),
                          ],
                        ),
                      )
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

  String? getKm(double latitude, double longitude) {
    double distanceInMeters = Geolocator.distanceBetween(latitude, longitude, MyAppState.selectedPosotion.latitude, MyAppState.selectedPosotion.longitude);
    double kilometer = distanceInMeters / 1000;

    return kilometer.toStringAsFixed(2).toString();
  }

  buildAllRestaurantsData(VendorModel vendor) {
    return GestureDetector(
      onTap: () {
        push(
          context,
          DineInRestaurantDetailsScreen(vendorModel: vendor),
        );
      },
      child: Container(
        decoration: new BoxDecoration(
          borderRadius: new BorderRadius.circular(10),
          color: isDarkMode(context) ? Color(DARK_CARD_BG_COLOR) : Colors.white,
        ),
        margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
        padding: EdgeInsets.all(5),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: new BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: getImageVAlidUrl(vendor.photo),
                height: 100,
                width: 100,
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
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      vendor.photo,
                      fit: BoxFit.cover,
                    )),
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(
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
                          vendor.title,
                          style: TextStyle(
                            fontFamily: "Poppinssm",
                            fontSize: 16,
                            color: isDarkMode(context) ? Colors.white : Color(0xff000000),
                          ),
                          maxLines: 1,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            if (lstFav.contains(vendor.id) == true) {
                              FavouriteModel favouriteModel = FavouriteModel(restaurantId: vendor.id, userId: MyAppState.currentUser!.userID);
                              lstFav.removeWhere((item) => item == vendor.id);
                              fireStoreUtils.removeFavouriteRestaurant(favouriteModel);
                            } else {
                              FavouriteModel favouriteModel = FavouriteModel(restaurantId: vendor.id, userId: MyAppState.currentUser!.userID);
                              fireStoreUtils.setFavouriteRestaurant(favouriteModel);
                              lstFav.add(vendor.id);
                            }
                          });
                        },
                        child: lstFav.contains(vendor.id) == true
                            ? Icon(
                                Icons.favorite,
                                color: Color(COLOR_PRIMARY),
                              )
                            : Icon(
                                Icons.favorite_border,
                                color: isDarkMode(context) ? Colors.white60 : Colors.black38,
                              ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          vendor.location,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                            fontFamily: "Poppinssm",
                            color: isDarkMode(context) ? Colors.grey.shade300 : Color(0xff9091A4),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: Row(
                          children: [
                            Container(
                              height: 5,
                              width: 5,
                              decoration: new BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDarkMode(context) ? Colors.grey.shade300 : Color(0xff555353),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: Text(getKm(vendor.latitude, vendor.longitude)! + " km",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: "Poppinssr",
                                    color: isDarkMode(context) ? Colors.grey.shade300 : Color(0xff555353),
                                  )),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star,
                        size: 20,
                        color: Color(COLOR_PRIMARY),
                      ),
                      SizedBox(width: 3),
                      Text(vendor.reviewsCount != 0 ? '${(vendor.reviewsSum / vendor.reviewsCount).toStringAsFixed(1)}' : 0.toString(),
                          style: TextStyle(
                            fontFamily: "Poppinssr",
                            letterSpacing: 0.5,
                            color: isDarkMode(context) ? Colors.white : Color(0xff000000),
                          )),
                      SizedBox(width: 3),
                      Text('(${vendor.reviewsCount.toStringAsFixed(1)})',
                          style: TextStyle(
                            fontFamily: "Poppinssr",
                            letterSpacing: 0.5,
                            color: isDarkMode(context) ? Colors.grey.shade300 : Color(0xff666666),
                          )),
                      SizedBox(width: 5),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

// ignore: camel_case_types
class buildDineInTitleRow extends StatelessWidget {
  final String titleValue;
  final Function? onClick;
  final bool? isViewAll;

  const buildDineInTitleRow({
    Key? key,
    required this.titleValue,
    this.onClick,
    this.isViewAll = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Container(
        color: isDarkMode(context) ? Color(DARK_COLOR) : Color(0xffFFFFFF),
        child: Align(
          alignment: Alignment.topLeft,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(titleValue.tr(), style: TextStyle(color: isDarkMode(context) ? Colors.white : Color(0xFF000000), fontSize: 16, fontFamily: "Poppinsm")),
              isViewAll!
                  ? Container()
                  : GestureDetector(
                      onTap: () {
                        onClick!.call();
                      },
                      child: Text('View All'.tr(), style: TextStyle(color: Color(COLOR_PRIMARY), fontFamily: "Poppinsm")),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
