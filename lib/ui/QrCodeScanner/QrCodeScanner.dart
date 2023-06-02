import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_qr_bar_scanner/qr_bar_scanner_camera.dart';
import 'package:foodie_customer/constants.dart';
import 'package:foodie_customer/model/VendorModel.dart';
import 'package:foodie_customer/services/helper.dart';
import 'package:foodie_customer/ui/vendorProductsScreen/newVendorProductsScreen.dart';

class QrCodeScanner extends StatefulWidget {
  const QrCodeScanner({Key? key}) : super(key: key);

  @override
  State<QrCodeScanner> createState() => _QrCodeScannerState();
}

class _QrCodeScannerState extends State<QrCodeScanner> {
  String? _qrInfo = 'Scan a QR/Bar code'.tr();
  bool _camState = false, isMainCall = false;


  _scanCode() {
    setState(() {
      _camState = true;
    });
  }

  @override
  void initState() {
    super.initState();
    _scanCode();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              elevation: 0,
              title: Text(
                "QR Code Scanner".tr(),
                style: TextStyle(fontFamily: "Poppins", letterSpacing: 0.5, fontWeight: FontWeight.normal, color: isDarkMode(context) ? Colors.white : Colors.black),
              ),
              centerTitle: false,
              automaticallyImplyLeading: false,
              leading: IconButton(
                icon: Icon(
                  Icons.chevron_left,
                  color: isDarkMode(context) ? Colors.white : Colors.black,
                  size: 40,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ), //isDarkMode(context) ? Color(COLOR_DARK) : null,
            body: Container(
                margin: const EdgeInsets.only(left: 10, right: 10),
                child: _camState
                    ? Center(
                        child: SizedBox(
                          height: 1000,
                          width: 500,
                          child: QRBarScannerCamera(
                            onError: (context, error) => Text(
                              error.toString(),
                              style: const TextStyle(color: Colors.red),
                            ),
                            qrCodeCallback: (code) {
                              // _qrCallback(code);
                              print("code ius $code");
                              if (code != null && code.isNotEmpty) {
                                Map codeVal = jsonDecode(code);
                                print("codeVal: $codeVal  ${allstoreList.isNotEmpty}");
                                if (allstoreList.isNotEmpty) {
                                  for (VendorModel storeModel in allstoreList) {
                                    print("store name ${storeModel.id}");
                                    if (storeModel.id == codeVal["vendorid"]) {
                                      isMainCall = true;
                                      _camState = false;
                                      setState(() {
                                        Navigator.of(context).pop();
                                        push(context, NewVendorProductsScreen(vendorModel: storeModel));
                                      });
                                    }
                                  }
                                } else {
                                  isMainCall = true;
                                  _camState = false;
                                  setState(() {});
                                  showAlertDialog(context, "error".tr(), "Store not available".tr(), true);
                                }
                              } else {
                                isMainCall = true;
                                _camState = false;
                                setState(() {});
                                showAlertDialog(context, "error".tr(), "Store not available".tr(), true);
                              }
                            },
                          ),
                        ),
                      )
                    : Center(
                        child: Text(_qrInfo!),
                      ))));
  }
}
