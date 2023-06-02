import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:foodie_customer/constants.dart';
import 'package:foodie_customer/model/CurrencyModel.dart';
import 'package:foodie_customer/services/FirebaseHelper.dart';
import 'package:foodie_customer/services/helper.dart';
import 'package:foodie_customer/services/localDatabase.dart';
import 'package:foodie_customer/ui/auth/AuthScreen.dart';
import 'package:foodie_customer/ui/container/ContainerScreen.dart';
import 'package:foodie_customer/ui/onBoarding/OnBoardingScreen.dart';
import 'package:foodie_customer/userPrefrence.dart';
import 'package:foodie_customer/utils/DarkThemeProvider.dart';
import 'package:foodie_customer/utils/Styles.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'model/User.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await EasyLocalization.ensureInitialized();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  await UserPreference.init();
  runApp(
    MultiProvider(
      providers: [
        Provider<CartDatabase>(
          create: (_) => CartDatabase(),
        )
      ],
      child: EasyLocalization(
          supportedLocales: [Locale('en'), Locale('ar')],
          path: 'assets/translations',
          fallbackLocale: Locale('en'),
          saveLocale: true,
          useOnlyLangCode: true,
          useFallbackTranslations: true,
          child: MyApp()),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> with WidgetsBindingObserver {
  Future<void> setupInteractedMessage(BuildContext context) async {
    initialize(context);
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('Message also contained a notification: ${initialMessage.notification!.body}');
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a message whilst in the foreground!');
      debugPrint('Message data: ${message.data}');

      if (message.notification != null) {
        debugPrint('Message data 1 : ${message.data}');
        display(message);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('On message app');
      debugPrint('Message data: ${message.data}');

      if (message.notification != null) {
        display(message);
      }
    });
  }

  Future<void> initialize(BuildContext context) async {
    AndroidNotificationChannel channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      importance: Importance.high,
    );

    await FlutterLocalNotificationsPlugin().resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);
  }

  void display(RemoteMessage message) async {
    print(message.notification!.title);
    print(message.notification!.body);
    try {
      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      const NotificationDetails notificationDetails = NotificationDetails(
          android: AndroidNotificationDetails(
        "01",
        "foodie_customer",
        importance: Importance.max,
        icon: '@mipmap/ic_launcher',
        priority: Priority.high,
        enableVibration: true,
      ));

      await FlutterLocalNotificationsPlugin().show(
        id,
        message.notification!.title,
        message.notification!.body,
        notificationDetails,
        payload: jsonEncode(message.data),
      );
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }

  static User? currentUser;
  static Position selectedPosotion = Position.fromMap({'latitude': 0.0, 'longitude': 0.0});
  late StreamSubscription tokenStream;

  // Set default `_initialized` and `_error` state to false
  bool _initialized = false, isColorLoad = false;
  bool _error = false;

  //  late Stream<StripeKeyModel> futureStirpe;
  //  String? data,d;

  // Define an async function to initialize FlutterFire
  void initializeFlutterFire() async {
    try {
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

      final FlutterExceptionHandler? originalOnError = FlutterError.onError;
      FlutterError.onError = (FlutterErrorDetails errorDetails) async {
        await FirebaseCrashlytics.instance.recordFlutterError(errorDetails);
        originalOnError!(errorDetails);
        // Forward to original handler.
      };
      FirebaseFirestore.instance.collection(Setting).doc("globalSettings").get().then((dineinresult) {
        if (dineinresult.exists && dineinresult.data() != null && dineinresult.data()!.containsKey("website_color")) {
          COLOR_PRIMARY = int.parse(dineinresult.data()!["website_color"].replaceFirst("#", "0xff"));
          setState(() {
            isColorLoad = true;
          });
        }
      });
      FirebaseFirestore.instance.collection(Setting).doc("DineinForRestaurant").get().then((dineinresult) {
        if (dineinresult.exists) {
          isDineInEnable = dineinresult.data()!["isEnabledForCustomer"];
        }
      });
      await FirebaseFirestore.instance.collection(Setting).doc("Version").get().then((value) {
        debugPrint(value.data().toString());
        appVersion = value.data()!['app_version'].toString();
      });

      await FirebaseFirestore.instance.collection(Setting).doc("googleMapKey").get().then((value) {
        print(value.data());
        GOOGLE_API_KEY = value.data()!['key'].toString();
      });

      tokenStream = FireStoreUtils.firebaseMessaging.onTokenRefresh.listen((event) {
        debugPrint('token $event');
        if (currentUser != null) {
          currentUser!.fcmToken = event;
          FireStoreUtils.updateCurrentUser(currentUser!);
        }
      });

      setState(() {
        _initialized = true;
      });
    } catch (e) {
      debugPrint(e.toString());
      // Set `_error` state to true if Firebase initialization fails
      setState(() {
        _error = true;
      });
    }
  }

  DarkThemeProvider themeChangeProvider = DarkThemeProvider();

  @override
  Widget build(BuildContext context) {
    // Show error message if initialization failed
    if (_error) {
      return MaterialApp(
          locale: context.locale,
          supportedLocales: context.supportedLocales,
          localizationsDelegates: context.localizationDelegates,
          home: Scaffold(
            body: Container(
              color: Colors.white,
              child: Center(
                  child: Column(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 25,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Failed to initialise firebase!'.tr(),
                    style: TextStyle(color: Colors.red, fontSize: 25),
                  ),
                ],
              )),
            ),
          ));
    }

    // Show a loader until FlutterFire is initialized
    if (!_initialized || !isColorLoad) {
      return Container(
        color: Colors.white,
        child: Center(
          child: CircularProgressIndicator.adaptive(
            valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
          ),
        ),
      );
    } else {
      return ChangeNotifierProvider(
        create: (_) {
          return themeChangeProvider;
        },
        child: Consumer<DarkThemeProvider>(
          builder: (context, value, child) {
            return MaterialApp(
                localizationsDelegates: context.localizationDelegates,
                locale: context.locale,
                supportedLocales: context.supportedLocales,
                debugShowCheckedModeBanner: false,
                theme: Styles.themeData(themeChangeProvider.darkTheme, context),
                home: OnBoarding());
          },
        ),
      );
      //
      // return MaterialApp(
      //     navigatorKey: navigatorKey,
      //     localizationsDelegates: context.localizationDelegates,
      //     supportedLocales: context.supportedLocales,
      //     locale: context.locale,
      //     title: 'FOODIES',
      //     // themeMode: ThemeMode.dark,
      //     theme: ThemeData(
      //         appBarTheme: AppBarTheme(
      //             centerTitle: true, color: Colors.transparent, elevation: 0, actionsIconTheme: IconThemeData(color: Color(COLOR_PRIMARY)), iconTheme: IconThemeData(color: Color(COLOR_PRIMARY))),
      //         bottomSheetTheme: BottomSheetThemeData(backgroundColor: Colors.white),
      //         primaryColor: Color(COLOR_PRIMARY),
      //         iconTheme: IconThemeData(color: Colors.white),
      //         brightness: Brightness.light),
      //     darkTheme: ThemeData(
      //         appBarTheme: AppBarTheme(
      //           centerTitle: true,
      //           color: Colors.transparent,
      //           elevation: 0,
      //           actionsIconTheme: IconThemeData(color: Color(COLOR_PRIMARY)),
      //           iconTheme: IconThemeData(color: Color(COLOR_PRIMARY)),
      //         ),
      //         iconTheme: IconThemeData(color: Colors.white),
      //         bottomSheetTheme: BottomSheetThemeData(backgroundColor: Colors.grey.shade900),
      //         primaryColor: Color(COLOR_PRIMARY),
      //         brightness: Brightness.dark),
      //     debugShowCheckedModeBanner: false,
      //     color: Color(COLOR_PRIMARY),
      //     home: OnBoarding());
    }
  }

  @override
  void initState() {
    initializeFlutterFire();
    setupInteractedMessage(context);
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    tokenStream.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    /*if (auth.FirebaseAuth.instance.currentUser != null && currentUser != null) {
      if (state == AppLifecycleState.paused) {
        //user offline
        tokenStream.pause();
        currentUser!.active = false;
        currentUser!.lastOnlineTimestamp = Timestamp.now();
        FireStoreUtils.updateCurrentUser(currentUser!);
      } else if (state == AppLifecycleState.resumed) {
        //user online
        tokenStream.resume();
        currentUser!.active = true;
        FireStoreUtils.updateCurrentUser(currentUser!);
      }
    }*/
  }
}

class OnBoarding extends StatefulWidget {
  @override
  State createState() {
    return OnBoardingState();
  }
}

class OnBoardingState extends State<OnBoarding> {
  late Future<List<CurrencyModel>> futureCurrency;

  Future hasFinishedOnBoarding() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool finishedOnBoarding = (prefs.getBool(FINISHED_ON_BOARDING) ?? false);

    if (finishedOnBoarding) {
      auth.User? firebaseUser = auth.FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        User? user = await FireStoreUtils.getCurrentUser(firebaseUser.uid);
        if (user != null) {
          if (user.role == USER_ROLE_CUSTOMER) {
            if (user.active) {
              user.active = true;
              user.role = USER_ROLE_CUSTOMER;
              user.fcmToken = await FireStoreUtils.firebaseMessaging.getToken() ?? '';
              await FireStoreUtils.updateCurrentUser(user);
              MyAppState.currentUser = user;
              pushReplacement(context, ContainerScreen(user: user));
            } else {
              user.lastOnlineTimestamp = Timestamp.now();
              user.fcmToken = "";
              await FireStoreUtils.updateCurrentUser(user);
              await auth.FirebaseAuth.instance.signOut();
              MyAppState.currentUser = null;
              Provider.of<CartDatabase>(context, listen: false).deleteAllProducts();
              pushAndRemoveUntil(context, AuthScreen(), false);
            }
          } else {
            pushReplacement(context, AuthScreen());
          }
        } else {
          pushReplacement(context, AuthScreen());
        }
      } else {
        pushReplacement(context, AuthScreen());
      }
    } else {
      pushReplacement(context, OnBoardingScreen());
    }
  }

  @override
  void initState() {
    super.initState();
    hasFinishedOnBoarding();
    // futureCurrency= FireStoreUtils().getCurrency();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: CircularProgressIndicator.adaptive(
          valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
        ),
      ),
    );
  }
}
