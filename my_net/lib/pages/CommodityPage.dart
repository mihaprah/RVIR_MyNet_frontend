import 'package:flutter/material.dart';
import 'package:my_net/main.dart';

import '../routes/app_routes.dart';
import '../routes/auth_routes.dart';
import '../widgets/CustomAppBar.dart';
import 'LoginPage.dart';

class CommodityPage extends StatefulWidget {
  @override
  _CommodityPageState createState() => _CommodityPageState();
}

class _CommodityPageState extends State<CommodityPage> {
  String currentScreen = '/commodities'; // Example: Set the initial screen to '/home'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(90.0), // same as your CustomAppBar preferredSize
        child: CustomAppBar(
          context: context,
          currentScreen: currentScreen,
          onScreenChange: (String screen, Widget widget) {
            setState(() {
              currentScreen = screen;
            });

            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) => widget,
                transitionDuration: const Duration(milliseconds: 0),
                transitionsBuilder: (context, animation1, animation2, child) {
                  return child;
                },
              ),
            );
          },
        ),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Commodity Page!',
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}

