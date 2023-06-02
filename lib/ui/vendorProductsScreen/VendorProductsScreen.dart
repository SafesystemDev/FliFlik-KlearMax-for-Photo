// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:clipboard/clipboard.dart';
// import 'package:dotted_border/dotted_border.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:provider/provider.dart';
// import 'package:share/share.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:foodie_customer/constants.dart';
// import 'package:foodie_customer/main.dart';
// import 'package:foodie_customer/model/ProductModel.dart';
// import 'package:foodie_customer/model/Ratingmodel.dart';
// import 'package:foodie_customer/model/VendorCategoryModel.dart';
// import 'package:foodie_customer/model/VendorModel.dart';
// import 'package:foodie_customer/model/offer_model.dart';
// import 'package:foodie_customer/services/FirebaseHelper.dart';
// import 'package:foodie_customer/services/helper.dart';
// import 'package:foodie_customer/services/localDatabase.dart';
// import 'package:foodie_customer/ui/auth/AuthScreen.dart';
// import 'package:foodie_customer/ui/cartScreen/CartScreen.dart';
// import 'package:foodie_customer/ui/container/ContainerScreen.dart';
// import 'package:foodie_customer/ui/productDetailsScreen/ProductDetailsScreen.dart';
// import 'package:foodie_customer/ui/vendorProductsScreen/photos.dart';
// import 'package:foodie_customer/ui/vendorProductsScreen/review.dart';
// import 'package:foodie_customer/ui/vendorProductsScreen/services.dart';
//
// import '../../model/WorkingHoursModel.dart';
//
// class VendorProductsScreen extends StatefulWidget {
//   final VendorModel vendorModel;
//
//   const VendorProductsScreen({Key? key, required this.vendorModel}) : super(key: key);
//
//   @override
//   _VendorProductsScreenState createState() => _VendorProductsScreenState();
// }
//
// class _VendorProductsScreenState extends State<VendorProductsScreen> with TickerProviderStateMixin {
//   static DateTime now = DateTime.now();
//   late Future<List<ProductModel>> productsFuture;
//   late Future<VendorModel> photofuture;
//   final FireStoreUtils fireStoreUtils = FireStoreUtils();
//   late TabController _tabcon;
//   late CartDatabase cartDatabase;
//   late List<CartProduct> cartProducts = [];
//
//   // late String data;
//   List a = [];
//   bool vegSwitch = false;
//   bool nonVegSwitch = false;
//
//   var data = [];
//   bool fav = false;
//   var tabcount = 0;
//
//   // var quen =0;
//   int cartCount = 0;
//   double total = 0;
//   List<ProductModel> productModel = [];
//
//   //  quen;
//   var catdata, sushi, ramen, bar, breakfast, italian, japanese, mexican, sadwiches, mediter;
//   late TabController tabController;
//   final f = new DateFormat('hh:mm');
//   var data1;
//   var position = LatLng(23.12, 70.22);
//
//   String? foodType;
//
//   Stream<List<OfferModel>>? lstOfferData;
//
//   void _getUserLocation() async {
//     setState(() {
//       position = LatLng(MyAppState.selectedPosotion.latitude, MyAppState.selectedPosotion.longitude);
//     });
//   }
//
//   ///rating review
//   late Future<List<RatingModel>> ratingproduct;
//   late RatingModel ratingModel;
//
//   getProducts() async {
//     productsFuture = fireStoreUtils.getVendorProducts(widget.vendorModel.id);
//     // lstOfferData = fireStoreUtils.getOfferStreamByVendorID(widget.vendorModel.id);
//
//     //productsFuture = fireStoreUtils.getVendorProducts(widget.vendorModel.id);
//     photofuture = fireStoreUtils.getVendorByVendorID(widget.vendorModel.id);
//     ratingproduct = fireStoreUtils.getReviewsbyVendorID(widget.vendorModel.id);
//   }
//
//   @override
//   void initState() {
//     getProducts();
//     super.initState();
//     _getUserLocation();
//     getFoodType();
//
//     statusCheck();
//     tabController = TabController(
//       length: vendorCateoryModel.length,
//       vsync: this,
//       initialIndex: 0,
//     );
//   }
//
//   void getFoodType() async {
//     SharedPreferences sp = await SharedPreferences.getInstance();
//     foodType = sp.getString("foodType") ?? "Delivery";
//     if (foodType == "Takeaway") {
//       productsFuture = fireStoreUtils.getVendorProductsTakeAWay(widget.vendorModel.id);
//     } else {
//       productsFuture = fireStoreUtils.getVendorProductsDelivery(widget.vendorModel.id);
//     }
//     productsFuture.then((value) {
//       productModel.addAll(value);
//       getVendorCategoryById();
//       setState(() {});
//     });
//   }
//
//   late Future<VendorCategoryModel?> obj;
//   List<VendorCategoryModel> vendorCateoryModel = [];
//   var cate = 0, isAnother = 0;
//
//   getVendorCategoryById() async {
//     vendorCateoryModel.clear();
//     await Future.delayed(Duration(seconds: 1));
//
//     for (int i = 0; i < productModel.length; i++) {
//       if (a.isNotEmpty && a.contains(productModel[i].categoryID)) {
//         a.forEach((element) {
//           if (productModel[i].categoryID == element) {
//             print("same");
//           }
//         });
//       } else if (!a.contains(productModel[i].categoryID)) {
//         a.add(productModel[i].categoryID);
//         // print(a);
//         obj = fireStoreUtils.getVendorCategoryById(productModel[i].categoryID);
//
//         obj.then((response) {
//           setState(() {
//             vendorCateoryModel.add(response!);
//           });
//
//           print("vendorModel = " + vendorCateoryModel.toList().toString());
//         });
//       }
//     }
//   }
//
//   count() {
//     FutureBuilder<List<ProductModel>>(
//         future: productsFuture,
//         initialData: [],
//         builder: (context, snapshot) {
//           return ListView.builder(
//               shrinkWrap: true,
//               physics: ClampingScrollPhysics(),
//               itemCount: snapshot.data!.length,
//               itemBuilder: (context, index) {
//                 data1 = snapshot.data![index].categoryID;
//                 return Center();
//               });
//         });
//     print('data::::::' + data1!.length.toString());
//   }
//
//   @override
//   void didChangeDependencies() {
//     cartDatabase = Provider.of<CartDatabase>(context);
//     super.didChangeDependencies();
//   }
//
//   bool tabcheck = false;
//   var ctime;
//   var otime;
//   var date1;
//   var date2;
//
//   @override
//   Widget build(BuildContext context) {
//     var _width = MediaQuery.of(context).size.width;
//     var _height = MediaQuery.of(context).size.height;
//     var pushNewMessages = false;
//
//     double distanceInMeters =
//     Geolocator.distanceBetween(widget.vendorModel.latitude, widget.vendorModel.longitude, position.latitude, position.longitude);
//     double kilometer = distanceInMeters / 1000;
//     print("KiloMeter${kilometer}");
//
//     double minutes = 1.2;
//     double value = minutes * kilometer;
//     final int hour = value ~/ 60;
//     final double minute = value % 60;
//     print('${hour.toString().padLeft(2, "0")}:${minute.toStringAsFixed(0).padLeft(2, "0")}');
//
//     return DefaultTabController(
//         initialIndex: 0,
//         length: vendorCateoryModel.length,
//         child: Scaffold(
//           // backgroundColor: Color(0xffF1F4F7),
//           body: SingleChildScrollView(
//               child: Container(
//                   color: isDarkMode(context) ? Color(DARK_VIEWBG_COLOR) : Color(0xffFFFFFF),
//                   child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
//                     Stack(children: [
//                       Container(
//                           height: _height * 0.3,
//                           decoration: BoxDecoration(
//                             boxShadow: <BoxShadow>[
//                               BoxShadow(
//                                   color: isDarkMode(context) ? Colors.black38 : Colors.white38, blurRadius: 25.0, offset: Offset(0.0, 0.75))
//                             ],
//                           ),
//                           width: _width * 1,
//                           child: CachedNetworkImage(
//                             imageUrl: getImageVAlidUrl(widget.vendorModel.photo),
//                             imageBuilder: (context, imageProvider) => Container(
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(0),
//                                 image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
//                               ),
//                             ),
//                             placeholder: (context, url) => Center(
//                                 child: CircularProgressIndicator.adaptive(
//                                   valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
//                                 )),
//                             errorWidget: (context, url, error) => Image.network(
//                               placeholderImage,
//                               fit: BoxFit.fitWidth,
//                             ),
//                             fit: BoxFit.fitWidth,
//                           )),
//                       Positioned.directional(
//                           textDirection: Directionality.of(context),
//                           top: _height * 0.033,
//                           start: _width * 0.03,
//                           child: CircleAvatar(
//                               backgroundColor: Colors.black54,
//                               radius: 20,
//                               child: IconButton(
//                                 onPressed: () => Navigator.pop(context),
//                                 icon: Icon(
//                                   Icons.arrow_back,
//                                   color: Colors.white,
//                                   size: 25,
//                                 ),
//                               ))),
//                       Positioned.directional(
//                           textDirection: Directionality.of(context),
//                           bottom: _height * 0.009,
//                           end: _width * 0.03,
//                           child: IconButton(
//                               icon: Image(
//                                 image: AssetImage(
//                                   "assets/images/img.png",
//                                 ),
//                                 height: 35,
//                               ),
//                               onPressed: () {
//                                 push(context, RestaurantPhotos(vendorModel: widget.vendorModel));
//                               }))
//                     ]),
//                     Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.center, children: [
//                       Container(
//                           constraints: BoxConstraints(maxWidth: 250),
//                           padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
//                           child: Text(widget.vendorModel.title,
//                               maxLines: 2,
//                               style: TextStyle(
//                                   fontFamily: "Poppinsm",
//                                   fontSize: 20,
//                                   letterSpacing: 0.5,
//                                   color: isDarkMode(context) ? Color(0xffFFFFFF) : Color(0xff2A2A2A)))),
//                       //restaurantStatus(),
//                       resttiming()
//                     ]),
//                     // SizedBox(height: 10,),
//                     Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.center, children: [
//                       Container(
//                           padding: const EdgeInsets.only(left: 15, right: 15),
//                           child: Row(children: [
//                             ImageIcon(
//                               AssetImage('assets/images/location3x.png'),
//                               size: 18,
//                               color: Color(0xff9091A4),
//                             ),
//                             SizedBox(width: 5),
//                             Container(
//                                 constraints: BoxConstraints(maxWidth: 215),
//                                 child: Text(
//                                   widget.vendorModel.location,
//                                   maxLines: 4,
//                                   style: TextStyle(fontFamily: "Poppinsr", letterSpacing: 0.5, color: Color(0xFF9091A4)),
//                                 ))
//                           ])),
//                       InkWell(
//                           onTap: () {
//                             showModalBottomSheet(
//                               isScrollControlled: true,
//                               isDismissible: true,
//                               context: context,
//                               useRootNavigator: true,
//                               backgroundColor: Colors.transparent,
//                               enableDrag: true,
//                               builder: (context) => showTiming(context),
//                             );
//                           },
//                           child: Container(
//                               padding: EdgeInsets.only(
//                                 right: 2,
//                                 left: 2,
//                               ),
//                               child: Text(
//                                 "View Timing",
//                                 style: TextStyle(
//                                   color: Color(COLOR_PRIMARY),
//                                   fontFamily: "Poppinsr",
//                                   //letterSpacing: 0.5,
//                                 ),
//                               ).tr()))
//                     ]),
//                     SizedBox(height: 6),
//                     Container(
//                         margin: EdgeInsets.all(15),
//                         decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(8),
//                             border: Border.all(color: isDarkMode(context) ? Colors.grey.shade900 : Colors.grey.shade100, width: 0.1),
//                             boxShadow: [
//                               BoxShadow(
//                                   color: isDarkMode(context) ? Colors.grey.shade700 : Colors.grey.shade300,
//                                   blurRadius: 3.0,
//                                   spreadRadius: 0.6,
//                                   offset: Offset(0.1, 0.5)),
//                             ],
//                             color: isDarkMode(context) ? Color(DARK_CARD_BG_COLOR) : Colors.white),
//                         child: Padding(
//                             padding: EdgeInsets.only(top: 10, left: 15, right: 10, bottom: 10),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Column(children: [
//                                   Image(
//                                     image: AssetImage("assets/images/location.png"),
//                                     height: 25,
//                                   ),
//                                   SizedBox(
//                                     height: 10,
//                                   ),
//                                   Text(
//                                     "${kilometer.toDouble().toStringAsFixed(2)} km",
//                                     style: TextStyle(
//                                         fontFamily: "Poppinssr",
//                                         letterSpacing: 0.5,
//                                         color: isDarkMode(context) ? Colors.grey.shade300 : Color(0xff565764)),
//                                   ).tr()
//                                 ]),
//                                 Column(children: [
//                                   Image(
//                                     image: AssetImage("assets/images/time.png"),
//                                     height: 25,
//                                   ),
//                                   SizedBox(
//                                     height: 10,
//                                   ),
//                                   Text(
//                                     '${hour.toString().padLeft(2, "0")}h ${minute.toStringAsFixed(0).padLeft(2, "0")}m',
//                                     // "${minute.toDouble()} min",
//                                     style: TextStyle(
//                                         fontFamily: "Poppinssr",
//                                         letterSpacing: 0.5,
//                                         color: isDarkMode(context) ? Colors.grey.shade300 : Color(0xff565764)),
//                                   )
//                                 ]),
//                                 // SizedBox(
//                                 //  width: 40,
//                                 // ),
//                                 Column(children: [
//                                   Image(
//                                     image: AssetImage("assets/images/rate.png"),
//                                     height: 25,
//                                   ),
//                                   SizedBox(
//                                     height: 10,
//                                   ),
//                                   Text(
//                                     widget.vendorModel.reviewsCount == 0
//                                         ? '0' + ' ' 'Rate'.tr()
//                                         : ' ${double.parse((widget.vendorModel.reviewsSum / widget.vendorModel.reviewsCount).toStringAsFixed(1))}' +
//                                         ' ' 'Rate'.tr(),
//                                     style: TextStyle(
//                                         fontFamily: "Poppinssr",
//                                         letterSpacing: 0.5,
//                                         color: isDarkMode(context) ? Colors.grey.shade300 : Color(0xff565764)),
//                                   ).tr()
//                                 ]),
//                                 // SizedBox(
//                                 //   width: 35,
//                                 // ),
//                                 InkWell(
//                                     onTap: () async {
//                                       // Share.shareFiles(
//                                       //     ['${widget.vendorModel.photo}'],
//                                       //     text:
//                                       //         '${widget.vendorModel.title}');
//                                       Share.share(
//                                           "${widget.vendorModel.title}\n${widget.vendorModel.location}\n\n${widget.vendorModel.photo}");
//                                     },
//                                     child: Column(children: [
//                                       Image(
//                                         image: AssetImage("assets/images/share.png"),
//                                         height: 25,
//                                       ),
//                                       SizedBox(
//                                         height: 10,
//                                       ),
//                                       Text(
//                                         "Share",
//                                         style: TextStyle(
//                                             fontFamily: "Poppinssr",
//                                             letterSpacing: 0.5,
//                                             color: isDarkMode(context) ? Colors.grey.shade300 : Color(0xff565764)),
//                                       ).tr()
//                                     ])),
//                               ],
//                             ))),
//                     SizedBox(
//                       height: 10,
//                     ),
//                     Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
//                       FutureBuilder<List<RatingModel>>(
//                           future: ratingproduct,
//                           // initialData: ratingModel,
//                           builder: (BuildContext context, snapshot) {
//                             if (snapshot.connectionState == ConnectionState.waiting)
//                               return Center(
//                                 child: CircularProgressIndicator.adaptive(
//                                   valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
//                                 ),
//                               );
//                             if (snapshot.hasData) {
//                               return
//
//                                 ///////////
//                                 InkWell(
//                                   onTap: () => push(
//                                     context,
//                                     Review(
//                                       vendorModel: widget.vendorModel,
//                                       reviewlength: snapshot.data!.length.toString(),
//                                     ),
//                                   ),
//                                   child: Container(
//                                       padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
//                                       decoration: BoxDecoration(
//                                           borderRadius: BorderRadius.circular(3),
//                                           border: Border.all(
//                                               color: isDarkMode(context) ? Colors.grey.shade900 : Colors.grey.shade100, width: 0.1),
//                                           boxShadow: [
//                                             BoxShadow(
//                                                 color: isDarkMode(context) ? Colors.grey.shade700 : Colors.grey.shade300,
//                                                 blurRadius: 3.0,
//                                                 spreadRadius: 0.6,
//                                                 offset: Offset(0.1, 0.5)),
//                                           ],
//                                           color: isDarkMode(context) ? Color(DARK_CARD_BG_COLOR) : Colors.white),
//                                       width: MediaQuery.of(context).size.width / 2.3,
//                                       margin: EdgeInsets.only(left: 10),
//                                       child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
//                                         Text(snapshot.data!.length.toString() + " " "reviews".tr(),
//                                             style: TextStyle(
//                                               fontFamily: "Poppinsr",
//                                               letterSpacing: 0.5,
//                                               color: isDarkMode(context) ? Colors.grey.shade300 : Color(0XFF676771),
//                                             )),
//                                         Image(
//                                           image: AssetImage("assets/images/review.png"),
//                                           width: 20,
//                                         )
//                                       ])),
//                                 );
//                             } else
//                               return CircularProgressIndicator();
//                           }),
//                       InkWell(
//                           onTap: () => showModalBottomSheet(
//                             isScrollControlled: true,
//                             isDismissible: true,
//                             context: context,
//                             backgroundColor: Colors.transparent,
//                             enableDrag: true,
//                             builder: (context) => ServicesScreen(vendorModel: widget.vendorModel),
//                           ),
//                           child: Container(
//                               width: MediaQuery.of(context).size.width / 2.3,
//                               margin: EdgeInsets.only(right: 10),
//                               padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
//                               decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(3),
//                                   border: Border.all(color: isDarkMode(context) ? Colors.grey.shade900 : Colors.grey.shade100, width: 0.1),
//                                   boxShadow: [
//                                     BoxShadow(
//                                         color: isDarkMode(context) ? Colors.grey.shade700 : Colors.grey.shade300,
//                                         blurRadius: 3.0,
//                                         spreadRadius: 0.6,
//                                         offset: Offset(0.1, 0.5)),
//                                   ],
//                                   color: isDarkMode(context) ? Color(DARK_CARD_BG_COLOR) : Colors.white),
//                               child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
//                                 Container(
//                                   child: Text("Services",
//                                       style: TextStyle(
//                                         fontFamily: "Poppinsr",
//                                         letterSpacing: 0.5,
//                                         color: isDarkMode(context) ? Colors.grey.shade300 : Color(0XFF676771),
//                                       )).tr(),
//                                 ),
//                                 Container(child: Image(image: AssetImage("assets/images/services.png"), height: 20))
//                               ])))
//                     ]),
//                     SizedBox(
//                       height: 25,
//                     ),
//                     Builder(builder: (context) {
//                       return StreamBuilder<List<OfferModel>>(
//                           stream: lstOfferData,
//                           builder: (context, snapshot) {
//                             if (snapshot.connectionState == ConnectionState.waiting)
//                               return Container(
//                                 child: Center(
//                                   child: CircularProgressIndicator(),
//                                 ),
//                               );
//                             if (!snapshot.hasData || (snapshot.data?.isEmpty ?? true)) {
//                               return Center(
//                                 child: Container(
//                                   child: Text("NoCoupons".tr(),
//                                       style: TextStyle(
//                                         fontFamily: "Poppinsr",
//                                         letterSpacing: 0.5,
//                                         color: Color(0XFF676771),
//                                       )),
//                                 ),
//                               );
//                             } else {
//                               return Container(
//                                 height: 85,
//                                 child: ListView.builder(
//                                     itemCount: snapshot.data!.length,
//                                     scrollDirection: Axis.horizontal,
//                                     itemBuilder: (context, index) {
//                                       return GestureDetector(
//                                         onTap: () {
//                                           FlutterClipboard.copy(snapshot.data![index].offerCode!).then((value) => print('copied'));
//
//                                           showModalBottomSheet(
//                                             isScrollControlled: true,
//                                             isDismissible: true,
//                                             context: context,
//                                             shape: RoundedRectangleBorder(
//                                               borderRadius: BorderRadius.circular(20.0),
//                                             ),
//                                             backgroundColor: Colors.transparent,
//                                             enableDrag: true,
//                                             builder: (context) => openCouponCode(context, snapshot.data![index]),
//                                           );
//                                         },
//                                         child: buildOfferItem(snapshot, index),
//                                       );
//                                     }),
//                               );
//                             }
//                           });
//                     }),
//                     Container(
//                       color: isDarkMode(context) ? Color(DARK_COLOR) : Color(0xffFFFFFF),
//                       // Color(0XFFF1F4F7),
//                       child: Stack(
//                         children: [
//                           TabBar(
//                               onTap: (value) {
//                                 setState(() {
//                                   value = tabController.index;
//                                 });
//                               },
//                               isScrollable: true,
//                               indicatorColor: Color(COLOR_PRIMARY),
//                               labelColor: Color(COLOR_PRIMARY),
//                               unselectedLabelColor: Color(0xff9394a1),
//                               labelStyle: TextStyle(fontSize: 16, fontFamily: "Poppinsm"),
//                               unselectedLabelStyle: TextStyle(fontFamily: "Poppinsr"),
//                               labelPadding: EdgeInsets.only(right: 20, left: 20),
//                               tabs: List.generate(
//                                   vendorCateoryModel.length,
//                                       (index) => Tab(
//                                     child: Text(
//                                       vendorCateoryModel[index].title,
//                                     ).tr(),
//                                   )))
//                         ],
//                       ),
//                     ),
//                     vendorCateoryModel.length == 0
//                         ? showEmptyState("", "NoFood".tr())
//                         : Container(
//                         color: isDarkMode(context) ? Color(DARK_COLOR) : Color(0xffffffff), //Color(0xffFFFFFF),
//                         width: MediaQuery.of(context).size.width * 1,
//                         height: 600,
//                         child: TabBarView(
//                             children: List.generate(
//                               vendorCateoryModel.length,
//                                   (index) => FutureBuilder<List<ProductModel>>(
//                                   future: productsFuture,
//                                   initialData: [],
//                                   builder: (context, snapshot) {
//                                     bool veg = false;
//                                     bool nonveg = false;
//                                     cate = 0;
//                                     isAnother = 0;
//                                     //print(snapshot.data![index].name.toString()+"=====NAME");
//                                     return SingleChildScrollView(
//                                       child: Column(
//                                         mainAxisSize: MainAxisSize.max,
//                                         crossAxisAlignment: CrossAxisAlignment.stretch,
//                                         children: [
//                                           SizedBox(height: 5),
//                                           snapshot.data!.length == 0 ? Container() : buildVeg(veg, nonveg),
//                                           Divider(color: Color(0xffE4E8EB)),
//                                           ListView.builder(
//                                             shrinkWrap: true,
//                                             physics: ClampingScrollPhysics(),
//                                             itemCount: snapshot.data!.length,
//                                             itemBuilder: (context, inx) {
//                                               return snapshot.data![inx].categoryID == vendorCateoryModel[index].id &&
//                                                   snapshot.data![inx].publish == true
//                                                   ? buildRow(snapshot.data![inx], veg, nonveg, snapshot.data![inx].categoryID,
//                                                   (inx == (snapshot.data!.length - 1)))
//                                                   : (isAnother == 0 && (inx == (snapshot.data!.length - 1)))
//                                                   ? showEmptyState("", "NoFood".tr())
//                                                   : Container();
//                                             },
//                                           ),
//                                         ],
//                                       ),
//                                     );
//                                   }),
//                             ))),
//                   ]))),
//           bottomNavigationBar: InkWell(
//             onTap: () {
//               if (MyAppState.currentUser == null) {
//                 push(context, AuthScreen());
//               } else {
//                 pushAndRemoveUntil(
//                     context,
//                     ContainerScreen(
//                       user: MyAppState.currentUser!,
//                       drawerSelection: DrawerSelection.Cart,
//                       currentWidget: CartScreen(
//                         fromContainer: true,
//                       ),
//                       appBarTitle: 'Your Cart'.tr(),
//                     ),
//                     false);
//               }
//             },
//             child: StreamBuilder<List<CartProduct>>(
//                 stream: cartDatabase.watchProducts,
//                 builder: (context, snapshot) {
//                   //print("==EL:1=== "+snapshot.data!.toString());
//                   cartCount = 0;
//                   total = 0;
//                   if (snapshot.hasData) {
//                     snapshot.data!.forEach((element) {
//                       // print("==EL: "+element.toJson().toString());
//                       //print("==EL:1= "+element.quantity.toString());
//                       cartCount += element.quantity;
//
//                       if (element.extras_price != null && element.extras_price!.isNotEmpty && double.parse(element.extras_price!) != 0) {
//                         total += element.quantity * double.parse(element.extras_price!);
//                       }
//
//                       // if(!element.extras_price!.isEmpty && element.extras_price!.toString() != "0.0") {
//                       //   total+=element.quantity*double.parse(element.price);
//                       // }else{
//                       total += element.quantity * double.parse(element.price);
//                       // }
//
//                       /*total = total +
//                           (element.quantity * double.parse(element.price));*/
//                     });
//                   }
//                   return Container(
//                     color: Color(COLOR_PRIMARY),
//                     height: 60,
//                     padding: EdgeInsets.only(left: 20, right: 20),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
//                           Text(
//                             cartCount.toString() + " " "Items",
//                             style: TextStyle(fontFamily: "Poppinsm", color: Colors.white, fontSize: 16),
//                           ).tr(),
//                           SizedBox(
//                             width: 15,
//                           ),
//                           Text("|", style: TextStyle(color: Colors.white, fontSize: 16)),
//                           SizedBox(
//                             width: 15,
//                           ),
//                           Text(
//                             symbol + '${total.toDouble().toStringAsFixed(decimal)}',
//                             style: TextStyle(fontFamily: "Poppinssm", color: Colors.white, fontSize: 16),
//                           ),
//                         ]),
//                         Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
//                           Text(
//                             "VIEW CART",
//                             style: TextStyle(fontFamily: "Poppinsm", color: Colors.white, fontSize: 16),
//                           ).tr(),
//                           SizedBox(
//                             width: 10,
//                           ),
//                           Image(
//                             image: AssetImage("assets/images/cart2.png"),
//                             height: 21,
//                             color: Colors.white,
//                           )
//                         ])
//                       ],
//                     ),
//                   );
//                 }),
//           ),
//         ));
//   }
//
//   Widget buildOfferItem(AsyncSnapshot<List<OfferModel>> snapshot, int index) {
//     return Container(
//       margin: EdgeInsets.fromLTRB(7, 10, 7, 10),
//       height: 85,
//       child: DottedBorder(
//         borderType: BorderType.RRect,
//         radius: Radius.circular(2),
//         padding: EdgeInsets.all(2),
//         color: Color(COUPON_DASH_COLOR),
//         strokeWidth: 2,
//         dashPattern: [5],
//         child: Padding(
//           padding: EdgeInsets.fromLTRB(12, 0, 12, 0),
//           child: Container(
//               decoration: new BoxDecoration(
//                 borderRadius: new BorderRadius.circular(2),
//               ),
//               margin: EdgeInsets.only(top: 4),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 children: [
//                   Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     children: [
//                       Image(
//                         image: AssetImage('assets/images/offer_icon.png'),
//                         height: 25,
//                         width: 25,
//                       ),
//                       SizedBox(
//                         width: 10,
//                       ),
//                       Container(
//                         margin: EdgeInsets.only(top: 3),
//                         child: Text(
//                           "${snapshot.data![index].discountTypeOffer == "Fix Price" ? "${symbol}" : ""}${snapshot.data![index].discountOffer}${snapshot.data![index].discountTypeOffer == "Percentage" ? "% OFF" : " OFF"}",
//                           style: TextStyle(
//                               color: isDarkMode(context) ? Colors.white60 : Color(GREY_TEXT_COLOR),
//                               fontWeight: FontWeight.bold,
//                               letterSpacing: 0.7),
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(
//                     height: 5,
//                   ),
//                   Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     children: [
//                       Text(
//                         snapshot.data![index].offerCode!,
//                         textAlign: TextAlign.left,
//                         style: TextStyle(
//                             fontSize: 16,
//                             fontFamily: "Poppins",
//                             fontWeight: FontWeight.normal,
//                             letterSpacing: 0.5,
//                             color: isDarkMode(context) ? Colors.white60 : Color(GREY_TEXT_COLOR)),
//                       ),
//                       Container(
//                         margin: EdgeInsets.only(left: 15, right: 15, top: 3),
//                         height: 15,
//                         width: 1,
//                         color: Color(COUPON_DASH_COLOR),
//                       ),
//                       Text("valid till".tr() + " " + getDate(snapshot.data![index].expireOfferDate!.toDate().toString())!,
//                           style: TextStyle(
//                               fontFamily: "Poppins", letterSpacing: 0.5, color: isDarkMode(context) ? Colors.white60 : Color(0Xff696A75)))
//                     ],
//                   ),
//                 ],
//               )),
//         ),
//       ),
//     );
//   }
//
//   //  database(CartProduct cartProduct){
//   //          data =cartProduct.id ;
//
//   //         //  quen = cartProduct.quantity;
//   //          return Container();
//   //  }
//   buildVeg(veg, nonveg) {
//     // var vegSwitch,nonVegSwitch = false;
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceAround,
//       children: [
//         Container(
//           height: 35,
//           width: MediaQuery.of(context).size.width / 2.1,
//           alignment: Alignment.center,
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Switch(
//                 value: vegSwitch,
//                 onChanged: (bool isOn) {
//                   setState(() {
//                     vegSwitch = isOn;
//                     // vegSwitch == false
//                     //     ? nonVegSwitch = true
//                     //     : nonVegSwitch = false;
//                   });
//                 },
//                 activeColor: Colors.green,
//                 activeTrackColor: Color(0xffCAD1D8),
//                 inactiveTrackColor: Color(0xffCAD1D8),
//                 inactiveThumbColor: Color(0xff9091A4),
//               ),
//               Text(
//                 "Veg".tr(),
//                 style: TextStyle(
//                   fontFamily: "Poppinssr",
//                   color: Color(0xff9091A4),
//                   letterSpacing: 0.5,
//                 ),
//               ),
//             ],
//           ),
//         ),
//         Text(
//           '|',
//           style: TextStyle(color: Color(0xffCAD1D8)),
//         ),
//         Container(
//           height: 35,
//           width: MediaQuery.of(context).size.width / 2.1,
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Switch(
//                 value: nonVegSwitch,
//                 onChanged: (bool isOn) {
//                   setState(() {
//                     nonVegSwitch = isOn;
//                   });
//                 },
//                 activeColor: Colors.red,
//                 activeTrackColor: Color(0xffCAD1D8),
//                 inactiveTrackColor: Color(0xffCAD1D8),
//                 inactiveThumbColor: Color(0xff9091A4),
//               ),
//               Text(
//                 "Non-Veg".tr(),
//                 style: TextStyle(
//                   fontFamily: "Poppinssr",
//                   color: Color(0xff9091A4),
//                   letterSpacing: 0.5,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//
//   buildRow(ProductModel productModel, veg, nonveg, inx, bool index) {
//     print(productModel.name + " =-=-= " + index.toString());
//     var price = double.parse('${productModel.price}');
//
//     assert(price is double);
//     if (vegSwitch == true && productModel.veg == true) {
//       isAnother++;
//       return datarow(productModel);
//     } else if (nonVegSwitch == true && productModel.veg == false) {
//       isAnother++;
//       return datarow(productModel);
//     } else if (vegSwitch != true && nonVegSwitch != true) {
//       isAnother++;
//       return datarow(productModel);
//     } else if (nonVegSwitch == true && productModel.nonveg == true) {
//       isAnother++;
//       return datarow(productModel);
//     } else if (inx == productModel.categoryID) {
//       cate++;
//       return (isAnother == 0 && index) ? showEmptyState("", "NoFood") : Container();
//     }
//     // else Center();
//   }
//
//   datarow(productModel) {
//     // var quen=productModel.quantity ?? 0 ;
//     print(productModel.quantity.toString() + "===INTIALQNT ${productModel.price} dixount ${productModel.toJson()}");
//     Future.delayed(const Duration(milliseconds: 500), () {
//       //setState(() {
//       //     quen == 0 ?
//       //  productModel.quantity = quen:null;
//       //});
//     });
//     var data;
//     var price = double.parse('${productModel.price}');
//     assert(price is double);
//     return GestureDetector(
//       behavior: HitTestBehavior.translucent,
//       onTap: () => showModalBottomSheet(
//         isScrollControlled: true,
//         isDismissible: true,
//         context: context,
//         backgroundColor: Colors.transparent,
//         enableDrag: true,
//         builder: (context) => ProductDetailsScreen(productModel: productModel, vendorModel: widget.vendorModel),
//       ).whenComplete(() => {setState(() {})}),
//       child: Container(
//         height: 120,
//         padding: const EdgeInsets.all(8),
//         margin: EdgeInsets.all(10),
//         decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(10),
//             border: Border.all(color: isDarkMode(context) ? Colors.grey.shade900 : Colors.grey.shade100, width: 0.1),
//             boxShadow: [
//               BoxShadow(
//                 color: isDarkMode(context) ? Colors.grey.shade700 : Colors.grey.shade300,
//                 blurRadius: 4.0,
//                 spreadRadius: 0.2,
//                 offset: Offset(0.2, 0.2),
//               ),
//             ],
//             color: isDarkMode(context) ? Color(DARK_CARD_BG_COLOR) : Colors.white),
//         child: Row(children: [
//           StreamBuilder<List<CartProduct>>(
//               stream: cartDatabase.watchProducts,
//               initialData: [],
//               builder: (context, snapshot) {
//                 cartProducts = snapshot.data!;
//                 print("cart pro copre  " + cartProducts.length.toString());
//                 print(cartProducts.toString());
//                 print("cart pro co " + productModel.quantity.toString());
//                 Future.delayed(const Duration(milliseconds: 300), () {
//                   productModel.quantity = 0;
//                   if (cartProducts.length > 0) {
//                     for (CartProduct cartProduct in cartProducts) {
//                       if (cartProduct.id == productModel.id) {
//                         productModel.quantity = cartProduct.quantity;
//                       }
//                     }
//                   }
//                 });
//
//                 return SizedBox(
//                   height: 0,
//                   width: 0,
//                 );
//               }),
//           Stack(children: [
//             Container(
//               child: CachedNetworkImage(
//                   height: 100,
//                   width: 115,
//                   imageUrl: getImageVAlidUrl(productModel.photo),
//                   imageBuilder: (context, imageProvider) => Container(
//                     // width: 100,
//                     // height: 100,
//                     decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(10),
//                         image: DecorationImage(
//                           image: imageProvider,
//                           fit: BoxFit.cover,
//                         )),
//                   ),
//                   errorWidget: (context, url, error) => ClipRRect(
//                       borderRadius: BorderRadius.circular(15),
//                       child: Image.network(
//                         placeholderImage,
//                         fit: BoxFit.cover,
//                         width: MediaQuery.of(context).size.width,
//                         height: MediaQuery.of(context).size.height,
//                       ))),
//             ),
//             Positioned(
//               left: 5,
//               top: 5,
//               child: Icon(
//                 Icons.circle,
//                 color: productModel.veg == true ? Color(0XFF3dae7d) : Colors.redAccent,
//                 size: 13,
//               ),
//             )
//           ]),
//           Spacer(
//             flex: 1,
//           ),
//           Expanded(
//               flex: 15,
//               child: Container(
//                 padding: const EdgeInsets.only(top: 5),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: <Widget>[
//                     Text(
//                       productModel.name,
//                       style: TextStyle(
//                           fontSize: 16,
//                           fontFamily: "Poppinssb",
//                           letterSpacing: 0.5,
//                           color: isDarkMode(context) ? Colors.white70 : Color(0XFF2A2A2A)),
//                     ),
//                     Text(
//                       productModel.description,
//                       maxLines: 1,
//                       style: TextStyle(
//                           color: isDarkMode(context) ? Colors.white54 : Color(0xff9091A4),
//                           fontFamily: "Poppinsm",
//                           letterSpacing: 0.5,
//                           fontSize: 15),
//                     ),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: <Widget>[
//                         (productModel.disPrice == "" || productModel.disPrice == "0")
//                             ? Text(
//                           symbol + '${price.toDouble().toStringAsFixed(decimal)}',
//                           style: TextStyle(fontSize: 18, fontFamily: "Poppinssm", letterSpacing: 0.5, color: Color(COLOR_PRIMARY)),
//                         )
//                             : Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               symbol + '${price.toDouble().toStringAsFixed(decimal)}',
//                               style: TextStyle(
//                                   fontFamily: "Poppinssm",
//                                   letterSpacing: 0.5,
//                                   color: isDarkMode(context) ? Colors.white60 : Colors.grey,
//                                   decoration: TextDecoration.lineThrough),
//                             ),
//                             Text(
//                               symbol + '${double.parse(productModel.disPrice).toDouble().toStringAsFixed(decimal)}',
//                               style: TextStyle(fontFamily: "Poppinssm", letterSpacing: 0.5, color: Color(COLOR_PRIMARY)),
//                             ),
//                           ],
//                         ),
//                         productModel.quantity == 0
//                             ? !isOpen
//                             ? Center()
//                             : Padding(
//                             padding: const EdgeInsets.only(right: 15),
//                             child: Container(
//                                 height: 33,
//                                 // width: 80,
//                                 // alignment:Alignment.center,
//                                 child: Center(
//                                   // height: 10,
//                                   //  width: 80,
//                                   child: TextButton.icon(
//                                     onPressed: () {
//                                       if (MyAppState.currentUser == null) {
//                                         push(context, AuthScreen());
//                                       } else {
//                                         setState(() {
//                                           productModel.quantity = 1;
//                                           // productModel.price = productModel.disPrice == "" || productModel.disPrice == "0"?productModel.price:productModel.disPrice;
//                                           addtocard(productModel, productModel.quantity);
//                                         });
//                                       }
//                                     },
//                                     icon: Icon(Icons.add, size: 18, color: Color(COLOR_PRIMARY)),
//                                     label: Text(
//                                       'ADD'.tr(),
//                                       style: TextStyle(
//                                           height: 1.2, fontFamily: "Poppinssb", letterSpacing: 0.5, color: Color(COLOR_PRIMARY)),
//                                     ),
//                                     style: TextButton.styleFrom(
//                                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
//                                       side: BorderSide(color: isDarkMode(context) ? Colors.white60 : Color(0XFFC3C5D1), width: 1.5),
//                                     ),
//                                   ),
//                                 )))
//                             : Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           children: [
//                             IconButton(
//                                 onPressed: () {
//                                   if (productModel.quantity != 0)
//                                     // setState(
//                                     // () {
//                                     setState(() {
//                                       productModel.quantity--;
//                                       if (productModel.quantity >= 0) {
//                                         // productModel.price = productModel.disPrice == "" || productModel.disPrice == "0"?productModel.price:productModel.disPrice;
//                                         removetocard(productModel, productModel.quantity);
//                                       } else {
//                                         // addtocard(productModel);
//                                         //removeQuntityFromCartProduct(productModel);
//
//                                       }
//
//                                       print(productModel.quantity.toString() + "***+++REMOVE");
//                                       //: addtocard(productModel);
//                                     });
//                                   //   productModel.quantity >=1?
//                                   //   removetocard(productModel, productModel.quantity)
//                                   //  :null;
//                                   // },
//                                   // );
//                                 },
//                                 icon: Image(
//                                   image: AssetImage("assets/images/minus.png"),
//                                   color: Color(COLOR_PRIMARY),
//                                   height: 28,
//                                 )),
//                             SizedBox(
//                               width: 5,
//                             ),
//
//                             // cartData( productModel.id)== null?
//
//                             StreamBuilder<List<CartProduct>>(
//                                 stream: cartDatabase.watchProducts,
//                                 initialData: [],
//                                 builder: (context, snapshot) {
//                                   cartProducts = snapshot.data!;
//                                   return SizedBox(
//                                       height: 25,
//                                       width: 0,
//                                       child: Column(children: [
//                                         Expanded(
//                                             child: ListView.builder(
//                                                 itemCount: cartProducts.length,
//                                                 itemBuilder: (context, index) {
//                                                   cartProducts[index].id == productModel.id
//                                                       ? productModel.quantity = cartProducts[index].quantity
//                                                       : null;
//                                                   // print('yahaaaaa');
//                                                   if (cartProducts[index].id == productModel.id) {
//                                                     return Center();
//                                                   } else {
//                                                     return Container();
//                                                   }
//                                                   //  return Center();
//
//                                                   // print(quen);
//                                                 }))
//                                       ]));
//                                 }),
//                             Text(
//                               '${productModel.quantity}'.tr(),
//                               style: TextStyle(
//                                 fontSize: 20,
//                                 color: isDarkMode(context) ? Colors.white : Colors.black,
//                                 letterSpacing: 0.5,
//                               ),
//                             ),
//                             //  Text("null"),
//                             SizedBox(
//                               width: 5,
//                             ),
//                             IconButton(
//                                 onPressed: () {
//                                   setState(() {
//                                     if (productModel.quantity != 0) productModel.quantity++;
//                                     //productModel.price = productModel.disPrice == "" || productModel.disPrice == "0"?productModel.price:productModel.disPrice;
//                                     addtocard(productModel, productModel.quantity);
//                                   });
//                                 },
//                                 icon: Image(
//                                   image: AssetImage("assets/images/plus.png"),
//                                   color: Color(COLOR_PRIMARY),
//                                   height: 28,
//                                 ))
//                           ],
//                         )
//                       ],
//                     ),
//                   ],
//                 ),
//               )),
//         ]),
//       ),
//     );
//   }
//
//   addtocard(productModel, quantity) async {
//     print("product quantitu $quantity");
//     if (productModel.quantity == 0) {
//       productModel.quantity = 1;
//     }
//     print("product model quantitu " + productModel.quantity.toString());
//     //List<CartProduct> cartProducts = await cartDatabase.allCartProducts;
//     /*
//     if (cartProducts.length > 0) {
//       for (int a = 0; a < cartProducts.length; a++) {
//         print("***+++ADDTOCART" +
//             cartProducts[a].vendorID.toString() +
//             "  " +
//             productModel.vendorID.toString());
//         if (cartProducts[a].vendorID != productModel.vendorID) {
//           print("***+++ADDTOCART");
//           cartDatabase.addProduct(productModel);
//           print("***+++ADDTOCARTFinal1");
//         } else {
//           print("***+++REMOVETOCARTBEFORE...");
//           cartProducts[a].quantity++;
//           cartDatabase.updateProduct(cartProducts[a]);
//           print("***+++REMOVETOCART");
//         }
//       }
//     } else {
//
//         print("***+++ADDTOCARTELSE");
//         cartDatabase.addProduct(productModel);
//         print("***+++ADDTOCARTFinal1ELSE");
//
//     }*/
//
//     /*if (cartProducts
//         .where((element) => element.vendorID != productModel.vendorID)
//         .isEmpty) {
//       print("***+++ADDTOCART");
//       cartDatabase.addProduct(productModel);
//       print("***+++ADDTOCARTFinal1");
//     } else {
//       {
//         print("***+++REMOVETOCARTBEFORE...");
//         cartDatabase.updateProduct(productModel);
//         print("***+++REMOVETOCART");
//       }
//     }
// */
//     /*  if (cartProducts
//         .where((element) => element.vendorID != productModel.vendorID)
//         .isEmpty) {
//       print("***+++ADDTOCART");
//       cartDatabase.addProduct(productModel);
//       print("***+++ADDTOCARTFinal1");
//     } else {
//       {
//         print("***+++REMOVETOCARTBEFORE...");
//         cartDatabase.updateProduct(productModel);
//         print("***+++REMOVETOCART");
//       }
//     }*/
//     List<AddAddonsDemo> lstTemp = [];
//     SharedPreferences sp = await SharedPreferences.getInstance();
//     final String musicsString = await sp.getString('musics_key') != null ? sp.getString('musics_key')! : "";
//
//     if (musicsString.isNotEmpty && musicsString != null) {
//       lstTemp = AddAddonsDemo.decode(musicsString);
//     }
//     print(quantity.toString() + "====QN");
//     bool isAddOnApplied = false;
//     double AddOnVal = 0;
//     for (int i = 0; i < lstTemp.length; i++) {
//       AddAddonsDemo addAddonsDemo = lstTemp[i];
//       if (addAddonsDemo.categoryID == productModel.id) {
//         isAddOnApplied = true;
//         AddOnVal = AddOnVal + double.parse(addAddonsDemo.price!);
//       }
//     }
//     List<CartProduct> cartProducts = await cartDatabase.allCartProducts;
//     /*List<CartProduct> cartProducts = await cartDatabase.allCartProducts;
//     if (cartProducts
//         .where((element) => element.vendorID != productModel.vendorID)
//         .isEmpty) {
//       print("====PDAdd");
//       print(productModel);
//       cartDatabase.addProduct(productModel);
//       print("====PDAdd=Done");
//     } else {
//       {
//         print("====PDUpdate");
//         await cartDatabase.updateProduct(productModel);
//         print("====PDUpdateDone");
//       }
//     }*/
//
//     if (quantity > 1) {
//       var joinTitleString = "";
//       String mainPrice = "";
//       var joinSizeString = "";
//       List<AddAddonsDemo> lstAddOns = [];
//       List<String> lstAddOnsTemp = [];
//       double extras_price = 0.0;
//
//       List<AddSizeDemo> lstAddSize = [];
//       List<String> lstAddSizeTemp = [];
//       List<String> lstSizeTemp = [];
//       String addOns = sp.getString("musics_key") != null ? sp.getString('musics_key')! : "";
//       String addSize = sp.getString("addsize") != null ? sp.getString('addsize')! : "";
//
//       bool isAddSame = false;
//       if (addSize.isNotEmpty && addSize != null) {
//         lstAddSize = AddSizeDemo.decode(addSize);
//
//         for (int a = 0; a < lstAddSize.length; a++) {
//           if (lstAddSize[a].categoryID == productModel.id) {
//             isAddSame = true;
//             lstAddSizeTemp.add(lstAddSize[a].price!);
//             lstSizeTemp.add(lstAddSize[a].name!);
//             mainPrice = ((lstAddSize[a].price!));
//           }
//         }
//         joinSizeString = lstSizeTemp.join(",");
//       }
//
//       if (!isAddSame) {
//         // extras_price=((productModel.disPrice == "" || productModel.disPrice == "0") ? double.parse(productModel.price) : double.parse(productModel.disPrice!) );
//         if (productModel.disPrice != null && productModel.disPrice!.isNotEmpty && double.parse(productModel.disPrice!) != 0) {
//           mainPrice = productModel.disPrice!;
//         } else {
//           mainPrice = productModel.price;
//         }
//       }
//
//       if (addOns.isNotEmpty && addOns != null) {
//         lstAddOns = AddAddonsDemo.decode(addOns);
//         print(lstAddOns.length.toString() + "----LEN");
//         for (int a = 0; a < lstAddOns.length; a++) {
//           AddAddonsDemo newAddonsObject = lstAddOns[a];
//           if (newAddonsObject.categoryID == productModel.id) {
//             if (newAddonsObject.isCheck == true) {
//               lstAddOnsTemp.add(newAddonsObject.name!);
//               extras_price += (double.parse(newAddonsObject.price!));
//             }
//           }
//         }
//
//         joinTitleString = lstAddOnsTemp.join(",");
//       }
//
//       await cartDatabase.updateProduct(CartProduct(
//         id: productModel.id,
//         name: productModel.name,
//         photo: productModel.photo,
//         price: mainPrice,
//         discountPrice: productModel.disPrice,
//         vendorID: productModel.vendorID,
//         quantity: quantity,
//         extras_price: extras_price.toString(),
//         extras: joinTitleString,
//         size: joinSizeString,
//       ));
//     } else {
//       if (cartProducts.length == 0) {
//         cartDatabase.addProduct(productModel);
//       } else {
//         if (cartProducts[0].vendorID == widget.vendorModel.id) {
//           cartDatabase.addProduct(productModel);
//         } else {
//           cartDatabase.deleteAllProducts();
//           cartDatabase.addProduct(productModel);
//         }
//       }
//     }
//     updatePrice(productModel);
//     //if(cartProducts.length==0){
//     // if (quantity > 1) {
//     //  setState(() async {
//     /*   await cartDatabase.updateProduct(CartProduct(
//         id: productModel.id,
//         name: productModel.name,
//         photo: productModel.photo,
//         price: productModel.price,
//         vendorID: productModel.vendorID,
//         quantity: quantity,
//       ));*/
//     /*await cartDatabase.updateProduct(CartProduct(
//         id: productModel.id,
//         name: productModel.name,
//         photo: productModel.photo,
//         price: productModel.price,
//         vendorID: productModel.vendorID,
//         quantity: quantity,
//       ));
//       print("====AUP===" + productModel.toString());
//       // });
//     } else {
//       if (cartProducts.length == 0) {
//         cartDatabase.addProduct(productModel);
//         print("====AD===" + productModel.toString());
//       } else {
//         print(cartProducts[0].vendorID.toString() +
//             "====VID===" +
//             widget.vendorModel.id);
//         if (cartProducts[0].vendorID == widget.vendorModel.id) {
//           cartDatabase.addProduct(productModel);
//         } else {
//           cartDatabase.deleteAllProducts();
//           cartDatabase.addProduct(productModel);
//           print("====VID===RES DIFF");
//         }
//       }*/
//     // }
//     /*} else{
//         setState(() {
//           cartProducts.clear();
//           cartProducts = [];
//         });
//
//         if (quantity > 1) {
//           //  setState(() async {
//           */ /*   await cartDatabase.updateProduct(CartProduct(
//         id: productModel.id,
//         name: productModel.name,
//         photo: productModel.photo,
//         price: productModel.price,
//         vendorID: productModel.vendorID,
//         quantity: quantity,
//       ));*/ /*
//           await cartDatabase.updateProduct(CartProduct(
//             id: productModel.id,
//             name: productModel.name,
//             photo: productModel.photo,
//             price: productModel.price,
//             vendorID: productModel.vendorID,
//             quantity: quantity,
//           ));
//           print("====AUP===" + productModel.toString());
//           // });
//         } else {
//           cartDatabase.addProduct(productModel);
//           print("====AD===" + productModel.toString());
//
//
//       }
//     }*/
//   }
//
//   removetocard(productModel, qun) async {
//     print("Remove product ${qun}");
//     if (qun >= 1) {
//       cartDatabase.allCartProducts.then((products) {
//         print("quantiti call");
//
//         for (CartProduct element in products) {
//           print("quantiti called");
//           if (element.id == productModel.id) {
//             CartProduct cartProduct = element;
//             cartProduct.quantity = qun;
//             print("quantiti ${cartProduct.quantity}");
//             cartDatabase.updateProduct(cartProduct);
//           }
//         }
//       });
//     } else {
//       cartDatabase.removeProduct(productModel.id);
//     }
//   }
//
//   removeQuntityFromCartProduct(productModel) async {
//     List<CartProduct> cartProducts = await cartDatabase.allCartProducts;
//     print("***+++ADDTOCART" + cartProducts.length.toString() + "LEN");
//     if (cartProducts.length > 0) {
//       for (int a = 0; a < cartProducts.length; a++) {
//         print("***+++ADDTOCART" + cartProducts[a].vendorID.toString() + "  " + productModel.vendorID.toString());
//         if (cartProducts[a].vendorID != productModel.vendorID) {
//           print("***+++ADDTOCART");
//           cartDatabase.addProduct(productModel);
//           print("***+++ADDTOCARTFinal1");
//         } else {
//           print("***+++REMOVETOCARTBEFORE...");
//           cartProducts[a].quantity--;
//           cartDatabase.updateProduct(cartProducts[a]);
//           print("***+++REMOVETOCART");
//         }
//       }
//     } else {
//       print("***+++ADDTOCARTELSE");
//       cartDatabase.addProduct(productModel);
//       print("***+++ADDTOCARTFinal1ELSE");
//     }
//
//     /*  if (cartProducts
//         .where((element) => element.vendorID != productModel.vendorID)
//         .isEmpty) {
//       print("***+++ADDTOCART");
//       cartDatabase.addProduct(productModel);
//       print("***+++ADDTOCARTFinal1");
//     } else {
//       {
//         print("***+++REMOVETOCARTBEFORE...");
//         cartDatabase.updateProduct(productModel);
//         print("***+++REMOVETOCART");
//       }
//     }*/
//   }
//
//   showTiming(BuildContext context) {
//     List<WorkingHoursModel> workingHours = widget.vendorModel.workingHours;
//     return Container(
//         decoration: BoxDecoration(
//             color: isDarkMode(context) ? Color(DARK_BG_COLOR) : Colors.white,
//             borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
//         child: Stack(children: [
//           Column(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             mainAxisSize: MainAxisSize.min,
//             children: <Widget>[
//               Container(
//                   child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
//                     Container(
//                         alignment: Alignment.center,
//                         padding: EdgeInsets.only(top: 15),
//                         child: Text(
//                           'Restaurant Timing'.tr(),
//                           style: TextStyle(
//                               fontSize: 18, fontFamily: "Poppinsm", color: isDarkMode(context) ? Color(0XFFdadada) : Color(0XFF252525)),
//                         )),
//                   ])),
//               SizedBox(
//                 height: 10,
//               ),
//
//               ListView.builder(
//                   shrinkWrap: true,
//                   physics: BouncingScrollPhysics(),
//                   itemCount: workingHours.length,
//                   itemBuilder: (context,dayIndex){
//                     print(workingHours[dayIndex].day.toString());
//                     return Padding(
//                       padding: const EdgeInsets.symmetric(horizontal:10,vertical: 2),
//                       child: Card(
//                           shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(6)
//                           ),
//                           color: isDarkMode(context) ? Color(0XFFdadada).withOpacity(0.1) : Colors.grey.shade100,
//                           elevation: 2,
//                           child: Padding(
//                             padding: const EdgeInsets.symmetric(vertical: 4),
//                             child: Column(
//                               children: [
//                                 Row(
//                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Padding(
//                                       padding: const EdgeInsets.symmetric(horizontal: 20),
//                                       child: Text(workingHours[dayIndex].day.toString(),
//                                         style: TextStyle(
//                                             fontSize: 16, fontFamily: "Poppinsm", color: isDarkMode(context) ? Color(0XFFdadada) : Color(0XFF252525)),
//                                       ),
//                                     ),
//
//                                     Visibility(
//                                       visible:workingHours[dayIndex].timeslot!.isEmpty,
//                                       child: Padding(
//                                         padding: const EdgeInsets.symmetric(horizontal: 15),
//                                         child: Container(
//                                             height: 35,
//                                             decoration: BoxDecoration(
//                                                 border: Border.all(color:  Colors.grey.shade400,width: 1.5),
//                                                 color: isDarkMode(context) ? Colors.white : Colors.white,
//                                                 borderRadius: BorderRadius.circular(10)),
//                                             padding: EdgeInsets.only(right: 15, left: 10),
//                                             child: Row(children: [
//                                               Icon(
//                                                 Icons.circle,
//                                                 color: Colors.redAccent,
//                                                 size: 11,
//                                               ),
//                                               SizedBox(width: 5,),
//
//                                               Text("Closed".tr(),
//                                                   style: TextStyle(fontFamily: "Poppinssm",
//                                                       color: Colors.redAccent))
//                                             ])),
//                                       ),
//                                     )
//                                   ],
//                                 ),
//                                 Visibility(
//                                   visible: workingHours[dayIndex].timeslot!.isNotEmpty,
//                                   child: ListView.builder(
//                                       physics: BouncingScrollPhysics(),
//                                       shrinkWrap: true,
//                                       itemCount: workingHours[dayIndex].timeslot!.length,
//                                       itemBuilder: (context,slotIndex){
//                                         return buildTimeCard(timeslot: workingHours[dayIndex].timeslot![slotIndex]);
//                                       }
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           )),
//                     );
//                   }
//               ),
//               SizedBox(
//                 height: 10,
//               ),
//             ],
//           ),
//           Positioned(
//               right: 10,
//               top: 5,
//               child: InkWell(
//                   onTap: () {
//                     Navigator.pop(context);
//                   },
//                   child:
//                   // Padding(padding: EdgeInsets.only(right: 5,top: 5,left: 15,bottom: 20),
//                   // child:
//                   CircleAvatar(
//                       radius: 17,
//                       backgroundColor: Color(0XFFF1F4F7),
//                       child: Image(
//                         image: AssetImage("assets/images/cancel.png"),
//                         height: 35,
//                       ))))
//         ]));
//   }
//
//   buildTimeCard({required Timeslot timeslot}){
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Card(
//           elevation: 2,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(6),
//             side: BorderSide(
//               color: isDarkMode(context) ? Color(0XFF3c3a2e) : Color(0XFFC3C5D1),
//               width: 1,
//             ),
//           ),
//           child: Padding(
//               padding: EdgeInsets.only(top: 7, bottom: 7, left: 20, right: 20),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   Text("From ".tr(),
//                       style: TextStyle(
//
//                           fontFamily: "Poppinsr",
//                           color: isDarkMode(context) ? Color(0XFFa5a292) : Color(0xff5A5D6D))),
//                   //  SizedBox(height: 5,),
//                   Text(timeslot.from.toString(),
//                       style: TextStyle(
//                           fontFamily: "Poppinsm",
//                           color: isDarkMode(context) ? Color(0XFFa5a292) : Color(0XFF5A5D6D)))
//                 ],
//               )),
//         ),
//         SizedBox(
//           width: 20,
//         ),
//         Card(
//           elevation: 2,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(6),
//             side: BorderSide(
//               color: isDarkMode(context) ? Color(0XFF3c3a2e) : Color(0XFFC3C5D1),
//               width: 1,
//             ),
//           ),
//           child: Padding(
//               padding: EdgeInsets.only(top: 7, bottom: 7, left: 20, right: 20),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//
//                   Text("To ".tr(),
//                       style: TextStyle(
//                           fontFamily: "Poppinsr",
//                           color: isDarkMode(context) ? Color(0XFFa5a292) : Color(0xff5A5D6D))),
//                   //  SizedBox(height: 5,),
//                   Text(timeslot.to.toString(),
//                       style: TextStyle(
//                           fontFamily: "Poppinsm",
//                           color: isDarkMode(context) ? Color(0XFFa5a292) : Color(0XFF5A5D6D)))
//                 ],
//               )),
//         ),
//       ],
//     );
//   }
//
//   timeing(BuildContext context) {
//     return Container(
//         decoration: BoxDecoration(
//             color: isDarkMode(context) ? Color(DARK_BG_COLOR) : Colors.white,
//             borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
//         height: 235,
//         child: Stack(children: [
//           Column(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             mainAxisSize: MainAxisSize.min,
//             children: <Widget>[
//               Container(
//                   child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
//                     Container(
//                         alignment: Alignment.center,
//                         padding: EdgeInsets.only(top: 15),
//                         child: Text(
//                           'Restaurant Timing'.tr(),
//                           style: TextStyle(
//                               fontSize: 18, fontFamily: "Poppinsm", color: isDarkMode(context) ? Color(0XFFdadada) : Color(0XFF252525)),
//                         )),
//                   ])),
//               SizedBox(
//                 height: 10,
//               ),
//               Container(
//                   padding: EdgeInsets.only(bottom: 20),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Card(
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                           side: BorderSide(
//                             color: isDarkMode(context) ? Color(0XFF3c3a2e) : Color(0XFFC3C5D1),
//                             width: 1,
//                           ),
//                         ),
//                         child: Padding(
//                             padding: EdgeInsets.only(top: 20, bottom: 20, left: 30, right: 30),
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                               children: [
//                                 Image(
//                                   image: AssetImage("assets/images/time.png"),
//                                   height: 25,
//                                 ),
//                                 SizedBox(
//                                   height: 10,
//                                 ),
//                                 Text("Open time".tr(),
//                                     style: TextStyle(
//                                         fontSize: 18,
//                                         fontFamily: "Poppinsr",
//                                         color: isDarkMode(context) ? Color(0XFFa5a292) : Color(0xff5A5D6D))),
//                                 //  SizedBox(height: 5,),
//                                 Text(widget.vendorModel.opentime == '' ? "10:00 AM" : widget.vendorModel.opentime.toString(),
//                                     style: TextStyle(
//                                         fontSize: 18,
//                                         fontFamily: "Poppinsm",
//                                         color: isDarkMode(context) ? Color(0XFFa5a292) : Color(0XFF5A5D6D)))
//                               ],
//                             )),
//                       ),
//                       SizedBox(
//                         width: 10,
//                       ),
//                       Card(
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                           side: BorderSide(
//                             color: isDarkMode(context) ? Color(0XFF3c3a2e) : Color(0XFFC3C5D1),
//                             width: 1,
//                           ),
//                         ),
//                         child: Padding(
//                             padding: EdgeInsets.only(top: 20, bottom: 20, left: 30, right: 30),
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                               children: [
//                                 Image(
//                                   image: AssetImage("assets/images/time.png"),
//                                   height: 25,
//                                 ),
//                                 SizedBox(
//                                   height: 10,
//                                 ),
//                                 Text("Close time".tr(),
//                                     style: TextStyle(
//                                         fontSize: 18,
//                                         fontFamily: "Poppinsr",
//                                         color: isDarkMode(context) ? Color(0XFFa5a292) : Color(0xff5A5D6D))),
//                                 //  SizedBox(height: 5,),
//                                 Text(widget.vendorModel.closetime == '' ? "10:00 PM" : widget.vendorModel.closetime.toString(),
//                                     style: TextStyle(
//                                         fontSize: 18,
//                                         fontFamily: "Poppinsm",
//                                         color: isDarkMode(context) ? Color(0XFFa5a292) : Color(0XFF5A5D6D)))
//                               ],
//                             )),
//                       ),
//                     ],
//                   ))
//             ],
//           ),
//           Positioned(
//               right: 10,
//               top: 5,
//               child: InkWell(
//                   onTap: () {
//                     Navigator.pop(context);
//                   },
//                   child:
//                   // Padding(padding: EdgeInsets.only(right: 5,top: 5,left: 15,bottom: 20),
//                   // child:
//                   CircleAvatar(
//                       radius: 17,
//                       backgroundColor: Color(0XFFF1F4F7),
//                       child: Image(
//                         image: AssetImage("assets/images/cancel.png"),
//                         height: 35,
//                       ))))
//         ]));
//   }
//
//   bool isOpen = false;
//   statusCheck(){
//     final now = new DateTime.now();
//     var day = DateFormat('EEEE').format(now);
//     var date = DateFormat('dd-MM-yyyy').format(now);
//     widget.vendorModel.workingHours.forEach((element) {
//       print("===>");
//       print(element);
//       if (day == element.day.toString()) {
//         print("---->1" + element.day.toString());
//         if (element.timeslot!.isNotEmpty) {
//           element.timeslot!.forEach((element) {
//             print("===>2");
//             print(element);
//             var start = DateFormat("dd-MM-yyyy HH:mm").parse(date + " " + element.from.toString());
//             var end = DateFormat("dd-MM-yyyy HH:mm").parse(date + " " + element.to.toString());
//             if (isCurrentDateInRange(start, end)) {
//               print("===>1");
//               setState(() {
//                 isOpen = true;
//                 print("===>");
//                 print(isOpen);
//               });
//             }
//           });
//         }
//       }
//     });
//   }
//
//   bool isCurrentDateInRange(DateTime startDate, DateTime endDate) {
//     print(startDate);
//     print(endDate);
//     final currentDate = DateTime.now();
//     print(currentDate);
//     return currentDate.isAfter(startDate) && currentDate.isBefore(endDate);
//   }
//
//   restaurantStatus() async {
//     return Container(
//         height: 35,
//         decoration: BoxDecoration(
//             color: isDarkMode(context) ? Color(DARK_CARD_BG_COLOR) : Color(0XFFF1F4F7),
//             borderRadius: BorderRadius.only(topLeft: Radius.circular(10), bottomLeft: Radius.circular(10))),
//         padding: EdgeInsets.only(right: 40, left: 10),
//         child: Row(children: [
//           Icon(
//             Icons.circle,
//             color: Color(0XFF3dae7d),
//             size: 13,
//           ),
//           SizedBox(
//             width: 10,
//           ),
//           Text(isOpen ? "Open":"Close".tr(), style: TextStyle(fontFamily: "Poppinssm", fontSize: 16, color: Color(0XFF3dae7d)))
//         ]));
//   }
//
//   resttiming() {
//     // var open = int.parse(widget. widget.vendorModel.opentime);
//     // assert(open is int);
//     // var close = int.parse(widget. vendorModel.closetime);
//     // assert(close is int);
//     // DateFormat inputFormat = DateFormat('h:mm a');
//     // DateTime a = inputFormat.parse(widget.vendorModel.opentime);
//
//     // // double open = a.hour.toDouble() + (a.minute.toDouble() / 60);
//
//     // DateTime b = inputFormat.parse(widget.vendorModel.closetime);
//     // // double close = b.hour.toDouble() + (b.minute.toDouble() / 60);
//     // DateTime time = DateTime.now();
//
//     // double now = time.hour.toDouble() + (time.minute.toDouble() / 60);
//     // double _timeDiff = open - now;
//
// // int _hr = _timeDiff.truncate();
// // double _minute = (
//     if (isOpen == true) {
//       return Container(
//           height: 35,
//           decoration: BoxDecoration(
//               color: isDarkMode(context) ? Color(DARK_CARD_BG_COLOR) : Color(0XFFF1F4F7),
//               borderRadius: BorderRadius.only(topLeft: Radius.circular(10), bottomLeft: Radius.circular(10))),
//           padding: EdgeInsets.only(right: 40, left: 10),
//           child: Row(children: [
//             Icon(
//               Icons.circle,
//               color: Color(0XFF3dae7d),
//               size: 13,
//             ),
//             SizedBox(
//               width: 10,
//             ),
//             Text("Open".tr(), style: TextStyle(fontFamily: "Poppinssm", fontSize: 16, color: Color(0XFF3dae7d)))
//           ]));
//     } else
//       return Container(
//           height: 35,
//           decoration: BoxDecoration(
//               color: isDarkMode(context) ? Colors.grey.shade700 : Color(0XFFF1F4F7),
//               borderRadius: BorderRadius.only(topLeft: Radius.circular(10), bottomLeft: Radius.circular(10))),
//           padding: EdgeInsets.only(right: 40, left: 10),
//           child: Row(children: [
//             Icon(
//               Icons.circle,
//               color: Colors.redAccent,
//               size: 13,
//             ),
//             SizedBox(
//               width: 10,
//             ),
//             Text("Close".tr(), style: TextStyle(fontFamily: "Poppinssm", fontSize: 16, letterSpacing: 0.5, color: Colors.redAccent))
//           ]));
//   }
//
//   String? getDate(String date) {
//     final format = DateFormat("MMM dd, yyyy");
//     String formattedDate = format.format(DateTime.parse(date));
//     return formattedDate;
//   }
//
//   openCouponCode(
//       BuildContext context,
//       OfferModel offerModel,
//       ) {
//     return Container(
//       height: 250,
//       decoration: new BoxDecoration(
//         borderRadius: new BorderRadius.circular(20),
//         color: Colors.white,
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//               margin: EdgeInsets.only(
//                 left: 40,
//                 right: 40,
//               ),
//               padding: EdgeInsets.only(
//                 left: 50,
//                 right: 50,
//               ),
//               decoration: BoxDecoration(
//                   image: DecorationImage(
//                     image: AssetImage("assets/images/offer_code_bg.png"),
//                   )),
//               child: Padding(
//                 padding: const EdgeInsets.all(15.0),
//                 child: Text(
//                   offerModel.offerCode!,
//                   style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, letterSpacing: 0.9),
//                 ),
//               )),
//           GestureDetector(
//             onTap: () {
//               FlutterClipboard.copy(offerModel.offerCode!).then((value) {
//                 final SnackBar snackBar = SnackBar(
//                   content: Text(
//                     "Coupon code copied".tr(),
//                     textAlign: TextAlign.center,
//                     style: TextStyle(color: Colors.white),
//                   ),
//                   backgroundColor: Colors.black38,
//                 );
//                 ScaffoldMessenger.of(context).showSnackBar(snackBar);
//                 return Navigator.pop(context);
//               });
//             },
//             child: Container(
//               margin: EdgeInsets.only(top: 30, bottom: 30),
//               child: Text(
//                 "COPY CODE".tr(),
//                 style: TextStyle(color: Color(COLOR_PRIMARY), fontWeight: FontWeight.w500, letterSpacing: 0.1),
//               ),
//             ),
//           ),
//           Container(
//             margin: EdgeInsets.only(bottom: 30),
//             child: RichText(
//               text: TextSpan(
//                 text: "Use code".tr(),
//                 style: TextStyle(fontSize: 16.0, color: Colors.grey, fontWeight: FontWeight.w700),
//                 children: <TextSpan>[
//                   TextSpan(
//                     text: offerModel.offerCode,
//                     style: TextStyle(color: Color(COLOR_PRIMARY), fontWeight: FontWeight.w500, letterSpacing: 0.1),
//                   ),
//                   TextSpan(
//                     text: "& get".tr() +
//                         " ${offerModel.discountTypeOffer == "Fix Price" ? "${symbol}" : ""}${offerModel.discountOffer}${offerModel.discountTypeOffer == "Percentage" ? "% off" : " off"} ",
//                     style: TextStyle(fontSize: 16.0, color: Colors.grey, fontWeight: FontWeight.w700),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Future<void> updatePrice(productModel) async {
//     List<AddAddonsDemo> lstTemp = [];
//     SharedPreferences sp = await SharedPreferences.getInstance();
//     final String musicsString = sp.getString('musics_key') != null ? sp.getString('musics_key')! : "";
//
//     if (musicsString.isNotEmpty && musicsString != null) {
//       lstTemp = AddAddonsDemo.decode(musicsString);
//     }
//
//     double AddOnVal = 0;
//     for (int i = 0; i < lstTemp.length; i++) {
//       AddAddonsDemo addAddonsDemo = lstTemp[i];
//       if (addAddonsDemo.categoryID == productModel.id) {
//         AddOnVal = AddOnVal + double.parse(addAddonsDemo.price!);
//       }
//     }
//     List<CartProduct> cartProducts = [];
//     Future.delayed(const Duration(milliseconds: 500), () {
//       cartProducts.clear();
//
//       cartDatabase.allCartProducts.then((value) {
//         total = 0;
//         cartProducts.addAll(value);
//         print("length cart " + cartProducts.length.toString());
//         for (int i = 0; i < cartProducts.length; i++) {
//           CartProduct e = cartProducts[i];
//           if (e.extras_price != "" && e.extras_price != "0") {
//             total += double.parse(e.extras_price!) * e.quantity;
//           } else if (e.discountPrice != "" || e.discountPrice != "0") {
//             total += double.parse(e.discountPrice!) * e.quantity;
//           } else {
//             total += double.parse(e.price) * e.quantity;
//           }
//         }
//         setState(() {});
//         print("cart price total $total");
//       });
//     });
//   }
// }
