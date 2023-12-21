import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:my_net/models/Client.dart';
import 'package:my_net/pages/CommodityPage.dart';
import 'package:my_net/pages/CryptoPage.dart';
import 'package:my_net/pages/HomePage.dart';
import 'package:my_net/pages/StocksPage.dart';
import 'package:my_net/pages/VaultsPage.dart';
import 'package:http/http.dart' as http;
import 'package:my_net/constants/constants.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(45.0);

  final String currentScreen;
  final Function(String, Widget) onScreenChange;
  final BuildContext context;

  const CustomAppBar({Key? key,
    required this.currentScreen,
    required this.onScreenChange,
    required this.context})
      : super(key: key);


  @override
  _CustomAppBarState createState() => _CustomAppBarState();

}

class _CustomAppBarState extends State<CustomAppBar>{
  late Client client;

  @override
  void initState() {
    super.initState();
    fetchClient();
  }

  Color getButtonBackgroundColor(String screen) {
    return widget.currentScreen == screen
        ? Theme.of(context).primaryColor
        : Colors.white;
  }

  Color getButtonTextColor(String screen) {
    return widget.currentScreen == screen
        ? Colors.white
        : Theme.of(context).primaryColor;
  }

  Future<void> fetchClient() async {
    try {
      var endPoint = "/client/1";
      var url = Uri.parse("$baseUrl$endPoint");

      var response = await http.get(url);
      var jsonData = json.decode(response.body);

      if (response.statusCode == 200) {
        client = Client.fromJson(jsonData);
      } else {
        print('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(45.0),
      child: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'MyNet',
              style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 25,
                  fontWeight: FontWeight.bold
              ),
            ),
            IconButton(
              onPressed: () {
                // Handle the action when the person icon is pressed
              },
              icon: Icon(
                Icons.person,
                color: Theme.of(context).primaryColor,
                size: 35,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(45.0),
          child: SizedBox(
            height: 44.0,
            child: Column(
              children: [
                Expanded(
                  child: Scrollbar(
                    controller: ScrollController(),
                    child: SingleChildScrollView(
                      physics:
                      const AlwaysScrollableScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      padding:
                      const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6),
                      child: Row(
                        children: [
                          ElevatedButton(
                            onPressed: () => widget.onScreenChange('/home', HomePage()),
                            style: ButtonStyle(
                              backgroundColor:
                              MaterialStateProperty.resolveWith<Color>(
                                    (Set<MaterialState> states) {
                                  return getButtonBackgroundColor('/home');
                                },
                              ),
                              side:
                              MaterialStateProperty.resolveWith<BorderSide>(
                                    (Set<MaterialState> states) {
                                  return BorderSide(
                                      color: Theme.of(context).primaryColor);
                                },
                              ),
                            ),
                            child: Text(
                              'Home',
                              style: TextStyle(
                                  color: getButtonTextColor('/home'),
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () => widget.onScreenChange('/vaults', VaultsPage()),
                            style: ButtonStyle(
                              backgroundColor:
                              MaterialStateProperty.resolveWith<Color>(
                                    (Set<MaterialState> states) {
                                  return getButtonBackgroundColor('/vaults');
                                },
                              ),
                              side:
                              MaterialStateProperty.resolveWith<BorderSide>(
                                    (Set<MaterialState> states) {
                                  return BorderSide(
                                      color: Theme.of(context).primaryColor);
                                },
                              ),
                            ),
                            child: Text(
                              'Vaults',
                              style: TextStyle(
                                  color: getButtonTextColor('/vaults'),
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () => widget.onScreenChange('/crypto', CryptoPage()),
                            style: ButtonStyle(
                              backgroundColor:
                              MaterialStateProperty.resolveWith<Color>(
                                    (Set<MaterialState> states) {
                                  return getButtonBackgroundColor('/crypto');
                                },
                              ),
                              side:
                              MaterialStateProperty.resolveWith<BorderSide>(
                                    (Set<MaterialState> states) {
                                  return BorderSide(
                                      color: Theme.of(context).primaryColor);
                                },
                              ),
                            ),
                            child: Text(
                              'Crypto',
                              style: TextStyle(
                                  color: getButtonTextColor('/crypto'),
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () => widget.onScreenChange('/stocks', StocksPage()),
                            style: ButtonStyle(
                              backgroundColor:
                              MaterialStateProperty.resolveWith<Color>(
                                    (Set<MaterialState> states) {
                                  return getButtonBackgroundColor('/stocks');
                                },
                              ),
                              side:
                              MaterialStateProperty.resolveWith<BorderSide>(
                                    (Set<MaterialState> states) {
                                  return BorderSide(
                                      color: Theme.of(context).primaryColor);
                                },
                              ),
                            ),
                            child: Text(
                              'Stocks',
                              style: TextStyle(
                                  color: getButtonTextColor('/stocks'),
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () => widget.onScreenChange('/commodities', CommodityPage()),
                            style: ButtonStyle(
                              backgroundColor:
                              MaterialStateProperty.resolveWith<Color>(
                                    (Set<MaterialState> states) {
                                  return getButtonBackgroundColor('/commodities');
                                },
                              ),
                              side:
                              MaterialStateProperty.resolveWith<BorderSide>(
                                    (Set<MaterialState> states) {
                                  return BorderSide(
                                      color: Theme.of(context).primaryColor);
                                },
                              ),
                            ),
                            child: Text(
                              'Commodities',
                              style: TextStyle(
                                  color: getButtonTextColor('/commodities'),
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  color: Theme.of(context)
                      .primaryColor,
                  height: 4.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}