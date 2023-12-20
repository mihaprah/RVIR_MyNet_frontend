import 'package:flutter/material.dart';
import 'package:my_net/main.dart';

import '../routes/app_routes.dart';
import '../routes/auth_routes.dart';
import '../widgets/CustomAppBar.dart';
import 'LoginPage.dart';

class StocksPage extends StatefulWidget {
  @override
  _StocksPageState createState() => _StocksPageState();
}

class _StocksPageState extends State<StocksPage> {
  String currentScreen = '/stocks'; // Example: Set the initial screen to '/home'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(90.0), // same as your CustomAppBar preferredSize
        child: CustomAppBar(
          context: context,
          currentScreen: currentScreen,
          onScreenChange: (String screen) {
            setState(() {
              currentScreen = screen;
            });


            Navigator.pushReplacementNamed(context, screen);


          },
        ),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Stocks Page!',
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}

