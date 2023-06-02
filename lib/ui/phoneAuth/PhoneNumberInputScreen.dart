import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart' as Easy;
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:foodie_customer/constants.dart';
import 'package:foodie_customer/main.dart';
import 'package:foodie_customer/model/User.dart';
import 'package:foodie_customer/services/FirebaseHelper.dart';
import 'package:foodie_customer/services/helper.dart';
import 'package:foodie_customer/ui/container/ContainerScreen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

File? _image;

class PhoneNumberInputScreen extends StatefulWidget {
  final bool login;

  const PhoneNumberInputScreen({Key? key, required this.login}) : super(key: key);

  @override
  _PhoneNumberInputScreenState createState() => _PhoneNumberInputScreenState();
}

class _PhoneNumberInputScreenState extends State<PhoneNumberInputScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  GlobalKey<FormState> _key = GlobalKey();
  String? firstName, lastName, _phoneNumber, _verificationID, referralCode;
  bool _isPhoneValid = false, _codeSent = false;
  AutovalidateMode _validate = AutovalidateMode.disabled;

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid && !widget.login) {
      retrieveLostData();
    }
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: isDarkMode(context) ? Colors.white : Colors.black),
      ),
      body: SingleChildScrollView(
        child: new Container(
          margin: new EdgeInsets.only(left: 16.0, right: 16, bottom: 16),
          child: new Form(
            key: _key,
            autovalidateMode: _validate,
            child: Column(
              children: <Widget>[
                new Align(
                    alignment: Directionality.of(context) == TextDirection.ltr ? Alignment.topLeft : Alignment.topRight,
                    child: Text(
                      widget.login ? "signIn".tr() : "createNewAccount".tr(),
                      style: TextStyle(color: Color(COLOR_PRIMARY), fontWeight: FontWeight.bold, fontSize: 25.0),
                    ).tr()),

                /// user profile picture,  this is visible until we verify the
                /// code in case of sign up with phone number
                // Padding(
                //   padding: const EdgeInsets.only(
                //       left: 8.0, top: 32, right: 8, bottom: 8),
                //   child: Visibility(
                //     visible: !_codeSent && !widget.login,
                //     child: Stack(
                //       alignment: Alignment.bottomCenter,
                //       children: <Widget>[
                //         CircleAvatar(
                //           radius: 65,
                //           backgroundColor: Colors.grey.shade400,
                //           child: ClipOval(
                //             child: SizedBox(
                //               width: 170,
                //               height: 170,
                //               child: _image == null
                //                   ? Image.asset(
                //                       'assets/images/placeholder.jpg',
                //                       fit: BoxFit.cover,
                //                     )
                //                   : Image.file(
                //                       _image!,
                //                       fit: BoxFit.cover,
                //                     ),
                //             ),
                //           ),
                //         ),
                //         Positioned(
                //           left: 80,
                //           right: 0,
                //           child: FloatingActionButton(
                //               backgroundColor: Color(COLOR_ACCENT),
                //               child: Icon(
                //                 CupertinoIcons.camera,
                //                 color: isDarkMode(context)
                //                     ? Colors.black
                //                     : Colors.white,
                //               ),
                //               mini: true,
                //               onPressed: () => _onCameraClick),
                //         )
                //       ],
                //     ),
                //   ),
                // ),

                /// user first name text field , this is visible until we verify the
                /// code in case of sign up with phone number
                Visibility(
                  visible: !_codeSent && !widget.login,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: double.infinity),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
                      child: TextFormField(
                        cursorColor: Color(COLOR_PRIMARY),
                        textAlignVertical: TextAlignVertical.center,
                        validator: validateName,
                        controller: _firstNameController,
                        onSaved: (String? val) {
                          firstName = val;
                        },
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          contentPadding: new EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          fillColor: Colors.white,
                          hintText: "firstName".tr(),
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
                        ),
                      ),
                    ),
                  ),
                ),

                /// last name of the user , this is visible until we verify the
                /// code in case of sign up with phone number
                Visibility(
                  visible: !_codeSent && !widget.login,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: double.infinity),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
                      child: TextFormField(
                        validator: validateName,
                        textAlignVertical: TextAlignVertical.center,
                        cursorColor: Color(COLOR_PRIMARY),
                        onSaved: (String? val) {
                          lastName = val;
                        },
                        controller: _lastNameController,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          contentPadding: new EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          fillColor: Colors.white,
                          hintText: "lastName".tr(),
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
                        ),
                      ),
                    ),
                  ),
                ),

                /// user phone number,  this is visible until we verify the code
                Visibility(
                  visible: !_codeSent,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(25), shape: BoxShape.rectangle, border: Border.all(color: Colors.grey.shade200)),
                      child: InternationalPhoneNumberInput(
                        onInputChanged: (PhoneNumber number) => _phoneNumber = number.phoneNumber,
                        onInputValidated: (bool value) => _isPhoneValid = value,
                        ignoreBlank: true,
                        autoValidateMode: AutovalidateMode.onUserInteraction,
                        inputDecoration: InputDecoration(
                          hintText: 'phoneNumber'.tr(),
                          border: const OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                          isDense: true,
                          errorBorder: const OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                        ),
                        inputBorder: const OutlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                        initialValue: PhoneNumber(isoCode: 'US'),
                        selectorConfig: const SelectorConfig(selectorType: PhoneInputSelectorType.DIALOG),
                      ),
                    ),
                  ),
                ),

                Visibility(
                  visible: !_codeSent && !widget.login,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: double.infinity),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
                      child: TextFormField(
                        textAlignVertical: TextAlignVertical.center,
                        textInputAction: TextInputAction.next,
                        onSaved: (String? val) {
                          referralCode = val;
                        },
                        style: TextStyle(fontSize: 18.0),
                        cursorColor: Color(COLOR_PRIMARY),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          fillColor: Colors.white,
                          hintText: 'Referral Code (Optional)'.tr(),
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
                        ),
                      ),
                    ),
                  ),
                ),

                /// code validation field, this is visible in case of sign up with
                /// phone number and the code is sent
                Visibility(
                  visible: _codeSent,
                  child: Padding(
                    padding: EdgeInsets.only(top: 32.0, right: 24.0, left: 24.0),
                    child: PinCodeTextField(
                      length: 6,
                      appContext: context,
                      keyboardType: TextInputType.phone,
                      backgroundColor: Colors.transparent,
                      pinTheme: PinTheme(
                          shape: PinCodeFieldShape.box,
                          borderRadius: BorderRadius.circular(5),
                          fieldHeight: 40,
                          fieldWidth: 40,
                          activeColor: Color(COLOR_PRIMARY),
                          activeFillColor: isDarkMode(context) ? Colors.grey.shade700 : Colors.grey.shade100,
                          selectedFillColor: Colors.transparent,
                          selectedColor: Color(COLOR_PRIMARY),
                          inactiveColor: Colors.grey.shade600,
                          inactiveFillColor: Colors.transparent),
                      enableActiveFill: true,
                      onCompleted: (v) {
                        _submitCode(v);
                      },
                      onChanged: (value) {
                        print(value);
                      },
                    ),
                  ),
                ),

                /// the main action button of the screen, this is hidden if we
                /// received the code from firebase
                /// the action and the title is base on the state,
                /// * Sign up with email and password: send email and password to
                /// firebase
                /// * Sign up with phone number: submits the phone number to
                /// firebase and await for code verification
                Visibility(
                  visible: !_codeSent,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 40.0, left: 40.0, top: 40.0),
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
                        onPressed: () => _signUp(),
                        child: Text(
                          "sendCode".tr(),
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDarkMode(context) ? Colors.black : Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Center(
                    child: Text(
                      "or",
                      style: TextStyle(color: isDarkMode(context) ? Colors.white : Colors.black),
                    ).tr(),
                  ),
                ),

                /// switch between sign up with phone number and email sign up states
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    widget.login ? "loginWithEmail".tr() : "signUpWithEmail".tr(),
                    style: TextStyle(color: Colors.lightBlue, fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// submits the code to firebase to be validated, then get get the user
  /// object from firebase database
  /// @param code the code from input from code field
  /// creates a new user from phone login
  void _submitCode(String code) async {
    await showProgress(context, widget.login ? "loggingIn".tr() : "signingUp".tr(), false);
    try {
      if (_verificationID != null) {
        dynamic result = await FireStoreUtils.firebaseSubmitPhoneNumberCode(
          _verificationID!,
          code,
          _phoneNumber!,
          context,
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
          referralCode: referralCode??''
        );
        await hideProgress();
        if (result != null && result is User) {
          MyAppState.currentUser = result;
          pushAndRemoveUntil(context, ContainerScreen(user: result), false);
          if (MyAppState.currentUser!.active == true) {
            pushAndRemoveUntil(context, ContainerScreen(user: result), false);
          } else {
            showAlertDialog(context, "accountDisabledContactAdmin".tr(), "", true);
          }
          // pushAndRemoveUntil(context, ContainerScreen(user: result), false);
        } else if (result != null && result is String) {
          showAlertDialog(context, "failed".tr(), result, true);
        } else {
          showAlertDialog(context, "failed".tr(), "notCreateUserPhone".tr(), true);
        }
      } else {
        await hideProgress();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("notVerificationID".tr()),
          duration: Duration(seconds: 6),
        ));
      }
    } on auth.FirebaseAuthException catch (exception) {
      hideProgress();
      String message = "anErrorOccurredTryAgain".tr();
      switch (exception.code) {
        case 'invalid-verification-code':
          message = "invalidCodeOrExpired".tr();
          break;
        case 'user-disabled':
          message = "userDisabled".tr();
          break;
        default:
          message = "anErrorOccurredTryAgain".tr();
          break;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message.tr(),
          ),
        ),
      );
    } catch (e, s) {
      print('_PhoneNumberInputScreenState._submitCode $e $s');
      hideProgress();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "anErrorOccurredTryAgain".tr(),
          ),
        ),
      );
    }
  }

  /// used on android by the image picker lib, sometimes on android the image
  /// is lost
  Future<void> retrieveLostData() async {
    final LostDataResponse? response = await _imagePicker.retrieveLostData();
    if (response == null) {
      return;
    }
    if (response.file != null) {
      setState(() {
        _image = File(response.file!.path);
      });
    }
  }

  _signUp() async {
    if (_key.currentState?.validate() ?? false) {
      _key.currentState!.save();
      if(widget.login){
        await _submitPhoneNumber(_phoneNumber!);
      }else{
        if (_isPhoneValid) {
          if (referralCode.toString().isNotEmpty) {
            FireStoreUtils.checkReferralCodeValidOrNot(referralCode.toString()).then((value) async {
              if (value == true) {
                await _submitPhoneNumber(_phoneNumber!);
              } else {
                final snack = SnackBar(
                  content: Text(
                    'Referral Code is Invalid'.tr(),
                    style: TextStyle(color: Colors.white),
                  ),
                  duration: Duration(seconds: 2),
                  backgroundColor: Colors.black,
                );
                ScaffoldMessenger.of(context).showSnackBar(snack);
              }
            });
          }else{
            await _submitPhoneNumber(_phoneNumber!);
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("InvalidPhoneNo".tr()),
          ));
        }
      }

    } else {
      setState(() {
        _validate = AutovalidateMode.onUserInteraction;
      });
    }
  }

  /// sends a request to firebase to create a new user using phone number and
  /// navigate to [ContainerScreen] after wards
  _submitPhoneNumber(String phoneNumber) async {
    //send code
    await showProgress(context, "SendingCode".tr(), true);
    await FireStoreUtils.firebaseSubmitPhoneNumber(
      phoneNumber,
      (String verificationId) {
        if (mounted) {
          hideProgress();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "codeTimeOut".tr(),
              ),
            ),
          );
          setState(() {
            _codeSent = false;
          });
        }
      },
      (String? verificationId, int? forceResendingToken) {
        if (mounted) {
          hideProgress();
          _verificationID = verificationId;
          setState(() {
            _codeSent = true;
          });
        }
      },
      (auth.FirebaseAuthException error) {
        if (mounted) {
          hideProgress();
          print('--->${error.code}');
          print('${error.message} ${error.stackTrace}');
          String message = "anErrorOccurredTryAgain".tr();
          switch (error.code) {
            case 'invalid-verification-code':
              message = "invalidCodeOrExpired".tr();
              break;
            case 'user-disabled':
              message = "userDisabled".tr();
              break;
            default:
              message = "anErrorOccurredTryAgain".tr();
              break;
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                message.tr(),
              ),
            ),
          );
        }
      },
      (auth.PhoneAuthCredential credential) async {
        if (mounted) {
          auth.UserCredential userCredential = await auth.FirebaseAuth.instance.signInWithCredential(credential);
          User? user = await FireStoreUtils.getCurrentUser(userCredential.user?.uid ?? '');
          if (user != null) {
            hideProgress();
            MyAppState.currentUser = user;
            pushAndRemoveUntil(context, ContainerScreen(user: user), false);
          } else {
            /// create a new user from phone login
            String profileImageUrl = '';
            if (_image != null) {
              File compressedImage = await FireStoreUtils.compressImage(_image!);
              final bytes = compressedImage.readAsBytesSync().lengthInBytes;
              final kb = bytes / 1024;
              final mb = kb / 1024;

              if (mb > 2) {
                hideProgress();
                showAlertDialog(context, "error".tr(), "imageTooLarge".tr(), true);
                return;
              }
              profileImageUrl = await FireStoreUtils.uploadUserImageToFireStorage(compressedImage, userCredential.user?.uid ?? '');
            }
            User user = User(
                firstName: _firstNameController.text,
                lastName: _lastNameController.text,
                fcmToken: await FireStoreUtils.firebaseMessaging.getToken() ?? '',
                phoneNumber: phoneNumber,
                active: true,
                role: USER_ROLE_CUSTOMER,
                lastOnlineTimestamp: Timestamp.now(),
                settings: UserSettings(),
                email: '',
                profilePictureURL: profileImageUrl,
                userID: userCredential.user?.uid ?? '');
            String? errorMessage = await FireStoreUtils.firebaseCreateNewUser(user, referralCode??'');
            hideProgress();
            if (errorMessage == null) {
              MyAppState.currentUser = user;
              pushAndRemoveUntil(context, ContainerScreen(user: user), false);
            } else {
              showAlertDialog(context, "failed".tr(), "notCreateUserPhone".tr(), true);
            }
          }
        }
      },
    );
  }
}
