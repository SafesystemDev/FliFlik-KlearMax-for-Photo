import 'package:cached_network_image/cached_network_image.dart';
import 'package:clipboard/clipboard.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:foodie_customer/constants.dart';
import 'package:foodie_customer/model/VendorModel.dart';
import 'package:foodie_customer/model/offer_model.dart';
import 'package:foodie_customer/services/FirebaseHelper.dart';
import 'package:foodie_customer/services/helper.dart';
import 'package:foodie_customer/ui/vendorProductsScreen/newVendorProductsScreen.dart';

class OffersScreen extends StatefulWidget {
  const OffersScreen({Key? key, required this.vendors}) : super(key: key);
  final List<VendorModel> vendors;

  @override
  _OffersScreenState createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> {
  List<VendorModel> offerVendorList = [];
  List<OfferModel> offersList = [];

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  void dispose() {

    super.dispose();
  }

  Stream<List<VendorModel>>? lstAllRestaurant;

  getData() async {
    await FireStoreUtils().getAllCoupons().then((value) {
      value.forEach((element1) {
        widget.vendors.forEach((element) {
          if (element1.restaurantId == element.id && element1.expireOfferDate!.toDate().isAfter(DateTime.now())) {
            offersList.add(element1);
            offerVendorList.add(element);
          }
        });
      });
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        //isDarkMode(context) ? Color(COLOR_DARK) : null,
        body: Column(
          children: [
            Stack(
              alignment: Alignment.centerLeft,
              children: [
                Image(
                  image: const AssetImage("assets/images/offers_bg.png"),
                  fit: BoxFit.cover,
                  height: 300,
                  width: MediaQuery.of(context).size.width,
                ),
                Positioned(
                    left: 20,
                    child: Text(
                      "OFFERS\nFOR YOU".tr(),
                      style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                    )),
                Positioned(
                  left: 10,
                  top: 10,
                  child: Align(
                    alignment: AlignmentDirectional.topStart,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(left: 5, top: 10, right: 5),
                        decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.black38),
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Image(
                            image: AssetImage("assets/images/ic_back.png"),
                            height: 20,
                            width: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: offerVendorList.isEmpty
                  ? showEmptyState('No Offers Found'.tr(), context)
                  : ListView.builder(
                      itemCount: offerVendorList.length,
                      scrollDirection: Axis.vertical,
                      itemBuilder: (context, index) {
                        return offerItemView(offerVendorList[index], offersList[index]);
                      }),
            ),
          ],
        ),
      ),
    );
  }

  String? getDate(String date) {
    final format = DateFormat("dd MMM, yyyy");
    String formattedDate = format.format(DateTime.parse(date));
    return formattedDate;
  }

  openCouponCode(
    BuildContext context,
    OfferModel offerModel,
  ) {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
              margin: const EdgeInsets.only(
                left: 40,
                right: 40,
              ),
              padding: const EdgeInsets.only(
                left: 50,
                right: 50,
              ),
              decoration: const BoxDecoration(image: DecorationImage(image: AssetImage("assets/images/offer_code_bg.png"))),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Text(
                  offerModel.offerCode!,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, letterSpacing: 0.9),
                ),
              )),
          GestureDetector(
            onTap: () {
              FlutterClipboard.copy(offerModel.offerCode!).then((value) {
                SnackBar snackBar = SnackBar(
                  content: Text(
                    "Coupon code copied".tr(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.black38,
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                return Navigator.pop(context);
              });
            },
            child: Container(
              margin: const EdgeInsets.only(top: 30, bottom: 30),
              child: Text(
                "COPY CODE".tr(),
                style: TextStyle(color: Color(COLOR_PRIMARY), fontWeight: FontWeight.w500, letterSpacing: 0.1),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 30),
            child: RichText(
              text: TextSpan(
                text: "Use code ".tr(),
                style: const TextStyle(fontSize: 16.0, color: Colors.grey, fontWeight: FontWeight.w700),
                children: <TextSpan>[
                  TextSpan(
                    text: offerModel.offerCode,
                    style: TextStyle(color: Color(COLOR_PRIMARY), fontWeight: FontWeight.w500, letterSpacing: 0.1),
                  ),
                  TextSpan(
                    text: " & get".tr() + " ${offerModel.discountTypeOffer == "Fix Price" ? symbol : ""}${offerModel.discountOffer}${offerModel.discountTypeOffer == "Percentage" ? "% off" : " off"} ",
                    style: const TextStyle(fontSize: 16.0, color: Colors.grey, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  offerItemView(VendorModel? vendorModel, OfferModel offerModel) {
    return Stack(
      alignment: Alignment.bottomLeft,
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10), // if you need this
              side: BorderSide(
                color: Colors.grey.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Container(
              margin: const EdgeInsets.fromLTRB(7, 7, 7, 7),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      imageUrl: getImageVAlidUrl(offerModel.imageOffer!),
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.black12,
                        ),
                        child: const Image(
                          image: AssetImage("assets/images/place_holder_offer.png"),
                          fit: BoxFit.cover,
                        ),
                      ),
                      placeholder: (context, url) => const Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 5,
                        ),
                        vendorModel == null
                            ? Container()
                            : vendorModel.id.toString() == offerModel.restaurantId.toString()
                                ? Container(
                                    margin: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            push(
                                              context,
                                              NewVendorProductsScreen(vendorModel: vendorModel),
                                            );
                                          },
                                          child: Text(vendorModel.title,
                                              maxLines: 1,
                                              style: const TextStyle(
                                                fontFamily: "Poppinsm",
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 0.5,
                                                color: Color(0xff000000),
                                              )).tr(),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            const ImageIcon(
                                              AssetImage('assets/images/location3x.png'),
                                              size: 15,
                                              color: Color(0xff9091A4),
                                            ),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            Expanded(
                                              child: Text(vendorModel.location,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontFamily: "Poppinsm",
                                                    letterSpacing: 0.5,
                                                    color: Color(0xff555353),
                                                  )),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  )
                                : Container(
                                    margin: const EdgeInsets.fromLTRB(0, 0, 5, 8),
                                    width: MediaQuery.of(context).size.width,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("eMart's Offer".tr(),
                                            maxLines: 1,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: "Poppinsm",
                                              letterSpacing: 0.5,
                                              color: Color(0xff000000),
                                            )).tr(),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Text("Apply Offer".tr(),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontFamily: "Poppinsm",
                                              letterSpacing: 0.5,
                                              color: Color(0xff555353),
                                            )).tr(),
                                      ],
                                    ),
                                  ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  showModalBottomSheet(
                                    isScrollControlled: true,
                                    isDismissible: true,
                                    context: context,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                    backgroundColor: Colors.transparent,
                                    enableDrag: true,
                                    builder: (context) => openCouponCode(context, offerModel),
                                  );
                                },
                                child: DottedBorder(
                                  borderType: BorderType.RRect,
                                  radius: const Radius.circular(2),
                                  padding: const EdgeInsets.all(2),
                                  color: const Color(COUPON_DASH_COLOR),
                                  strokeWidth: 2,
                                  dashPattern: const [5],
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                    child: Container(
                                        height: 25,
                                        width: MediaQuery.of(context).size.width,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(2),
                                          color: const Color(COUPON_BG_COLOR),
                                        ),
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          offerModel.offerCode!,
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(fontSize: 15, fontFamily: "Poppins", fontWeight: FontWeight.bold, letterSpacing: 0.5, color: Color(COLOR_PRIMARY)),
                                        )),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            vendorModel!.id.toString() == offerModel.restaurantId.toString()
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.star,
                                        size: 20,
                                        color: Color(COLOR_PRIMARY),
                                      ),
                                      const SizedBox(width: 3),
                                      Text(vendorModel.reviewsCount != 0 ? (vendorModel.reviewsSum / vendorModel.reviewsCount).toStringAsFixed(1) : 0.toString(),
                                          style: const TextStyle(
                                            fontFamily: "Poppinsm",
                                            letterSpacing: 0.5,
                                            color: Color(0xff000000),
                                          )),
                                      const SizedBox(width: 3),
                                      Text('(${vendorModel.reviewsCount.toStringAsFixed(1)})',
                                          style: const TextStyle(
                                            fontFamily: "Poppinsm",
                                            letterSpacing: 0.5,
                                            color: Color(0xff666666),
                                          )),
                                    ],
                                  )
                                : Container(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Align(
          alignment: AlignmentDirectional.bottomStart,
          child: Container(
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Container(width: 75, margin: const EdgeInsets.only(bottom: 10), child: const Image(image: AssetImage("assets/images/offer_badge.png"))),
                Container(
                  margin: const EdgeInsets.only(top: 3),
                  child: Text(
                    "${offerModel.discountTypeOffer == "Fix Price".tr() ? symbol : ""}${offerModel.discountOffer}${offerModel.discountTypeOffer == "Percentage" ? "% Off" : " Off"}",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 0.7),
                  ),
                )
              ],
            ),
          ),
        )
      ],
    );
  }
}
