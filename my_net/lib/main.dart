import 'package:flutter/material.dart';
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Routing Example',
      theme: ThemeData(
        primaryColor: Color(0xFF4169E5),
        errorColor: Colors.redAccent,
        primaryColorLight: Color(0xFFC0CEDE),

      ),
      initialRoute: AuthRoutes.login, // Set initial route
      routes: {
        AuthRoutes.login: (context) => LoginPage(),
        AuthRoutes.register: (context) => RegisterPage(),
        AppRoutes.home: (context) => HomePage(),
      },
    );
  }
}
