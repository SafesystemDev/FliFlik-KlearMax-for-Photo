import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_braintree/flutter_braintree.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe1;
import 'package:flutterwave_standard/flutterwave.dart';
import 'package:foodie_customer/model/FlutterWaveSettingDataModel.dart';
import 'package:foodie_customer/model/MercadoPagoSettingsModel.dart';
import 'package:foodie_customer/model/PayFastSettingData.dart';
import 'package:foodie_customer/model/PayPalCurrencyCodeErrorModel.dart' as payPalCurrModel;
import 'package:foodie_customer/model/PayStackSettingsModel.dart';
import 'package:foodie_customer/model/StripePayFailedModel.dart';
import 'package:foodie_customer/model/createRazorPayOrderModel.dart';
import 'package:foodie_customer/model/payStackURLModel.dart';
import 'package:foodie_customer/model/paypalErrorSettle.dart';
import 'package:foodie_customer/model/paypalPaymentSettle.dart' as payPalSettel;
import 'package:foodie_customer/model/paypalSettingData.dart';
import 'package:foodie_customer/model/paytmSettingData.dart';
import 'package:foodie_customer/model/razorpayKeyModel.dart';
import 'package:foodie_customer/model/stripeSettingData.dart';
import 'package:foodie_customer/model/topupTranHistory.dart';
import 'package:foodie_customer/services/FirebaseHelper.dart';
import 'package:foodie_customer/services/paypalclientToken.dart';
import 'package:foodie_customer/services/paystack_url_genrater.dart';
import 'package:foodie_customer/services/rozorpayConroller.dart';
import 'package:foodie_customer/ui/wallet/MercadoPagoScreen.dart';
import 'package:foodie_customer/ui/wallet/PayFastScreen.dart';
import 'package:foodie_customer/ui/wallet/payStackScreen.dart';
import 'package:http/http.dart' as http;
import 'package:mercadopago_sdk/mercadopago_sdk.dart';
import 'package:paytm_allinonesdk/paytm_allinonesdk.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../constants.dart';
import '../../main.dart';
import '../../model/OrderModel.dart';
import '../../model/User.dart';
import '../../model/getPaytmTxtToken.dart';
import '../../services/helper.dart';
import '../../userPrefrence.dart';
import '../orderDetailsScreen/OrderDetailsScreen.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({Key? key}) : super(key: key);

  @override
  WalletScreenState createState() => WalletScreenState();
}

class WalletScreenState extends State<WalletScreen> {
  static FirebaseFirestore fireStore = FirebaseFirestore.instance;
  Stream<QuerySnapshot>? topupHistoryQuery;
  Stream<DocumentSnapshot<Map<String, dynamic>>>? userQuery;

  String? selectedRadioTile;

  GlobalKey<FormState> _globalKey = GlobalKey();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Razorpay _razorPay = Razorpay();
  RazorPayModel? razorPayData;
  StripeSettingData? stripeData;
  PaytmSettingData? paytmSettingData;
  PaypalSettingData? paypalSettingData;
  PayStackSettingData? payStackSettingData;
  FlutterWaveSettingData? flutterWaveSettingData;
  PayFastSettingData? payFastSettingData;
  MercadoPagoSettingData? mercadoPagoSettingData;

  TextEditingController _amountController = TextEditingController(text: 50.toString());

  Map<String, dynamic>? paymentIntentData;

  showAlert(context, {required String response, required Color colors}) {
    return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(response),
      backgroundColor: colors,
      duration: Duration(seconds: 8),
    ));
  }

  final userId = MyAppState.currentUser!.userID;

  getPaymentSettingData() async {
    topupHistoryQuery = fireStore.collection(Wallet).where('user_id', isEqualTo: userId).orderBy('date', descending: true).snapshots();
    userQuery = fireStore.collection(USERS).doc(MyAppState.currentUser!.userID).snapshots();

    await UserPreference.getStripeData().then((value) async {
      stripeData = value;
      stripe1.Stripe.publishableKey = stripeData!.clientpublishableKey;
      stripe1.Stripe.merchantIdentifier = 'Foodie';
      await stripe1.Stripe.instance.applySettings();
    });

    razorPayData = await UserPreference.getRazorPayData();
    paytmSettingData = await UserPreference.getPaytmData();
    paypalSettingData = await UserPreference.getPayPalData();
    payStackSettingData = await UserPreference.getPayStackData();
    flutterWaveSettingData = await UserPreference.getFlutterWaveData();
    payFastSettingData = await UserPreference.getPayFastData();
    mercadoPagoSettingData = await UserPreference.getMercadoPago();
  }

  @override
  void initState() {
    setRef();
    getPaymentSettingData();
    selectedRadioTile = "Stripe";

    _razorPay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorPay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWaller);
    _razorPay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        color: Colors.black.withOpacity(0.03),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 120.0),
              child: showTopupHistory(context),
            ),
            Positioned(
              top: 0,
              child: Container(
                decoration: BoxDecoration(image: DecorationImage(fit: BoxFit.fitWidth, image: AssetImage("assets/images/wallet_background@3x.png"))),
                //color: Colors.deepOrange,
                //height: size.height*0.3,
                width: size.width,
                child: SafeArea(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 0.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Text(
                                    "Total Balance".tr(),
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 18),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10.0, bottom: 20.0),
                                    child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                                      stream: userQuery,
                                      builder: (context, AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> asyncSnapshot) {
                                        if (asyncSnapshot.hasError) {
                                          return Text(
                                            "error".tr(),
                                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 30),
                                          );
                                        }
                                        if (asyncSnapshot.connectionState == ConnectionState.waiting) {
                                          return Center(
                                              child: SizedBox(
                                                  height: 20,
                                                  width: 20,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 0.8,
                                                    color: Colors.white,
                                                    backgroundColor: Colors.transparent,
                                                  )));
                                        }
                                        User userData = User.fromJson(asyncSnapshot.data!.data()!);
                                        return Text(
                                          "${currencyData!.symbol} ${double.parse(userData.walletAmount.toString()).toStringAsFixed(decimal)}",
                                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 30),
                                        );
                                      },
                                    ),
                                  ),

                                  // Padding(
                                  //   padding: const EdgeInsets.only(top: 10.0,bottom: 20.0),
                                  //   child: Text("\$$walletAmount",
                                  //     style: TextStyle(color: Colors.white,
                                  //         fontWeight: FontWeight.bold,
                                  //         fontSize: 30),),
                                  // ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 28.0, right: 15, left: 15),
                              child: buildTopUpButton(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTopUpButton() {
    return GestureDetector(
      onTap: () {
        topUpBalance();
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 10),
          child: Text(
            "TOPUP WALLET".tr(),
            style: TextStyle(color: Color(COLOR_PRIMARY), fontWeight: FontWeight.w700, fontSize: 16),
          ),
        ),
      ),
    );
  }

  Widget showTopupHistory(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: topupHistoryQuery,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Something went wrong'.tr()));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: SizedBox(height: 35, width: 35, child: CircularProgressIndicator()));
        }
        if (snapshot.data!.docs.isEmpty) {
          return Center(
              child: Text(
            "No Transaction History".tr(),
            style: TextStyle(fontSize: 18),
          ));
        } else {
          return ListView(
            physics: BouncingScrollPhysics(),
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              final topUpData = TopupTranHistoryModel.fromJson(document.data() as Map<String, dynamic>);
              //Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
              return buildTransactionCard(
                topupTranHistory: topUpData,
                date: topUpData.date.toDate(),
              );
            }).toList(),
          );
        }
      },
    );
  }

  Widget buildTransaction(BuildContext context) {
    return FutureBuilder<List<TopupTranHistoryModel>>(
        future: FireStoreUtils.getTopUpTransaction(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
                physics: BouncingScrollPhysics(),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  List<TopupTranHistoryModel>? tranHistoryModel = snapshot.data;
                  return buildTransactionCard(
                    topupTranHistory: tranHistoryModel![index],
                    date: tranHistoryModel[index].date.toDate(),
                  );
                });
          } else {
            return Center(child: SizedBox(height: 45, width: 45, child: CircularProgressIndicator()));
          }
        });
  }

  Widget buildTransactionCard({
    required TopupTranHistoryModel topupTranHistory,
    required DateTime date,
  }) {
    final size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 3),
      child: GestureDetector(
        onTap: () => showTransactionDetails(topupTranHistory: topupTranHistory),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipOval(
                  child: Container(
                    color: Color(COLOR_PRIMARY).withOpacity(0.06),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Icon(Icons.account_balance_wallet_rounded, size: 28, color: Color(COLOR_PRIMARY)),
                    ),
                  ),
                ),
                SizedBox(
                  width: size.width * 0.78,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: size.width * 0.48,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              topupTranHistory.isTopup ? "Wallet Topup".tr() : "Wallet Amount Deducted".tr(),
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Opacity(
                              opacity: 0.65,
                              child: Text(
                                "${DateFormat('KK:mm:ss a, dd MMM yyyy').format(topupTranHistory.date.toDate()).toUpperCase()}",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 4.0, left: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "${topupTranHistory.isTopup ? "+" : "-"} ${currencyData!.symbol}${double.parse(topupTranHistory.amount.toString()).toStringAsFixed(decimal)}",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: topupTranHistory.isTopup ? Colors.green : Colors.red,
                                fontSize: 18,
                              ),
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 15,
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  showLoadingAlert() {
    return showDialog<void>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CircularProgressIndicator(),
              const Text('Please wait!!').tr(),
            ],
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                SizedBox(
                  height: 15,
                ),
                Text(
                  'Please wait!! while completing Transaction'.tr(),
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(
                  height: 15,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  showTransactionDetails({
    required TopupTranHistoryModel topupTranHistory,
  }) {
    final size = MediaQuery.of(context).size;
    return showModalBottomSheet(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15))),
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Container(
              height: size.height * 0.80,
              width: size.width,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 25.0),
                      child: Text(
                        "Transaction Details".tr(),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15.0,
                      ),
                      child: Card(
                        elevation: 1.5,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Transaction ID".tr(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Opacity(
                                    opacity: 0.8,
                                    child: Text(
                                      topupTranHistory.id,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 30),
                        child: Card(
                          elevation: 1.5,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ClipOval(
                                  child: Container(
                                    color: Color(COLOR_PRIMARY).withOpacity(0.05),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Icon(Icons.account_balance_wallet_rounded, size: 28, color: Color(COLOR_PRIMARY)),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: size.width * 0.48,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${DateFormat('KK:mm:ss a, dd MMM yyyy').format(topupTranHistory.date.toDate())}",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Opacity(
                                        opacity: 0.7,
                                        child: Text(
                                          topupTranHistory.isTopup ? "Wallet Topup".tr() : "Wallet Amount Deducted".tr(),
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      "${topupTranHistory.isTopup ? "+" : "-"} ${currencyData!.symbol}${double.parse(topupTranHistory.amount.toString()).toStringAsFixed(decimal)}",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: topupTranHistory.isTopup ? Colors.green : Colors.red,
                                        fontSize: 18,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 8,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        )),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Payment Details".tr(),
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        children: [
                                          Opacity(
                                            opacity: 0.7,
                                            child: Text(
                                              "Pay Via".tr(),
                                              style: TextStyle(
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                          Visibility(
                                            visible: !topupTranHistory.isTopup,
                                            child: Text(
                                              "  " + topupTranHistory.paymentMethod.toUpperCase(),
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: Color(COLOR_PRIMARY),
                                                fontSize: 16,
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      if (!topupTranHistory.isTopup) {
                                        FireStoreUtils.firestore.collection(ORDERS).doc(topupTranHistory.orderId).get().then((value) {
                                          OrderModel orderModel = OrderModel.fromJson(value.data()!);
                                          push(
                                              context,
                                              OrderDetailsScreen(
                                                orderModel: orderModel,
                                              ));
                                        });
                                      }
                                    },
                                    child: Text(
                                      topupTranHistory.isTopup ? topupTranHistory.paymentMethod.toUpperCase() : "View Order".tr().toUpperCase(),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Color(COLOR_PRIMARY),
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 15),
                              child: Divider(),
                            ),
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 8),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Date in UTC Format".tr(),
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Opacity(
                                        opacity: 0.7,
                                        child: Text(
                                          "${DateFormat('KK:mm:ss a, dd MMM yyyy').format(topupTranHistory.date.toDate()).toUpperCase()}",
                                          style: TextStyle(
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          });
        });
  }

  topUpBalance() {
    final size = MediaQuery.of(context).size;
    return showModalBottomSheet(
        elevation: 5,
        enableDrag: true,
        useRootNavigator: true,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15))),
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) => Container(
              //height: size.height * 0.85,
              width: size.width,
              height: size.height * 0.95,
              child: Form(
                key: _globalKey,
                autovalidateMode: AutovalidateMode.always,
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15.0,
                              ),
                              child: RichText(
                                text: TextSpan(
                                  text: "Topup Wallet".tr(),
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: isDarkMode(context) ? Colors.white : Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5),
                            child: RichText(
                              text: TextSpan(
                                text: "Add Topup Amount".tr(),
                                style: TextStyle(fontSize: 16, color: isDarkMode(context) ? Colors.white54 : Colors.black54),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 2),
                        child: Card(
                          elevation: 2.0,
                          color: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 8),
                            child: TextFormField(
                              controller: _amountController,
                              style: TextStyle(
                                color: Color(COLOR_PRIMARY),
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                              //initialValue:"50",
                              maxLines: 1,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "*required Field".tr();
                                } else {
                                  return null;
                                }
                              },
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                prefix: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 2),
                                  child: Text(
                                    currencyData!.symbol.toString(),
                                    style: TextStyle(
                                      color: Colors.blueGrey.shade900,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5),
                            child: RichText(
                              text: TextSpan(
                                text: "Select Payment Option".tr(),
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: isDarkMode(context) ? Colors.white : Colors.black,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Visibility(
                        visible: stripeData!.isEnabled,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 20),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: stripe ? 0 : 2,
                            child: RadioListTile(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: stripe ? Color(COLOR_PRIMARY) : Colors.transparent)),
                              controlAffinity: ListTileControlAffinity.trailing,
                              value: "Stripe",
                              groupValue: selectedRadioTile,
                              onChanged: (String? value) {
                                setState(() {
                                  flutterWave = false;
                                  stripe = true;
                                  mercadoPago = false;
                                  payFast = false;
                                  payStack = false;
                                  razorPay = false;
                                  payTm = false;
                                  paypal = false;
                                  selectedRadioTile = value!;
                                });
                              },
                              selected: stripe,
                              //selectedRadioTile == "strip" ? true : false,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                      decoration: BoxDecoration(
                                        color: Colors.blueGrey.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 10),
                                        child: SizedBox(
                                          width: 80,
                                          height: 35,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                                            child: Image.asset(
                                              "assets/images/stripe.png",
                                            ),
                                          ),
                                        ),
                                      )),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Text("Stripe"),
                                ],
                              ),
                              //toggleable: true,
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: payStackSettingData!.isEnabled,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 20),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: payStack ? 0 : 2,
                            child: RadioListTile(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: payStack ? Color(COLOR_PRIMARY) : Colors.transparent)),
                              controlAffinity: ListTileControlAffinity.trailing,
                              value: "PayStack",
                              groupValue: selectedRadioTile,
                              onChanged: (String? value) {
                                setState(() {
                                  flutterWave = false;
                                  payStack = true;
                                  mercadoPago = false;
                                  stripe = false;
                                  payFast = false;
                                  razorPay = false;
                                  payTm = false;
                                  paypal = false;
                                  selectedRadioTile = value!;
                                });
                              },
                              selected: payStack,
                              //selectedRadioTile == "strip" ? true : false,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                      decoration: BoxDecoration(
                                        color: Colors.blueGrey.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 10),
                                        child: SizedBox(
                                          width: 80,
                                          height: 35,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                                            child: Image.asset(
                                              "assets/images/paystack.png",
                                            ),
                                          ),
                                        ),
                                      )),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Text("PayStack"),
                                ],
                              ),
                              //toggleable: true,
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible:flutterWaveSettingData != null &&  flutterWaveSettingData!.isEnable,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 20),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: flutterWave ? 0 : 2,
                            child: RadioListTile(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: flutterWave ? Color(COLOR_PRIMARY) : Colors.transparent)),
                              controlAffinity: ListTileControlAffinity.trailing,
                              value: "FlutterWave",
                              groupValue: selectedRadioTile,
                              onChanged: (String? value) {
                                setState(() {
                                  flutterWave = true;
                                  payStack = false;
                                  mercadoPago = false;
                                  payFast = false;
                                  stripe = false;
                                  razorPay = false;
                                  payTm = false;
                                  paypal = false;
                                  selectedRadioTile = value!;
                                });
                              },
                              selected: flutterWave,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                      decoration: BoxDecoration(
                                        color: Colors.blueGrey.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 10),
                                        child: SizedBox(
                                          width: 80,
                                          height: 35,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                                            child: Image.asset(
                                              "assets/images/flutterwave.png",
                                            ),
                                          ),
                                        ),
                                      )),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Text("FlutterWave"),
                                ],
                              ),
                              //toggleable: true,
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: razorPayData!.isEnabled,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 20),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: razorPay ? 0 : 2,
                            child: RadioListTile(
                              //toggleable: true,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: razorPay ? Color(COLOR_PRIMARY) : Colors.transparent)),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                              controlAffinity: ListTileControlAffinity.trailing,
                              value: "RazorPay",
                              groupValue: selectedRadioTile,
                              onChanged: (String? value) {
                                setState(() {
                                  mercadoPago = false;
                                  flutterWave = false;
                                  stripe = false;
                                  razorPay = true;
                                  payTm = false;
                                  payFast = false;
                                  paypal = false;
                                  payStack = false;
                                  selectedRadioTile = value!;
                                });
                              },
                              selected: razorPay,
                              //selectedRadioTile == "strip" ? true : false,
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                      decoration: BoxDecoration(
                                        color: Colors.blueGrey.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 10),
                                        child: SizedBox(width: 80, height: 35, child: Image.asset("assets/images/razorpay_@3x.png")),
                                      )),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Text("RazorPay"),
                                ],
                              ),
                              //toggleable: true,
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: payFastSettingData != null && payFastSettingData!.isEnable,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 20),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: payFast ? 0 : 2,
                            child: RadioListTile(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: payFast ? Color(COLOR_PRIMARY) : Colors.transparent)),
                              controlAffinity: ListTileControlAffinity.trailing,
                              value: "payFast",
                              groupValue: selectedRadioTile,
                              onChanged: (String? value) {
                                setState(() {
                                  payFast = true;
                                  stripe = false;
                                  mercadoPago = false;
                                  razorPay = false;
                                  payStack = false;
                                  flutterWave = false;
                                  payTm = false;
                                  paypal = false;
                                  selectedRadioTile = value!;
                                });
                              },
                              selected: payFast,
                              //selectedRadioTile == "strip" ? true : false,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                      decoration: BoxDecoration(
                                        color: Colors.blueGrey.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 10),
                                        child: SizedBox(
                                          width: 80,
                                          height: 35,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                                            child: Image.asset(
                                              "assets/images/payfast.png",
                                            ),
                                          ),
                                        ),
                                      )),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Text("Pay Fast"),
                                ],
                              ),
                              //toggleable: true,
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: paytmSettingData!.isEnabled,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 20),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: payTm ? 0 : 2,
                            child: RadioListTile(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: payTm ? Color(COLOR_PRIMARY) : Colors.transparent)),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                              controlAffinity: ListTileControlAffinity.trailing,
                              value: "PayTm",
                              groupValue: selectedRadioTile,
                              onChanged: (String? value) {
                                setState(() {
                                  stripe = false;
                                  flutterWave = false;
                                  payTm = true;
                                  mercadoPago = false;
                                  razorPay = false;
                                  paypal = false;
                                  payFast = false;
                                  payStack = false;
                                  selectedRadioTile = value!;
                                });
                              },
                              selected: payTm,
                              //selectedRadioTile == "strip" ? true : false,
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                      decoration: BoxDecoration(
                                        color: Colors.blueGrey.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 10),
                                        child: SizedBox(
                                            width: 80,
                                            height: 35,
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 3.0),
                                              child: Image.asset(
                                                "assets/images/paytm_@3x.png",
                                              ),
                                            )),
                                      )),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Text("Paytm"),
                                ],
                              ),
                              //toggleable: true,
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: mercadoPagoSettingData != null && mercadoPagoSettingData!.isEnabled,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 20),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: mercadoPago ? 0 : 2,
                            child: RadioListTile(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: mercadoPago ? Color(COLOR_PRIMARY) : Colors.transparent)),
                              controlAffinity: ListTileControlAffinity.trailing,
                              value: "MercadoPago",
                              groupValue: selectedRadioTile,
                              onChanged: (String? value) {
                                setState(() {
                                  mercadoPago = true;
                                  payFast = false;
                                  stripe = false;
                                  razorPay = false;
                                  payStack = false;
                                  flutterWave = false;
                                  payTm = false;
                                  paypal = false;
                                  selectedRadioTile = value!;
                                });
                              },
                              selected: mercadoPago,
                              //selectedRadioTile == "strip" ? true : false,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                      decoration: BoxDecoration(
                                        color: Colors.blueGrey.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 10),
                                        child: SizedBox(
                                          width: 80,
                                          height: 35,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                                            child: Image.asset(
                                              "assets/images/mercadopago.png",
                                            ),
                                          ),
                                        ),
                                      )),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Text("Mercado Pago"),
                                ],
                              ),
                              //toggleable: true,
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: paypalSettingData != null && paypalSettingData!.isEnabled,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 20),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: paypal ? 0 : 2,
                            child: RadioListTile(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: paypal ? Color(COLOR_PRIMARY) : Colors.transparent)),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                              controlAffinity: ListTileControlAffinity.trailing,
                              value: "PayPal",
                              groupValue: selectedRadioTile,
                              onChanged: (String? value) {
                                setState(() {
                                  stripe = false;
                                  payTm = false;
                                  mercadoPago = false;
                                  flutterWave = false;
                                  razorPay = false;
                                  paypal = true;
                                  payFast = false;
                                  payStack = false;
                                  selectedRadioTile = value!;
                                });
                              },
                              selected: paypal,
                              //selectedRadioTile == "strip" ? true : false,
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                      decoration: BoxDecoration(
                                        color: Colors.blueGrey.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 10),
                                        child: SizedBox(
                                            width: 80,
                                            height: 35,
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 3.0),
                                              child: Image.asset("assets/images/paypal_@3x.png"),
                                            )),
                                      )),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Text("PayPal"),
                                ],
                              ),
                              //toggleable: true,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 22),
                        child: GestureDetector(
                          onTap: () async {
                            await FireStoreUtils.createPaymentId();

                            if (selectedRadioTile == "Stripe" && stripeData?.isEnabled == true) {
                              Navigator.pop(context);
                              showLoadingAlert();
                              stripeMakePayment(amount: _amountController.text);
                              //push(context, CardDetailsScreen(paymentMode: selectedRadioTile,),);
                            } else if (selectedRadioTile == "MercadoPago") {
                              Navigator.pop(context);
                              showLoadingAlert();
                              mercadoPagoMakePayment();
                            } else if (selectedRadioTile == "payFast") {
                              showLoadingAlert();
                              PayStackURLGen.getPayHTML(payFastSettingData: payFastSettingData!, amount: _amountController.text).then((value) async {
                                bool isDone = await Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => PayFastScreen(
                                          htmlData: value,
                                          payFastSettingData: payFastSettingData!,
                                        )));
                                if (isDone) {
                                  Navigator.pop(context);
                                  FireStoreUtils.createPaymentId().then((value) {
                                    final paymentID = value;
                                    FireStoreUtils.topUpWalletAmount(paymentMethod: "PayFast", amount: double.parse(_amountController.text), id: paymentID).then((value) {
                                      FireStoreUtils.updateWalletAmount(amount: double.parse(_amountController.text)).then((value) {
                                        Navigator.pop(context);
                                      });
                                    });
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    content: Text(
                                      "Payment Successful!!".tr() + "\n",
                                    ),
                                    backgroundColor: Colors.green.shade400,
                                    duration: Duration(seconds: 6),
                                  ));
                                } else {
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    content: Text(
                                      "Payment Unsuccessful!!".tr() + "\n",
                                    ),
                                    backgroundColor: Colors.red.shade400,
                                    duration: Duration(seconds: 6),
                                  ));
                                }
                              });
                            } else if (selectedRadioTile == "RazorPay") {
                              Navigator.pop(context);
                              showLoadingAlert();
                              RazorPayController().createOrderRazorPay(isTopup: true, amount: int.parse(_amountController.text)).then((value) {
                                if (value != null) {
                                  CreateRazorPayOrderModel result = value;

                                  openCheckout(
                                    amount: _amountController.text,
                                    orderId: result.id,
                                  );
                                } else {
                                  Navigator.pop(context);
                                  showAlert(_globalKey.currentContext!, response: "Something went wrong, please contact admin.".tr(), colors: Colors.red);
                                }
                              });
                            } else if (selectedRadioTile == "PayTm") {
                              Navigator.pop(context);
                              showLoadingAlert();
                              getPaytmCheckSum(context, amount: double.parse(_amountController.text));
                            } else if (selectedRadioTile == "PayPal") {
                              Navigator.pop(context);
                              showLoadingAlert();
                              _paypalPayment();
                            } else if (selectedRadioTile == "PayStack") {
                              Navigator.pop(context);
                              showLoadingAlert();
                              payStackPayment();
                            } else if (selectedRadioTile == "FlutterWave") {
                              _flutterWaveInitiatePayment(context);
                            }
                          },
                          child: Container(
                            height: 45,
                            decoration: BoxDecoration(
                              color: Color(COLOR_PRIMARY),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                                child: Text(
                              "CONTINUE".tr(),
                              style: TextStyle(color: Colors.white),
                            )),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  buildPaymentCard({required image, PaymentOptionString value = PaymentOptionString.Stripe, required String title}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 20),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: paypal ? 0 : 2,
        child: RadioListTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: paypal ? Color(COLOR_PRIMARY) : Colors.transparent)),
          contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          controlAffinity: ListTileControlAffinity.trailing,
          value: "",
          groupValue: selectedRadioTile,
          onChanged: (String? value) {
            setState(() {
              stripe = false;
              payTm = false;
              razorPay = false;
              paypal = true;
              payFast = false;
              selectedRadioTile = value!;
            });
          },
          selected: paypal,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 10),
                    child: SizedBox(width: 80, height: 40, child: Image.asset(image)),
                  )),
              SizedBox(
                width: 20,
              ),
              Text(title),
            ],
          ),
        ),
      ),
    );
  }

  bool stripe = true;

  bool razorPay = false;
  bool payTm = false;
  bool paypal = false;
  bool payStack = false;
  bool flutterWave = false;
  bool payFast = false;
  bool mercadoPago = false;

  ///
  ///
  ///

  /// RazorPay Payment Gateway
  void openCheckout({required amount, required orderId}) async {
    var options = {
      'key': razorPayData!.razorpayKey,
      'amount': amount * 100,
      'name': 'Foodies',
      'order_id': orderId,
      "currency": currencyData?.code,
      'description': 'wallet Topup',
      'retry': {'enabled': true, 'max_count': 1},
      'send_sms_hash': true,
      'prefill': {
        'contact': MyAppState.currentUser!.phoneNumber,
        'email': MyAppState.currentUser!.email,
      },
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorPay.open(options);
    } catch (e) {
      debugPrint('error'.tr() + ': $e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    FireStoreUtils.createPaymentId().then((value) {
      final paymentID = value;
      FireStoreUtils.topUpWalletAmount(paymentMethod: "RazorPay", amount: double.parse(_amountController.text), id: paymentID).then((value) {
        FireStoreUtils.updateWalletAmount(amount: double.parse(_amountController.text)).then((value) {
          Navigator.pop(context);
        });
      });
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        "Payment Successful!!".tr() + "\n" + response.orderId!,
      ),
      backgroundColor: Colors.green.shade400,
      duration: Duration(seconds: 6),
    ));
  }

  void _handleExternalWaller(ExternalWalletResponse response) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        "Payment Processing Via".tr() + "\n" + response.walletName!,
      ),
      backgroundColor: Colors.blue.shade400,
      duration: Duration(seconds: 8),
    ));
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        "Payment Failed!!".tr() + "\n" + jsonDecode(response.message!)['error']['description'],
      ),
      backgroundColor: Colors.red.shade400,
      duration: Duration(seconds: 8),
    ));
  }

  /// PayPal Payment Gateway
  _paypalPayment() async {
    PayPalClientTokenGen.paypalClientToken(paypalSettingData: paypalSettingData!).then((value) async {
      final String tokenizationKey = paypalSettingData!.braintreeTokenizationKey; //"sandbox_w3dpbsks_5whrtf2sbrp4vx74";

      var request = BraintreePayPalRequest(amount: _amountController.text, currencyCode: currencyData!.code, billingAgreementDescription: "djsghxghf", displayName: 'Foodies company');
      BraintreePaymentMethodNonce? resultData;
      try {
        resultData = await Braintree.requestPaypalNonce(tokenizationKey, request);
      } on Exception catch (ex) {
        print("Stripe error");
        showAlert(_globalKey.currentContext!, response: "Something went wrong, please contact admin.".tr() + " $ex", colors: Colors.red);
      }
      print(resultData?.nonce);
      print(resultData?.paypalPayerId);
      if (resultData?.nonce != null) {
        PayPalClientTokenGen.paypalSettleAmount(
          paypalSettingData: paypalSettingData!,
          nonceFromTheClient: resultData?.nonce,
          amount: _amountController.text,
          deviceDataFromTheClient: resultData?.typeLabel,
        ).then((value) {
          if (value['success'] == "true" || value['success'] == true) {
            if (value['data']['success'] == "true" || value['data']['success'] == true) {
              payPalSettel.PayPalClientSettleModel settleResult = payPalSettel.PayPalClientSettleModel.fromJson(value);
              if (settleResult.data.success) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(
                    "Status : ${settleResult.data.transaction.status}\n"
                    "Transaction id : ${settleResult.data.transaction.id}\n"
                    "Amount : ${settleResult.data.transaction.amount}",
                  ),
                  duration: Duration(seconds: 8),
                  backgroundColor: Colors.green,
                ));

                FireStoreUtils.createPaymentId().then((value) {
                  final paymentID = value;
                  FireStoreUtils.topUpWalletAmount(paymentMethod: "Paypal", amount: double.parse(_amountController.text), id: paymentID).then((value) {
                    FireStoreUtils.updateWalletAmount(amount: double.parse(_amountController.text)).then((value) {});
                  });
                });
              }
            } else {
              payPalCurrModel.PayPalCurrencyCodeErrorModel settleResult = payPalCurrModel.PayPalCurrencyCodeErrorModel.fromJson(value);
              Navigator.pop(_scaffoldKey.currentContext!);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text("Status :".tr() + " ${settleResult.data.message}"),
                duration: Duration(seconds: 8),
                backgroundColor: Colors.red,
              ));
            }
          } else {
            PayPalErrorSettleModel settleResult = PayPalErrorSettleModel.fromJson(value);
            Navigator.pop(_scaffoldKey.currentContext!);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("Status :".tr() + " ${settleResult.data.message}"),
              duration: Duration(seconds: 8),
              backgroundColor: Colors.red,
            ));
          }
        });
      } else {
        Navigator.pop(_scaffoldKey.currentContext!);
        ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(SnackBar(
          content: Text('Status : Payment Incomplete!!'.tr()),
          duration: Duration(seconds: 8),
          backgroundColor: Colors.red,
        ));
      }
    });
  }

  void showNonce(BraintreePaymentMethodNonce nonce) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Payment method nonce:'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text('Nonce: ${nonce.nonce}'),
            SizedBox(height: 16),
            Text('Type label: ${nonce.paypalPayerId}'),
            SizedBox(height: 16),
            Text('Type label: ${nonce.typeLabel}'),
            SizedBox(height: 16),
            Text('Description: ${nonce.description}'),
          ],
        ),
      ),
    );
  }

  /// Stripe Payment Gateway
  Future<void> stripeMakePayment({required String amount}) async {
    try {
      paymentIntentData = await createStripeIntent(
        amount,
      );
      if (paymentIntentData!.containsKey("error")) {
        Navigator.pop(context);
        showAlert(_scaffoldKey.currentContext, response: "Something went wrong, please contact admin.".tr(), colors: Colors.red);
      } else {
        await stripe1.Stripe.instance
            .initPaymentSheet(
                paymentSheetParameters: stripe1.SetupPaymentSheetParameters(
              paymentIntentClientSecret: paymentIntentData!['client_secret'],
              applePay: const stripe1.PaymentSheetApplePay(
                merchantCountryCode: 'US',
              ),
              allowsDelayedPaymentMethods: false,
              googlePay: stripe1.PaymentSheetGooglePay(
                merchantCountryCode: 'US',
                testEnv: true,
                currencyCode: currencyData!.code,
              ),
              style: ThemeMode.system,
              appearance: stripe1.PaymentSheetAppearance(
                colors: stripe1.PaymentSheetAppearanceColors(
                  primary: Color(COLOR_PRIMARY),
                ),
              ),
              merchantDisplayName: 'Emart',
            ))
            .then((value) {});
        setState(() {});
        displayStripePaymentSheet();
      }
    } catch (e, s) {
      print('exception:$e$s');
    }
  }

  displayStripePaymentSheet() async {
    try {
      await stripe1.Stripe.instance.presentPaymentSheet().then((value) {
        FireStoreUtils.createPaymentId().then((value) {
          final paymentID = value;
          FireStoreUtils.topUpWalletAmount(paymentMethod: "Stripe", amount: double.parse(_amountController.text), id: paymentID).then((value) {
            FireStoreUtils.updateWalletAmount(amount: double.parse(_amountController.text)).then((value) {});
          });
        });
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Payment Successful!!".tr()),
          duration: Duration(seconds: 8),
          backgroundColor: Colors.green,
        ));
        paymentIntentData = null;
      });
    } on stripe1.StripeException catch (e) {
      Navigator.pop(context);
      var lo1 = jsonEncode(e);
      var lo2 = jsonDecode(lo1);
      StripePayFailedModel lom = StripePayFailedModel.fromJson(lo2);
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
                content: Text("${lom.error.message}"),
              ));
    } catch (e) {
      print('$e');
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("$e"),
        duration: Duration(seconds: 8),
        backgroundColor: Colors.red,
      ));
    }
  }

  createStripeIntent(
    String amount,
  ) async {
    try {
      Map<String, dynamic> body = {
        'amount': calculateAmount(amount),
        'currency': currencyData!.code,
        'payment_method_types[0]': 'card',
        // 'payment_method_types[1]': 'ideal',
        "description": "${MyAppState.currentUser?.userID} Wallet Topup",
        "shipping[name]": "${MyAppState.currentUser?.firstName} ${MyAppState.currentUser?.lastName}",
        "shipping[address][line1]": "510 Townsend St",
        "shipping[address][postal_code]": "98140",
        "shipping[address][city]": "San Francisco",
        "shipping[address][state]": "CA",
        "shipping[address][country]": "US",
      };
      var response = await http.post(Uri.parse('https://api.stripe.com/v1/payment_intents'), body: body, headers: {
        'Authorization': 'Bearer ${stripeData?.stripeSecret}',
        //$_paymentIntentClientSecret',
        'Content-Type': 'application/x-www-form-urlencoded'
      });
      return jsonDecode(response.body);
    } catch (err) {
      print('error charging user: ${err.toString()}');
    }
  }

  calculateAmount(String amount) {
    final a = (int.parse(amount)) * 100;
    return a.toString();
  }

  /// Paytm Payment Gateway
  bool isStaging = true;
  String callbackUrl = "http://162.241.125.167/~foodie/payments/paytmpaymentcallback?ORDER_ID=";
  bool restrictAppInvoke = false;
  bool enableAssist = true;
  String result = "";

  getPaytmCheckSum(
    context, {
    required double amount,
  }) async {
    final String orderId = UserPreference.getPaymentId();
    String getChecksum = "${GlobalURL}payments/getpaytmchecksum";

    final response = await http.post(
        Uri.parse(
          getChecksum,
        ),
        headers: {},
        body: {
          "mid": paytmSettingData?.paytmMID,
          "order_id": orderId,
          "key_secret": paytmSettingData?.paytmMerchantKey,
        });

    final data = jsonDecode(response.body);

    await verifyCheckSum(checkSum: data["code"], amount: amount, orderId: orderId).then((value) {
      initiatePayment(context, amount: amount, orderId: orderId).then((value) {
        GetPaymentTxtTokenModel result = value;
        String callback = "";
        if (paytmSettingData!.isSandboxEnabled) {
          callback = callback + "https://securegw-stage.paytm.in/theia/paytmCallback?ORDER_ID=$orderId";
        } else {
          callback = callback + "https://securegw.paytm.in/theia/paytmCallback?ORDER_ID=$orderId";
        }

        _startTransaction(
          context,
          txnTokenBy: result.body.txnToken,
          orderId: orderId,
          amount: amount,
        );
      });
    });
  }

  Future verifyCheckSum({required String checkSum, required double amount, required orderId}) async {
    String getChecksum = "${GlobalURL}payments/validatechecksum";
    final response = await http.post(
        Uri.parse(
          getChecksum,
        ),
        headers: {},
        body: {
          "mid": paytmSettingData?.paytmMID,
          "order_id": orderId,
          "key_secret": paytmSettingData?.paytmMerchantKey,
          "checksum_value": checkSum,
        });
    final data = jsonDecode(response.body);
    return data['status'];
  }

  Future<GetPaymentTxtTokenModel> initiatePayment(BuildContext context, {required double amount, required orderId}) async {
    String initiateURL = "${GlobalURL}payments/initiatepaytmpayment";
    String callback = "";
    if (paytmSettingData!.isSandboxEnabled) {
      callback = callback + "https://securegw-stage.paytm.in/theia/paytmCallback?ORDER_ID=$orderId";
    } else {
      callback = callback + "https://securegw.paytm.in/theia/paytmCallback?ORDER_ID=$orderId";
    }
    final response = await http.post(
        Uri.parse(
          initiateURL,
        ),
        headers: {},
        body: {
          "mid": paytmSettingData?.paytmMID,
          "order_id": orderId,
          "key_secret": paytmSettingData?.paytmMerchantKey.toString(),
          "amount": amount.toString(),
          "currency": currencyData!.code,
          "callback_url": callback,
          "custId": MyAppState.currentUser!.userID,
          "issandbox": paytmSettingData!.isSandboxEnabled ? "1" : "2",
        });
    final data = jsonDecode(response.body);
    if (data["body"]["txnToken"] == null || data["body"]["txnToken"].toString().isEmpty) {
      Navigator.pop(_scaffoldKey.currentContext!);
      showAlert(_scaffoldKey.currentContext!, response: "something went wrong, please contact admin.".tr(), colors: Colors.red);
    }
    return GetPaymentTxtTokenModel.fromJson(data);
  }

  Future<void> _startTransaction(
    context, {
    required String txnTokenBy,
    required orderId,
    required double amount,
  }) async {
    try {
      var response = AllInOneSdk.startTransaction(
        paytmSettingData!.paytmMID,
        orderId,
        amount.toString(),
        txnTokenBy,
        "https://securegw-stage.paytm.in/theia/paytmCallback?ORDER_ID=$orderId",
        isStaging,
        true,
        enableAssist,
      );

      response.then((value) {
        if (value!["RESPMSG"] == "Txn Success") {
          FireStoreUtils.createPaymentId().then((value) {
            final paymentID = value;
            FireStoreUtils.topUpWalletAmount(paymentMethod: "Paytm", amount: double.parse(_amountController.text), id: paymentID).then((value) {
              FireStoreUtils.updateWalletAmount(amount: double.parse(_amountController.text)).whenComplete(() {
                Navigator.pop(_scaffoldKey.currentContext!);
                ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(SnackBar(
                  content: Text("Payment Successful!!".tr() + "\n"),
                  backgroundColor: Colors.green,
                ));
              });
            });
          });
        }
      }).catchError((onError) {
        if (onError is PlatformException) {
          Navigator.pop(_scaffoldKey.currentContext!);

          result = onError.message.toString() + " \n  " + onError.code.toString();
          showAlert(_scaffoldKey.currentContext!, response: onError.message.toString(), colors: Colors.red);
        } else {
          result = onError.toString();
          Navigator.pop(_scaffoldKey.currentContext!);
          showAlert(_scaffoldKey.currentContext!, response: result, colors: Colors.red);
        }
      });
    } catch (err) {
      result = err.toString();
      Navigator.pop(_scaffoldKey.currentContext!);
      showAlert(_scaffoldKey.currentContext!, response: result, colors: Colors.red);
    }
  }

  ///PayStack Payment Method
  payStackPayment() async {
    await PayStackURLGen.payStackURLGen(
      amount: (double.parse(_amountController.text) * 100).toString(),
      currency: currencyData!.code,
      secretKey: payStackSettingData!.secretKey,
    ).then((value) async {
      if (value != null) {
        PayStackUrlModel _payStackModel = value;
        bool isDone = await Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => PayStackScreen(
                  secretKey: payStackSettingData!.secretKey,
                  callBackUrl: payStackSettingData!.callbackURL,
                  initialURl: _payStackModel.data.authorizationUrl,
                  amount: _amountController.text,
                  reference: _payStackModel.data.reference,
                )));
        Navigator.pop(_scaffoldKey.currentContext!);

        if (isDone) {
          FireStoreUtils.createPaymentId().then((value) {
            final paymentID = value;
            FireStoreUtils.topUpWalletAmount(paymentMethod: "PayStack", amount: double.parse(_amountController.text), id: paymentID).then((value) {
              FireStoreUtils.updateWalletAmount(amount: double.parse(_amountController.text)).whenComplete(() {});
            });
          });
          ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(SnackBar(
            content: Text("Payment Successful!!".tr() + "\n"),
            backgroundColor: Colors.green,
          ));
        } else {
          hideProgress();
          ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(SnackBar(
            content: Text("Payment UnSuccessful!!".tr() + "\n"),
            backgroundColor: Colors.red,
          ));
        }
      } else {
        hideProgress();

        ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(SnackBar(
          content: Text("Error while transaction!".tr() + "\n"),
          backgroundColor: Colors.red,
        ));
      }
    });
  }

  ///MercadoPago Payment Method

  mercadoPagoMakePayment() {
    makePreference().then((result) async {
      if (result.isNotEmpty) {
        var preferenceId = result['response']['id'];

        final bool isDone = await Navigator.push(context, MaterialPageRoute(builder: (context) => MercadoPagoScreen(initialURl: result['response']['init_point'])));
        print(isDone);
        print(result.toString());
        print(preferenceId);

        if (isDone) {
          FireStoreUtils.createPaymentId().then((value) {
            final paymentID = value;
            FireStoreUtils.topUpWalletAmount(paymentMethod: "Mercado Pago", amount: double.parse(_amountController.text), id: paymentID).then((value) {
              FireStoreUtils.updateWalletAmount(amount: double.parse(_amountController.text)).whenComplete(() {
                Navigator.pop(_scaffoldKey.currentContext!);
              });
            });
          });
          ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(SnackBar(
            content: Text("Payment Successful!!".tr() + "\n"),
            backgroundColor: Colors.green,
          ));
        } else {
          Navigator.pop(_scaffoldKey.currentContext!);
          ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(SnackBar(
            content: Text("Payment UnSuccessful!!".tr() + "\n"),
            backgroundColor: Colors.red,
          ));
        }
      } else {
        hideProgress();

        ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(SnackBar(
          content: Text("Error while transaction!".tr() + "\n"),
          backgroundColor: Colors.red,
        ));
      }
    });
  }

  Future<Map<String, dynamic>> makePreference() async {
    final mp = MP.fromAccessToken(mercadoPagoSettingData!.accessToken);
    var pref = {
      "items": [
        {"title": "Wallet TopUp", "quantity": 1, "unit_price": double.parse(_amountController.text)}
      ],
      "auto_return": "all",
      "back_urls": {"failure": "${GlobalURL}payment/failure", "pending": "${GlobalURL}payment/pending", "success": "${GlobalURL}payment/success"},
    };

    var result = await mp.createPreference(pref);
    return result;
  }

  ///FlutterWave Payment Method
  String? _ref;

  setRef() {
    Random numRef = Random();
    int year = DateTime.now().year;
    int refNumber = numRef.nextInt(20000);
    if (Platform.isAndroid) {
      setState(() {
        _ref = "AndroidRef$year$refNumber";
      });
    } else if (Platform.isIOS) {
      setState(() {
        _ref = "IOSRef$year$refNumber";
      });
    }
  }

  _flutterWaveInitiatePayment(
    BuildContext context,
  ) async {
    final style = FlutterwaveStyle(
      appBarText: "Foodies",
      buttonColor: Color(COLOR_PRIMARY),
      buttonTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
      ),
      appBarColor: Color(COLOR_PRIMARY),
      dialogCancelTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 18,
      ),
      dialogContinueTextStyle: TextStyle(
        color: Color(COLOR_PRIMARY),
        fontSize: 18,
      ),
      mainTextStyle: TextStyle(color: Colors.black, fontSize: 19, letterSpacing: 2),
      dialogBackgroundColor: Colors.white,
      appBarTitleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 18,
      ),
    );
    final flutterwave = Flutterwave(
      amount: _amountController.text.toString().trim(),
      currency: currencyData!.code,
      style: style,
      customer: Customer(name: MyAppState.currentUser!.firstName, phoneNumber: MyAppState.currentUser!.phoneNumber.trim(), email: MyAppState.currentUser!.email.trim()),
      context: context,
      publicKey: flutterWaveSettingData!.publicKey.trim(),
      paymentOptions: "card, payattitude",
      customization: Customization(title: "Foodies"),
      txRef: _ref!,
      redirectUrl: '${GlobalURL}success',
      isTestMode: flutterWaveSettingData!.isSandbox,
    );
    final ChargeResponse response = await flutterwave.charge();
    if (response.toString().isNotEmpty) {
      if (response.success!) {
        FireStoreUtils.createPaymentId().then((value) {
          final paymentID = value;
          FireStoreUtils.topUpWalletAmount(paymentMethod: "FlutterWave", amount: double.parse(_amountController.text), id: paymentID).then((value) {
            FireStoreUtils.updateWalletAmount(amount: double.parse(_amountController.text)).whenComplete(() {
              Navigator.pop(_scaffoldKey.currentContext!);
              ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(SnackBar(
                content: Text("Payment Successful!!".tr() + "\n"),
                backgroundColor: Colors.green,
              ));
            });
          });
        });
      } else {
        this.showLoading(message: response.status!);
      }
      print("${response.toJson()}");
    } else {
      this.showLoading(message: "No Response!".tr(), txtColor: Colors.red);
    }
  }

  Future<void> showLoading({required String message, Color txtColor = Colors.black}) {
    return showDialog(
      context: this.context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
            margin: EdgeInsets.fromLTRB(30, 20, 30, 20),
            width: double.infinity,
            height: 30,
            child: Text(
              message,
              style: TextStyle(color: txtColor),
            ),
          ),
        );
      },
    );
  }
}

enum PaymentOptionString { RazorPay, Stripe, PayTm, PayPal, PayStack, FlutterWave }
