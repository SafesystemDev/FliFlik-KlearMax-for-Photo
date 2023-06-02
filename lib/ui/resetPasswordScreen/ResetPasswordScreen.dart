import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:foodie_customer/constants.dart';
import 'package:foodie_customer/services/helper.dart';

class ResetPasswordScreen extends StatefulWidget {
  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  GlobalKey<FormState> _key = GlobalKey();
  AutovalidateMode _validate = AutovalidateMode.disabled;
  String _emailAddress = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: isDarkMode(context) ? Colors.white : Colors.black),
        elevation: 0.0,
      ),
      body: Form(
        autovalidateMode: _validate,
        key: _key,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(top: 32.0, right: 16.0, left: 16.0),
                  child: Text(
                    'Reset Password',
                    style: TextStyle(color: Color(COLOR_PRIMARY), fontSize: 25.0, fontWeight: FontWeight.bold),
                  ).tr(),
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(minWidth: double.infinity),
                child: Padding(
                  padding: const EdgeInsets.only(top: 32.0, right: 24.0, left: 24.0),
                  child: TextFormField(
                    textAlignVertical: TextAlignVertical.center,
                    textInputAction: TextInputAction.done,
                    validator: validateEmail,
                    onFieldSubmitted: (_) => resetPassword(),
                    onSaved: (val) => _emailAddress = val!,
                    style: TextStyle(fontSize: 18.0),
                    keyboardType: TextInputType.emailAddress,
                    cursorColor: Color(COLOR_PRIMARY),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(left: 16, right: 16),
                      hintText: 'E-mail'.tr(),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide(color: Color(COLOR_PRIMARY), width: 2.0),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Theme.of(context).errorColor),
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Theme.of(context).errorColor),
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 40.0, left: 40.0, top: 40),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: double.infinity),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(COLOR_PRIMARY),
                      padding: EdgeInsets.only(top: 12, bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        side: BorderSide(
                          color: Color(COLOR_PRIMARY),
                        ),
                      ),
                    ),
                    onPressed: () => resetPassword(),
                    child: Text(
                      'Send Link'.tr(),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode(context) ? Colors.black : Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  resetPassword() async {
    if (_key.currentState?.validate() ?? false) {
      _key.currentState!.save();
      showProgress(context, "SendingEmail".tr(), false);
      await auth.FirebaseAuth.instance.sendPasswordResetEmail(email: _emailAddress);
      hideProgress();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please check your email.'.tr(),
          ),
        ),
      );
    } else {
      setState(() {
        _validate = AutovalidateMode.onUserInteraction;
      });
    }
  }
}
