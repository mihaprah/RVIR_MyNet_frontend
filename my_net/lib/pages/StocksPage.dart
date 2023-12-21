import 'package:flutter/material.dart';
import 'package:my_net/models/Client.dart';
import '../widgets/CustomAppBar.dart';

class StocksPage extends StatefulWidget {
  @override
  _StocksPageState createState() => _StocksPageState();
}

class _StocksPageState extends State<StocksPage> {
  String currentScreen = '/stocks';
  late Client currentClient;

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
              'Stocks Page!',
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}

