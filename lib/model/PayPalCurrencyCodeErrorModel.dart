// To parse this JSON data, do
//
//     final payPalCurrencyCodeErrorModel = payPalCurrencyCodeErrorModelFromJson(jsonString);

import 'dart:convert';

PayPalCurrencyCodeErrorModel payPalCurrencyCodeErrorModelFromJson(String str) => PayPalCurrencyCodeErrorModel.fromJson(json.decode(str));

String payPalCurrencyCodeErrorModelToJson(PayPalCurrencyCodeErrorModel data) => json.encode(data.toJson());

class PayPalCurrencyCodeErrorModel {
  PayPalCurrencyCodeErrorModel({
    required this.success,
    required this.data,
  });

  bool success;
  Data data;

  factory PayPalCurrencyCodeErrorModel.fromJson(Map<String, dynamic> json) => PayPalCurrencyCodeErrorModel(
        success: json["success"],
        data: Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "data": data.toJson(),
      };
}

class Data {
  Data({
    required this.errors,
    required this.params,
    required this.message,
    required this.transaction,
    this.creditCardVerification,
    this.subscription,
    this.merchantAccount,
    this.verification,
  });

  List<dynamic> errors;
  Params params;
  String message;
  DataTransaction transaction;
  dynamic creditCardVerification;
  dynamic subscription;
  dynamic merchantAccount;
  dynamic verification;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        errors: List<dynamic>.from(json["errors"].map((x) => x)),
        params: Params.fromJson(json["params"]),
        message: json["message"],
        transaction: DataTransaction.fromJson(json["transaction"]),
        creditCardVerification: json["creditCardVerification"],
        subscription: json["subscription"],
        merchantAccount: json["merchantAccount"],
        verification: json["verification"],
      );

  Map<String, dynamic> toJson() => {
        "errors": List<dynamic>.from(errors.map((x) => x)),
        "params": params.toJson(),
        "message": message,
        "transaction": transaction.toJson(),
        "creditCardVerification": creditCardVerification,
        "subscription": subscription,
        "merchantAccount": merchantAccount,
        "verification": verification,
      };
}

class Params {
  Params({
    required this.transaction,
  });

  ParamsTransaction transaction;

  factory Params.fromJson(Map<String, dynamic> json) => Params(
        transaction: ParamsTransaction.fromJson(json["transaction"]),
      );

  Map<String, dynamic> toJson() => {
        "transaction": transaction.toJson(),
      };
}

class ParamsTransaction {
  ParamsTransaction({
    required this.correlationId,
    required this.type,
    required this.amount,
    required this.paymentMethodNonce,
    required this.options,
  });

  String correlationId;
  String type;
  String amount;
  String paymentMethodNonce;
  Options options;

  factory ParamsTransaction.fromJson(Map<String, dynamic> json) => ParamsTransaction(
        correlationId: json["correlationId"] ?? " ",
        type: json["type"],
        amount: json["amount"],
        paymentMethodNonce: json["paymentMethodNonce"],
        options: Options.fromJson(json["options"]),
      );

  Map<String, dynamic> toJson() => {
        "correlationId": correlationId,
        "type": type,
        "amount": amount,
        "paymentMethodNonce": paymentMethodNonce,
        "options": options.toJson(),
      };
}

class Options {
  Options({
    required this.submitForSettlement,
  });

  String submitForSettlement;

  factory Options.fromJson(Map<String, dynamic> json) => Options(
        submitForSettlement: json["submitForSettlement"],
      );

  Map<String, dynamic> toJson() => {
        "submitForSettlement": submitForSettlement,
      };
}

class DataTransaction {
  DataTransaction({
    required this.id,
    required this.status,
    required this.type,
    required this.currencyIsoCode,
    required this.amount,
    required this.amountRequested,
    required this.merchantAccountId,
    this.subMerchantAccountId,
    this.masterMerchantAccountId,
    this.orderId,
    required this.createdAt,
    required this.updatedAt,
    required this.customer,
    required this.billing,
    this.refundId,
    required this.refundIds,
    this.refundedTransactionId,
    required this.partialSettlementTransactionIds,
    this.authorizedTransactionId,
    this.settlementBatchId,
    required this.shipping,
    this.customFields,
    required this.accountFundingTransaction,
    this.avsErrorResponseCode,
    required this.avsPostalCodeResponseCode,
    required this.avsStreetAddressResponseCode,
    required this.cvvResponseCode,
    this.gatewayRejectionReason,
    this.processorAuthorizationCode,
    required this.processorResponseCode,
    required this.processorResponseText,
    required this.additionalProcessorResponse,
    this.voiceReferralNumber,
    this.purchaseOrderNumber,
    this.taxAmount,
    required this.taxExempt,
    this.scaExemptionRequested,
    required this.processedWithNetworkToken,
    required this.creditCard,
    required this.paypal,
    required this.statusHistory,
    this.planId,
    this.subscriptionId,
    required this.subscription,
    required this.addOns,
    required this.discounts,
    required this.descriptor,
    required this.recurring,
    this.channel,
    this.serviceFeeAmount,
    this.escrowStatus,
    required this.disbursementDetails,
    required this.disputes,
    required this.authorizationAdjustments,
    required this.paymentInstrumentType,
    this.processorSettlementResponseCode,
    this.processorSettlementResponseText,
    this.networkResponseCode,
    this.networkResponseText,
    this.threeDSecureInfo,
    this.shipsFromPostalCode,
    this.shippingAmount,
    this.discountAmount,
    this.networkTransactionId,
    required this.processorResponseType,
    this.authorizationExpiresAt,
    required this.retryIds,
    this.retriedTransactionId,
    required this.refundGlobalIds,
    required this.partialSettlementTransactionGlobalIds,
    this.refundedTransactionGlobalId,
    this.authorizedTransactionGlobalId,
    required this.globalId,
    required this.retryGlobalIds,
    this.retriedTransactionGlobalId,
    this.retrievalReferenceNumber,
    this.installmentCount,
    required this.installments,
    required this.refundedInstallments,
    this.responseEmvData,
    this.acquirerReferenceNumber,
    this.merchantIdentificationNumber,
    this.terminalIdentificationNumber,
    this.merchantName,
    required this.merchantAddress,
    required this.pinVerified,
    this.debitNetwork,
    this.processingMode,
    required this.paymentReceipt,
    required this.creditCardDetails,
    required this.paypalDetails,
    required this.customerDetails,
    required this.billingDetails,
    required this.shippingDetails,
    required this.subscriptionDetails,
  });

  String id;
  String status;
  String type;
  String currencyIsoCode;
  String amount;
  String amountRequested;
  String merchantAccountId;
  dynamic subMerchantAccountId;
  dynamic masterMerchantAccountId;
  dynamic orderId;
  AtedAt createdAt;
  AtedAt updatedAt;
  Customer customer;
  Ing billing;
  dynamic refundId;
  List<dynamic> refundIds;
  dynamic refundedTransactionId;
  List<dynamic> partialSettlementTransactionIds;
  dynamic authorizedTransactionId;
  dynamic settlementBatchId;
  Ing shipping;
  dynamic customFields;
  bool accountFundingTransaction;
  dynamic avsErrorResponseCode;
  String avsPostalCodeResponseCode;
  String avsStreetAddressResponseCode;
  String cvvResponseCode;
  dynamic gatewayRejectionReason;
  dynamic processorAuthorizationCode;
  String processorResponseCode;
  String processorResponseText;
  String additionalProcessorResponse;
  dynamic voiceReferralNumber;
  dynamic purchaseOrderNumber;
  dynamic taxAmount;
  bool taxExempt;
  dynamic scaExemptionRequested;
  bool processedWithNetworkToken;
  CreditCard creditCard;
  Paypal paypal;
  List<BillingDetails> statusHistory;
  dynamic planId;
  dynamic subscriptionId;
  Subscription subscription;
  List<dynamic> addOns;
  List<dynamic> discounts;
  BillingDetails descriptor;
  bool recurring;
  dynamic channel;
  dynamic serviceFeeAmount;
  dynamic escrowStatus;
  BillingDetails disbursementDetails;
  List<dynamic> disputes;
  List<dynamic> authorizationAdjustments;
  String paymentInstrumentType;
  dynamic processorSettlementResponseCode;
  dynamic processorSettlementResponseText;
  dynamic networkResponseCode;
  dynamic networkResponseText;
  dynamic threeDSecureInfo;
  dynamic shipsFromPostalCode;
  dynamic shippingAmount;
  dynamic discountAmount;
  dynamic networkTransactionId;
  String processorResponseType;
  dynamic authorizationExpiresAt;
  List<dynamic> retryIds;
  dynamic retriedTransactionId;
  List<dynamic> refundGlobalIds;
  List<dynamic> partialSettlementTransactionGlobalIds;
  dynamic refundedTransactionGlobalId;
  dynamic authorizedTransactionGlobalId;
  String globalId;
  List<dynamic> retryGlobalIds;
  dynamic retriedTransactionGlobalId;
  dynamic retrievalReferenceNumber;
  dynamic installmentCount;
  List<dynamic> installments;
  List<dynamic> refundedInstallments;
  dynamic responseEmvData;
  dynamic acquirerReferenceNumber;
  dynamic merchantIdentificationNumber;
  dynamic terminalIdentificationNumber;
  dynamic merchantName;
  MerchantAddress merchantAddress;
  bool pinVerified;
  dynamic debitNetwork;
  dynamic processingMode;
  PaymentReceipt paymentReceipt;
  BillingDetails creditCardDetails;
  BillingDetails paypalDetails;
  BillingDetails customerDetails;
  BillingDetails billingDetails;
  BillingDetails shippingDetails;
  BillingDetails subscriptionDetails;

  factory DataTransaction.fromJson(Map<String, dynamic> json) => DataTransaction(
        id: json["id"],
        status: json["status"],
        type: json["type"],
        currencyIsoCode: json["currencyIsoCode"],
        amount: json["amount"],
        amountRequested: json["amountRequested"],
        merchantAccountId: json["merchantAccountId"],
        subMerchantAccountId: json["subMerchantAccountId"],
        masterMerchantAccountId: json["masterMerchantAccountId"],
        orderId: json["orderId"],
        createdAt: AtedAt.fromJson(json["createdAt"]),
        updatedAt: AtedAt.fromJson(json["updatedAt"]),
        customer: Customer.fromJson(json["customer"]),
        billing: Ing.fromJson(json["billing"]),
        refundId: json["refundId"],
        refundIds: List<dynamic>.from(json["refundIds"].map((x) => x)),
        refundedTransactionId: json["refundedTransactionId"],
        partialSettlementTransactionIds: List<dynamic>.from(json["partialSettlementTransactionIds"].map((x) => x)),
        authorizedTransactionId: json["authorizedTransactionId"],
        settlementBatchId: json["settlementBatchId"],
        shipping: Ing.fromJson(json["shipping"]),
        customFields: json["customFields"],
        accountFundingTransaction: json["accountFundingTransaction"],
        avsErrorResponseCode: json["avsErrorResponseCode"],
        avsPostalCodeResponseCode: json["avsPostalCodeResponseCode"],
        avsStreetAddressResponseCode: json["avsStreetAddressResponseCode"],
        cvvResponseCode: json["cvvResponseCode"],
        gatewayRejectionReason: json["gatewayRejectionReason"],
        processorAuthorizationCode: json["processorAuthorizationCode"],
        processorResponseCode: json["processorResponseCode"],
        processorResponseText: json["processorResponseText"],
        additionalProcessorResponse: json["additionalProcessorResponse"],
        voiceReferralNumber: json["voiceReferralNumber"],
        purchaseOrderNumber: json["purchaseOrderNumber"],
        taxAmount: json["taxAmount"],
        taxExempt: json["taxExempt"],
        scaExemptionRequested: json["scaExemptionRequested"],
        processedWithNetworkToken: json["processedWithNetworkToken"],
        creditCard: CreditCard.fromJson(json["creditCard"]),
        paypal: Paypal.fromJson(json["paypal"]),
        statusHistory: List<BillingDetails>.from(json["statusHistory"].map((x) => BillingDetails.fromJson(x))),
        planId: json["planId"],
        subscriptionId: json["subscriptionId"],
        subscription: Subscription.fromJson(json["subscription"]),
        addOns: List<dynamic>.from(json["addOns"].map((x) => x)),
        discounts: List<dynamic>.from(json["discounts"].map((x) => x)),
        descriptor: BillingDetails.fromJson(json["descriptor"]),
        recurring: json["recurring"],
        channel: json["channel"],
        serviceFeeAmount: json["serviceFeeAmount"],
        escrowStatus: json["escrowStatus"],
        disbursementDetails: BillingDetails.fromJson(json["disbursementDetails"]),
        disputes: List<dynamic>.from(json["disputes"].map((x) => x)),
        authorizationAdjustments: List<dynamic>.from(json["authorizationAdjustments"].map((x) => x)),
        paymentInstrumentType: json["paymentInstrumentType"],
        processorSettlementResponseCode: json["processorSettlementResponseCode"],
        processorSettlementResponseText: json["processorSettlementResponseText"],
        networkResponseCode: json["networkResponseCode"],
        networkResponseText: json["networkResponseText"],
        threeDSecureInfo: json["threeDSecureInfo"],
        shipsFromPostalCode: json["shipsFromPostalCode"],
        shippingAmount: json["shippingAmount"],
        discountAmount: json["discountAmount"],
        networkTransactionId: json["networkTransactionId"],
        processorResponseType: json["processorResponseType"],
        authorizationExpiresAt: json["authorizationExpiresAt"],
        retryIds: List<dynamic>.from(json["retryIds"].map((x) => x)),
        retriedTransactionId: json["retriedTransactionId"],
        refundGlobalIds: List<dynamic>.from(json["refundGlobalIds"].map((x) => x)),
        partialSettlementTransactionGlobalIds: List<dynamic>.from(json["partialSettlementTransactionGlobalIds"].map((x) => x)),
        refundedTransactionGlobalId: json["refundedTransactionGlobalId"],
        authorizedTransactionGlobalId: json["authorizedTransactionGlobalId"],
        globalId: json["globalId"],
        retryGlobalIds: List<dynamic>.from(json["retryGlobalIds"].map((x) => x)),
        retriedTransactionGlobalId: json["retriedTransactionGlobalId"],
        retrievalReferenceNumber: json["retrievalReferenceNumber"],
        installmentCount: json["installmentCount"],
        installments: List<dynamic>.from(json["installments"].map((x) => x)),
        refundedInstallments: List<dynamic>.from(json["refundedInstallments"].map((x) => x)),
        responseEmvData: json["responseEmvData"],
        acquirerReferenceNumber: json["acquirerReferenceNumber"],
        merchantIdentificationNumber: json["merchantIdentificationNumber"],
        terminalIdentificationNumber: json["terminalIdentificationNumber"],
        merchantName: json["merchantName"],
        merchantAddress: MerchantAddress.fromJson(json["merchantAddress"]),
        pinVerified: json["pinVerified"],
        debitNetwork: json["debitNetwork"],
        processingMode: json["processingMode"],
        paymentReceipt: PaymentReceipt.fromJson(json["paymentReceipt"]),
        creditCardDetails: BillingDetails.fromJson(json["creditCardDetails"]),
        paypalDetails: BillingDetails.fromJson(json["paypalDetails"]),
        customerDetails: BillingDetails.fromJson(json["customerDetails"]),
        billingDetails: BillingDetails.fromJson(json["billingDetails"]),
        shippingDetails: BillingDetails.fromJson(json["shippingDetails"]),
        subscriptionDetails: BillingDetails.fromJson(json["subscriptionDetails"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "status": status,
        "type": type,
        "currencyIsoCode": currencyIsoCode,
        "amount": amount,
        "amountRequested": amountRequested,
        "merchantAccountId": merchantAccountId,
        "subMerchantAccountId": subMerchantAccountId,
        "masterMerchantAccountId": masterMerchantAccountId,
        "orderId": orderId,
        "createdAt": createdAt.toJson(),
        "updatedAt": updatedAt.toJson(),
        "customer": customer.toJson(),
        "billing": billing.toJson(),
        "refundId": refundId,
        "refundIds": List<dynamic>.from(refundIds.map((x) => x)),
        "refundedTransactionId": refundedTransactionId,
        "partialSettlementTransactionIds": List<dynamic>.from(partialSettlementTransactionIds.map((x) => x)),
        "authorizedTransactionId": authorizedTransactionId,
        "settlementBatchId": settlementBatchId,
        "shipping": shipping.toJson(),
        "customFields": customFields,
        "accountFundingTransaction": accountFundingTransaction,
        "avsErrorResponseCode": avsErrorResponseCode,
        "avsPostalCodeResponseCode": avsPostalCodeResponseCode,
        "avsStreetAddressResponseCode": avsStreetAddressResponseCode,
        "cvvResponseCode": cvvResponseCode,
        "gatewayRejectionReason": gatewayRejectionReason,
        "processorAuthorizationCode": processorAuthorizationCode,
        "processorResponseCode": processorResponseCode,
        "processorResponseText": processorResponseText,
        "additionalProcessorResponse": additionalProcessorResponse,
        "voiceReferralNumber": voiceReferralNumber,
        "purchaseOrderNumber": purchaseOrderNumber,
        "taxAmount": taxAmount,
        "taxExempt": taxExempt,
        "scaExemptionRequested": scaExemptionRequested,
        "processedWithNetworkToken": processedWithNetworkToken,
        "creditCard": creditCard.toJson(),
        "paypal": paypal.toJson(),
        "statusHistory": List<dynamic>.from(statusHistory.map((x) => x.toJson())),
        "planId": planId,
        "subscriptionId": subscriptionId,
        "subscription": subscription.toJson(),
        "addOns": List<dynamic>.from(addOns.map((x) => x)),
        "discounts": List<dynamic>.from(discounts.map((x) => x)),
        "descriptor": descriptor.toJson(),
        "recurring": recurring,
        "channel": channel,
        "serviceFeeAmount": serviceFeeAmount,
        "escrowStatus": escrowStatus,
        "disbursementDetails": disbursementDetails.toJson(),
        "disputes": List<dynamic>.from(disputes.map((x) => x)),
        "authorizationAdjustments": List<dynamic>.from(authorizationAdjustments.map((x) => x)),
        "paymentInstrumentType": paymentInstrumentType,
        "processorSettlementResponseCode": processorSettlementResponseCode,
        "processorSettlementResponseText": processorSettlementResponseText,
        "networkResponseCode": networkResponseCode,
        "networkResponseText": networkResponseText,
        "threeDSecureInfo": threeDSecureInfo,
        "shipsFromPostalCode": shipsFromPostalCode,
        "shippingAmount": shippingAmount,
        "discountAmount": discountAmount,
        "networkTransactionId": networkTransactionId,
        "processorResponseType": processorResponseType,
        "authorizationExpiresAt": authorizationExpiresAt,
        "retryIds": List<dynamic>.from(retryIds.map((x) => x)),
        "retriedTransactionId": retriedTransactionId,
        "refundGlobalIds": List<dynamic>.from(refundGlobalIds.map((x) => x)),
        "partialSettlementTransactionGlobalIds": List<dynamic>.from(partialSettlementTransactionGlobalIds.map((x) => x)),
        "refundedTransactionGlobalId": refundedTransactionGlobalId,
        "authorizedTransactionGlobalId": authorizedTransactionGlobalId,
        "globalId": globalId,
        "retryGlobalIds": List<dynamic>.from(retryGlobalIds.map((x) => x)),
        "retriedTransactionGlobalId": retriedTransactionGlobalId,
        "retrievalReferenceNumber": retrievalReferenceNumber,
        "installmentCount": installmentCount,
        "installments": List<dynamic>.from(installments.map((x) => x)),
        "refundedInstallments": List<dynamic>.from(refundedInstallments.map((x) => x)),
        "responseEmvData": responseEmvData,
        "acquirerReferenceNumber": acquirerReferenceNumber,
        "merchantIdentificationNumber": merchantIdentificationNumber,
        "terminalIdentificationNumber": terminalIdentificationNumber,
        "merchantName": merchantName,
        "merchantAddress": merchantAddress.toJson(),
        "pinVerified": pinVerified,
        "debitNetwork": debitNetwork,
        "processingMode": processingMode,
        "paymentReceipt": paymentReceipt.toJson(),
        "creditCardDetails": creditCardDetails.toJson(),
        "paypalDetails": paypalDetails.toJson(),
        "customerDetails": customerDetails.toJson(),
        "billingDetails": billingDetails.toJson(),
        "shippingDetails": shippingDetails.toJson(),
        "subscriptionDetails": subscriptionDetails.toJson(),
      };
}

class Ing {
  Ing({
    this.id,
    this.firstName,
    this.lastName,
    this.company,
    this.streetAddress,
    this.extendedAddress,
    this.locality,
    this.region,
    this.postalCode,
    this.countryName,
    this.countryCodeAlpha2,
    this.countryCodeAlpha3,
    this.countryCodeNumeric,
  });

  dynamic id;
  dynamic firstName;
  dynamic lastName;
  dynamic company;
  dynamic streetAddress;
  dynamic extendedAddress;
  dynamic locality;
  dynamic region;
  dynamic postalCode;
  dynamic countryName;
  dynamic countryCodeAlpha2;
  dynamic countryCodeAlpha3;
  dynamic countryCodeNumeric;

  factory Ing.fromJson(Map<String, dynamic> json) => Ing(
        id: json["id"],
        firstName: json["firstName"],
        lastName: json["lastName"],
        company: json["company"],
        streetAddress: json["streetAddress"],
        extendedAddress: json["extendedAddress"],
        locality: json["locality"],
        region: json["region"],
        postalCode: json["postalCode"],
        countryName: json["countryName"],
        countryCodeAlpha2: json["countryCodeAlpha2"],
        countryCodeAlpha3: json["countryCodeAlpha3"],
        countryCodeNumeric: json["countryCodeNumeric"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "firstName": firstName,
        "lastName": lastName,
        "company": company,
        "streetAddress": streetAddress,
        "extendedAddress": extendedAddress,
        "locality": locality,
        "region": region,
        "postalCode": postalCode,
        "countryName": countryName,
        "countryCodeAlpha2": countryCodeAlpha2,
        "countryCodeAlpha3": countryCodeAlpha3,
        "countryCodeNumeric": countryCodeNumeric,
      };
}

class BillingDetails {
  BillingDetails();

  factory BillingDetails.fromJson(Map<String, dynamic> json) => BillingDetails();

  Map<String, dynamic> toJson() => {};
}

class AtedAt {
  AtedAt({
    required this.date,
    required this.timezoneType,
    required this.timezone,
  });

  DateTime date;
  int timezoneType;
  String timezone;

  factory AtedAt.fromJson(Map<String, dynamic> json) => AtedAt(
        date: DateTime.parse(json["date"]),
        timezoneType: json["timezone_type"],
        timezone: json["timezone"],
      );

  Map<String, dynamic> toJson() => {
        "date": date.toIso8601String(),
        "timezone_type": timezoneType,
        "timezone": timezone,
      };
}

class CreditCard {
  CreditCard({
    this.token,
    this.bin,
    this.last4,
    this.cardType,
    this.expirationMonth,
    this.expirationYear,
    this.customerLocation,
    this.cardholderName,
    required this.imageUrl,
    required this.prepaid,
    required this.healthcare,
    required this.debit,
    required this.durbinRegulated,
    required this.commercial,
    required this.payroll,
    required this.issuingBank,
    required this.countryOfIssuance,
    required this.productId,
    this.globalId,
    this.accountType,
    this.uniqueNumberIdentifier,
    required this.venmoSdk,
    this.accountBalance,
  });

  dynamic token;
  dynamic bin;
  dynamic last4;
  dynamic cardType;
  dynamic expirationMonth;
  dynamic expirationYear;
  dynamic customerLocation;
  dynamic cardholderName;
  String imageUrl;
  String prepaid;
  String healthcare;
  String debit;
  String durbinRegulated;
  String commercial;
  String payroll;
  String issuingBank;
  String countryOfIssuance;
  String productId;
  dynamic globalId;
  dynamic accountType;
  dynamic uniqueNumberIdentifier;
  bool venmoSdk;
  dynamic accountBalance;

  factory CreditCard.fromJson(Map<String, dynamic> json) => CreditCard(
        token: json["token"],
        bin: json["bin"],
        last4: json["last4"],
        cardType: json["cardType"],
        expirationMonth: json["expirationMonth"],
        expirationYear: json["expirationYear"],
        customerLocation: json["customerLocation"],
        cardholderName: json["cardholderName"],
        imageUrl: json["imageUrl"],
        prepaid: json["prepaid"],
        healthcare: json["healthcare"],
        debit: json["debit"],
        durbinRegulated: json["durbinRegulated"],
        commercial: json["commercial"],
        payroll: json["payroll"],
        issuingBank: json["issuingBank"],
        countryOfIssuance: json["countryOfIssuance"],
        productId: json["productId"],
        globalId: json["globalId"],
        accountType: json["accountType"],
        uniqueNumberIdentifier: json["uniqueNumberIdentifier"],
        venmoSdk: json["venmoSdk"],
        accountBalance: json["accountBalance"],
      );

  Map<String, dynamic> toJson() => {
        "token": token,
        "bin": bin,
        "last4": last4,
        "cardType": cardType,
        "expirationMonth": expirationMonth,
        "expirationYear": expirationYear,
        "customerLocation": customerLocation,
        "cardholderName": cardholderName,
        "imageUrl": imageUrl,
        "prepaid": prepaid,
        "healthcare": healthcare,
        "debit": debit,
        "durbinRegulated": durbinRegulated,
        "commercial": commercial,
        "payroll": payroll,
        "issuingBank": issuingBank,
        "countryOfIssuance": countryOfIssuance,
        "productId": productId,
        "globalId": globalId,
        "accountType": accountType,
        "uniqueNumberIdentifier": uniqueNumberIdentifier,
        "venmoSdk": venmoSdk,
        "accountBalance": accountBalance,
      };
}

class Customer {
  Customer({
    this.id,
    this.firstName,
    this.lastName,
    this.company,
    this.email,
    this.website,
    this.phone,
    this.fax,
  });

  dynamic id;
  dynamic firstName;
  dynamic lastName;
  dynamic company;
  dynamic email;
  dynamic website;
  dynamic phone;
  dynamic fax;

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
        id: json["id"],
        firstName: json["firstName"],
        lastName: json["lastName"],
        company: json["company"],
        email: json["email"],
        website: json["website"],
        phone: json["phone"],
        fax: json["fax"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "firstName": firstName,
        "lastName": lastName,
        "company": company,
        "email": email,
        "website": website,
        "phone": phone,
        "fax": fax,
      };
}

class MerchantAddress {
  MerchantAddress({
    this.streetAddress,
    this.locality,
    this.region,
    this.postalCode,
    this.phone,
  });

  dynamic streetAddress;
  dynamic locality;
  dynamic region;
  dynamic postalCode;
  dynamic phone;

  factory MerchantAddress.fromJson(Map<String, dynamic> json) => MerchantAddress(
        streetAddress: json["streetAddress"],
        locality: json["locality"],
        region: json["region"],
        postalCode: json["postalCode"],
        phone: json["phone"],
      );

  Map<String, dynamic> toJson() => {
        "streetAddress": streetAddress,
        "locality": locality,
        "region": region,
        "postalCode": postalCode,
        "phone": phone,
      };
}

class PaymentReceipt {
  PaymentReceipt({
    required this.id,
    required this.globalId,
    required this.amount,
    required this.currencyIsoCode,
    required this.processorResponseCode,
    required this.processorResponseText,
    this.processorAuthorizationCode,
    this.merchantName,
    required this.merchantAddress,
    this.merchantIdentificationNumber,
    this.terminalIdentificationNumber,
    required this.type,
    required this.pinVerified,
    this.processingMode,
    this.networkIdentificationCode,
  });

  String id;
  String globalId;
  String amount;
  String currencyIsoCode;
  String processorResponseCode;
  String processorResponseText;
  dynamic processorAuthorizationCode;
  dynamic merchantName;
  MerchantAddress merchantAddress;
  dynamic merchantIdentificationNumber;
  dynamic terminalIdentificationNumber;
  String type;
  bool pinVerified;
  dynamic processingMode;
  dynamic networkIdentificationCode;

  factory PaymentReceipt.fromJson(Map<String, dynamic> json) => PaymentReceipt(
        id: json["id"],
        globalId: json["globalId"],
        amount: json["amount"],
        currencyIsoCode: json["currencyIsoCode"],
        processorResponseCode: json["processorResponseCode"],
        processorResponseText: json["processorResponseText"],
        processorAuthorizationCode: json["processorAuthorizationCode"],
        merchantName: json["merchantName"],
        merchantAddress: MerchantAddress.fromJson(json["merchantAddress"]),
        merchantIdentificationNumber: json["merchantIdentificationNumber"],
        terminalIdentificationNumber: json["terminalIdentificationNumber"],
        type: json["type"],
        pinVerified: json["pinVerified"],
        processingMode: json["processingMode"],
        networkIdentificationCode: json["networkIdentificationCode"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "globalId": globalId,
        "amount": amount,
        "currencyIsoCode": currencyIsoCode,
        "processorResponseCode": processorResponseCode,
        "processorResponseText": processorResponseText,
        "processorAuthorizationCode": processorAuthorizationCode,
        "merchantName": merchantName,
        "merchantAddress": merchantAddress.toJson(),
        "merchantIdentificationNumber": merchantIdentificationNumber,
        "terminalIdentificationNumber": terminalIdentificationNumber,
        "type": type,
        "pinVerified": pinVerified,
        "processingMode": processingMode,
        "networkIdentificationCode": networkIdentificationCode,
      };
}

class Paypal {
  Paypal({
    this.token,
    required this.payerEmail,
    this.paymentId,
    this.authorizationId,
    required this.imageUrl,
    required this.debugId,
    this.payeeId,
    this.payeeEmail,
    this.customField,
    this.payerId,
    this.payerFirstName,
    this.payerLastName,
    this.payerStatus,
    this.payerPhone,
    this.sellerProtectionStatus,
    this.captureId,
    this.refundId,
    this.transactionFeeAmount,
    this.transactionFeeCurrencyIsoCode,
    this.refundFromTransactionFeeAmount,
    this.refundFromTransactionFeeCurrencyIsoCode,
    this.selectedFinancingTerm,
    this.selectedFinancingCurrencyCode,
    this.selectedFinancingDiscountPercentage,
    this.description,
    this.shippingOptionId,
    this.globalId,
    this.cobrandedCardLabel,
    this.implicitlyVaultedPaymentMethodToken,
    this.implicitlyVaultedPaymentMethodGlobalId,
    this.billingAgreementId,
    this.paypalRetailTransactionId,
    this.paypalRetailTransactionStatus,
    this.paypalRetailTransactionRefundUrl,
    this.paypalRetailTransactionLookupUrl,
    this.appUsedForScanning,
  });

  dynamic token;
  String payerEmail;
  dynamic paymentId;
  dynamic authorizationId;
  String imageUrl;
  String debugId;
  dynamic payeeId;
  dynamic payeeEmail;
  dynamic customField;
  dynamic payerId;
  dynamic payerFirstName;
  dynamic payerLastName;
  dynamic payerStatus;
  dynamic payerPhone;
  dynamic sellerProtectionStatus;
  dynamic captureId;
  dynamic refundId;
  dynamic transactionFeeAmount;
  dynamic transactionFeeCurrencyIsoCode;
  dynamic refundFromTransactionFeeAmount;
  dynamic refundFromTransactionFeeCurrencyIsoCode;
  dynamic selectedFinancingTerm;
  dynamic selectedFinancingCurrencyCode;
  dynamic selectedFinancingDiscountPercentage;
  dynamic description;
  dynamic shippingOptionId;
  dynamic globalId;
  dynamic cobrandedCardLabel;
  dynamic implicitlyVaultedPaymentMethodToken;
  dynamic implicitlyVaultedPaymentMethodGlobalId;
  dynamic billingAgreementId;
  dynamic paypalRetailTransactionId;
  dynamic paypalRetailTransactionStatus;
  dynamic paypalRetailTransactionRefundUrl;
  dynamic paypalRetailTransactionLookupUrl;
  dynamic appUsedForScanning;

  factory Paypal.fromJson(Map<String, dynamic> json) => Paypal(
        token: json["token"],
        payerEmail: json["payerEmail"],
        paymentId: json["paymentId"],
        authorizationId: json["authorizationId"],
        imageUrl: json["imageUrl"],
        debugId: json["debugId"],
        payeeId: json["payeeId"],
        payeeEmail: json["payeeEmail"],
        customField: json["customField"],
        payerId: json["payerId"],
        payerFirstName: json["payerFirstName"],
        payerLastName: json["payerLastName"],
        payerStatus: json["payerStatus"],
        payerPhone: json["payerPhone"],
        sellerProtectionStatus: json["sellerProtectionStatus"],
        captureId: json["captureId"],
        refundId: json["refundId"],
        transactionFeeAmount: json["transactionFeeAmount"],
        transactionFeeCurrencyIsoCode: json["transactionFeeCurrencyIsoCode"],
        refundFromTransactionFeeAmount: json["refundFromTransactionFeeAmount"],
        refundFromTransactionFeeCurrencyIsoCode: json["refundFromTransactionFeeCurrencyIsoCode"],
        selectedFinancingTerm: json["selectedFinancingTerm"],
        selectedFinancingCurrencyCode: json["selectedFinancingCurrencyCode"],
        selectedFinancingDiscountPercentage: json["selectedFinancingDiscountPercentage"],
        description: json["description"],
        shippingOptionId: json["shippingOptionId"],
        globalId: json["globalId"],
        cobrandedCardLabel: json["cobrandedCardLabel"],
        implicitlyVaultedPaymentMethodToken: json["implicitlyVaultedPaymentMethodToken"],
        implicitlyVaultedPaymentMethodGlobalId: json["implicitlyVaultedPaymentMethodGlobalId"],
        billingAgreementId: json["billingAgreementId"],
        paypalRetailTransactionId: json["paypalRetailTransactionId"],
        paypalRetailTransactionStatus: json["paypalRetailTransactionStatus"],
        paypalRetailTransactionRefundUrl: json["paypalRetailTransactionRefundUrl"],
        paypalRetailTransactionLookupUrl: json["paypalRetailTransactionLookupUrl"],
        appUsedForScanning: json["appUsedForScanning"],
      );

  Map<String, dynamic> toJson() => {
        "token": token,
        "payerEmail": payerEmail,
        "paymentId": paymentId,
        "authorizationId": authorizationId,
        "imageUrl": imageUrl,
        "debugId": debugId,
        "payeeId": payeeId,
        "payeeEmail": payeeEmail,
        "customField": customField,
        "payerId": payerId,
        "payerFirstName": payerFirstName,
        "payerLastName": payerLastName,
        "payerStatus": payerStatus,
        "payerPhone": payerPhone,
        "sellerProtectionStatus": sellerProtectionStatus,
        "captureId": captureId,
        "refundId": refundId,
        "transactionFeeAmount": transactionFeeAmount,
        "transactionFeeCurrencyIsoCode": transactionFeeCurrencyIsoCode,
        "refundFromTransactionFeeAmount": refundFromTransactionFeeAmount,
        "refundFromTransactionFeeCurrencyIsoCode": refundFromTransactionFeeCurrencyIsoCode,
        "selectedFinancingTerm": selectedFinancingTerm,
        "selectedFinancingCurrencyCode": selectedFinancingCurrencyCode,
        "selectedFinancingDiscountPercentage": selectedFinancingDiscountPercentage,
        "description": description,
        "shippingOptionId": shippingOptionId,
        "globalId": globalId,
        "cobrandedCardLabel": cobrandedCardLabel,
        "implicitlyVaultedPaymentMethodToken": implicitlyVaultedPaymentMethodToken,
        "implicitlyVaultedPaymentMethodGlobalId": implicitlyVaultedPaymentMethodGlobalId,
        "billingAgreementId": billingAgreementId,
        "paypalRetailTransactionId": paypalRetailTransactionId,
        "paypalRetailTransactionStatus": paypalRetailTransactionStatus,
        "paypalRetailTransactionRefundUrl": paypalRetailTransactionRefundUrl,
        "paypalRetailTransactionLookupUrl": paypalRetailTransactionLookupUrl,
        "appUsedForScanning": appUsedForScanning,
      };
}

class Subscription {
  Subscription({
    this.billingPeriodEndDate,
    this.billingPeriodStartDate,
  });

  dynamic billingPeriodEndDate;
  dynamic billingPeriodStartDate;

  factory Subscription.fromJson(Map<String, dynamic> json) => Subscription(
        billingPeriodEndDate: json["billingPeriodEndDate"],
        billingPeriodStartDate: json["billingPeriodStartDate"],
      );

  Map<String, dynamic> toJson() => {
        "billingPeriodEndDate": billingPeriodEndDate,
        "billingPeriodStartDate": billingPeriodStartDate,
      };
}
