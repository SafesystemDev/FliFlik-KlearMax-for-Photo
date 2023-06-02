import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:foodie_customer/constants.dart';
import 'package:foodie_customer/main.dart';
import 'package:foodie_customer/model/OrderModel.dart';
import 'package:foodie_customer/services/FirebaseHelper.dart';
import 'package:foodie_customer/services/helper.dart';
import 'package:foodie_customer/services/localDatabase.dart';
import 'package:foodie_customer/ui/container/ContainerScreen.dart';
import 'package:foodie_customer/ui/ordersScreen/OrdersScreen.dart';

class PlaceOrderScreen extends StatefulWidget {
  final OrderModel orderModel;

  const PlaceOrderScreen({Key? key, required this.orderModel}) : super(key: key);

  @override
  _PlaceOrderScreenState createState() => _PlaceOrderScreenState();
}

class _PlaceOrderScreenState extends State<PlaceOrderScreen> {
  FireStoreUtils fireStoreUtils = FireStoreUtils();
  late Timer timer;

  @override
  void initState() {
    timer = Timer(Duration(seconds: 3), () => animateOut());
    super.initState();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      height: MediaQuery.of(context).size.height * 0.95,
      decoration: BoxDecoration(
        color: isDarkMode(context) ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      child: Column(
        children: [
          ListTile(
            title: Text(
              'Placing Order...'.tr(),
              style: TextStyle(color: isDarkMode(context) ? Colors.grey.shade300 : Colors.grey.shade800, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            trailing: Container(
              width: 24,
              height: 24,
              child: CircularProgressIndicator.adaptive(
                valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
              ),
            ),
          ),
          Visibility(
            visible: widget.orderModel.takeAway == false,
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 40),
                  title: Text(
                    '${widget.orderModel.address.line1} ${widget.orderModel.address.line2} ${widget.orderModel.address.city}',
                    style: TextStyle(color: isDarkMode(context) ? Colors.grey.shade300 : Colors.grey.shade800, fontWeight: FontWeight.w500, fontSize: 17),
                  ),
                  subtitle: Text('Deliver to door'.tr()),
                  leading: Icon(
                    CupertinoIcons.checkmark_alt,
                    color: Color(COLOR_PRIMARY),
                  ),
                ),
                Divider(indent: 40, endIndent: 40),
              ],
            ),
          ),

          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 40),
            title: Text(
              'Your order, {}'.tr(args: ['${widget.orderModel.address.name}']),
              style: TextStyle(
                color: isDarkMode(context) ? Colors.grey.shade300 : Colors.grey.shade800,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            leading: Icon(
              CupertinoIcons.checkmark_alt,
              color: Color(COLOR_PRIMARY),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsetsDirectional.only(start: 56),
              itemCount: widget.orderModel.products.length,
              itemBuilder: (context, index) => Padding(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      color: isDarkMode(context) ? Colors.grey.shade700 : Colors.grey.shade200,
                      padding: EdgeInsets.all(6),
                      child: Text('${index + 1}'),
                    ),
                    SizedBox(width: 16),
                    Text(
                      '${widget.orderModel.products[index].name}',
                      style: TextStyle(
                        color: isDarkMode(context) ? Colors.grey.shade300 : Colors.grey.shade800,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          // RaisedButton(onPressed: () => deleteOrder(), child: Text('Undo'))
        ],
      ),
    );
  }

  animateOut() {
    print(widget.orderModel.vendor.fcmToken.toString() + "{}{}{}{======TOKEN");
    FireStoreUtils.sendFcmMessage("newOrder".tr(), '${MyAppState.currentUser!.firstName}' + "hasOrdered", widget.orderModel.vendor.fcmToken);

    Provider.of<CartDatabase>(context, listen: false).deleteAllProducts();

    pushAndRemoveUntil(
        context,
        ContainerScreen(
          user: MyAppState.currentUser!,
          currentWidget: OrdersScreen(isAnimation: true),
          appBarTitle: 'Orders'.tr(),
          drawerSelection: DrawerSelection.Orders,
        ),
        false);
  }
}
