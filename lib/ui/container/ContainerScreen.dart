import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:foodie_customer/AppGlobal.dart';
import 'package:foodie_customer/constants.dart';
import 'package:foodie_customer/main.dart';
import 'package:foodie_customer/model/User.dart';
import 'package:foodie_customer/services/FirebaseHelper.dart';
import 'package:foodie_customer/services/helper.dart';
import 'package:foodie_customer/services/localDatabase.dart';
import 'package:foodie_customer/ui/Language/language_choose_screen.dart';
import 'package:foodie_customer/ui/QrCodeScanner/QrCodeScanner.dart';
import 'package:foodie_customer/ui/auth/AuthScreen.dart';
import 'package:foodie_customer/ui/cartScreen/CartScreen.dart';
import 'package:foodie_customer/ui/chat_screen/inbox_driver_screen.dart';
import 'package:foodie_customer/ui/chat_screen/inbox_screen.dart';
import 'package:foodie_customer/ui/cuisinesScreen/CuisinesScreen.dart';
import 'package:foodie_customer/ui/dineInScreen/dine_in_screen.dart';
import 'package:foodie_customer/ui/dineInScreen/my_booking_screen.dart';
import 'package:foodie_customer/ui/home/HomeScreen.dart';
import 'package:foodie_customer/ui/home/favourite_item.dart';
import 'package:foodie_customer/ui/home/favourite_restaurant.dart';
import 'package:foodie_customer/ui/mapView/MapViewScreen.dart';
import 'package:foodie_customer/ui/ordersScreen/OrdersScreen.dart';
import 'package:foodie_customer/ui/privacy_policy/privacy_policy.dart';
import 'package:foodie_customer/ui/profile/ProfileScreen.dart';
import 'package:foodie_customer/ui/referral_screen/referral_screen.dart';
import 'package:foodie_customer/ui/searchScreen/SearchScreen.dart';
import 'package:foodie_customer/ui/termsAndCondition/terms_and_codition.dart';
import 'package:foodie_customer/ui/wallet/walletScreen.dart';
import 'package:foodie_customer/userPrefrence.dart';
import 'package:foodie_customer/utils/DarkThemeProvider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

enum DrawerSelection { Home, Wallet, dineIn, Search, Cuisines, Cart, Profile, Orders, MyBooking, termsCondition, privacyPolicy, chooseLanguage, referral,inbox, driver, Logout, LikedRestaurant, LikedProduct }

class ContainerScreen extends StatefulWidget {
  final User? user;
  final Widget currentWidget;
  final String appBarTitle;
  final DrawerSelection drawerSelection;

  ContainerScreen({Key? key, required this.user, currentWidget, appBarTitle, this.drawerSelection = DrawerSelection.Home})
      : this.appBarTitle = appBarTitle ?? 'Home'.tr(),
        this.currentWidget = currentWidget ??
            HomeScreen(
              user: MyAppState.currentUser,
            ),
        super(key: key);

  @override
  _ContainerScreen createState() {
    return _ContainerScreen();
  }
}

class _ContainerScreen extends State<ContainerScreen> {
  var key = GlobalKey<ScaffoldState>();

  late CartDatabase cartDatabase;
  late User user;
  late String _appBarTitle;
  final fireStoreUtils = FireStoreUtils();

  late Widget _currentWidget;
  late DrawerSelection _drawerSelection;

  int cartCount = 0;
  bool? isWalletEnable;

  @override
  void initState() {
    super.initState();
    setCurrency();
    if (widget.user != null) {
      user = widget.user!;
    } else {
      user = new User();
    }
    _currentWidget = widget.currentWidget;
    _appBarTitle = widget.appBarTitle;
    _drawerSelection = widget.drawerSelection;
    //getKeyHash();
    /// On iOS, we request notification permissions, Does nothing and returns null on Android
    FireStoreUtils.firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    fireStoreUtils.getplaceholderimage().then((value) {
      AppGlobal.placeHolderImage = value;
    });
  }

  setCurrency() async {
    await FireStoreUtils().getCurrency().then((value) {
      for (var element in value) {
        if (element.isactive = true) {
          symbol = element.symbol;
          isRight = element.symbolatright;
          currName = element.code;
          decimal = element.decimal;
          currencyData = element;
        }
      }
    });

    await FireStoreUtils().getRazorPayDemo();
    await FireStoreUtils.getPaypalSettingData();
    await FireStoreUtils.getStripeSettingData();
    await FireStoreUtils.getPayStackSettingData();
    await FireStoreUtils.getFlutterWaveSettingData();
    await FireStoreUtils.getPaytmSettingData();
    await FireStoreUtils.getWalletSettingData();
    await FireStoreUtils.getPayFastSettingData();
    await FireStoreUtils.getMercadoPagoSettingData();
    await FireStoreUtils.getReferralAmount();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    cartDatabase = Provider.of<CartDatabase>(context);
  }

  DateTime preBackpress = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return WillPopScope(
      onWillPop: () async {
        if (!(_currentWidget is HomeScreen)) {
          setState(() {
            _drawerSelection = DrawerSelection.Home;
            _appBarTitle = 'Restaurants'.tr();
            _currentWidget = HomeScreen(
              user: MyAppState.currentUser,
            );
          });
          return false;
        } else {
          final timegap = DateTime.now().difference(preBackpress);
          final cantExit = timegap >= Duration(seconds: 2);
          preBackpress = DateTime.now();
          if (cantExit) {
            //show snackbar
            final snack = SnackBar(
              content: Text(
                'Press Back button again to Exit'.tr(),
                style: TextStyle(color: Colors.white),
              ),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.black,
            );
            ScaffoldMessenger.of(context).showSnackBar(snack);
            return false; // false will do nothing when back press
          } else {
            return true; // true will exit the app
          }
        }
      },
      child: ChangeNotifierProvider.value(
        value: user,
        child: Consumer<User>(
          builder: (context, user, _) {
            return Scaffold(
              extendBodyBehindAppBar: _drawerSelection == DrawerSelection.Wallet ? true : false,
              key: key,
              drawer: Drawer(
                child: Container(
                    color: isDarkMode(context) ? Color(DARK_VIEWBG_COLOR) : null,
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView(
                            padding: EdgeInsets.zero,
                            children: [
                              Consumer<User>(builder: (context, user, _) {
                                return DrawerHeader(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      displayCircleImage(user.profilePictureURL, 75, false),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.only(top: 8.0),
                                                  child: Text(
                                                    user.fullName(),
                                                    style: const TextStyle(color: Colors.white),
                                                  ),
                                                ),
                                                Padding(
                                                    padding: const EdgeInsets.only(top: 5.0),
                                                    child: Text(
                                                      user.email,
                                                      style: const TextStyle(color: Colors.white),
                                                    )),
                                              ],
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              !themeChange.darkTheme ? const Icon(Icons.light_mode_sharp) : const Icon(Icons.nightlight),
                                              Switch(
                                                // thumb color (round icon)
                                                splashRadius: 50.0,
                                                activeThumbImage: const AssetImage('https://lists.gnu.org/archive/html/emacs-devel/2015-10/pngR9b4lzUy39.png'),
                                                inactiveThumbImage: const AssetImage('http://wolfrosch.com/_img/works/goodies/icon/vim@2x'),

                                                value: themeChange.darkTheme,
                                                onChanged: (value) => setState(() => themeChange.darkTheme = value),
                                              ),
                                            ],
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                  decoration: BoxDecoration(
                                    color: Color(COLOR_PRIMARY),
                                  ),
                                );
                              }),
                              ListTileTheme(
                                style: ListTileStyle.drawer,
                                selectedColor: Color(COLOR_PRIMARY),
                                child: ListTile(
                                  selected: _drawerSelection == DrawerSelection.Home,
                                  title: Text('Restaurants').tr(),
                                  onTap: () {
                                    Navigator.pop(context);
                                    setState(() {
                                      _drawerSelection = DrawerSelection.Home;
                                      _appBarTitle = 'Restaurants'.tr();
                                      _currentWidget = HomeScreen(
                                        user: MyAppState.currentUser,
                                      );
                                    });
                                  },
                                  leading: Icon(CupertinoIcons.home),
                                ),
                              ),
                              ListTileTheme(
                                style: ListTileStyle.drawer,
                                selectedColor: Color(COLOR_PRIMARY),
                                child: ListTile(
                                    selected: _drawerSelection == DrawerSelection.Cuisines,
                                    leading: Image.asset(
                                      'assets/images/app_logo.png',
                                      color: _drawerSelection == DrawerSelection.Cuisines
                                          ? Color(COLOR_PRIMARY)
                                          : isDarkMode(context)
                                          ? Colors.grey.shade200
                                          : Colors.grey.shade600,
                                      width: 24,
                                      height: 24,
                                    ),
                                    title: Text('Cuisines').tr(),
                                    onTap: () {
                                      Navigator.pop(context);
                                      setState(() {
                                        _drawerSelection = DrawerSelection.Cuisines;
                                        _appBarTitle = 'Cuisines'.tr();
                                        _currentWidget = CuisinesScreen();
                                      });
                                    }),
                              ),
                              !isDineInEnable
                                  ? Container()
                                  : ListTileTheme(
                                style: ListTileStyle.drawer,
                                selectedColor: Color(COLOR_PRIMARY),
                                child: ListTile(
                                    selected: _drawerSelection == DrawerSelection.dineIn,
                                    leading: Icon(Icons.restaurant),
                                    title: Text('Dine-in').tr(),
                                    onTap: () {
                                      Navigator.pop(context);
                                      setState(() {
                                        _drawerSelection = DrawerSelection.dineIn;
                                        _appBarTitle = 'Dine-In'.tr();
                                        _currentWidget = DineInScreen(
                                          user: MyAppState.currentUser,
                                        );
                                      });
                                    }),
                              ),
                              ListTileTheme(
                                style: ListTileStyle.drawer,
                                selectedColor: Color(COLOR_PRIMARY),
                                child: ListTile(
                                    selected: _drawerSelection == DrawerSelection.Search,
                                    title: Text('search').tr(),
                                    leading: Icon(Icons.search),
                                    onTap: () async {
                                      push(context, const SearchScreen());
                                    }),
                              ),
                              ListTileTheme(
                                style: ListTileStyle.drawer,
                                selectedColor: Color(COLOR_PRIMARY),
                                child: ListTile(
                                  selected: _drawerSelection == DrawerSelection.LikedRestaurant,
                                  title: Text('Favourite Restaurants').tr(),
                                  onTap: () {
                                    if (MyAppState.currentUser == null) {
                                      Navigator.pop(context);
                                      push(context, AuthScreen());
                                    } else {
                                      Navigator.pop(context);
                                      setState(() {
                                        _drawerSelection = DrawerSelection.LikedRestaurant;
                                        _appBarTitle = 'Favourite Restaurants'.tr();
                                        _currentWidget = FavouriteRestaurantScreen();
                                      });
                                    }
                                  },
                                  leading: Icon(CupertinoIcons.heart),
                                ),
                              ),
                              ListTileTheme(
                                style: ListTileStyle.drawer,
                                selectedColor: Color(COLOR_PRIMARY),
                                child: ListTile(
                                  selected: _drawerSelection == DrawerSelection.LikedProduct,
                                  title: const Text('Favourite Foods').tr(),
                                  onTap: () {
                                    Navigator.pop(context);
                                    if (MyAppState.currentUser == null) {
                                      push(context, AuthScreen());
                                    } else {
                                      setState(() {
                                        _drawerSelection = DrawerSelection.LikedProduct;
                                        _appBarTitle = 'Favourite Foods'.tr();
                                        _currentWidget = const FavouriteItemScreen();
                                      });
                                    }
                                  },
                                  leading: const Icon(CupertinoIcons.heart),
                                ),
                              ),
                              Visibility(
                                visible: UserPreference.getWalletData() ?? false,
                                child: ListTileTheme(
                                  style: ListTileStyle.drawer,
                                  selectedColor: Color(COLOR_PRIMARY),
                                  child: ListTile(
                                    selected: _drawerSelection == DrawerSelection.Wallet,
                                    leading: Icon(Icons.account_balance_wallet_outlined),
                                    title: Text('Wallet').tr(),
                                    onTap: () {
                                      if (MyAppState.currentUser == null) {
                                        Navigator.pop(context);
                                        push(context, AuthScreen());
                                      } else {
                                        Navigator.pop(context);
                                        setState(() {
                                          _drawerSelection = DrawerSelection.Wallet;
                                          _appBarTitle = 'Wallet'.tr();
                                          _currentWidget = WalletScreen();
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ),
                              ListTileTheme(
                                style: ListTileStyle.drawer,
                                selectedColor: Color(COLOR_PRIMARY),
                                child: ListTile(
                                  selected: _drawerSelection == DrawerSelection.Cart,
                                  leading: Icon(CupertinoIcons.cart),
                                  title: Text('Cart').tr(),
                                  onTap: () {
                                    if (MyAppState.currentUser == null) {
                                      Navigator.pop(context);
                                      push(context, AuthScreen());
                                    } else {
                                      Navigator.pop(context);
                                      setState(() {
                                        _drawerSelection = DrawerSelection.Cart;
                                        _appBarTitle = 'Your Cart'.tr();
                                        _currentWidget = CartScreen(
                                          fromContainer: true,
                                        );
                                      });
                                    }
                                  },
                                ),
                              ),
                              ListTileTheme(
                                style: ListTileStyle.drawer,
                                selectedColor: Color(COLOR_PRIMARY),
                                child: ListTile(
                                  selected: _drawerSelection == DrawerSelection.Profile,
                                  leading: Icon(CupertinoIcons.person),
                                  title: Text('Profile').tr(),
                                  onTap: () {
                                    if (MyAppState.currentUser == null) {
                                      Navigator.pop(context);
                                      push(context, AuthScreen());
                                    } else {
                                      Navigator.pop(context);
                                      setState(() {
                                        _drawerSelection = DrawerSelection.Profile;
                                        _appBarTitle = 'My Profile'.tr();
                                        _currentWidget = ProfileScreen(
                                          user: user,
                                        );
                                      });
                                    }
                                  },
                                ),
                              ),
                              ListTileTheme(
                                style: ListTileStyle.drawer,
                                selectedColor: Color(COLOR_PRIMARY),
                                child: ListTile(
                                  selected: _drawerSelection == DrawerSelection.Orders,
                                  leading: Image.asset(
                                    'assets/images/truck.png',
                                    color: _drawerSelection == DrawerSelection.Orders
                                        ? Color(COLOR_PRIMARY)
                                        : isDarkMode(context)
                                        ? Colors.grey.shade200
                                        : Colors.grey.shade600,
                                    width: 24,
                                    height: 24,
                                  ),
                                  title: Text('Orders').tr(),
                                  onTap: () {
                                    if (MyAppState.currentUser == null) {
                                      Navigator.pop(context);
                                      push(context, AuthScreen());
                                    } else {
                                      Navigator.pop(context);
                                      setState(() {
                                        _drawerSelection = DrawerSelection.Orders;
                                        _appBarTitle = 'Orders'.tr();
                                        _currentWidget = OrdersScreen();
                                      });
                                    }
                                  },
                                ),
                              ),
                              !isDineInEnable
                                  ? Container()
                                  : ListTileTheme(
                                style: ListTileStyle.drawer,
                                selectedColor: Color(COLOR_PRIMARY),
                                child: ListTile(
                                  selected: _drawerSelection == DrawerSelection.MyBooking,
                                  leading: Image.asset(
                                    'assets/images/your_booking.png',
                                    color: _drawerSelection == DrawerSelection.MyBooking
                                        ? Color(COLOR_PRIMARY)
                                        : isDarkMode(context)
                                        ? Colors.grey.shade200
                                        : Colors.grey.shade600,
                                    width: 24,
                                    height: 24,
                                  ),
                                  title: Text('Dine-In Bookings').tr(),
                                  onTap: () {
                                    if (MyAppState.currentUser == null) {
                                      Navigator.pop(context);
                                      push(context, AuthScreen());
                                    } else {
                                      Navigator.pop(context);
                                      setState(() {
                                        _drawerSelection = DrawerSelection.MyBooking;
                                        _appBarTitle = 'Dine-In Bookings'.tr();
                                        _currentWidget = MyBookingScreen();
                                      });
                                    }
                                  },
                                ),
                              ),

                              ListTileTheme(
                                style: ListTileStyle.drawer,
                                selectedColor: Color(COLOR_PRIMARY),
                                child: ListTile(
                                  selected: _drawerSelection == DrawerSelection.referral,
                                  leading:  Image.asset('assets/images/refer.png',width: 28,color: Colors.grey,),
                                  title: const Text('Refer a friend').tr(),
                                  onTap: () async {
                                    if (MyAppState.currentUser == null) {
                                      Navigator.pop(context);
                                      push(context, AuthScreen());
                                    } else {
                                      Navigator.pop(context);
                                     push(context, ReferralScreen());
                                    }
                                  },
                                ),
                              ),
                              ListTileTheme(
                                style: ListTileStyle.drawer,
                                selectedColor: Color(COLOR_PRIMARY),
                                child: ListTile(
                                  selected: _drawerSelection == DrawerSelection.chooseLanguage,
                                  leading: Icon(
                                    Icons.language,
                                    color: _drawerSelection == DrawerSelection.chooseLanguage
                                        ? Color(COLOR_PRIMARY)
                                        : isDarkMode(context)
                                        ? Colors.grey.shade200
                                        : Colors.grey.shade600,
                                  ),
                                  title: const Text('Language').tr(),
                                  onTap: () {
                                    Navigator.pop(context);
                                    setState(() {
                                      _drawerSelection = DrawerSelection.chooseLanguage;
                                      _appBarTitle = 'Language'.tr();
                                      _currentWidget = LanguageChooseScreen(
                                        isContainer: true,
                                      );
                                    });
                                  },
                                ),
                              ),
                              ListTileTheme(
                                style: ListTileStyle.drawer,
                                selectedColor: Color(COLOR_PRIMARY),
                                child: ListTile(
                                  selected: _drawerSelection == DrawerSelection.inbox,
                                  leading: Icon(CupertinoIcons.chat_bubble_2_fill),
                                  title: Text('Restaurant Inbox').tr(),
                                  onTap: () {
                                    if (MyAppState.currentUser == null) {
                                      Navigator.pop(context);
                                      push(context, AuthScreen());
                                    } else {
                                      Navigator.pop(context);
                                      setState(() {
                                        _drawerSelection = DrawerSelection.inbox;
                                        _appBarTitle = 'Restaurant Inbox'.tr();
                                        _currentWidget = InboxScreen();
                                      });
                                    }
                                  },
                                ),
                              ),
                              ListTileTheme(
                                style: ListTileStyle.drawer,
                                selectedColor: Color(COLOR_PRIMARY),
                                child: ListTile(
                                  selected: _drawerSelection == DrawerSelection.driver,
                                  leading: Icon(CupertinoIcons.chat_bubble_2_fill),
                                  title: Text('Driver Inbox').tr(),
                                  onTap: () {
                                    if (MyAppState.currentUser == null) {
                                      Navigator.pop(context);
                                      push(context, AuthScreen());
                                    } else {
                                      Navigator.pop(context);
                                      setState(() {
                                        _drawerSelection = DrawerSelection.driver;
                                        _appBarTitle = 'Driver Inbox'.tr();
                                        _currentWidget = InboxDriverScreen();
                                      });
                                    }
                                  },
                                ),
                              ),
                              ListTileTheme(
                                style: ListTileStyle.drawer,
                                selectedColor: Color(COLOR_PRIMARY),
                                child: ListTile(
                                  selected: _drawerSelection == DrawerSelection.termsCondition,
                                  leading: const Icon(Icons.policy),
                                  title: const Text('Terms and Condition').tr(),
                                  onTap: () async {
                                    push(context, const TermsAndCondition());
                                  },
                                ),
                              ),
                              ListTileTheme(
                                style: ListTileStyle.drawer,
                                selectedColor: Color(COLOR_PRIMARY),
                                child: ListTile(
                                  selected: _drawerSelection == DrawerSelection.privacyPolicy,
                                  leading: const Icon(Icons.privacy_tip),
                                  title: const Text('Privacy policy').tr(),
                                  onTap: () async {
                                    push(context, const PrivacyPolicyScreen());
                                  },
                                ),
                              ),
                              ListTileTheme(
                                style: ListTileStyle.drawer,
                                selectedColor: Color(COLOR_PRIMARY),
                                child: ListTile(
                                    selected: _drawerSelection == DrawerSelection.Logout,
                                    leading: Icon(Icons.logout),
                                    title: Text(MyAppState.currentUser == null ? 'Login' : 'Log Out').tr(),
                                    onTap: () async {
                                      if (MyAppState.currentUser == null) {
                                        pushAndRemoveUntil(context, AuthScreen(), false);
                                      } else {
                                        Navigator.pop(context);
                                        //user.active = false;
                                        user.lastOnlineTimestamp = Timestamp.now();
                                        user.fcmToken = "";
                                        await FireStoreUtils.updateCurrentUser(user);
                                        await auth.FirebaseAuth.instance.signOut();
                                        MyAppState.currentUser = null;
                                        MyAppState.selectedPosotion = Position.fromMap({'latitude': 0.0, 'longitude': 0.0});
                                        Provider.of<CartDatabase>(context, listen: false).deleteAllProducts();
                                        pushAndRemoveUntil(context, AuthScreen(), false);
                                      }
                                    }),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("V : $appVersion"),
                        )
                      ],
                    )),
              ),
              appBar: AppBar(
                elevation: 0,
                centerTitle: _drawerSelection == DrawerSelection.Wallet ? true : false,
                backgroundColor: _drawerSelection == DrawerSelection.Wallet
                    ? Colors.transparent
                    : isDarkMode(context)
                    ? Color(DARK_COLOR)
                    : _drawerSelection == DrawerSelection.Home
                    ? Colors.black
                    : Colors.white,
                //isDarkMode(context) ? Color(DARK_COLOR) : null,
                leading: IconButton(
                    visualDensity: VisualDensity(horizontal: -4),
                    padding: EdgeInsets.only(right: 5),
                    icon: Image(
                      image: AssetImage("assets/images/menu.png"),
                      width: 20,
                      color: _drawerSelection == DrawerSelection.Wallet
                          ? Colors.white
                          : isDarkMode(context) || _drawerSelection == DrawerSelection.Home
                          ? Colors.white
                          : Color(DARK_COLOR),
                    ),
                    onPressed: () => key.currentState!.openDrawer()),
                // iconTheme: IconThemeData(color: Colors.blue),
                title: Text(
                  _appBarTitle,
                  style: TextStyle(
                      fontFamily: "Poppinsm",
                      color: _drawerSelection == DrawerSelection.Wallet || _drawerSelection == DrawerSelection.Home
                          ? Colors.white
                          : isDarkMode(context)
                          ? Colors.white
                          : Color(DARK_COLOR),
                      //isDarkMode(context) ? Colors.white : Colors.black,
                      fontWeight: FontWeight.normal),
                ),
                actions: _drawerSelection == DrawerSelection.Wallet || _drawerSelection == DrawerSelection.MyBooking
                    ? []
                    : _drawerSelection == DrawerSelection.dineIn
                    ? [
                  IconButton(
                      padding: const EdgeInsets.only(right: 20),
                      visualDensity: VisualDensity(horizontal: -4),
                      tooltip: 'QrCode'.tr(),
                      icon: Image(
                        image: AssetImage("assets/images/qrscan.png"),
                        width: 20,
                        color: isDarkMode(context) || _drawerSelection == DrawerSelection.Home ? Colors.white : Colors.black,
                      ),
                      onPressed: () {
                        push(
                          context,
                          QrCodeScanner(),
                        );
                      }),
                  IconButton(
                      visualDensity: const VisualDensity(horizontal: -4),
                      padding: EdgeInsets.only(right: 10),
                      icon: Image(
                        image: AssetImage("assets/images/search.png"),
                        width: 20,
                        color: isDarkMode(context) || _drawerSelection == DrawerSelection.Home ? Colors.white : null,
                      ),
                      onPressed: () {
                        setState(() {
                          push(context, const SearchScreen());
                        });
                      }),
                  if (!(_currentWidget is CartScreen) || !(_currentWidget is ProfileScreen))
                    IconButton(
                      visualDensity: VisualDensity(horizontal: -4),
                      padding: EdgeInsets.only(right: 10),
                      icon: Image(
                        image: AssetImage("assets/images/map.png"),
                        width: 20,
                        color: isDarkMode(context) || _drawerSelection == DrawerSelection.Home ? Colors.white : Color(0xFF333333),
                      ),
                      onPressed: () => push(
                        context,
                        MapViewScreen(),
                      ),
                    )
                ]
                    : [
                  IconButton(
                      padding: const EdgeInsets.only(right: 20),
                      visualDensity: VisualDensity(horizontal: -4),
                      tooltip: 'QrCode'.tr(),
                      icon: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Image(
                            image: AssetImage("assets/images/qrscan.png"),
                            width: 20,
                            color: isDarkMode(context) || _drawerSelection == DrawerSelection.Home ? Colors.white : Colors.black,
                          ),
                        ],
                      ),
                      onPressed: () {
                        push(
                          context,
                          QrCodeScanner(),
                        );
                      }),
                  IconButton(
                      visualDensity: const VisualDensity(horizontal: -4),
                      padding: EdgeInsets.only(right: 10),
                      icon: Image(
                        image: AssetImage("assets/images/search.png"),
                        width: 20,
                        color: isDarkMode(context) || _drawerSelection == DrawerSelection.Home ? Colors.white : null,
                      ),
                      onPressed: () {
                        push(context, const SearchScreen());
                      }),
                  if (!(_currentWidget is CartScreen) || !(_currentWidget is ProfileScreen))
                    IconButton(
                      visualDensity: VisualDensity(horizontal: -4),
                      padding: EdgeInsets.only(right: 10),
                      icon: Image(
                        image: AssetImage("assets/images/map.png"),
                        width: 20,
                        color: isDarkMode(context) || _drawerSelection == DrawerSelection.Home ? Colors.white : Color(0xFF333333),
                      ),
                      onPressed: () => push(
                        context,
                        MapViewScreen(),
                      ),
                    ),
                  if (!(_currentWidget is CartScreen) || !(_currentWidget is ProfileScreen))
                    IconButton(
                        padding: EdgeInsets.only(right: 20),
                        visualDensity: VisualDensity(horizontal: -4),
                        tooltip: 'Cart'.tr(),
                        icon: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Image(
                              image: AssetImage("assets/images/cart.png"),
                              width: 20,
                              color: isDarkMode(context) || _drawerSelection == DrawerSelection.Home ? Colors.white : null,
                            ),
                            StreamBuilder<List<CartProduct>>(
                              stream: cartDatabase.watchProducts,
                              builder: (context, snapshot) {
                                cartCount = 0;
                                if (snapshot.hasData) {
                                  snapshot.data!.forEach((element) {
                                    cartCount += element.quantity;
                                  });
                                }
                                return Visibility(
                                  visible: cartCount >= 1,
                                  child: Positioned(
                                    right: -6,
                                    top: -8,
                                    child: Container(
                                      padding: EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(COLOR_PRIMARY),
                                      ),
                                      constraints: BoxConstraints(
                                        minWidth: 12,
                                        minHeight: 12,
                                      ),
                                      child: Center(
                                        child: new Text(
                                          cartCount <= 99 ? '$cartCount' : '+99',
                                          style: new TextStyle(
                                            color: Colors.white,
                                            // fontSize: 10,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            )
                          ],
                        ),
                        onPressed: () {
                          if (MyAppState.currentUser == null) {
                            Navigator.pop(context);
                            push(context, AuthScreen());
                          } else {
                            setState(() {
                              _drawerSelection = DrawerSelection.Cart;
                              _appBarTitle = 'Your Cart'.tr();
                              _currentWidget = CartScreen(
                                fromContainer: true,
                              );
                            });
                          }
                        }),
                ],
              ),
              body: _currentWidget,
            );
          },
        ),
      ),
    );
  }
}
