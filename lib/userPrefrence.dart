import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:foodie_customer/model/FlutterWaveSettingDataModel.dart';
import 'package:foodie_customer/model/PayFastSettingData.dart';
import 'package:foodie_customer/model/PayStackSettingsModel.dart';
import 'package:foodie_customer/model/paytmSettingData.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'model/MercadoPagoSettingsModel.dart';
import 'model/paypalSettingData.dart';
import 'model/razorpayKeyModel.dart';
import 'model/stripeSettingData.dart';

class UserPreference {
  static late SharedPreferences _preferences;

  static Future init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  static const razorPayDataKey = "razorPayData";
  static const _userId = "userId";

  static setUserId({required String userID}) {
    debugPrint(userID);
    _preferences.setString(_userId, userID);
  }

  static String walletKey = "walletKey";

  static setWalletData(bool isEnable) async {
    await _preferences.setBool(walletKey, isEnable);
  }

  static getWalletData() {
    final bool? isEnable = _preferences.getBool(walletKey);
    return isEnable;
  }

  static setRazorPayData(RazorPayModel razorPayModel) async {
    final jsonData = jsonEncode(razorPayModel);
    await _preferences.setString(razorPayDataKey, jsonData);
  }

  static getRazorPayData() {
    final String? jsonData = _preferences.getString(razorPayDataKey);
    if (jsonData != null) return RazorPayModel.fromJson(jsonDecode(jsonData));
  }

  static String paypalKey = "paypalKey";

  static setPayPalData(PaypalSettingData payPalSettingModel) async {
    final jsonData = jsonEncode(payPalSettingModel);
    await _preferences.setString(paypalKey, jsonData);
  }

  static getPayPalData() {
    final String? jsonData = _preferences.getString(paypalKey);
    if (jsonData != null) return PaypalSettingData.fromJson((jsonDecode(jsonData)));
  }

  static String payFast = "payFast";

  static setPayFastData(PayFastSettingData payFastSettingModel) async {
    final jsonData = jsonEncode(payFastSettingModel);
    await _preferences.setString(payFast, jsonData);
  }

  static getPayFastData() {
    final String? jsonData = _preferences.getString(payFast);
    if (jsonData != null) return PayFastSettingData.fromJson((jsonDecode(jsonData)));
  }

  static String mercadoPago = "mercadoPago";

  static setMercadoPago(MercadoPagoSettingData mercadoPagoSettingData) async {
    final jsonData = jsonEncode(mercadoPagoSettingData);
    await _preferences.setString(mercadoPago, jsonData);
  }

  static getMercadoPago() {
    final String? jsonData = _preferences.getString(mercadoPago);
    if (jsonData != null) return MercadoPagoSettingData.fromJson((jsonDecode(jsonData)));
  }

  static String stripeKey = "stripeKey";

  static setStripeData(StripeSettingData stripeSettingModel) async {
    final jsonData = jsonEncode(stripeSettingModel);
    await _preferences.setString(stripeKey, jsonData);
  }

  static Future<StripeSettingData> getStripeData() async {
    final String? jsonData = _preferences.getString(stripeKey);
    final stripeData = jsonDecode(jsonData!);
    debugPrint(stripeData.toString());
    return StripeSettingData.fromJson(stripeData);
  }

  static String flutterWaveStack = "flutterWaveStack";

  static setFlutterWaveData(FlutterWaveSettingData flutterWaveSettingData) async {
    debugPrint(flutterWaveSettingData.toString());
    final jsonData = jsonEncode(flutterWaveSettingData);
    await _preferences.setString(flutterWaveStack, jsonData);
  }

  static Future<FlutterWaveSettingData> getFlutterWaveData() async {
    final String? jsonData = _preferences.getString(flutterWaveStack);
    final flutterWaveData = jsonDecode(jsonData!);
    return FlutterWaveSettingData.fromJson(flutterWaveData);
  }

  static String payStack = "payStack";

  static setPayStackData(PayStackSettingData payStackSettingModel) async {
    final jsonData = jsonEncode(payStackSettingModel);
    await _preferences.setString(payStack, jsonData);
  }

  static Future<PayStackSettingData> getPayStackData() async {
    final String? jsonData = _preferences.getString(payStack);
    final payStackData = jsonDecode(jsonData!);
    return PayStackSettingData.fromJson(payStackData);
  }

  static String _paytmKey = "paytmKey";

  static setPaytmData(PaytmSettingData paytmSettingModel) async {
    final jsonData = jsonEncode(paytmSettingModel);
    await _preferences.setString(_paytmKey, jsonData);
  }

  static getPaytmData() async {
    final String? jsonData = _preferences.getString(_paytmKey);
    final paytmData = jsonDecode(jsonData!);
    return PaytmSettingData.fromJson(paytmData);
  }

  static const _orderId = "orderId";

  static setOrderId({required String orderId}) {
    _preferences.setString(_orderId, orderId);
  }

  static getOrderId() {
    final String? orderId = _preferences.getString(_orderId);
    return orderId != null ? orderId : "";
  }

  static const _paymentId = "paymentId";

  static setPaymentId({required String paymentId}) {
    _preferences.setString(_paymentId, paymentId);
  }

  static getPaymentId() {
    final String? paymentId = _preferences.getString(_paymentId);
    return paymentId != null ? paymentId : "";
  }
}
