import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:foodie_customer/services/helper.dart';
import 'package:foodie_customer/ui/cartScreen/CartScreen.dart';
import 'package:foodie_customer/ui/mapView/MapViewScreen.dart';
import 'package:foodie_customer/ui/searchScreen/SearchScreen.dart';

import 'constants.dart';

class AppGlobal {
  static double deliveryCharges = 0.0;

  static String? placeHolderImage = "";

  static AppBar buildAppBar(BuildContext context, String title) {
    return AppBar(
      centerTitle: false,
      backgroundColor: isDarkMode(context) ? Color(DARK_COLOR) : null,
      automaticallyImplyLeading: false,
      leading: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Icon(
          Icons.arrow_back_ios,
          color: Color(COLOR_PRIMARY),
        ),
      ),
      title: Text(
        title,
        style: TextStyle(fontFamily: "Poppinsm", color: isDarkMode(context) ? Colors.white : Colors.black, fontWeight: FontWeight.normal),
      ),
      actions: [
        IconButton(
            padding: EdgeInsets.only(right: 7),
            icon: Image(
              image: AssetImage("assets/images/search.png"),
              width: 20,
              color: isDarkMode(context) ? Colors.white : null,
            ),
            onPressed: () async {
              push(
                context,
                SearchScreen(),
              );
              await Future.delayed(Duration(seconds: 1), () {});
            }),
        IconButton(
          padding: EdgeInsets.only(right: 7),
          icon: Image(
            image: AssetImage("assets/images/map.png"),
            width: 20,
            color: isDarkMode(context) ? Colors.white : Color(0xFF333333),
          ),
          onPressed: () => push(
            context,
            MapViewScreen(),
          ),
        ),
        IconButton(
            padding: EdgeInsets.only(right: 17),
            tooltip: 'Cart'.tr(),
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                Image(
                  image: AssetImage("assets/images/cart.png"),
                  width: 20,
                  color: isDarkMode(context) ? Colors.white : null,
                ),
              ],
            ),
            onPressed: () {
              push(
                context,
                CartScreen(
                  fromContainer: false,
                ),
              );
            }),
      ],
    );
  }

  static AppBar buildSimpleAppBar(BuildContext context, String title) {
    return AppBar(
      centerTitle: false,
      elevation: 0,
      leading: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Icon(
          Icons.arrow_back_ios,
          color: Color(COLOR_PRIMARY),
        ),
      ),
      title: Text(title, style: TextStyle(fontFamily: 'Poppinssb', color: isDarkMode(context) ? Colors.white : Colors.black)).tr(),
    );
  }
}
