class PaypalSettingData {
  String braintreeMerchantid;
  String braintreePrivatekey;
  String braintreePublickey;
  String braintreeTokenizationKey;
  bool isEnabled;
  bool isLive;
  String paypalAppId;
  String paypalSecret;
  String paypalUserName;
  String paypalPassword;

  PaypalSettingData({
    this.braintreeMerchantid = '',
    this.braintreePrivatekey = '',
    this.braintreePublickey = '',
    this.braintreeTokenizationKey = '',
    required this.isLive,
    this.paypalAppId = '',
    this.paypalPassword = '',
    this.paypalUserName = '',
    required this.isEnabled,
    required this.paypalSecret,
  });

  factory PaypalSettingData.fromJson(Map<String, dynamic> parsedJson) {
    return PaypalSettingData(
      paypalSecret: parsedJson['paypalSecret'] ?? '',
      braintreeMerchantid: parsedJson['braintree_merchantid'] ?? '',
      isLive: parsedJson['isLive'],
      isEnabled: parsedJson['isEnabled'],
      braintreePrivatekey: parsedJson['braintree_privatekey'] ?? '',
      braintreePublickey: parsedJson['braintree_publickey'] ?? '',
      braintreeTokenizationKey: parsedJson['braintree_tokenizationKey'] ?? '',
      paypalAppId: parsedJson['paypalAppId'] ?? '',
      paypalPassword: parsedJson['paypalpassword'] ?? '',
      paypalUserName: parsedJson['paypalUserName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'paypalUserName': this.paypalUserName,
      'paypalpassword': this.paypalPassword,
      'isEnabled': this.isEnabled,
      'isLive': this.isLive,
      'paypalSecret': this.paypalSecret,
      'paypalAppId': this.paypalAppId,
      'braintree_tokenizationKey': this.braintreeTokenizationKey,
      'braintree_publickey': this.braintreePublickey,
      'braintree_privatekey': this.braintreePrivatekey,
      'braintree_merchantid': this.braintreeMerchantid,
    };
  }
}
