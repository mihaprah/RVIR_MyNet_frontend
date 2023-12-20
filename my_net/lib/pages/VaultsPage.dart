import 'package:flutter/material.dart';
import 'package:my_net/main.dart';

import '../routes/app_routes.dart';
import '../routes/auth_routes.dart';
import '../widgets/CustomAppBar.dart';
import 'LoginPage.dart';

class VaultsPage extends StatefulWidget {
  @override
  _VaultsPageState createState() => _VaultsPageState();
}

class _VaultsPageState extends State<VaultsPage> {
  String currentScreen = '/vaults'; // Example: Set the initial screen to '/home'

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
              'Vaults Page!',
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}

