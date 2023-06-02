import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:foodie_customer/constants.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  String? termsAndCondition;

  @override
  void initState() {
    FirebaseFirestore.instance.collection(Setting).doc("privacyPolicy").get().then((value) {
      setState(() {
        termsAndCondition = value['privacy_policy'];
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(
            Icons.arrow_back,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: termsAndCondition != null
              ? HtmlWidget(
                  // the first parameter (`html`) is required
                  '''
                  $termsAndCondition
                   ''',
                  onErrorBuilder: (context, element, error) => Text('$element error: $error'),
                  onLoadingBuilder: (context, element, loadingProgress) => const CircularProgressIndicator(),
                )
              : const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}
