import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:foodie_customer/constants.dart';
import 'package:foodie_customer/main.dart';
import 'package:foodie_customer/model/OrderModel.dart';
import 'package:foodie_customer/model/ProductModel.dart';
import 'package:foodie_customer/model/VendorModel.dart';
import 'package:foodie_customer/services/FirebaseHelper.dart';
import 'package:foodie_customer/services/helper.dart';
import 'package:foodie_customer/services/localDatabase.dart';
import 'package:foodie_customer/ui/placeOrderScreen/PlaceOrderScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../model/TaxModel.dart';

class CheckoutScreen extends StatefulWidget {
  final String paymentOption, paymentType;
  final double total;
  final double? discount;
  final String? couponCode;
  final String? couponId, notes;
  final List<CartProduct> products;
  final List<String>? extraAddons;
  final String? tipValue;
  final bool? takeAway;
  final String? deliveryCharge;
  final String? size;
  final bool isPaymentDone;
  final TaxModel? taxModel;
  final Map<String, dynamic>? specialDiscountMap;

  const CheckoutScreen(
      {Key? key,
      required this.isPaymentDone,
      required this.paymentOption,
      required this.paymentType,
      required this.total,
      this.discount,
      this.couponCode,
      this.couponId,
      this.notes,
      required this.products,
      this.extraAddons,
      this.tipValue,
      this.takeAway,
      this.deliveryCharge,
      this.taxModel,
      this.specialDiscountMap,
      this.size})
      : super(key: key);

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final fireStoreUtils = FireStoreUtils();
  late Map<String, dynamic>? adminCommission;
  String? adminCommissionValue = "", addminCommissionType = "";
  bool? isEnableAdminCommission = false;

  @override
  void initState() {

    super.initState();
    placeAutoOrder();
    fireStoreUtils.getAdminCommission().then((value) {
      if (value != null) {
        setState(() {
          adminCommission = value;
          adminCommissionValue = adminCommission!["adminCommission"].toString();
          addminCommissionType = adminCommission!["adminCommissionType"].toString();
          isEnableAdminCommission = adminCommission!["isAdminCommission"];
        });
      }
    });
  }

  placeAutoOrder() {
    if (widget.isPaymentDone) {
      Future.delayed(Duration(seconds: 2), () {
        placeOrder();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode(context) ? Colors.grey.shade900 : Colors.grey.shade50,
      appBar: AppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              'Checkout'.tr(),
              style: TextStyle(fontSize: 24, color: isDarkMode(context) ? Colors.grey.shade300 : Colors.grey.shade800, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                Container(
                  color: isDarkMode(context) ? Colors.black : Colors.white,
                  child: ListTile(
                    leading: Text(
                      'Payment'.tr(),
                      style: TextStyle(color: Color(COLOR_PRIMARY), fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    trailing: Text(
                      widget.paymentOption,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                ),
                Divider(
                  height: 3,
                ),
                Container(
                  color: isDarkMode(context) ? Colors.black : Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Deliver to'.tr(),
                          style: TextStyle(color: Color(COLOR_PRIMARY), fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width / 2,
                          child: Text(
                            '${MyAppState.currentUser!.shippingAddress.line1} ${MyAppState.currentUser!.shippingAddress.line2}',
                            textAlign: TextAlign.end,
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Divider(
                  height: 3,
                ),
                Container(
                  color: isDarkMode(context) ? Colors.black : Colors.white,
                  child: ListTile(
                    leading: Text(
                      'Total'.tr(),
                      style: TextStyle(color: Color(COLOR_PRIMARY), fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    trailing: Text(
                      symbol + widget.total.toDouble().toStringAsFixed(decimal),
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                ),
              ],
              shrinkWrap: true,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(20), backgroundColor: Color(COLOR_PRIMARY),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                if (!widget.isPaymentDone) {
                  Future.delayed(Duration(seconds: 3), () {
                    placeOrder();
                  });
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Visibility(
                      visible: widget.isPaymentDone,
                      child: SizedBox(
                          height: 25,
                          width: 25,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ))),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    'PLACE ORDER'.tr(),
                    style: TextStyle(color: isDarkMode(context) ? Colors.black : Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> setPrefData() async {
    SharedPreferences sp = await SharedPreferences.getInstance();

    sp.setString("musics_key", "");
    sp.setString("addsize", "");
  }

  placeOrder() async {
    List<CartProduct> tempProduc = [];

    for (CartProduct cartProduct in widget.products) {
      CartProduct tempCart = cartProduct;
      // tempCart.extras = cartProduct.extras?.split(",");
      tempProduc.add(tempCart);
    }
    FireStoreUtils fireStoreUtils = FireStoreUtils();
    //place order
    showProgress(context, 'Placing Order...'.tr(), false);
    VendorModel vendorModel = await fireStoreUtils.getVendorByVendorID(widget.products.first.vendorID).whenComplete(() => setPrefData());
    log(vendorModel.fcmToken.toString() + "{}{}{}{======TOKENADD" + vendorModel.toJson().toString());
    OrderModel orderModel = OrderModel(
        address: MyAppState.currentUser!.shippingAddress,
        author: MyAppState.currentUser,
        authorID: MyAppState.currentUser!.userID,
        createdAt: Timestamp.now(),
        products: tempProduc,
        status: ORDER_STATUS_PLACED,
        vendor: vendorModel,
        vendorID: widget.products.first.vendorID,
        discount: widget.discount,
        couponCode: widget.couponCode,
        couponId: widget.couponId,
        notes: widget.notes,
        taxModel: widget.taxModel,
        paymentMethod: widget.paymentType,
        specialDiscount: widget.specialDiscountMap,
        //// extra_size: widget.extra_size,
        // extras: widget.extra_addons!,
        tipValue: widget.tipValue,
        adminCommission: isEnableAdminCommission! ? adminCommissionValue : "0",
        adminCommissionType: isEnableAdminCommission! ? addminCommissionType : "",
        takeAway: widget.takeAway,
        deliveryCharge: widget.deliveryCharge);

    OrderModel placedOrder = await fireStoreUtils.placeOrder(orderModel);
    for (int i = 0; i < tempProduc.length; i++) {
      await FireStoreUtils().getProductByID(tempProduc[i].id.split('~').first).then((value) async {
        ProductModel? productModel = value;
        log("-----------1>${value.toJson()}");
        if (tempProduc[i].variant_info != null) {
          for (int j = 0; j < productModel.itemAttributes!.variants!.length; j++) {
            if (productModel.itemAttributes!.variants![j].variantId == tempProduc[i].id.split('~').last) {
              if (productModel.itemAttributes!.variants![j].variantQuantity != "-1") {
                productModel.itemAttributes!.variants![j].variantQuantity = (int.parse(productModel.itemAttributes!.variants![j].variantQuantity.toString()) - tempProduc[i].quantity).toString();
              }
            }

          }
        } else {
          if (productModel.quantity != -1) {
            productModel.quantity = productModel.quantity - tempProduc[i].quantity;
          }
        }

        await FireStoreUtils.updateProduct(productModel).then((value) {
          log("-----------2>${value!.toJson()}");
        });
      });
    }

    hideProgress();
    showModalBottomSheet(
      isScrollControlled: true,
      isDismissible: false,
      context: context,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) => PlaceOrderScreen(orderModel: placedOrder),
    );
  }
}
