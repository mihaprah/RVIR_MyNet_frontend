import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:my_net/constants/constants.dart';
import 'package:my_net/models/Client.dart';
import 'package:my_net/models/CommodityShare.dart';
import 'package:my_net/models/StockShare.dart';
import 'package:my_net/models/UpdateAmountRequest.dart';
import 'package:my_net/widgets/PopupEditCashBalance.dart';
import 'package:provider/provider.dart';

import '../models/ClientProvider.dart';
import '../models/CryptocurrencyShare.dart';
import '../models/Vault.dart';
import '../widgets/CustomAppBar.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  final Client? client;

  const HomePage({
    Key? key,
    this.client,
  }) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String currentScreen = '/home';
  List<Vault> clientVaults = [];
  double cashBalance = 0.0;
  double vaultsSum = 0.0;
  double netWorth = 0.0;
  Map<String, double> cryptoShares = {};
  Map<String, double> stocksShares = {};
  Map<String, double> commoditiesShares = {};
  late Client client;

  @override
  void initState() {
    super.initState();
    fetchClient();
    getClientCashBalance();
    getClientVaults();
    getClientCrypto();
    getClientStocks();
    getClientCommodities();
    calculateNetWorth();
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

  void getClientCashBalance() {
    if (widget.client != null) {
      setState(() {
        cashBalance = widget.client!.cashBalance;
      });
    }
  }

  void getClientVaults() {
    vaultsSum = 0.0;
    if (widget.client != null) {
      clientVaults = widget.client!.vaults;
      for (Vault v in clientVaults) {
        vaultsSum += v.amount;
      }
      vaultsSum = double.parse(vaultsSum.toStringAsFixed(2));
    }
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
            addOrUpdateCryptoShare(crypto.cryptocurrency.code, crypto.amount);
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
      // If the code exists, update the amount
      cryptoShares[code] = cryptoShares[code]! + amount;
    } else {
      // If the code doesn't exist, add it with the amount
      cryptoShares[code] = amount;
    }
  }

  Future<void> getClientStocks() async {
    try {
      if (widget.client != null) {
        var endPoint = "/stockshare/all/${widget.client!.id}";
        var url = Uri.parse("$baseUrl$endPoint");

        var response = await http.get(url);
        var jsonData = json.decode(response.body);

        if (response.statusCode == 200) {
          List<StockShare> clientStocks = (jsonData as List)
              .map((item) => StockShare.fromJson(item))
              .toList();
          for (var stock in clientStocks) {
            addOrUpdateStocksShare(stock.stock.code, stock.amount);
          }
        } else {
          print("Request failed with status: ${response.statusCode}");
        }
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  void addOrUpdateStocksShare(String code, double amount) {
    if (stocksShares.containsKey(code)) {
      // If the code exists, update the amount
      stocksShares[code] = stocksShares[code]! + amount;
    } else {
      // If the code doesn't exist, add it with the amount
      stocksShares[code] = amount;
    }
  }

  Future<void> getClientCommodities() async {
    try {
      if (widget.client != null) {
        var endPoint = "/commodityshare/all/${widget.client!.id}";
        var url = Uri.parse("$baseUrl$endPoint");

        var response = await http.get(url);
        var jsonData = json.decode(response.body);

        if (response.statusCode == 200) {
          List<CommodityShare> clientCommodities = (jsonData as List)
              .map((item) => CommodityShare.fromJson(item))
              .toList();
          for (var commodity in clientCommodities) {
            addOrUpdateCommoditiesShare(
                commodity.commodity.code, commodity.amount);
          }
        } else {
          print("Request failed with status: ${response.statusCode}");
        }
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  void addOrUpdateCommoditiesShare(String code, double amount) {
    if (commoditiesShares.containsKey(code)) {
      // If the code exists, update the amount
      commoditiesShares[code] = commoditiesShares[code]! + amount;
    } else {
      // If the code doesn't exist, add it with the amount
      commoditiesShares[code] = amount;
    }
  }
  void calculateNetWorth(){
    if (widget.client != null) {
      double temp = vaultsSum + cashBalance;
      temp = double.parse(temp.toStringAsFixed(2));

      setState(() {
        netWorth = temp;
      });
    }
  }

  Future<void> updateCashBalance(double addedAmount) async {
    try {
      if (widget.client != null) {
        var endPoint = "/client/updateCash/${widget.client!.id}";
        var url = Uri.parse("$baseUrl$endPoint");
        double newAmount = addedAmount + widget.client!.cashBalance;
        UpdateAmountRequest requestBody = UpdateAmountRequest(amount: newAmount);

        var response = await http.put(
            url,
            headers: <String, String>{
              'Content-Type': 'application/json',
            },
            body: jsonEncode(requestBody)
        );

        if (response.statusCode == 200) {
          setState(() {
            cashBalance = double.tryParse(response.body) ?? 0.0;
          });
          calculateNetWorth();
        } else {
          print("Request failed with status: ${response.statusCode}");
        }
      }
    } catch (e) {
      print("Error: $e");
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
      body: SingleChildScrollView(
        child: Center(
            child: Column(
              children: [
                const SizedBox(
                  height: 10,
                ),
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
                            left: 15.0, top: 10.0, right: 20.0, bottom: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                  widget.client != null
                                      ? "$cashBalance €"
                                      : "Loading...",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 25,
                                  ),
                                )
                              ],
                            ),
                            PopupEditCashBalance(
                              title: "Change cash balance",
                              onSave: (bool isAddSelected, double amount) {
                                if (isAddSelected){
                                  updateCashBalance(amount);
                                } else {
                                  updateCashBalance(-amount);
                                }
                              },
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
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
                            left: 15.0, top: 10.0, right: 20.0, bottom: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Net worth',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(
                                  height: 2,
                                ),
                                Text(
                                  widget.client != null
                                      ? "$netWorth €"
                                      : "Loading...",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 25,
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
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
                            left: 15.0, top: 10.0, right: 20.0, bottom: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Portfolio',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(
                                  height: 2,
                                ),
                                Text.rich(
                                  TextSpan(
                                    children: [
                                      const TextSpan(
                                        text: 'Cash: ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                      TextSpan(
                                        text: widget.client != null
                                            ? '$cashBalance €'
                                            : 'Loading...',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 25,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 2,
                                ),
                                Text.rich(
                                  TextSpan(
                                    children: [
                                      const TextSpan(
                                        text: 'Vaults: ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                      TextSpan(
                                        text: widget.client != null
                                            ? '$vaultsSum €'
                                            : 'Loading...',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 25,
                                        ),
                                      ),
                                      TextSpan(
                                        text: widget.client != null
                                            ? ' (${widget.client!.vaults.length} vaults)'
                                            : '',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.normal,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 2,
                                ),
                                Text.rich(
                                  TextSpan(
                                    children: [
                                      const TextSpan(
                                        text: 'Crypto: ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                      TextSpan(
                                        text: cryptoShares.isNotEmpty
                                            ? 'tba €'
                                            : 'Loading ...',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 25,
                                        ),
                                      ),
                                      TextSpan(
                                        text: cryptoShares.isNotEmpty
                                            ? ' (${cryptoShares.length} currencies)'
                                            : '',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.normal,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 2,
                                ),
                                Text.rich(
                                  TextSpan(
                                    children: [
                                      const TextSpan(
                                        text: 'Stocks: ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                      TextSpan(
                                        text: stocksShares.isNotEmpty
                                            ? 'tba €'
                                            : 'Loading...',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 25,
                                        ),
                                      ),
                                      TextSpan(
                                        text: stocksShares.isNotEmpty
                                            ? ' (${stocksShares.length} stocks)'
                                            : '',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.normal,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 2,
                                ),
                                Text.rich(
                                  TextSpan(
                                    children: [
                                      const TextSpan(
                                        text: 'Commodities: ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                      TextSpan(
                                        text: commoditiesShares.isNotEmpty
                                            ? 'tba €'
                                            : 'Loading...',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 25,
                                        ),
                                      ),
                                      TextSpan(
                                        text: commoditiesShares.isNotEmpty
                                            ? ' (${commoditiesShares.length} commodities)'
                                            : '',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.normal,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
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
                              left: 15.0, top: 10.0, right: 20.0, bottom: 10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Vaults',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              ListView.builder(
                                  itemCount: clientVaults.length,
                                  shrinkWrap: true,
                                  itemBuilder: (BuildContext context, int index) {
                                    final vault = clientVaults[index];
                                    final initial =
                                    vault.name.substring(0, 1).toUpperCase();
                                    final completion = vault.amount / vault.goal;
                                    final percentage =
                                    ((completion * 100).round()).toInt();

                                    return Row(
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
                                                      initial,
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 30,
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
                                                      vault.name,
                                                      style: const TextStyle(
                                                        fontWeight: FontWeight.normal,
                                                        fontSize: 15,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 5),
                                                    Text(
                                                      vault.amount.toString(),
                                                      style: const TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 20,
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
                                                    value: completion,
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
                                    );
                                  }),
                            ],
                          )
                      ),
                      const SizedBox(height: 10,)
                    ],
                  ),
                )
              ],
            )
        ),
      )
    );
  }
}
