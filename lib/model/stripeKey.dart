class StripeKeyModel {
  String stripeKey;
  String stripeSecret;

  StripeKeyModel({
    this.stripeKey = '',
    this.stripeSecret = '',
  });

  factory StripeKeyModel.fromJson(Map<String, dynamic> parsedJson) {
    return StripeKeyModel(
      stripeKey: parsedJson['stripeKey'] ?? '',
      stripeSecret: parsedJson['stripeSecret'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stripeKey': this.stripeKey,
      'stripeSecret': this.stripeSecret,
    };
  }
}
