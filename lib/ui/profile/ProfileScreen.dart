import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:foodie_customer/constants.dart';
import 'package:foodie_customer/main.dart';
import 'package:foodie_customer/model/User.dart';
import 'package:foodie_customer/services/FirebaseHelper.dart';
import 'package:foodie_customer/services/helper.dart';
import 'package:foodie_customer/ui/accountDetails/AccountDetailsScreen.dart';
import 'package:foodie_customer/ui/auth/AuthScreen.dart';
import 'package:foodie_customer/ui/contactUs/ContactUsScreen.dart';
import 'package:foodie_customer/ui/reauthScreen/reauth_user_screen.dart';
import 'package:foodie_customer/ui/settings/SettingsScreen.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  final User user;

  ProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  late User user;

  @override
  void initState() {
    user = widget.user;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode(context) ? Color(DARK_COLOR) : null,
      body: SingleChildScrollView(
        child: Column(children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 32.0, left: 32, right: 32),
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: <Widget>[
                Center(child: displayCircleImage(user.profilePictureURL, 130, false)),
                Positioned.directional(
                  textDirection: Directionality.of(context),
                  start: 80,
                  end: 0,
                  child: FloatingActionButton(
                      backgroundColor: Color(COLOR_ACCENT),
                      child: Icon(
                        Icons.camera_alt,
                        color: isDarkMode(context) ? Colors.black : Colors.white,
                      ),
                      mini: true,
                      onPressed: _onCameraClick),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0, right: 32, left: 32),
            child: Text(
              user.fullName(),
              style: TextStyle(color: isDarkMode(context) ? Colors.white : Colors.black, fontSize: 20),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              children: <Widget>[
                ListTile(
                  onTap: () {
                    push(context, AccountDetailsScreen(user: user));
                  },
                  title: Text(
                    "accountDetails",
                    style: TextStyle(fontSize: 16),
                  ).tr(),
                  leading: Icon(
                    CupertinoIcons.person_alt,
                    color: Colors.blue,
                  ),
                ),
                // ListTile(
                //   onTap: () {
                //     push(context, SettingsScreen(user: user));
                //   },
                //   title: Text(
                //     "settings",
                //     style: TextStyle(fontSize: 16),
                //   ).tr(),
                //   leading: Icon(
                //     CupertinoIcons.settings,
                //     color: Colors.grey,
                //   ),
                // ),
                ListTile(
                  onTap: () {
                    push(context, ContactUsScreen());
                  },
                  title: Text(
                    "contactUs",
                    style: TextStyle(fontSize: 16),
                  ).tr(),
                  leading: Hero(
                    tag: 'contactUs'.tr(),
                    child: Icon(
                      CupertinoIcons.phone_solid,
                      color: Colors.green,
                    ),
                  ),
                ),
                ListTile(
                  onTap: () async {
                    AuthProviders? authProvider;
                    List<auth.UserInfo> userInfoList = auth.FirebaseAuth.instance.currentUser?.providerData ?? [];
                    await Future.forEach(userInfoList, (auth.UserInfo info) {
                      switch (info.providerId) {
                        case 'password':
                          authProvider = AuthProviders.PASSWORD;
                          break;
                        case 'phone':
                          authProvider = AuthProviders.PHONE;
                          break;
                        case 'facebook.com':
                          authProvider = AuthProviders.FACEBOOK;
                          break;
                        case 'apple.com':
                          authProvider = AuthProviders.APPLE;
                          break;
                      }
                    });
                    bool? result = await showDialog(
                      context: context,
                      builder: (context) => ReAuthUserScreen(
                        provider: authProvider!,
                        email: auth.FirebaseAuth.instance.currentUser!.email,
                        phoneNumber: auth.FirebaseAuth.instance.currentUser!.phoneNumber,
                        deleteUser: true,
                      ),
                    );
                    if (result != null && result) {
                      await showProgress(context, "deletingAccount".tr(), false);
                      await FireStoreUtils.deleteUser();
                      await hideProgress();
                      MyAppState.currentUser = null;
                      pushAndRemoveUntil(context, AuthScreen(), false);
                    }
                  },
                  title: Text(
                    'Delete Account'.tr(),
                    style: TextStyle(fontSize: 16),
                  ).tr(),
                  leading: Icon(
                    CupertinoIcons.delete,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: double.infinity),
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  padding: EdgeInsets.only(top: 12, bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0), side: BorderSide(color: isDarkMode(context) ? Colors.grey.shade700 : Colors.grey.shade200)),
                ),
                child: Text(
                  'Log Out',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDarkMode(context) ? Colors.white : Colors.black),
                ).tr(),
                onPressed: () async {
                  //user.active = false;
                  user.lastOnlineTimestamp = Timestamp.now();
                  await FireStoreUtils.updateCurrentUser(user);
                  await auth.FirebaseAuth.instance.signOut();
                  MyAppState.currentUser = null;
                  pushAndRemoveUntil(context, AuthScreen(), false);
                },
              ),
            ),
          ),
        ]),
      ),
    );
  }

  _onCameraClick() {
    final action = CupertinoActionSheet(
      message: Text(
        "addProfilePicture",
        style: TextStyle(fontSize: 15.0),
      ).tr(),
      actions: <Widget>[
        CupertinoActionSheetAction(
          child: Text("removePicture").tr(),
          isDestructiveAction: true,
          onPressed: () async {
            Navigator.pop(context);
            showProgress(context, "removingPicture".tr(), false);
            user.profilePictureURL = '';
            await FireStoreUtils.updateCurrentUser(user);
            MyAppState.currentUser = user;
            hideProgress();
            setState(() {});
          },
        ),
        CupertinoActionSheetAction(
          child: Text("chooseFromGallery").tr(),
          onPressed: () async {
            Navigator.pop(context);
            XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
            if (image != null) {
              await _imagePicked(File(image.path));
            }
            setState(() {});
          },
        ),
        CupertinoActionSheetAction(
          child: Text("takeAPicture").tr(),
          onPressed: () async {
            Navigator.pop(context);
            XFile? image = await _imagePicker.pickImage(source: ImageSource.camera);
            if (image != null) {
              await _imagePicked(File(image.path));
            }
            setState(() {});
          },
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        child: Text('Cancel').tr(),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
    showCupertinoModalPopup(context: context, builder: (context) => action);
  }

  Future<void> _imagePicked(File image) async {
    showProgress(context, "uploadingImage".tr(), false);
    File compressedImage = await FireStoreUtils.compressImage(image);
    final bytes = compressedImage.readAsBytesSync().lengthInBytes;
    final kb = bytes / 1024;
    final mb = kb / 1024;

    if (mb > 2) {
      hideProgress();
      showAlertDialog(context, "error".tr(), "imageTooLarge".tr(), true);
      return;
    }
    user.profilePictureURL = await FireStoreUtils.uploadUserImageToFireStorage(compressedImage, user.userID);
    await FireStoreUtils.updateCurrentUser(user);
    MyAppState.currentUser = user;
    hideProgress();
  }
}
