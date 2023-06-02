import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:foodie_customer/constants.dart';
import 'package:foodie_customer/services/FirebaseHelper.dart';
import 'package:foodie_customer/services/helper.dart';

import 'language_model.dart';

// ignore: must_be_immutable
class LanguageChooseScreen extends StatefulWidget {
  bool isContainer = false;

  LanguageChooseScreen({Key? key, required this.isContainer}) : super(key: key);

  @override
  State<LanguageChooseScreen> createState() => _LanguageChooceScreenState();
}

class _LanguageChooceScreenState extends State<LanguageChooseScreen> {
  var languageList = <Data>[];
  String selectedLanguage = "en";

  @override
  void initState() {
    loadData();
    super.initState();
  }

  void loadData() async {
    languageList.clear();
    await FireStoreUtils.firestore.collection(Setting).doc("languages").get().then((value) {
      List list = value.data()!["list"];
      for (int i = 0; i < list.length; i++) {
        Map data = list[i];
        if (data["isActive"]) {
          Data langData = new Data();
          langData.language = data["title"];
          langData.languageCode = data["slug"];

          if (langData.languageCode == "en") {
            langData.icon = "assets/flags/ic_uk.png";
          } else if (langData.languageCode == "es") {
            langData.icon = "assets/flags/ic_spain.png";
          } else if (langData.languageCode == "ar") {
            langData.icon = "assets/flags/ic_uae.png";
          } else if (langData.languageCode == "Fr") {
            langData.icon = "assets/flags/ic_france.png";
          } else if (langData.languageCode == "pt") {
            langData.icon = "assets/flags/ic_portugal.png";
          }
          languageList.add(langData);
        }

        if (i == (languageList.length - 1)) {
          setState(() {});
        }
      }
    });
    // final response = await rootBundle.loadString("assets/translations/language.json");
    // final decodeData = jsonDecode(response);
    // var productData = decodeData["data"];
    // setState(() {
    //   languageList = List.from(productData).map<Data>((item) => Data.fromJson(item)).toList();
    // });
    SharedPreferences sp = await SharedPreferences.getInstance();
    if (sp.containsKey("languageCode")) {
      selectedLanguage = sp.getString("languageCode")!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: isDarkMode(context) ? Color(DARK_VIEWBG_COLOR) : Color(0xffFFFFFF),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              ListView.builder(
                itemCount: languageList.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      setState(() {
                        selectedLanguage = languageList[index].languageCode.toString();
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Container(
                        decoration: languageList[index].languageCode == selectedLanguage
                            ? BoxDecoration(
                                border: Border.all(color: Color(COLOR_PRIMARY)),
                                borderRadius: const BorderRadius.all(Radius.circular(5.0) //                 <--- border radius here
                                    ),
                              )
                            : null,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            children: [
                              Image.asset(
                                languageList[index].icon.toString(),
                                height: 60,
                                width: 60,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 10, right: 10),
                                child: Text(languageList[index].language.toString(), style: const TextStyle(fontSize: 16)),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              )
            ],
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(COLOR_PRIMARY),
              padding: const EdgeInsets.only(top: 8, bottom: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
                side: BorderSide(
                  color: Color(COLOR_PRIMARY),
                ),
              ),
            ),
            onPressed: () async {
              if (selectedLanguage == "en") {
                SharedPreferences sp = await SharedPreferences.getInstance();
                sp.setString("languageCode", selectedLanguage);
                context.setLocale(Locale(selectedLanguage));
              } else if (selectedLanguage == "ar") {
                SharedPreferences sp = await SharedPreferences.getInstance();
                sp.setString("languageCode", selectedLanguage);
                context.setLocale(Locale(selectedLanguage));
              } else {
                SharedPreferences sp = await SharedPreferences.getInstance();
                sp.setString("languageCode", "en");
                context.setLocale(Locale("en"));
              }

              if (widget.isContainer) {
                SnackBar snack = SnackBar(
                  content: const Text(
                    'Language change successfully',
                    style: TextStyle(color: Colors.white),
                  ).tr(),
                  duration: const Duration(seconds: 2),
                  backgroundColor: Colors.black,
                );
                ScaffoldMessenger.of(context).showSnackBar(snack);
              } else {
                Navigator.pop(context);
              }
            },
            child: Text(
              'Save'.tr(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDarkMode(context) ? Colors.black : Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
