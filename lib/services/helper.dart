import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

import '../constants.dart';

String? validateName(String? value) {
  String pattern = r'(^[a-zA-Z ]*$)';
  RegExp regExp = RegExp(pattern);
  if (value?.length == 0) {
    return "nameIsRequired".tr();
  } else if (!regExp.hasMatch(value ?? '')) {
    return "nameMustBeValid".tr();
  }
  return null;
}

String? validateMobile(String? value) {
  String pattern = r'(^\+?[0-9]*$)';
  RegExp regExp = RegExp(pattern);
  if (value?.length == 0) {
    return "mobileIsRequired".tr();
  } else if (!regExp.hasMatch(value ?? '')) {
    return "mobileNumberMustBeDigits".tr();
  } else if (value!.length < 10 || value.length > 10) {
    return "validNumber".tr();
  }
  return null;
}

String? validatePassword(String? value) {
  if ((value?.length ?? 0) < 6)
    return "passwordLength".tr();
  else
    return null;
}

String? validateEmail(String? value) {
  String pattern = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  RegExp regex = RegExp(pattern);
  if (!regex.hasMatch(value ?? ''))
    return "validEmail".tr();
  else
    return null;
}

String? validateConfirmPassword(String? password, String? confirmPassword) {
  if (password != confirmPassword) {
    return "passwordNoMatch".tr();
  } else if (confirmPassword?.length == 0) {
    return "confirmPassReq".tr();
  } else {
    return null;
  }
}

String? validateEmptyField(String? text) => text == null || text.isEmpty ? 'This field can\'t be empty.'.tr() : null;

//helper method to show progress
ProgressDialog? pd;

showProgress(BuildContext context, String message, bool isDismissible) async {
  pd = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: isDismissible);
  pd!.style(
      message: message,
      borderRadius: 10.0,
      backgroundColor: Color(COLOR_PRIMARY),
      elevation: 10.0,
      insetAnimCurve: Curves.easeInOut,
      messageTextStyle: const TextStyle(color: Colors.white, fontSize: 19.0, fontWeight: FontWeight.w600));
  await pd!.show();
}

updateProgress(String message) {
  pd!.update(message: message, maxProgress: 100);
  // progressDialog.update(message: message);
}

hideProgress() {
  pd!.hide();
}

//helper method to show alert dialog
showAlertDialog(BuildContext context, String title, String content, bool addOkButton) {
  // set up the AlertDialog
  Widget? okButton;
  if (addOkButton) {
    okButton = TextButton(
      child: Text('ok').tr(),
      onPressed: () {
        Navigator.pop(context);
      },
    );
  }
  if (Platform.isIOS) {
    CupertinoAlertDialog alert = CupertinoAlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [if (okButton != null) okButton],
    );
    showCupertinoDialog(
        context: context,
        builder: (context) {
          return alert;
        });
  } else {
    AlertDialog alert = AlertDialog(title: Text(title), content: Text(content), actions: [if (okButton != null) okButton]);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}

pushReplacement(BuildContext context, Widget destination) {
  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => destination));
}

push(BuildContext context, Widget destination) {
  Navigator.of(context).push(MaterialPageRoute(builder: (context) => destination));
}

pushAndRemoveUntil(BuildContext context, Widget destination, bool predict) {
  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => destination), (Route<dynamic> route) => predict);
}

String formatTimestamp(int timestamp) {
  var format = DateFormat('hh:mm a');
  var date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
  return format.format(date);
}

String setLastSeen(int seconds) {
  var format = DateFormat('hh:mm a');
  var date = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
  var diff = DateTime.now().millisecondsSinceEpoch - (seconds * 1000);
  if (diff < 24 * HOUR_MILLIS) {
    return format.format(date);
  } else if (diff < 48 * HOUR_MILLIS) {
    return 'yesterdayAtTime'.tr(args: ['${format.format(date)}']);
  } else {
    format = DateFormat('MMM d');
    return '${format.format(date)}';
  }
}

Widget displayImage(String picUrl) => CachedNetworkImage(
    imageBuilder: (context, imageProvider) => _getFlatImageProvider(imageProvider),
    imageUrl: getImageVAlidUrl(picUrl),
    placeholder: (context, url) => _getFlatPlaceholderOrErrorImage(true),
    errorWidget: (context, url, error) => _getFlatPlaceholderOrErrorImage(false));

Widget _getFlatPlaceholderOrErrorImage(bool placeholder) => Container(
      child: placeholder
          ? Center(
              child: CircularProgressIndicator.adaptive(
              valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
            ))
          : Icon(
              Icons.error,
              color: Color(COLOR_PRIMARY),
            ),
    );

Widget _getFlatImageProvider(ImageProvider provider) {
  return Container(
    decoration: BoxDecoration(image: DecorationImage(image: provider, fit: BoxFit.cover)),
  );
}

Widget displayCircleImage(String picUrl, double size, hasBorder) => CachedNetworkImage(
    height: size,
    width: size,
    imageBuilder: (context, imageProvider) => _getCircularImageProvider(imageProvider, size, hasBorder),
    imageUrl: getImageVAlidUrl(picUrl),
    placeholder: (context, url) => _getPlaceholderOrErrorImage(size, hasBorder),
    errorWidget: (context, url, error) => _getPlaceholderOrErrorImage(size, hasBorder));

Widget _getPlaceholderOrErrorImage(double size, hasBorder) => ClipOval(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
            color: const Color(COLOR_ACCENT),
            borderRadius: BorderRadius.all(Radius.circular(size / 2)),
            border: Border.all(
              color: Colors.white,
              style: hasBorder ? BorderStyle.solid : BorderStyle.none,
              width: 2.0,
            ),
            image: DecorationImage(
                image: Image.asset(
              'assets/images/placeholder.jpg',
              fit: BoxFit.cover,
              height: size,
              width: size,
            ).image)),
      ),
    );

Widget _getCircularImageProvider(ImageProvider provider, double size, bool hasBorder) {
  return ClipOval(
      child: Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(size / 2)),
        border: Border.all(
          color: Colors.white,
          style: hasBorder ? BorderStyle.solid : BorderStyle.none,
          width: 1.0,
        ),
        image: DecorationImage(
          image: provider,
          fit: BoxFit.cover,
        )),
  ));
}

bool isDarkMode(BuildContext context) {
  if (Theme.of(context).brightness == Brightness.light) {
    return false;
  } else {
    return true;
  }
}

/// Determine the current position of the device.
///
/// When the location services are not enabled or permissions
/// are denied the `Future` will return an error.
Future<Position> getCurrentLocation() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.

      return Future.error("LocationDenied".tr());
    }
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error("LocationServicesDisabled".tr());
    }
  }
  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    return Future.error("LocationPermanentlyDenied".tr());
  }

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  return await Geolocator.getCurrentPosition();
}

String audioMessageTime(Duration audioDuration) {
  String twoDigits(int n) {
    if (n >= 10) return '$n';
    return '0$n';
  }

  String twoDigitsHours(int n) {
    if (n >= 10) return '$n:';
    if (n == 0) return '';
    return '0$n:';
  }

  String twoDigitMinutes = twoDigits(audioDuration.inMinutes.remainder(60));
  String twoDigitSeconds = twoDigits(audioDuration.inSeconds.remainder(60));
  return '${twoDigitsHours(audioDuration.inHours)}$twoDigitMinutes:$twoDigitSeconds';
}

String updateTime(Timer timer) {
  Duration callDuration = Duration(seconds: timer.tick);
  String twoDigits(int n) {
    if (n >= 10) return '$n';
    return '0$n';
  }

  String twoDigitsHours(int n) {
    if (n >= 10) return '$n:';
    if (n == 0) return '';
    return '0$n:';
  }

  String twoDigitMinutes = twoDigits(callDuration.inMinutes.remainder(60));
  String twoDigitSeconds = twoDigits(callDuration.inSeconds.remainder(60));
  return '${twoDigitsHours(callDuration.inHours)}$twoDigitMinutes:$twoDigitSeconds';
}

Widget showEmptyState(String title, BuildContext context, {String? description, String? buttonTitle, VoidCallback? action}) {
  return Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
      const SizedBox(height: 30),
      Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: isDarkMode(context) ? Colors.white : Colors.black)),
      const SizedBox(height: 15),
      Text(
        description == null ? "" : description.toString(),
        textAlign: TextAlign.center,
        style: TextStyle(color: isDarkMode(context) ? Colors.white : Colors.black, fontSize: 16),
      ),
      const SizedBox(height: 25),
      if (action != null)
        Padding(
          padding: const EdgeInsets.only(left: 24.0, right: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: double.infinity),
            child: ElevatedButton(
                child: Text(
                  buttonTitle!,
                  style: TextStyle(color: isDarkMode(context) ? Colors.white : Colors.black, fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: Color(COLOR_PRIMARY),
                ),
                onPressed: action),
          ),
        )
    ]),
  );
}

String orderDate(Timestamp? timestamp) {
  return DateFormat(' MMM d yyyy').format(DateTime.fromMillisecondsSinceEpoch(timestamp!.millisecondsSinceEpoch));
}

class ShowDialogToDismiss extends StatelessWidget {
  final String content;
  final String title;
  final String buttonText;
  final String? secondaryButtonText;
  final VoidCallback? action;

  ShowDialogToDismiss({required this.title, required this.buttonText, required this.content, this.secondaryButtonText, this.action});

  @override
  Widget build(BuildContext context) {
    if (!Platform.isIOS) {
      return AlertDialog(
        title: Text(
          title,
        ),
        content: Text(
          this.content,
        ),
        actions: [
          if (action != null)
            TextButton(
              child: Text(
                secondaryButtonText!,
                style: TextStyle(color: Colors.redAccent),
              ),
              onPressed: action,
            ),
          TextButton(
            child: Text(
              buttonText,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    } else {
      return CupertinoAlertDialog(
        title: Text(
          title,
        ),
        content: Text(
          this.content,
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text(
              buttonText[0].toUpperCase() + buttonText.substring(1).toLowerCase(),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          if (action != null)
            CupertinoDialogAction(
              isDefaultAction: true,
              isDestructiveAction: true,
              child: new Text(
                secondaryButtonText![0].toUpperCase() + secondaryButtonText!.substring(1).toLowerCase(),
              ),
              onPressed: action,
            ),
        ],
      );
    }
  }
}
