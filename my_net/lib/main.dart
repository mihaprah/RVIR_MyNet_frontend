import 'package:flutter/material.dart';
import 'package:my_net/models/ClientProvider.dart';
import 'package:my_net/pages/CommodityPage.dart';
import 'package:my_net/pages/CryptoPage.dart';
import 'package:my_net/pages/StocksPage.dart';
import 'package:my_net/pages/VaultsPage.dart';
import 'package:provider/provider.dart';
import 'pages/HomePage.dart';
import 'pages/LoginPage.dart';
import 'pages/RegisterPage.dart';
import 'routes/auth_routes.dart';

import 'routes/app_routes.dart';

void main() async {
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ClientProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: const Color(0xFF4169E5),
          primaryColorLight: const Color(0xFFC0CEDE),
        ),
        initialRoute: AuthRoutes.login,
        routes: {
          AuthRoutes.login: (context) => LoginPage(),
          AuthRoutes.register: (context) => RegisterPage(),
          AppRoutes.home: (context) => HomePage(),
          AppRoutes.vaults: (context) => VaultsPage(),
          AppRoutes.crypto: (context) => CryptoPage(),
          AppRoutes.commodities: (context) => CommodityPage(),
          AppRoutes.stocks: (context) => StocksPage(),
        },
      ),
    );
  }
}
