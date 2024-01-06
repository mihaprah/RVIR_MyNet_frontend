import 'package:flutter/material.dart';
import 'package:my_net/models/Client.dart';

import '../widgets/SlowLoadingBar.dart';
import 'HomePage.dart';

class LoadingPage extends StatelessWidget {
  final Client client;

  const LoadingPage({
    required this.client,
    Key? key, // Fix the syntax error here
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(milliseconds: 5500), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(client: client),
        ),
      );
    });
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFECECEC),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Taking you to your number one net worth managing app.',
              style: TextStyle(fontSize: 25),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10,),
            SlowLoadingBar(duration: 5500),
          ],
        ),
      ),
    );
  }
}
