import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:the_apple_sign_in/the_apple_sign_in.dart' as apple;
import 'package:foodie_customer/constants.dart';
import 'package:foodie_customer/main.dart';
import 'package:foodie_customer/model/User.dart';
import 'package:foodie_customer/services/FirebaseHelper.dart';
import 'package:foodie_customer/services/helper.dart';
import 'package:foodie_customer/ui/container/ContainerScreen.dart';
import 'package:foodie_customer/ui/phoneAuth/PhoneNumberInputScreen.dart';
import 'package:foodie_customer/ui/resetPasswordScreen/ResetPasswordScreen.dart';

class LoginScreen extends StatefulWidget {
  @override
  State createState() {
    return _LoginScreen();
  }
}

class _LoginScreen extends State<LoginScreen> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  AutovalidateMode _validate = AutovalidateMode.disabled;
  GlobalKey<FormState> _key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: isDarkMode(context) ? Colors.white : Colors.black),
        elevation: 0.0,
      ),
      body: Form(
        key: _key,
        autovalidateMode: _validate,
        child: ListView(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 32.0, right: 16.0, left: 16.0),
              child: Text(
                'signIn',
                style: TextStyle(color: Color(COLOR_PRIMARY), fontSize: 25.0, fontWeight: FontWeight.bold),
              ).tr(),
            ),

            /// email address text field, visible when logging with email
            /// and password
            ConstrainedBox(
              constraints: BoxConstraints(minWidth: double.infinity),
              child: Padding(
                padding: const EdgeInsets.only(top: 32.0, right: 24.0, left: 24.0),
                child: TextFormField(
                    textAlignVertical: TextAlignVertical.center,
                    textInputAction: TextInputAction.next,
                    validator: validateEmail,
                    controller: _emailController,
                    style: TextStyle(fontSize: 18.0),
                    keyboardType: TextInputType.emailAddress,
                    cursorColor: Color(COLOR_PRIMARY),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(left: 16, right: 16),
                      hintText: 'emailAddress'.tr(),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(25.0), borderSide: BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
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
                    )),
              ),
            ),

            /// password text field, visible when logging with email and
            /// password
            ConstrainedBox(
              constraints: BoxConstraints(minWidth: double.infinity),
              child: Padding(
                padding: const EdgeInsets.only(top: 32.0, right: 24.0, left: 24.0),
                child: TextFormField(
                    textAlignVertical: TextAlignVertical.center,
                    controller: _passwordController,
                    obscureText: true,
                    validator: validatePassword,
                    onFieldSubmitted: (password) => _login(),
                    textInputAction: TextInputAction.done,
                    style: TextStyle(fontSize: 18.0),
                    cursorColor: Color(COLOR_PRIMARY),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(left: 16, right: 16),
                      hintText: 'password'.tr(),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(25.0), borderSide: BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
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
                    )),
              ),
            ),

            /// forgot password text, navigates user to ResetPasswordScreen
            /// and this is only visible when logging with email and password
            Padding(
              padding: const EdgeInsets.only(top: 16, right: 24),
              child: Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => push(context, ResetPasswordScreen()),
                  child: Text(
                    'Forgot password?'.tr(),
                    style: TextStyle(color: Colors.lightBlue, fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                ),
              ),
            ),

            /// the main action button of the screen, this is hidden if we
            /// received the code from firebase
            /// the action and the title is base on the state,
            /// * logging with email and password: send email and password to
            /// firebase
            /// * logging with phone number: submits the phone number to
            /// firebase and await for code verification
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
                  child: Text(
                    'logIn'.tr(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode(context) ? Colors.black : Colors.white,
                    ),
                  ),
                  onPressed: () => _login(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Center(
                child: Text(
                  'or',
                  style: TextStyle(color: isDarkMode(context) ? Colors.white : Colors.black),
                ).tr(),
              ),
            ),

            /// facebook login button
            Padding(
              padding: const EdgeInsets.only(right: 40.0, left: 40.0, bottom: 20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: double.infinity),
                child: ElevatedButton.icon(
                    label: Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'facebookLogin',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey.shade200),
                        ).tr()),
                    icon: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
                      child: Image.asset(
                        'assets/images/facebook_logo.png',
                        color: Colors.grey.shade200,
                        height: 30,
                        width: 30,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(FACEBOOK_BUTTON_COLOR),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        side: BorderSide(
                          color: Color(FACEBOOK_BUTTON_COLOR),
                        ),
                      ),
                    ),
                    onPressed: () async => loginWithFacebook()),
              ),
            ),
            FutureBuilder<bool>(
              future: apple.TheAppleSignIn.isAvailable(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator.adaptive(
                    valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
                  );
                }
                if (!snapshot.hasData || (snapshot.data != true)) {
                  return Container();
                } else {
                  return Padding(
                    padding: const EdgeInsets.only(right: 40.0, left: 40.0, bottom: 20),
                    child: apple.AppleSignInButton(
                      cornerRadius: 25.0,
                      type: apple.ButtonType.signIn,
                      style: isDarkMode(context) ? apple.ButtonStyle.white : apple.ButtonStyle.black,
                      onPressed: () => loginWithApple(),
                    ),
                  );
                }
              },
            ),

            /// switch between login with phone number and email login states
            InkWell(
              onTap: () {
                push(context, PhoneNumberInputScreen(login: true));
              },
              child: Padding(
                padding: EdgeInsets.only(top: 10, right: 40, left: 40),
                child: Container(
                    alignment: Alignment.bottomCenter,
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(25), border: Border.all(color: Color(COLOR_PRIMARY), width: 1)),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                      Icon(
                        Icons.phone,
                        color: Color(COLOR_PRIMARY),
                      ),
                      Text(
                        'loginWithPhoneNumber'.tr(),
                        style: TextStyle(color: Color(COLOR_PRIMARY), fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1),
                      ),
                    ])),
              ),
            )
          ],
        ),
      ),
    );
  }

  _login() async {
    if (_key.currentState?.validate() ?? false) {
      _key.currentState!.save();
      await _loginWithEmailAndPassword(_emailController.text.trim(), _passwordController.text.trim());
    } else {
      setState(() {
        _validate = AutovalidateMode.onUserInteraction;
      });
    }
  }

  /// login with email and password with firebase
  /// @param email user email
  /// @param password user password
  _loginWithEmailAndPassword(String email, String password) async {
    await showProgress(context, "loggingInPleaseWait".tr(), false);
    dynamic result = await FireStoreUtils.loginWithEmailAndPassword(email.trim(), password.trim());
    await hideProgress();
    if (result != null && result is User && result.role == USER_ROLE_CUSTOMER) {
      result.fcmToken = await FireStoreUtils.firebaseMessaging.getToken() ?? '';
      await FireStoreUtils.updateCurrentUser(result).then((value) {
        MyAppState.currentUser = result;
        print(MyAppState.currentUser!.active.toString() + "===S");
        if (MyAppState.currentUser!.active == true) {
          pushAndRemoveUntil(context, ContainerScreen(user: result), false);
        } else {
          showAlertDialog(context, "accountDisabledContactAdmin".tr(), "", true);
        }
      });
    } else if (result != null && result is String) {
      showAlertDialog(context, "NotAuthenticate".tr(), result, true);
    } else {
      showAlertDialog(context, "NotAuthenticate".tr(), 'Login failed, Please try again.'.tr(), true);
    }
  }

  ///dispose text editing controllers to avoid memory leaks
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  loginWithFacebook() async {
    try {
      await showProgress(context, "loggingInPleaseWait".tr(), false);
      dynamic result = await FireStoreUtils.loginWithFacebook();
      await hideProgress();
      if (result != null && result is User) {
        MyAppState.currentUser = result;

        if (MyAppState.currentUser!.active == true) {
          pushAndRemoveUntil(context, ContainerScreen(user: result), false);
        } else {
          showAlertDialog(context, "accountDisabledContactAdmin".tr(), "", true);
        }
      } /*else if (result != null && result is String) {
        showAlertDialog(context, 'Error'.tr(), result.tr(), true);
      } else {
        showAlertDialog(
            context, 'Error', "notLoginFacebook".tr(), true);
      }*/
    } catch (e, s) {
      await hideProgress();
      print('_LoginScreen.loginWithFacebook $e $s');
      showAlertDialog(context, 'error'.tr(), "notLoginFacebook".tr(), true);
    }
  }

  loginWithApple() async {
    try {
      await showProgress(context, "loggingInPleaseWait".tr(), false);
      dynamic result = await FireStoreUtils.loginWithApple();
      await hideProgress();
      if (result != null && result is User) {
        MyAppState.currentUser = result;
        // pushAndRemoveUntil(context, ContainerScreen(user: result), false);
        if (MyAppState.currentUser!.active == true) {
          pushAndRemoveUntil(context, ContainerScreen(user: result), false);
        } else {
          showAlertDialog(context, "accountDisabledContactAdmin".tr(), "", true);
        }
      } else if (result != null && result is String) {
        showAlertDialog(context, 'error'.tr(), result.tr(), true);
      } else {
        showAlertDialog(context, 'error', "notLoginApple".tr(), true);
      }
    } catch (e, s) {
      await hideProgress();
      print('_LoginScreen.loginWithApple $e $s');
      showAlertDialog(context, 'error'.tr(), "notLoginApple".tr(), true);
    }
  }
}
