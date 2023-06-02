import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:foodie_customer/main.dart';
import 'package:foodie_customer/model/PayFastSettingData.dart';
import 'package:foodie_customer/model/payStackURLModel.dart';
import 'package:http/http.dart' as http;

class PayStackURLGen {
  static Future payStackURLGen({required String amount, required String secretKey, required String currency}) async {
    final url = "https://api.paystack.co/transaction/initialize";
    final response = await http.post(Uri.parse(url), body: {
      "email": MyAppState.currentUser?.email,
      "amount": amount,
      "currency": currency,
    }, headers: {
      "Authorization": "Bearer $secretKey",
    });
    debugPrint(response.body);
    final data = jsonDecode(response.body);
    debugPrint(data);
    if (!data["status"]) {
      return null;
    }
    return PayStackUrlModel.fromJson(data);
  }

  static Future<bool> verifyTransaction({
    required String reference,
    required String secretKey,
    required String amount,
  }) async {
    debugPrint("we Enter payment Settle");
    debugPrint(reference);

    final url = "https://api.paystack.co/transaction/verify/$reference";

    var response = await http.get(Uri.parse(url), headers: {
      "Authorization": "Bearer $secretKey",
    });

    debugPrint(response.body);
    final data = jsonDecode(response.body);
    if (data["status"] == true) {
      if (data["message"] == "Verification successful") {}
    }

    return data["status"];

    //PayPalClientSettleModel.fromJson(data);
  }

  static Future<String> getPayHTML({required String amount, required PayFastSettingData payFastSettingData, String itemName = "wallet Topup"}) async {
    String newUrl = 'https://${!payFastSettingData.isSandbox ? "www" : "sandbox"}.payfast.co.za/eng/process';
    Map body = {
      'merchant_id': payFastSettingData.merchantId,
      'merchant_key': payFastSettingData.merchantKey,
      'amount': amount,
      'item_name': itemName,
      'return_url': payFastSettingData.returnUrl,
      'cancel_url': payFastSettingData.cancelUrl,
      'notify_url': payFastSettingData.notifyUrl,
      'name_first': MyAppState.currentUser!.firstName,
      'name_last': MyAppState.currentUser!.lastName,
      'email_address': MyAppState.currentUser!.email,
    };

    final response = await http.post(
      Uri.parse(newUrl),
      body: body,
    );

    debugPrint(response.body);
    return response.body;
  }
}
