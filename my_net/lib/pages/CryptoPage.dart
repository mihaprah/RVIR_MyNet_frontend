import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:my_net/models/Client.dart';
import 'package:my_net/models/Cryptocurrency.dart';
import 'package:my_net/models/UpdateAmountRequest.dart';
import 'package:my_net/widgets/CustomLineChart.dart';
import 'package:my_net/widgets/PopupAddCrypto.dart';
import 'package:my_net/widgets/PopupEditCrypto.dart';
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
  List<CryptocurrencyShare> clientCrypto = [];
  String selectedCrypto = 'ETH';
  List<String> availableCryptos = [];

  double maxValueEtherium = 5000;
  double maxValueBitcoin = 60000;

  Map<String, List<FlSpot>> cryptoData = {
    'ETH': [
      FlSpot(0, 2000),
      FlSpot(1, 3400),
      FlSpot(2, 2600),
      FlSpot(3, 1600),
      FlSpot(4, 3000),
      FlSpot(5, 4200),
      FlSpot(6, 4800),
      FlSpot(7, 4865),
      FlSpot(8, 4835),
      FlSpot(9, 4634),
      FlSpot(10, 3567),
      FlSpot(11, 4040),
    ],
    'BTC': [
      FlSpot(0, 30000),
      FlSpot(1, 34000),
      FlSpot(2, 26000),
      FlSpot(3, 16000),
      FlSpot(4, 30000),
      FlSpot(5, 42000),
      FlSpot(6, 48000),
      FlSpot(7, 48565),
      FlSpot(8, 48635),
      FlSpot(9, 46834),
      FlSpot(10, 34567),
      FlSpot(11, 49040),
    ],
    'BNB': [
      FlSpot(0, 20000),
      FlSpot(1, 22000),
      // Add more data points for BNB...
    ],
  };

  Map<String, double> cryptoMaxValues = {
    'ETH': 5000,
    'BTC': 60000,
    'BNB': 25000,
  };

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
    clientCrypto.clear();
    cryptoShares.clear();
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
          setState(() {
            clientCrypto = clientCryptos;
            availableCryptos = cryptoShares.keys.toList();
          });
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

  Future<void> addCryptoAmount(double amount, String code) async {
    try {
      if (code.isNotEmpty) {
        CryptocurrencyShare? share = getCryptoShare(code);
        double oldAmount = getOldAmount(code);
        double newAmount = oldAmount + amount;
        if (share != null) {
          UpdateAmountRequest requestBody = UpdateAmountRequest(amount: newAmount);
          var endPoint = "/cryptocurrencyshare/updateAmount/${share.id}";
          var url = Uri.parse("$baseUrl$endPoint");

          var response = await http.put(
            url,
            headers: <String, String>{
              'Content-Type': 'application/json',
            },
            body: jsonEncode(requestBody)
          );

          if (response.statusCode == 200) {
            getClientCrypto();
          }
        } else {
          print('CryptocurrencyShare not found for code: $code');
        }
      } else {
        print('Empty code provided');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  double getOldAmount(String code) {
    if (cryptoShares.containsKey(code)) {
      return cryptoShares[code]!;
    } else {
      return 0.0;
    }
  }

  CryptocurrencyShare? getCryptoShare(String code) {
    for (var cryptoShare in clientCrypto) {
      if (cryptoShare.cryptocurrency.code == code) {
        return cryptoShare;
      }
    }
    return null;
  }

  Future<void> addNewCrypto(double amount, String code) async {
    try {
      if (code.isNotEmpty) {
        Cryptocurrency? crypto = await getCryptoByCode(code);
        if (crypto != null) {
          CryptocurrencyShare share = CryptocurrencyShare(amount: amount, client: client, cryptocurrency: crypto);
          var endPoint = "/cryptocurrencyshare/add";
          var url = Uri.parse("$baseUrl$endPoint");
          var response = await http.post(
            url,
            headers: <String, String>{
              'Content-Type': 'application/json',
            },
            body: jsonEncode(share)
          );
          if (response.statusCode == 200) {
            getClientCrypto();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("New cryptocurrency added successfully."),
                duration: Duration(seconds: 3),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        } else {
          print('CryptocurrencyShare not found for code: $code');
        }
      } else {
        print('Empty code provided.');
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<Cryptocurrency?> getCryptoByCode(String code) async {
    try {
      var endPoint = "/cryptocurrency/code/$code";
      var url = Uri.parse("$baseUrl$endPoint");

      var response = await http.get(url);
      var jsonData = json.decode(response.body);

      if (response.statusCode == 200) {
        return Cryptocurrency.fromJson(jsonData);
      } else {
        print('Failed to get cryptocurrency. Status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print("Error: $e");
    }
    return null;
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
                            color: Colors.grey.withOpacity(0.5),
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
                                PopupEditCrypto(
                                    title: "Change cryptos amount",
                                    cryptos: availableCryptos,
                                    onSave: (bool isAddSelected, double amount, String code) {
                                      if (isAddSelected) {
                                        addCryptoAmount(amount, code);
                                      } else {
                                        addCryptoAmount(-amount, code);
                                      }
                                    },
                                ),
                                const SizedBox(width: 50),
                                PopupAddCrypto(
                                    title: "Add new Cryptocurrency",
                                    onSave: (double amount, String code) {
                                      addNewCrypto(amount, code);
                                    },
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
                                                      "$shares $cryptoCode \u2022 20000.00 €",
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
              ),
              const SizedBox(height: 10,),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        width: MediaQuery.of(context).size.width,
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
                          left: 1.0,
                          top: 1.0,
                          right: 1.0,
                          bottom: 1.0,
                        ),
                        child: Column(
                          children: [
                            const SizedBox(height: 10,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const SizedBox(width: 20,),
                                DropdownButton<String>(
                                  value: selectedCrypto,
                                  onChanged: (String? newValue) {
                                    if (newValue != null) {
                                      setState(() {
                                        selectedCrypto = newValue;
                                      });
                                    }
                                  },
                                  items: <String>['ETH', 'BTC', 'BNB'].map<DropdownMenuItem<String>>((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(
                                        value,
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const SizedBox(width: 20,),
                                const Text("2365.56 €", style: TextStyle(fontWeight: FontWeight.bold),),
                              ],
                            ),
                            CustomLineChart(
                              dataSpots: cryptoData[selectedCrypto] ?? [],
                              maxValue: cryptoMaxValues[selectedCrypto] ?? 0.0,
                            )
                          ],
                        )
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10,)
            ],
          ),
        ),
      )

    );
  }
}

