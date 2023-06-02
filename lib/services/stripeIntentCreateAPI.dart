import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:foodie_customer/constants.dart';
import 'package:foodie_customer/model/stripeIntentModel.dart';
import 'package:http/http.dart' as http;

class StripeCreateIntent {
  static Future<StripeCreateIntentModel> stripeCreateIntent({
    required currency,
    required amount,
    required stripesecret,
  }) async {
    final url = "${GlobalURL}payments/stripepaymentintent";

    final response = await http.post(
      Uri.parse(url),
      body: {
        "currency": currency,
        "stripesecret": stripesecret,
        "amount": amount,
      },
    );
    debugPrint(response.body);

    final data = jsonDecode(response.body);
    return StripeCreateIntentModel.fromJson(data); //PayPalClientSettleModel.fromJson(data);
  }
}
