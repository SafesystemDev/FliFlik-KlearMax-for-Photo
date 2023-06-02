import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:foodie_customer/AppGlobal.dart';
import 'package:foodie_customer/constants.dart';
import 'package:foodie_customer/main.dart';
import 'package:foodie_customer/model/VendorModel.dart';
import 'package:foodie_customer/services/FirebaseHelper.dart';
import 'package:foodie_customer/services/helper.dart';
import 'package:foodie_customer/ui/vendorProductsScreen/newVendorProductsScreen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:permission_handler/permission_handler.dart';

class MapViewScreen extends StatefulWidget {
  @override
  _MapViewScreenState createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  Position? locationData;
  Stream<List<VendorModel>>? _mapFuture;

  // Stream<List<VendorModel>>? vendorsFuture;
  late BitmapDescriptor mapMarker;
  late BitmapDescriptor mapMarkerSelect;
  int selected = 0;
  ScrollController contro = ScrollController();

  void setCustomMaker() async {
    mapMarker = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(),
      'assets/images/map_unselected2x.png',
    );
    mapMarkerSelect = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(),
      'assets/images/map_selected3x.png',
    );
  }

  GoogleMapController? _mapController;
  FireStoreUtils fireStoreUtils = FireStoreUtils();
  List<VendorModel> vendors = [];

  var id, inx, latpos, lotpos;
  final itemKey = GlobalKey();

  // var controller = IndexedScrollController();
  @override
  void initState() {
    _getLocation();
    super.initState();
    fireStoreUtils.getRestaurantNearBy().whenComplete(() {
      print("======ERROE12");
      if (mounted) {
        setState(() {
          _mapFuture = fireStoreUtils.getVendors1().asBroadcastStream();
          // vendorsFuture = _mapFuture;
        });
      }

      setCustomMaker();
    }).catchError((onError) {
      print("======ERROE" + onError.toString());
    });
  }

  scrollable() {
    if (contro.hasClients) {
      // id = id+1;
      //  var _width =MediaQuery.of(context).size.width*1;
      var size = 355 * id;

      contro.jumpTo(size.toDouble());
    } else {
      print('no');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Map View'.tr()),
      // ),
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: StreamBuilder<List<VendorModel>>(
                stream: _mapFuture,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Container(
                      child: Center(
                        child: CircularProgressIndicator.adaptive(
                          valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
                        ),
                      ),
                    );
                  }
                  vendors = snapshot.data!;
                  print("======ERROEvendors" + vendors.length.toString());
                  return GoogleMap(
                    zoomControlsEnabled: false,
                    myLocationEnabled: true,

                    // myLocationButtonEnabled: true,
                    markers: List.generate(
                      vendors.length,
                      (index) => Marker(
                        onDrag: (latLng) {
                          setState(() {
                            latpos = vendors[index].latitude;
                            lotpos = vendors[index].longitude;
                            CameraUpdate.newLatLngZoom(latLng, 10);
                            move();
                          });
                        },
                        markerId: MarkerId('marker_$index'),
                        position: LatLng(vendors[index].latitude, vendors[index].longitude),
                        icon: selected == index ? mapMarkerSelect : mapMarker,
                        onTap: () {
                          setState(() {
                            selected = index;
                            id = index;
                            inx = index;

                            scrollable();
                            //  locationData.
                          });
                        },
                        infoWindow: InfoWindow(
                          onTap: () {
                            push(
                              context,
                              NewVendorProductsScreen(
                                vendorModel: vendors[index],
                              ),
                            );
                          },
                          title: vendors[index].title,
                        ),
                      ),
                    ).toSet(),
                    mapType: MapType.normal,
                    initialCameraPosition: CameraPosition(
                      target: locationData == null
                          ? vendors.isNotEmpty
                              ? LatLng(vendors.first.latitude, vendors.first.longitude)
                              : LatLng(0, 0)
                          : LatLng(locationData!.latitude, locationData!.longitude),
                      zoom: 14,
                    ),

                    onMapCreated: _onMapCreated,
                  );
                }),
          ),
          Align(
              alignment: Alignment.topLeft,
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: CircleAvatar(
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.black,
                      ),
                      // onPressed: () {
                      //   Navigator.pop(context);
                      // },

                      radius: 20,
                      backgroundColor: Colors.grey.shade100,
                    )),
              )
              // Container(height: 50, width: 100, color: Colors.amber),
              ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              height: 150,
              // width: 420,
              margin: EdgeInsets.only(bottom: 20),
              child: StreamBuilder<List<VendorModel>>(
                  stream: _mapFuture,
                  initialData: [],
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting)
                      return Center(
                        child: CircularProgressIndicator.adaptive(
                          valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
                        ),
                      );

                    if (snapshot.hasData || (snapshot.data?.isNotEmpty ?? false)) {
                      vendors = snapshot.data!;
                      return NotificationListener(
                          onNotification: (change) {
                            if (change is ScrollNotification) {
                              if (selected < vendors.length) {
                                setState(() {
                                  //  print(contro.position.pixels~/100);
                                  print(selected);

                                  selected = contro.position.pixels ~/ 300.toInt();
                                  latpos = vendors[selected].latitude;
                                  lotpos = vendors[selected].longitude;
                                  move();
                                });
                              }
                            }
                            return true;
                          },
                          child: ListView.builder(
                            controller: contro,
                            itemCount: vendors.length,
                            scrollDirection: Axis.horizontal,
                            key: itemKey,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Card(
                                  elevation: 3,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Container(
                                    height: 150,
                                    width: 330,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      color: isDarkMode(context) ? Color(0XFF0a0a0a) : Colors.grey.shade100,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                            flex: 3,
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: CachedNetworkImage(
                                                imageUrl: getImageVAlidUrl(vendors[index].photo),
                                                imageBuilder: (context, imageProvider) => Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(15),
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
                                              ),
                                            )),
                                        Expanded(
                                          flex: 5,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  vendors[index].title,
                                                  style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Poppinsm', color: isDarkMode(context) ? Colors.white70 : Colors.black, fontSize: 17),
                                                ),
                                                Row(
                                                  children: [
                                                    Icon(Icons.star, color: Color(COLOR_PRIMARY)),
                                                    SizedBox(width: 5),
                                                    Text(
                                                      vendors[index].reviewsCount.toStringAsFixed(1),
                                                      style: TextStyle(
                                                        fontFamily: 'Poppinsm',
                                                        color: isDarkMode(context) ? Colors.white70 : Colors.black,
                                                      ),
                                                    ),
                                                    SizedBox(width: 4),
                                                    Text(
                                                      "(${vendors[index].reviewsSum.toString()})",
                                                      style: TextStyle(
                                                        fontFamily: 'Poppinsm',
                                                        color: isDarkMode(context) ? Colors.white70 : Colors.black,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Text(
                                                  vendors[index].location,
                                                  maxLines: 2,
                                                  style: TextStyle(
                                                    fontFamily: 'Poppinsm',
                                                    color: isDarkMode(context) ? Colors.white70 : Colors.black,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ));
                    } else {
                      return showEmptyState('No Restaurant found'.tr(), context);
                    }
                  }),
            ),
          )
        ],
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;

    if (isDarkMode(context))
      _mapController!.setMapStyle('[{"featureType": "all","'
          'elementType": "'
          'geo'
          'met'
          'ry","stylers": [{"color": "#242f3e"}]},{"featureType": "all","elementType": "labels.text.stroke","stylers": [{"lightness": -80}]},{"featureType": "administrative","elementType": "labels.text.fill","stylers": [{"color": "#746855"}]},{"featureType": "administrative.locality","elementType": "labels.text.fill","stylers": [{"color": "#d59563"}]},{"featureType": "poi","elementType": "labels.text.fill","stylers": [{"color": "#d59563"}]},{"featureType": "poi.park","elementType": "geometry","stylers": [{"color": "#263c3f"}]},{"featureType": "poi.park","elementType": "labels.text.fill","stylers": [{"color": "#6b9a76"}]},{"featureType": "road","elementType": "geometry.fill","stylers": [{"color": "#2b3544"}]},{"featureType": "road","elementType": "labels.text.fill","stylers": [{"color": "#9ca5b3"}]},{"featureType": "road.arterial","elementType": "geometry.fill","stylers": [{"color": "#38414e"}]},{"featureType": "road.arterial","elementType": "geometry.stroke","stylers": [{"color": "#212a37"}]},{"featureType": "road.highway","elementType": "geometry.fill","stylers": [{"color": "#746855"}]},{"featureType": "road.highway","elementType": "geometry.stroke","stylers": [{"color": "#1f2835"}]},{"featureType": "road.highway","elementType": "labels.text.fill","stylers": [{"color": "#f3d19c"}]},{"featureType": "road.local","elementType": "geometry.fill","stylers": [{"color": "#38414e"}]},{"featureType": "road.local","elementType": "geometry.stroke","stylers": [{"color": "#212a37"}]},{"featureType": "transit","elementType": "geometry","stylers": [{"color": "#2f3948"}]},{"featureType": "transit.station","elementType": "labels.text.fill","stylers": [{"color": "#d59563"}]},{"featureType": "water","elementType": "geometry","stylers": [{"color": "#17263c"}]},{"featureType": "water","elementType": "labels.text.fill","stylers": [{"color": "#515c6d"}]},{"featureType": "water","elementType": "labels.text.stroke","stylers": [{"lightness": -20}]}]');

    if (locationData != null)
      _mapController!.moveCamera(
        CameraUpdate.newLatLng(
          LatLng(locationData!.latitude, locationData!.longitude),
        ),
      );
  }

  void _getLocation() async {
    bool _serviceEnabled;
    loc.Location location = new loc.Location();

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
          locationData = await getCurrentLocation();
        }
      } else if (status.isRestricted) {
        getTempLocation();
      } else if (status.isPermanentlyDenied) {
        if (Platform.isIOS) {
          openAppSettings();
        } else {
        }
      } else {
        _getLocation();
      }
      return;
    } else {
      getTempLocation();
    }
    if (_mapController != null)
      _mapController!.moveCamera(
        CameraUpdate.newLatLng(
          LatLng(locationData!.latitude, locationData!.longitude),
        ),
      );
  }

  Future<void> getTempLocation() async {
    debugPrint('location map: ${MyAppState.selectedPosotion}');
    if (MyAppState.currentUser == null && MyAppState.selectedPosotion.longitude != 0 && MyAppState.selectedPosotion.latitude != 0) {
      locationData = MyAppState.selectedPosotion;
      setState(() {});
    }
  }

  void move() {
    _mapController!.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(latpos, lotpos), 13),
    );
  }
}
