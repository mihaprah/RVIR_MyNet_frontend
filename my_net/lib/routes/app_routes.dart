import 'package:flutter/cupertino.dart';

import '../pages/HomePage.dart';
import '../pages/LoginPage.dart';
import '../pages/RegisterPage.dart';
import '../pages/VaultsPage.dart';
import 'auth_routes.dart';

class AppRoutes {
  static const String home = '/home';
  static const String crypto = '/crypto';
  static const String commodities = '/commodities';
  static const String stocks = '/stocks';
  static const String vaults = '/vaults';
  static const String user = '/user';
  static const String settings = '/settings';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      AuthRoutes.login: (context) => LoginPage(),
      AuthRoutes.register: (context) => RegisterPage(),
      AppRoutes.home: (context) => HomePage(),
      AppRoutes.vaults: (context) => VaultsPage(),
      // Add other routes as needed
    };
  }
}
