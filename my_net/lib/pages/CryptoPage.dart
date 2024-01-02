import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:my_net/models/Client.dart';
import '../constants/constants.dart';
import '../models/CryptocurrencyShare.dart';
import '../widgets/CustomAppBar.dart';
import 'package:http/http.dart' as http;


class CryptoPage extends StatefulWidget {
  final Client? client;

  const CryptoPage({
    Key? key,
    this.client,
  }) : super(key: key);

  @override
  _CryptoPageState createState() => _CryptoPageState();
}

class _CryptoPageState extends State<CryptoPage> {
  String currentScreen = '/crypto';
  late Client currentClient;
  double cryptoSum = 0.0;
  late Client client;
  Map<String, double> cryptoShares = {};

  @override
  void initState() {
    super.initState();
    setClient(widget.client!);
    fetchClient();
  }

  Future<void> fetchClient() async {
    try {
      var endPoint = "/client/${widget.client!.id}";
      var url = Uri.parse("$baseUrl$endPoint");

      var response = await http.get(url);
      var jsonData = json.decode(response.body);

      if (response.statusCode == 200) {
        setClient(Client.fromJson(jsonData));
        cryptoShares.clear();
        getClientCrypto();
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  void setClient(Client clientOne) {
    setState(() {
      client = clientOne;
    });
  }

  Future<void> getClientCrypto() async {
    try {
      if (widget.client != null) {
        var endPoint = "/cryptocurrencyshare/all/${widget.client!.id}";
        var url = Uri.parse("$baseUrl$endPoint");

        var response = await http.get(url);
        var jsonData = json.decode(response.body);

        if (response.statusCode == 200) {
          List<CryptocurrencyShare> clientCryptos = (jsonData as List)
              .map((item) => CryptocurrencyShare.fromJson(item))
              .toList();
          for (var crypto in clientCryptos) {
            setState(() {
              addOrUpdateCryptoShare(crypto.cryptocurrency.code, crypto.amount);
            });
          }
        } else {
          print("Request failed with status: ${response.statusCode}");
        }
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  void addOrUpdateCryptoShare(String code, double amount) {
    if (cryptoShares.containsKey(code)) {
      cryptoShares[code] = cryptoShares[code]! + amount;
    } else {
      cryptoShares[code] = amount;
    }
  }

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
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width - 20.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5), // Color of the shadow
                          spreadRadius: 2,
                          blurRadius: 3,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.only(
                      left: 15.0,
                      top: 10.0,
                      right: 20.0,
                      bottom: 10.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Crypto balance',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(
                          height: 2,
                        ),
                        Text( "$cryptoSum €",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 25,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(onPressed: () {}, icon: Icon(
                                Icons.edit,
                                color: Theme.of(context).primaryColor,
                                size: 25,
                              ),
                              ),
                              const SizedBox(width: 50),
                              IconButton(onPressed: () {}, icon: Icon(
                                Icons.add,
                                color: Theme.of(context).primaryColor,
                                size: 25,
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      width: MediaQuery.of(context).size.width - 20.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 3,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.only(
                          left: 15.0, top: 10.0, right: 20.0, bottom: 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Cryptocurrencies',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          ListView.builder(
                              itemCount: cryptoShares.length,
                              shrinkWrap: true,
                              itemBuilder: (BuildContext context, int index) {
                                final List<MapEntry<String, double>> cryptoList = cryptoShares.entries.toList();
                                final crypto = cryptoList[index];
                                final cryptoCode = crypto.key;
                                String cryptoName = "";
                                final shares = crypto.value;
                                final completion = 0.0;
                                final percentage = ((completion * 100).round()).toInt();

                                if (cryptoCode == "ETH") {
                                  cryptoName = "Etherium";
                                } else if (cryptoCode == "BTC") {
                                  cryptoName = "Bitcoin";
                                } else {
                                  cryptoName = "Binance coin";
                                }

                                return GestureDetector(
                                  onTap: () async {
                                    // final result = await Navigator.push(
                                    //   context,
                                    //   MaterialPageRoute(
                                    //     builder: (context) => SingleVaultPage(id: vault.id!),
                                    //   ),
                                    // );
                                    //
                                    // if (result == null) {
                                    //   fetchClient();
                                    // }
                                  },
                                  child: Row(
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Row(
                                            children: [
                                              Container(
                                                width: 50,
                                                height: 50,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    cryptoCode,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 20,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 15),
                                              Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    cryptoName,
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.normal,
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Text(
                                                   "100.00 €",
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 20,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Text(
                                                    "$shares",
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.w400,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const Expanded(
                                        child: SizedBox(),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            right: 10.0, top: 15.0),
                                        child: Container(
                                          width: 60,
                                          height: 60,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color: Colors.transparent,
                                                width: 4),
                                            color: Colors.transparent,
                                          ),
                                          child: Stack(
                                            children: [
                                              Center(
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 4,
                                                  value: 0.33,
                                                  valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      Theme.of(context)
                                                          .primaryColor),
                                                  backgroundColor:
                                                  Colors.transparent,
                                                ),
                                              ),
                                              Center(
                                                child: Text(
                                                  '$percentage%',
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );


                              }),
                        ],
                      )),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

