import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_net/models/Client.dart';

import 'HomePage.dart';

class LoadingPage extends StatelessWidget {
  final Client client;

  const LoadingPage({
    required this.client,
    super.key});

  @override
  Widget build(BuildContext context) {

    Future.delayed(const Duration(milliseconds: 4500), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(client: client,),
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
              'Taking you to your number one net worth managing page.',
              style: TextStyle(fontSize: 25),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10,),
            CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor)
            )
          ],
        ),
      ),
    );
  }
}
