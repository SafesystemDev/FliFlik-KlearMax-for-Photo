import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:foodie_customer/constants.dart';
import 'package:foodie_customer/model/ProductModel.dart';
import 'package:foodie_customer/model/VendorCategoryModel.dart';
import 'package:foodie_customer/model/VendorModel.dart';
import 'package:foodie_customer/model/offer_model.dart';
import 'package:foodie_customer/services/FirebaseHelper.dart';
import 'package:foodie_customer/services/helper.dart';
import 'package:foodie_customer/services/localDatabase.dart';
import 'package:foodie_customer/ui/productDetailsScreen/ProductDetailsScreen.dart';
import 'package:foodie_customer/ui/vendorProductsScreen/widgets/fappbar.dart';
import 'package:provider/provider.dart';
import 'package:rect_getter/rect_getter.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NewVendorProductsScreen extends StatefulWidget {
  final VendorModel vendorModel;

  const NewVendorProductsScreen({Key? key, required this.vendorModel}) : super(key: key);

  @override
  State<NewVendorProductsScreen> createState() => _NewVendorProductsScreenState();
}

class _NewVendorProductsScreenState extends State<NewVendorProductsScreen> with SingleTickerProviderStateMixin {
  final FireStoreUtils fireStoreUtils = FireStoreUtils();

  final listViewKey = RectGetter.createGlobalKey();

  bool isCollapsed = false;

  late AutoScrollController scrollController;
  TabController? tabController;

  final double expandedHeight = 500.0;

  // final PageData data = ExampleData.data;
  final double collapsedHeight = kToolbarHeight;

  Map<int, dynamic> itemKeys = {};

  // prevent animate when press on tab bar
  bool pauseRectGetterIndex = false;

  @override
  void initState() {
    getFoodType();
    statusCheck();
    scrollController = AutoScrollController();
    super.initState();
  }

  String? foodType;

  List a = [];
  List<ProductModel> productModel = [];

  void getFoodType() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    foodType = sp.getString("foodType") ?? "Delivery".tr();

    if (foodType == "Takeaway") {
      await fireStoreUtils.getVendorProductsTakeAWay(widget.vendorModel.id).then((value) {
        productModel.clear();
        productModel.addAll(value);
        getVendorCategoryById();
        setState(() {});
      });
    } else {
      await fireStoreUtils.getVendorProductsDelivery(widget.vendorModel.id).then((value) {
        productModel.clear();
        productModel.addAll(value);
        getVendorCategoryById();
        setState(() {});
      });
    }
  }

  List<VendorCategoryModel> vendorCateoryModel = [];
  List<OfferModel> offerList = [];

  getVendorCategoryById() async {
    vendorCateoryModel.clear();

    for (int i = 0; i < productModel.length; i++) {
      if (a.isNotEmpty && a.contains(productModel[i].categoryID)) {
      } else if (!a.contains(productModel[i].categoryID)) {
        a.add(productModel[i].categoryID);

        await fireStoreUtils.getVendorCategoryById(productModel[i].categoryID).then((value) {
          if (value != null) {
            setState(() {
              vendorCateoryModel.add(value);
            });
          }
        });
      }
    }
    setState(() {
      tabController = TabController(length: vendorCateoryModel.length, vsync: this);
    });

    await FireStoreUtils().getOfferByVendorID(widget.vendorModel.id).then((value) {
      setState(() {
        offerList = value;
      });
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    tabController!.dispose();
    super.dispose();
  }

  List<int> getVisibleItemsIndex() {
    Rect? rect = RectGetter.getRectFromKey(listViewKey);
    List<int> items = [];
    if (rect == null) return items;
    itemKeys.forEach((index, key) {
      Rect? itemRect = RectGetter.getRectFromKey(key);
      if (itemRect == null) return;
      if (itemRect.top > rect.bottom) return;
      if (itemRect.bottom < rect.top) return;
      items.add(index);
    });
    return items;
  }

  void onCollapsed(bool value) {
    if (this.isCollapsed == value) return;
    setState(() => this.isCollapsed = value);
  }

  bool onScrollNotification(ScrollNotification notification) {
    if (pauseRectGetterIndex) return true;
    int lastTabIndex = tabController!.length - 1;
    List<int> visibleItems = getVisibleItemsIndex();

    bool reachLastTabIndex = visibleItems.isNotEmpty && visibleItems.length <= 2 && visibleItems.last == lastTabIndex;
    if (reachLastTabIndex) {
      tabController!.animateTo(lastTabIndex);
    } else if (visibleItems.isNotEmpty) {
      int sumIndex = visibleItems.reduce((value, element) => value + element);
      int middleIndex = sumIndex ~/ visibleItems.length;
      if (tabController!.index != middleIndex) tabController!.animateTo(middleIndex);
    }
    return false;
  }

  void animateAndScrollTo(int index) {
    pauseRectGetterIndex = true;
    tabController!.animateTo(index);
    scrollController.scrollToIndex(index, preferPosition: AutoScrollPosition.begin).then((value) => pauseRectGetterIndex = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: tabController == null
          ? const Center(child: CircularProgressIndicator())
          : RectGetter(
              key: listViewKey,
              child: NotificationListener<ScrollNotification>(
                child: buildSliverScrollView(),
                onNotification: onScrollNotification,
              ),
            ),
    );
  }

  Widget buildSliverScrollView() {
    return CustomScrollView(
      controller: scrollController,
      slivers: [
        buildAppBar(),
        buildBody(),
      ],
    );
  }

  @override
  void didChangeDependencies() {
    cartDatabase = Provider.of<CartDatabase>(context);
    super.didChangeDependencies();
  }

  SliverAppBar buildAppBar() {
    return FAppBar(
      vendorModel: widget.vendorModel,
      vendorCateoryModel: vendorCateoryModel,
      isOpen: isOpen,
      context: context,
      scrollController: scrollController,
      expandedHeight: expandedHeight,
      collapsedHeight: collapsedHeight,
      isCollapsed: isCollapsed,
      onCollapsed: onCollapsed,
      tabController: tabController!,
      offerList: offerList,
      onTap: (index) => animateAndScrollTo(index),
    );
  }

  SliverList buildBody() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => buildCategoryItem(index),
        childCount: vendorCateoryModel.length,
      ),
    );
  }

  Widget buildCategoryItem(int index) {
    itemKeys[index] = RectGetter.createGlobalKey();
    VendorCategoryModel category = vendorCateoryModel[index];
    return RectGetter(
      key: itemKeys[index],
      child: AutoScrollTag(
        key: ValueKey(index),
        index: index,
        controller: scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            productModel.isEmpty
                ? Container()
                : index == 0
                    ? buildVeg(veg, nonveg)
                    : Container(),
            _buildSectionTileHeader(category),
            _buildFoodTileList(context, category),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTileHeader(VendorCategoryModel category) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Text(
          category.title.toString(),
          style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  var isAnother = 0;
  bool veg = false;
  bool nonveg = false;

  Widget _buildFoodTileList(BuildContext context, VendorCategoryModel category) {
    isAnother = 0;
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Divider(
            color: Color(0xffE4E8EB),
            thickness: 1,
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: productModel.length,
          padding: EdgeInsets.zero,
          itemBuilder: (context, inx) {
            return productModel[inx].categoryID == category.id
                ? buildRow(productModel[inx], veg, nonveg, productModel[inx].categoryID, (inx == (productModel.length - 1)))
                : (isAnother == 0 && (inx == (productModel.length - 1)))
                    ? showEmptyState("No Item are available.".tr(), context)
                    : Container();
          },
        ),
      ],
    );
  }

  buildRow(ProductModel productModel, veg, nonveg, inx, bool index) {
    if (vegSwitch == true && productModel.veg == true) {
      isAnother++;
      return datarow(productModel);
    } else if (nonVegSwitch == true && productModel.veg == false) {
      isAnother++;
      return datarow(productModel);
    } else if (vegSwitch != true && nonVegSwitch != true) {
      isAnother++;
      return datarow(productModel);
    } else if (nonVegSwitch == true && productModel.nonveg == true) {
      isAnother++;
      return datarow(productModel);
    } else if (inx == productModel.categoryID) {
      return (isAnother == 0 && index) ? showEmptyState("No Food are available.", context) : Container();
    }
  }

  late CartDatabase cartDatabase;
  late List<CartProduct> cartProducts = [];

  datarow(ProductModel productModel) {
    var price = double.parse(productModel.price);
    assert(price is double);
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () async {
        // await Navigator.of(context)
        //     .push(MaterialPageRoute(builder: (context) => ProductDetailsScreen(productModel: productModel, vendorModel: widget.vendorModel)))
        //     .whenComplete(() => {setState(() {})});

        // showModalBottomSheet(
        //   isScrollControlled: true,
        //   isDismissible: true,
        //   context: context,
        //   backgroundColor: Colors.transparent,
        //   enableDrag: true,
        //   builder: (context) => ProductDetailsScreen(productModel: productModel, vendorModel: widget.vendorModel),
        // ).whenComplete(() => {setState(() {})})
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isDarkMode(context) ? const Color(DarkContainerBorderColor) : Colors.grey.shade100, width: 1),
          color: isDarkMode(context) ? Color(DarkContainerColor) : Colors.white,
          boxShadow: [
            isDarkMode(context)
                ? const BoxShadow()
                : BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    blurRadius: 5,
                  ),
          ],
        ),
        child: Row(children: [
          // StreamBuilder<List<CartProduct>>(
          //     stream: cartDatabase.watchProducts,
          //     initialData: [],
          //     builder: (context, snapshot) {
          //       cartProducts = snapshot.data!;
          //       print("cart pro copre  " + cartProducts.length.toString());
          //       print(cartProducts.toString());
          //       print("cart pro co " + productModel.quantity.toString());
          //       Future.delayed(const Duration(milliseconds: 300), () {
          //         productModel.quantity = 0;
          //         if (cartProducts.isNotEmpty) {
          //           for (CartProduct cartProduct in cartProducts) {
          //             if (cartProduct.id == productModel.id) {
          //               productModel.quantity = cartProduct.quantity;
          //             }
          //           }
          //         }
          //       });
          //       return const SizedBox(
          //         height: 0,
          //         width: 0,
          //       );
          //     }),
          Stack(children: [
            CachedNetworkImage(
                height: 80,
                width: 80,
                imageUrl: getImageVAlidUrl(productModel.photo),
                imageBuilder: (context, imageProvider) => Container(
                      // width: 100,
                      // height: 100,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          )),
                    ),
                errorWidget: (context, url, error) => ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(
                      placeholderImage,
                      fit: BoxFit.cover,
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                    ))),
            Positioned(
              left: 5,
              top: 5,
              child: Icon(
                Icons.circle,
                color: productModel.veg == true ? const Color(0XFF3dae7d) : Colors.redAccent,
                size: 13,
              ),
            )
          ]),
          const SizedBox(
            width: 10,
          ),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                productModel.name,
                style: const TextStyle(fontSize: 16, fontFamily: "Poppinssb", letterSpacing: 0.5),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(
                height: 5,
              ),
              Row(
                children: <Widget>[
                  productModel.disPrice == "" || productModel.disPrice == "0"
                      ? Text(
                          symbol + double.parse(productModel.price).toStringAsFixed(decimal),
                          style: TextStyle(fontSize: 16, fontFamily: "Poppinsm", letterSpacing: 0.5, color: Color(COLOR_PRIMARY)),
                        )
                      : Row(
                          children: [
                            Text(
                              "$symbol${double.parse(productModel.disPrice.toString()).toStringAsFixed(decimal)}",
                              style: TextStyle(
                                fontFamily: "Poppinsm",
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(COLOR_PRIMARY),
                              ),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Text(
                              '$symbol${double.parse(productModel.price).toStringAsFixed(decimal)}',
                              style: const TextStyle(fontFamily: "Poppinsm", fontWeight: FontWeight.bold, color: Colors.grey, decoration: TextDecoration.lineThrough),
                            ),
                          ],
                        ),
                  // productModel.quantity == 0
                  //     ? isOpen != true
                  //         ? const Center()
                  //         : Padding(
                  //             padding: const EdgeInsets.only(right: 15),
                  //             child: SizedBox(
                  //                 height: 33,
                  //                 // width: 80,
                  //                 // alignment:Alignment.center,
                  //                 child: Center(
                  //                   // height: 10,
                  //                   //  width: 80,
                  //                   child: TextButton.icon(
                  //                     onPressed: () {
                  //                       if (MyAppState.currentUser == null) {
                  //                         push(context, const AuthScreen());
                  //                       } else {
                  //                         setState(() {
                  //                           productModel.quantity = 1;
                  //                           // productModel.price = productModel.disPrice == "" || productModel.disPrice == "0"?productModel.price:productModel.disPrice;
                  //                           addtocard(productModel, productModel.quantity);
                  //                         });
                  //                       }
                  //                     },
                  //                     icon: Icon(Icons.add, size: 18, color: Color(COLOR_PRIMARY)),
                  //                     label: Text(
                  //                       'ADD'.tr(),
                  //                       style: TextStyle(height: 1.2, fontFamily: "Poppinssb", letterSpacing: 0.5, color: Color(COLOR_PRIMARY)),
                  //                     ),
                  //                     style: TextButton.styleFrom(
                  //                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                  //                       side: const BorderSide(color: Color(0XFFC3C5D1), width: 1.5),
                  //                     ),
                  //                   ),
                  //                 )))
                  //     : Row(
                  //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  //         crossAxisAlignment: CrossAxisAlignment.center,
                  //         children: [
                  //           IconButton(
                  //               onPressed: () {
                  //                 if (productModel.quantity != 0) {
                  //                   setState(() {
                  //                     productModel.quantity--;
                  //                     if (productModel.quantity >= 0) {
                  //                       // productModel.price = productModel.disPrice == "" || productModel.disPrice == "0"?productModel.price:productModel.disPrice;
                  //                       removetocard(productModel, productModel.quantity);
                  //                     } else {
                  //                       // addtocard(productModel);
                  //                       //removeQuntityFromCartProduct(productModel);
                  //
                  //                     }
                  //
                  //                     //: addtocard(productModel);
                  //                   });
                  //                 }
                  //                 //   productModel.quantity >=1?
                  //                 //   removetocard(productModel, productModel.quantity)
                  //                 //  :null;
                  //                 // },
                  //                 // );
                  //               },
                  //               icon: Image(
                  //                 image: const AssetImage("assets/images/minus.png"),
                  //                 color: Color(COLOR_PRIMARY),
                  //                 height: 28,
                  //               )),
                  //           const SizedBox(
                  //             width: 5,
                  //           ),
                  //
                  //           // cartData( productModel.id)== null?
                  //
                  //           StreamBuilder<List<CartProduct>>(
                  //               stream: cartDatabase.watchProducts,
                  //               initialData: const [],
                  //               builder: (context, snapshot) {
                  //                 cartProducts = snapshot.data!;
                  //                 return SizedBox(
                  //                     height: 25,
                  //                     width: 0,
                  //                     child: Column(children: [
                  //                       Expanded(
                  //                           child: ListView.builder(
                  //                               itemCount: cartProducts.length,
                  //                               itemBuilder: (context, index) {
                  //                                 cartProducts[index].id == productModel.id ? productModel.quantity = cartProducts[index].quantity : null;
                  //                                 // print('yahaaaaa');
                  //                                 if (cartProducts[index].id == productModel.id) {
                  //                                   return const Center();
                  //                                 } else {
                  //                                   return Container();
                  //                                 }
                  //                                 //  return Center();
                  //
                  //                                 // print(quen);
                  //                               }))
                  //                     ]));
                  //               }),
                  //           Text(
                  //             '${productModel.quantity}'.tr(),
                  //             style: const TextStyle(
                  //               fontSize: 20,
                  //               color: Colors.black,
                  //               letterSpacing: 0.5,
                  //             ),
                  //           ),
                  //           //  Text("null"),
                  //           const SizedBox(
                  //             width: 5,
                  //           ),
                  //           IconButton(
                  //               onPressed: () {
                  //                 setState(() {
                  //                   if (productModel.quantity != 0) {
                  //                     productModel.quantity++;
                  //                   }
                  //                   //productModel.price = productModel.disPrice == "" || productModel.disPrice == "0"?productModel.price:productModel.disPrice;
                  //                   addtocard(productModel, productModel.quantity);
                  //                 });
                  //               },
                  //               icon: Image(
                  //                 image: const AssetImage("assets/images/plus.png"),
                  //                 color: Color(COLOR_PRIMARY),
                  //                 height: 28,
                  //               ))
                  //         ],
                  //       )
                ],
              ),
              const SizedBox(
                height: 5,
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(productModel.reviewsCount != 0 ? (productModel.reviewsSum / productModel.reviewsCount).toStringAsFixed(1) : 0.toString(),
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
            ],
          )),
          TextButton.icon(
            onPressed: () async {
              await Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => ProductDetailsScreen(productModel: productModel, vendorModel: widget.vendorModel)))
                  .whenComplete(() => {setState(() {})});
            },
            icon: Icon(
              Icons.add,
              color: Color(COLOR_PRIMARY),
              size: 16,
            ),
            label: Text(
              'ADD'.tr(),
              style: TextStyle(fontFamily: "Poppinsm", color: Color(COLOR_PRIMARY)),
            ),
            style: TextButton.styleFrom(
              side: BorderSide(color: Colors.grey.shade300, width: 2),
            ),
          )
        ]),
      ),
    );
  }

  bool vegSwitch = false;
  bool nonVegSwitch = false;

  buildVeg(veg, nonveg) {
    // var vegSwitch,nonVegSwitch = false;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Container(
            width: MediaQuery.of(context).size.width / 2.1,
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Switch(
                  value: vegSwitch,
                  onChanged: (bool isOn) {
                    setState(() {
                      vegSwitch = isOn;
                      // vegSwitch == false
                      //     ? nonVegSwitch = true
                      //     : nonVegSwitch = false;
                    });
                  },
                  activeColor: Colors.green,
                  activeTrackColor: const Color(0xffCAD1D8),
                  inactiveTrackColor: const Color(0xffCAD1D8),
                  inactiveThumbColor: const Color(0xff9091A4),
                ),
                Text(
                  "Veg".tr(),
                  style: const TextStyle(
                    fontFamily: "Poppinsm",
                    color: Color(0xff9091A4),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const Text(
            '|',
            style: TextStyle(color: Color(0xffCAD1D8)),
          ),
          SizedBox(
            height: 35,
            width: MediaQuery.of(context).size.width / 2.1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Switch(
                  value: nonVegSwitch,
                  onChanged: (bool isOn) {
                    setState(() {
                      nonVegSwitch = isOn;
                    });
                  },
                  activeColor: Colors.red,
                  activeTrackColor: const Color(0xffCAD1D8),
                  inactiveTrackColor: const Color(0xffCAD1D8),
                  inactiveThumbColor: const Color(0xff9091A4),
                ),
                Text(
                  "Non-Veg".tr(),
                  style: const TextStyle(
                    fontFamily: "Poppinsm",
                    color: Color(0xff9091A4),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool isOpen = false;

  statusCheck() {
    final now = new DateTime.now();
    var day = DateFormat('EEEE', 'en_US').format(now);
    var date = DateFormat('dd-MM-yyyy').format(now);
    widget.vendorModel.workingHours.forEach((element) {
      print("===>");
      print(element);
      if (day == element.day.toString()) {
        print("---->1" + element.day.toString());
        if (element.timeslot!.isNotEmpty) {
          element.timeslot!.forEach((element) {
            print("===>2");
            print(element);
            var start = DateFormat("dd-MM-yyyy HH:mm").parse(date + " " + element.from.toString());
            var end = DateFormat("dd-MM-yyyy HH:mm").parse(date + " " + element.to.toString());
            if (isCurrentDateInRange(start, end)) {
              print("===>1");
              setState(() {
                isOpen = true;
                print("===>");
                print(isOpen);
              });
            }
          });
        }
      }
    });
  }

  bool isCurrentDateInRange(DateTime startDate, DateTime endDate) {
    print(startDate);
    print(endDate);
    final currentDate = DateTime.now();
    print(currentDate);
    return currentDate.isAfter(startDate) && currentDate.isBefore(endDate);
  }
}
