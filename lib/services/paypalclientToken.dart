import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:foodie_customer/constants.dart';
import 'package:foodie_customer/model/paypalClientToken.dart';
import 'package:foodie_customer/model/paypalSettingData.dart';
import 'package:http/http.dart' as http;

class PayPalClientTokenGen {
  static Future<PayPalClientTokenModel> paypalClientToken({
    required PaypalSettingData paypalSettingData,
  }) async {
    // final String userId = UserPreference.getUserId();
    // final String orderId = isTopup ? UserPreference.getPaymentId() : UserPreference.getOrderId();

    final url = "${GlobalURL}payments/paypalclientid";

    final response = await http.post(
      Uri.parse(url),
      body: {
        "environment": paypalSettingData.isLive ? "production" : "sandbox",
        "merchant_id": paypalSettingData.braintreeMerchantid,
        "public_key": paypalSettingData.braintreePublickey,
        "private_key": paypalSettingData.braintreePrivatekey,
      },
    );
    debugPrint(response.body.toString());

    final data = jsonDecode(response.body);
    debugPrint(data.toString());

    return PayPalClientTokenModel.fromJson(data);
  }

  static paypalSettleAmount({
    required nonceFromTheClient,
    required amount,
    required deviceDataFromTheClient,
    required PaypalSettingData paypalSettingData,
  }) async {
    final url = "${GlobalURL}payments/paypaltransaction";

    final response = await http.post(
      Uri.parse(url),
      body: {
        "environment": paypalSettingData.isLive ? "production" : "sandbox",
        "merchant_id": paypalSettingData.braintreeMerchantid,
        "public_key": paypalSettingData.braintreePublickey,
        "private_key": paypalSettingData.braintreePrivatekey,
        "nonceFromTheClient": nonceFromTheClient,
        "amount": amount,
        "deviceDataFromTheClient": deviceDataFromTheClient,
      },
    );

    final data = jsonDecode(response.body);

    return data; //PayPalClientSettleModel.fromJson(data);
  }
}
