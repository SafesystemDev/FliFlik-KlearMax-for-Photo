import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:foodie_customer/AppGlobal.dart';
import 'package:foodie_customer/constants.dart';
import 'package:foodie_customer/model/BookTableModel.dart';
import 'package:foodie_customer/services/helper.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class TableOrderDetailsScreen extends StatefulWidget {
  final BookTableModel bookTableModel;

  const TableOrderDetailsScreen({Key? key, required this.bookTableModel}) : super(key: key);

  @override
  State<TableOrderDetailsScreen> createState() => _TableOrderDetailsScreenState();
}

class _TableOrderDetailsScreenState extends State<TableOrderDetailsScreen> {
  String bookStatus = '';
  bool isVisible = false;
  Future<PolylineResult>? polyLinesFuture;
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  List<Polyline> polylines = [];
  List<Marker> mapMarkers = [];
  late BitmapDescriptor driverIcon;
  late BitmapDescriptor storeIcon;
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    print(widget.bookTableModel.id);
    if (widget.bookTableModel.status == ORDER_STATUS_PLACED) {
      if (widget.bookTableModel.date.compareTo(Timestamp.now()) <= 0) {
        bookStatus = 'Expired';
      } else {
        bookStatus = 'Processing request';
        isVisible = true;
      }
    } else if (widget.bookTableModel.status == ORDER_STATUS_ACCEPTED) {
      bookStatus = 'Confirmed';
      polyLinesFuture = polylinePoints.getRouteBetweenCoordinates(GOOGLE_API_KEY, PointLatLng(widget.bookTableModel.vendor.latitude, widget.bookTableModel.vendor.longitude),
          PointLatLng(widget.bookTableModel.author.location.latitude, widget.bookTableModel.author.location.longitude));
      isVisible = false;
    } else if (widget.bookTableModel.status == ORDER_STATUS_REJECTED) {
      bookStatus = 'Rejected';
      isVisible = false;
    }
    setMarkerIcon();
  }

  void setMarkerIcon() async {
    driverIcon = await BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(44, 44)), 'assets/images/location_black3x.png');
    storeIcon = await BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(44, 44)), 'assets/images/location_orange3x.png');
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        backgroundColor: isDarkMode(context) ? Color(DARK_COLOR) : Color(0xffFFFFFF),
        appBar: AppGlobal.buildSimpleAppBar(context, ""),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 18.0, vertical: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.bookTableModel.vendor.title,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                              child: Opacity(
                                opacity: 0.7,
                                child: Text(
                                  "${widget.bookTableModel.vendor.location}",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                  ),
                  child: Card(
                    elevation: 5,
                    color: isDarkMode(context) ? Color(DARK_CARD_BG_COLOR) : Color(0xffFFFFFF),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(height: 22, child: Icon(Icons.check_circle, color: Color(COLOR_PRIMARY))),
                              SizedBox(
                                height: 36,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "|",
                                      style: TextStyle(fontWeight: FontWeight.bold, color: Color(COLOR_PRIMARY), fontSize: 8),
                                    ),
                                    Text(
                                      "|",
                                      style: TextStyle(fontWeight: FontWeight.bold, color: Color(COLOR_PRIMARY), fontSize: 8),
                                    ),
                                    Text(
                                      "|",
                                      style: TextStyle(fontWeight: FontWeight.bold, color: Color(COLOR_PRIMARY), fontSize: 8),
                                    ),
                                    Text(
                                      "|",
                                      style: TextStyle(fontWeight: FontWeight.bold, color: Color(COLOR_PRIMARY), fontSize: 8),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 22,
                                child: Container(
                                  height: 18,
                                  width: 18,
                                  child: CustomPaint(
                                    painter: RingPainter(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    "${widget.bookTableModel.vendor.title}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                                    child: Divider(
                                      color: Colors.grey.shade400,
                                      thickness: 0.8,
                                    ),
                                  ),
                                  Text(
                                    "$bookStatus",
                                    style: TextStyle(
                                      color: (bookStatus == 'Confirmed') ? Colors.green : Color(COLOR_PRIMARY),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Visibility(
                                    visible: isVisible,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                                      child: Opacity(
                                        opacity: 0.7,
                                        child: Text(
                                          "Your request is in processing. ".tr() + "it may \ntake up to 3 mins.".tr(),
                                          textAlign: TextAlign.start,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
                        child: Text(
                          "Booking Details".tr(),
                          style: TextStyle(color: Color(COLOR_PRIMARY), fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                      Card(
                        color: isDarkMode(context) ? Color(DARK_CARD_BG_COLOR) : Color(0xffFFFFFF),
                        elevation: 5,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Column(
                          children: [
                            buildDetails(
                              iconsData: Icons.person_outline,
                              title: "Name".tr(),
                              value: "${widget.bookTableModel.guestFirstName} ${widget.bookTableModel.guestLastName}",
                            ),
                            buildDetails(
                              iconsData: Icons.local_phone_outlined,
                              title: "phoneNumber".tr(),
                              value: "${widget.bookTableModel.guestPhone}",
                            ),
                            buildDetails(
                              iconsData: Icons.date_range,
                              title: "Date".tr(),
                              value: "${DateFormat("MMM dd, yyyy 'at' hh:mm a").format(widget.bookTableModel.date.toDate())}",
                            ),
                            buildDetails(
                              iconsData: Icons.people_outline,
                              title: "Guest".tr(),
                              value: "${widget.bookTableModel.totalGuest}",
                            ),
                            buildDetails(
                              iconsData: Icons.discount,
                              title: "Discount",
                              value: "${widget.bookTableModel.discount} ${widget.bookTableModel.discountType == "amount" ? symbol : "%"} off",
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
                      child: Text(
                        "Restaurant Details".tr(),
                        style: TextStyle(color: Color(COLOR_PRIMARY), fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: size.width * 0.65,
                          child: buildDetails(
                            iconsData: Icons.location_on_outlined,
                            title: "Address".tr(),
                            value: "${widget.bookTableModel.vendor.location}",
                          ),
                        ),
                        Row(
                          children: [
                            InkWell(
                              onTap: () {
                                launchUrl(createCoordinatesUrl(widget.bookTableModel.vendor.latitude, widget.bookTableModel.vendor.longitude, widget.bookTableModel.vendor.title));
                              },
                              child: Transform.rotate(
                                angle: 3.14,
                                child: ClipOval(
                                  child: Container(
                                    color: Colors.grey.shade200,
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Icon(Icons.subdirectory_arrow_left, color: Color(COLOR_PRIMARY), size: 22),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                if (widget.bookTableModel.vendor.phonenumber.isNotEmpty) {
                                  final Uri launchUri = Uri(
                                    scheme: 'tel',
                                    path: widget.bookTableModel.vendor.phonenumber,
                                  );
                                  launchUrl(launchUri);
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: ClipOval(
                                  child: Container(
                                    color: Colors.grey.shade200,
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Icon(Icons.phone, color: Color(COLOR_PRIMARY), size: 22),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 12),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    height: 200,
                    width: size.width * 0.9,
                    child: buildDeliveryMap(widget.bookTableModel),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  buildDetails({required IconData iconsData, required String title, required String value}) {
    return ListTile(
      enabled: false,
      dense: true,
      contentPadding: EdgeInsets.only(left: 8),
      horizontalTitleGap: 0.0,
      visualDensity: VisualDensity.comfortable,
      leading: Icon(
        iconsData,
        size: 25,
        color: isDarkMode(context) ? Colors.white : Colors.black,
      ),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: isDarkMode(context) ? Colors.white : Colors.black),
      ),
      subtitle: Text(
        value,
        style: TextStyle(color: isDarkMode(context) ? Colors.white : Colors.black),
      ),
    );
  }

  Widget buildDeliveryMap(BookTableModel orderModel) {
    return FutureBuilder<PolylineResult>(
        future: polyLinesFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!.status == 'OK') {
              polylineCoordinates.clear();
              for (PointLatLng point in snapshot.data!.points) {
                polylineCoordinates.add(LatLng(point.latitude, point.longitude));
              }
            }
            polylines.clear();
            mapMarkers.clear();
            if (polylineCoordinates.isNotEmpty) {
              if (orderModel.status == ORDER_STATUS_ACCEPTED) {
                mapMarkers.add(
                  Marker(
                    markerId: MarkerId('driverMarker'),
                    position: polylineCoordinates.first,
                    icon: driverIcon,
                    infoWindow: InfoWindow(
                      title: '${orderModel.guestFirstName} ${orderModel.guestLastName}',
                    ),
                  ),
                );
                mapMarkers.add(
                  Marker(
                    markerId: MarkerId('storeMarker'),
                    position: polylineCoordinates.last,
                    icon: storeIcon,
                    infoWindow: InfoWindow(
                      title: orderModel.vendor.title,
                    ),
                  ),
                );

                Polyline polyline = Polyline(
                  polylineId: PolylineId('polyline_id_${orderModel.author.firstName.isEmpty ? 'user' : orderModel.author.firstName.isEmpty}_to_${orderModel.vendor.title}'),
                  color: isDarkMode(context) ? Colors.white : Colors.black,
                  width: 5,
                  points: polylineCoordinates,
                );
                polylines.add(polyline);
              }
            }
            return SizedBox(
              height: MediaQuery.of(context).size.height / 2.7,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0.0),
                  ),
                  child: GoogleMap(
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    compassEnabled: true,
                    gestureRecognizers: Set()..add(Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer())),
                    markers: Set<Marker>.from(mapMarkers),
                    polylines: Set<Polyline>.of(polylines),
                    mapType: MapType.normal,
                    initialCameraPosition: CameraPosition(
                      target: LatLng(orderModel.vendor.latitude, orderModel.vendor.longitude),
                      zoom: 15,
                    ),
                    onMapCreated: (controller) => _onMapCreated(controller, orderModel),
                  ),
                ),
              ),
            );
          }
          return Container();
        });
  }

  void _onMapCreated(GoogleMapController controller, BookTableModel orderModel) {
    print("tedtal12");
    _mapController = controller;
    if (isDarkMode(context))
      _mapController!.setMapStyle('[{"featureType": "all","'
          'elementType": "'
          'geo'
          'met'
          'ry","stylers": [{"color": "#242f3e"}]},{"featureType": "all","elementType": "labels.text.stroke","stylers": [{"lightness": -80}]},{"featureType": "administrative","elementType": "labels.text.fill","stylers": [{"color": "#746855"}]},{"featureType": "administrative.locality","elementType": "labels.text.fill","stylers": [{"color": "#d59563"}]},{"featureType": "poi","elementType": "labels.text.fill","stylers": [{"color": "#d59563"}]},{"featureType": "poi.park","elementType": "geometry","stylers": [{"color": "#263c3f"}]},{"featureType": "poi.park","elementType": "labels.text.fill","stylers": [{"color": "#6b9a76"}]},{"featureType": "road","elementType": "geometry.fill","stylers": [{"color": "#2b3544"}]},{"featureType": "road","elementType": "labels.text.fill","stylers": [{"color": "#9ca5b3"}]},{"featureType": "road.arterial","elementType": "geometry.fill","stylers": [{"color": "#38414e"}]},{"featureType": "road.arterial","elementType": "geometry.stroke","stylers": [{"color": "#212a37"}]},{"featureType": "road.highway","elementType": "geometry.fill","stylers": [{"color": "#746855"}]},{"featureType": "road.highway","elementType": "geometry.stroke","stylers": [{"color": "#1f2835"}]},{"featureType": "road.highway","elementType": "labels.text.fill","stylers": [{"color": "#f3d19c"}]},{"featureType": "road.local","elementType": "geometry.fill","stylers": [{"color": "#38414e"}]},{"featureType": "road.local","elementType": "geometry.stroke","stylers": [{"color": "#212a37"}]},{"featureType": "transit","elementType": "geometry","stylers": [{"color": "#2f3948"}]},{"featureType": "transit.station","elementType": "labels.text.fill","stylers": [{"color": "#d59563"}]},{"featureType": "water","elementType": "geometry","stylers": [{"color": "#17263c"}]},{"featureType": "water","elementType": "labels.text.fill","stylers": [{"color": "#515c6d"}]},{"featureType": "water","elementType": "labels.text.stroke","stylers": [{"lightness": -20}]}]');
    if (orderModel.status == ORDER_STATUS_IN_TRANSIT) {
      updateCameraLocation(LatLng(orderModel.vendor.latitude, orderModel.vendor.longitude), LatLng(orderModel.author.location.latitude, orderModel.author.location.longitude), _mapController);
    }
  }

  Future<void> updateCameraLocation(
    LatLng source,
    LatLng destination,
    GoogleMapController? mapController,
  ) async {
    if (mapController == null) return;

    LatLngBounds bounds;

    if (source.latitude > destination.latitude && source.longitude > destination.longitude) {
      bounds = LatLngBounds(southwest: destination, northeast: source);
    } else if (source.longitude > destination.longitude) {
      bounds = LatLngBounds(southwest: LatLng(source.latitude, destination.longitude), northeast: LatLng(destination.latitude, source.longitude));
    } else if (source.latitude > destination.latitude) {
      bounds = LatLngBounds(southwest: LatLng(destination.latitude, source.longitude), northeast: LatLng(source.latitude, destination.longitude));
    } else {
      bounds = LatLngBounds(southwest: source, northeast: destination);
    }

    CameraUpdate cameraUpdate = CameraUpdate.newLatLngBounds(bounds, 70);

    return checkCameraLocation(cameraUpdate, mapController);
  }

  Future<void> checkCameraLocation(CameraUpdate cameraUpdate, GoogleMapController mapController) async {
    mapController.animateCamera(cameraUpdate);
    LatLngBounds l1 = await mapController.getVisibleRegion();
    LatLngBounds l2 = await mapController.getVisibleRegion();

    if (l1.southwest.latitude == -90 || l2.southwest.latitude == -90) {
      return checkCameraLocation(cameraUpdate, mapController);
    }
  }
}

class RingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double height = size.height;
    double width = size.width;
    //Paint to draw ring shape
    Paint paint = Paint()
      ..color = Colors.green
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    //defining Center of Box
    Offset center = Offset(width / 2, height / 2);
    //defining radius
    double radius = min(width / 2, height / 2);
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
