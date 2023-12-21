import 'package:flutter/material.dart';
import 'package:my_net/models/Client.dart';

import '../widgets/CustomAppBar.dart';

class HomePage extends StatefulWidget {
  final Client? client;

  const HomePage({Key? key,
    this.client,})
      : super(key: key);


  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String currentScreen = '/home';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(90.0),
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
      body: Center(
          child: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0), // Set the horizontal margin
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width - 20.0, // Full width minus the margins
                  decoration: BoxDecoration(
                    border: Border.all(), // Add borders for visual separation
                  ),
                  padding: const EdgeInsets.only(left: 15.0, top: 10.0, right: 20.0, bottom: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // Align items to the ends of the row
                    children: [
                       Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Cash balance',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(
                            height: 2,
                          ),
                          Text(
                            "${widget.client!.cashBalance} €",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 25,
                            ),
                          )
                        ],
                      ),
                      IconButton(
                        onPressed: () {
                          // Handle button press
                        },
                        icon: Icon(
                          Icons.add,
                          color: Theme.of(context).primaryColor,
                          size: 30,
                        ),
                      )

                    ],
                  ),
                ),
                const SizedBox(height: 10), // Spacer between containers
                // Repeat the Container widgets for the other sections similarly
              ],
            ),
          ),

          const SizedBox(height: 10), // Spacer between containers
        ],
      )),
    );
  }
}
