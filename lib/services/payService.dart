//
// import 'package:flutter/material.dart';
// import 'package:pay/pay.dart';
//
//
// const _paymentItems = [
//   PaymentItem(
//     label: 'Total',
//     amount: '99.99',
//     status: PaymentItemStatus.final_price,
//   )
// ];
//
//
// class PaySampleApp extends StatefulWidget {
//   PaySampleApp({Key? key}) : super(key: key);
//
//   @override
//   _PaySampleAppState createState() => _PaySampleAppState();
// }
//
// class _PaySampleAppState extends State<PaySampleApp> {
//   void onGooglePayResult(paymentResult) {
//     debugdebugPrint(paymentResult.toString());
//   }
//
//   void onApplePayResult(paymentResult) {
//     debugPrint(paymentResult.toString());
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('T-shirt Shop'),
//       ),
//       backgroundColor: Colors.white,
//       body: ListView(
//         padding: const EdgeInsets.symmetric(horizontal: 20),
//         children: [
//           Container(
//             margin: const EdgeInsets.symmetric(vertical: 20),
//             child: const Image(
//               image: AssetImage('assets/images/good_for_breakfast.png'),
//               height: 350,
//             ),
//           ),
//
//           GooglePayButton(
//             childOnError: Text("error accour"),
//             onError: (fff){
//               print("bhf");
//               print(fff);
//             },
//             paymentConfigurationAsset:
//             'assets/json file/default_payment_profile_google_pay.json',
//             paymentItems: _paymentItems,
//             style: GooglePayButtonStyle.black,
//             type: GooglePayButtonType.pay,
//             margin: const EdgeInsets.only(top: 15.0),
//             onPaymentResult: onGooglePayResult,
//             loadingIndicator: const Center(
//               child: CircularProgressIndicator(color: Colors.red,),
//             ),
//           ),
//           const Text(
//             'Amanda\'s Polo Shirt',
//             style: TextStyle(
//               fontSize: 20,
//               color: Color(0xff333333),
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 5),
//           const Text(
//             '\$50.20',
//             style: TextStyle(
//               color: Color(0xff777777),
//              ,
//             ),
//           ),
//           const SizedBox(height: 15),
//           const Text(
//             'Description',
//             style: TextStyle(
//              ,
//               color: Color(0xff333333),
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 5),
//           const Text(
//             'A versatile full-zip that you can wear all day long and even...',
//             style: TextStyle(
//               color: Color(0xff777777),
//              ,
//             ),
//           ),
//           GooglePayButton(
//             childOnError: Text("error accour"),
//             paymentConfigurationAsset:
//             'assets/json file/default_payment_profile_google_pay.json',
//             paymentItems: _paymentItems,
//             style: GooglePayButtonStyle.black,
//             type: GooglePayButtonType.pay,
//             margin: const EdgeInsets.only(top: 15.0),
//             onPaymentResult: onGooglePayResult,
//             loadingIndicator: const Center(
//               child: CircularProgressIndicator(color: Colors.red,),
//             ),
//           ),
//           ApplePayButton(
//             paymentConfigurationAsset:
//             'assets/json file/default_payment_profile_apple_pay.json',
//             paymentItems: _paymentItems,
//             style: ApplePayButtonStyle.black,
//             type: ApplePayButtonType.buy,
//             margin: const EdgeInsets.only(top: 15.0),
//             onPaymentResult: onApplePayResult,
//             loadingIndicator: const Center(
//               child: CircularProgressIndicator(),
//             ),
//
//
//           ),
//           const SizedBox(height: 15)
//         ],
//       ),
//     );
//   }
// }
