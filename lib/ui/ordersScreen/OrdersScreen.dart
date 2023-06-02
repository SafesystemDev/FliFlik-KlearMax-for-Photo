// ignore_for_file: must_be_immutable

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:foodie_customer/constants.dart';
import 'package:foodie_customer/main.dart';
import 'package:foodie_customer/model/OrderModel.dart';
import 'package:foodie_customer/services/FirebaseHelper.dart';
import 'package:foodie_customer/services/helper.dart';
import 'package:foodie_customer/services/localDatabase.dart';
import 'package:foodie_customer/ui/orderDetailsScreen/OrderDetailsScreen.dart';
import 'package:provider/provider.dart';

class OrdersScreen extends StatefulWidget {
  bool? isAnimation = true;

   OrdersScreen({super.key, this.isAnimation});
  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  late Stream<List<OrderModel>> ordersFuture;
  FireStoreUtils _fireStoreUtils = FireStoreUtils();
  List<OrderModel> ordersList = [];
  late CartDatabase cartDatabase;

  @override
  void initState() {
    super.initState();
    ordersFuture = _fireStoreUtils.getOrders(MyAppState.currentUser!.userID);

    Future.delayed(const Duration(seconds: 7), () {
      setState(() {
        widget.isAnimation = false;
      });
    });
  }

  @override
  void didChangeDependencies() {
    cartDatabase = Provider.of<CartDatabase>(context, listen: false);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    FireStoreUtils().closeOrdersStream();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode(context) ? Color(DARK_COLOR) : Color(0xffFFFFFF),
      // Color(0XFFF1F4F7),
      body: widget.isAnimation == true
          ? Center(
              child: Image.asset(
                'assets/order_place_gif.gif',
              ),
            )
          : StreamBuilder<List<OrderModel>>(
              stream: ordersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting)
                  return Container(
                    child: Center(
                      child: CircularProgressIndicator.adaptive(
                        valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
                      ),
                    ),
                  );
                if (!snapshot.hasData || (snapshot.data?.isEmpty ?? true)) {
                  return Center(
                    child: showEmptyState('No Previous Orders'.tr(), context, description: "orders-food".tr()),
                  );
                } else {
                  // ordersList = snapshot.data!;
                  return ListView.builder(itemCount: snapshot.data!.length, padding: const EdgeInsets.all(12), itemBuilder: (context, index) => buildOrderItem(snapshot.data![index]));
                }
              }),
    );
  }

  Widget buildOrderItem(OrderModel orderModel) {
    double total = 0.0;
    orderModel.products.forEach((element) {
      try {
        if (element.extras_price!.isNotEmpty && double.parse(element.extras_price!) != 0.0) {
          total += element.quantity * double.parse(element.extras_price!);
        }
        total += element.quantity * double.parse(element.price);
      } catch (ex) {}
    });
    total = total - orderModel.discount!;

    return Card(
        color: isDarkMode(context) ? Color(DARK_CARD_BG_COLOR) : Color(0xffFFFFFF),
        margin: EdgeInsets.only(bottom: 30, right: 5, left: 5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.only(top: 5, bottom: 15, right: 10, left: 10),
          child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => push(
                  context,
                  OrderDetailsScreen(
                    orderModel: orderModel,
                  )),
              child: Column(children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  // mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 90,
                      width: 90,

                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: NetworkImage((orderModel.products.first.photo.isNotEmpty) ? orderModel.products.first.photo : placeholderImage),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.darken),
                        ),
                      ),

                      // child: Center(
                      //   child: Text(
                      //     '${orderDate(orderModel.createdAt)} - ${orderModel.status}',
                      //     style: TextStyle(color: Colors.white, fontSize: 17),
                      //   ),
                      // ),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    Expanded(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ORDER ID:'.tr(),
                              style: TextStyle(
                                fontFamily: 'Poppinsm',
                                fontSize: 16,
                                letterSpacing: 0.5,
                                color: isDarkMode(context) ? Colors.grey.shade300 : Color(0xff9091A4),
                              ),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              orderModel.id,
                              style: TextStyle(fontSize: 18, color: isDarkMode(context) ? Colors.grey.shade200 : Color(0XFF000000), fontFamily: "Poppinsm"),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: orderModel.products.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return Padding(
                                  padding: EdgeInsets.only(top: 00),
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                                      // mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          orderModel.products[index].name,
                                          style: TextStyle(fontSize: 18, color: isDarkMode(context) ? Colors.grey.shade200 : Color(0XFF000000), fontFamily: "Poppinsm"),
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Row(
                                          children: [
                                            Text(orderModel.status.tr(), style: TextStyle(color: isDarkMode(context) ? Colors.grey.shade200 : Color(0XFF555353), fontFamily: "Poppinsr")),
                                            SizedBox(width: 3),
                                            Image(
                                              image: AssetImage("assets/images/verti_divider.png"),
                                              height: 10,
                                              width: 10,
                                              color: Color(0XFF555353),
                                            ),
                                            Text(orderDate(orderModel.createdAt), style: TextStyle(color: isDarkMode(context) ? Colors.grey.shade200 : Color(0XFF555353), fontFamily: "Poppinsr")),
                                          ],
                                        ),
                                        SizedBox(height: 5),
                                        getPriceTotalText(orderModel.products[index])
                                      ]));
                            }),
                      ],
                    )),
                  ],
                ),
                SizedBox(height: 20),
              ])),
        ));
  }

  String? getPrice(OrderModel product, int index, CartProduct cartProduct) {
    /*double.parse(product.price)
        .toStringAsFixed(decimal)*/
    var subTotal;
    var price = cartProduct.extras_price == "" || cartProduct.extras_price == null || cartProduct.extras_price == "0.0" ? 0.0 : cartProduct.extras_price;
    var tipValue = product.tipValue.toString() == "" || product.tipValue == null ? 0.0 : product.tipValue.toString();
    var dCharge = product.deliveryCharge == null || product.deliveryCharge.toString().isEmpty ? 0.0 : double.parse(product.deliveryCharge.toString());
    var dis = product.discount.toString() == "" || product.discount == null ? 0.0 : product.discount.toString();

    subTotal = double.parse(price.toString()) + double.parse(tipValue.toString()) + double.parse(dCharge.toString()) - double.parse(dis.toString());

    return subTotal.toString();
  }

  String? getPriceTotal(String price, int quantity) {
    double ans = double.parse(price) * double.parse(quantity.toString());
    return ans.toString();
  }

  getPriceTotalText(CartProduct s) {
    double total = 0.0;
    print("price $s");
    if (s.extras_price != null && s.extras_price!.isNotEmpty && double.parse(s.extras_price!) != 0.0) {
      total += s.quantity * double.parse(s.extras_price!);
    }
    total += s.quantity * double.parse(s.price);

    return Text(
      symbol + total.toStringAsFixed(decimal),
      style: TextStyle(fontSize: 20, color: isDarkMode(context) ? Colors.grey.shade200 : Color(COLOR_PRIMARY), fontFamily: "Poppinssm"),
    );
  }
}
