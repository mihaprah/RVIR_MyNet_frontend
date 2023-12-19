import 'package:flutter/material.dart';
import 'pages/HomePage.dart';
import 'pages/LoginPage.dart';
import 'routes/auth_routes.dart';

import 'routes/app_routes.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Routing Example',
      initialRoute: AuthRoutes.login, // Set initial route
      routes: {
        AuthRoutes.login: (context) => LoginPage(),
        AppRoutes.home: (context) => HomePage(),
      },
    );
  }
}
