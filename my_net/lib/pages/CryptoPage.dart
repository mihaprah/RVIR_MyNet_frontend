import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:my_net/models/Client.dart';
import 'package:my_net/models/PolygonApiResponse.dart';
import 'package:my_net/models/Cryptocurrency.dart';
import 'package:my_net/models/UpdateAmountRequest.dart';
import 'package:my_net/providers/CryptoProvider.dart';
import 'package:my_net/widgets/CustomLineChart.dart';
import 'package:my_net/widgets/PopupAddInvestment.dart';
import 'package:my_net/widgets/PopupEditInvestment.dart';
import 'package:provider/provider.dart';
import '../constants/constants.dart';
import '../models/CryptocurrencyShare.dart';
import '../providers/CurrencyProvider.dart';
import '../widgets/CustomAppBar.dart';
import 'package:http/http.dart' as http;
import '../widgets/CustomSnackBar.dart';


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
  double conversionRate = 0.0;
  double cryptoSum = 0.0;
  late Client client;
  Map<String, double> cryptoShares = {};
  List<CryptocurrencyShare> clientCryptoRaw = [];
  String selectedCrypto = 'ETH';
  List<String> availableCryptos = [];
  List<PolygonApiResponse> bitcoinResponse = [];
  List<PolygonApiResponse> etheriumResponse = [];
  List<PolygonApiResponse> solanaResponse = [];
  double bitcoinValue = 0.0;
  double etheriumValue = 0.0;
  double solanaValue = 0.0;

  Map<String, List<FlSpot>> cryptoChartData = {};
  Map<String, double> cryptoChartMaxValues = {};

  @override
  void initState() {
    super.initState();
    setClient(widget.client!);
    fetchClient();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getConversionRate();
      fetchCryptoPrices();
    });
  }

  void getConversionRate() {
    CurrencyProvider currencyProvider = Provider.of<CurrencyProvider>(context, listen: false);

    setState(() {
      conversionRate = currencyProvider.usdToEurConversion;
    });
  }

  void fetchCryptoPrices() {
      CryptoProvider cryptoProvider = Provider.of<CryptoProvider>(context, listen: false);
      bitcoinResponse = cryptoProvider.bitcoinList;
      etheriumResponse = cryptoProvider.etheriumList;
      solanaResponse = cryptoProvider.solanaList;

      setState(() {
        bitcoinValue = (bitcoinResponse[bitcoinResponse.length - 1].c) * conversionRate;
        etheriumValue = (etheriumResponse[etheriumResponse.length -1].c) * conversionRate;
        solanaValue = (solanaResponse[solanaResponse.length - 1].c) * conversionRate;
        cryptoChartMaxValues = cryptoProvider.cryptoMaxValues;
        cryptoChartData = {
          "ETH": cryptoProvider.getYearChartData(etheriumResponse, conversionRate),
          "BTC": cryptoProvider.getYearChartData(bitcoinResponse, conversionRate),
          "SOL": cryptoProvider.getYearChartData(solanaResponse, conversionRate),
        };
      });
  }


  void calculateCryptoSum() {
    double temp = 0.0;
    cryptoShares.forEach((code, amount) {
      if (code == "ETH") {
        temp += amount * etheriumValue;
      } else if (code == "BTC") {
        temp += amount * bitcoinValue;
      } else {
        temp += amount * solanaValue;
      }
    });
    setState(() {
      cryptoSum = temp*conversionRate;
    });
  }

  void checkForEmptyCrypto() {
    cryptoShares.forEach((code, amount) {
      if (amount == 0.0) {
        deleteShare(code);
      }
    });
    cryptoShares.removeWhere((code, amount) => amount == 0.0);
  }

  Future<void> deleteShare(String code) async {
    int id = 0;
    clientCryptoRaw.forEach((element) {
      if (element.cryptocurrency.code == code) {
        id = element.id!;
      }
    });

    try {
    if (id != 0) {
      var endPoint = "/cryptocurrencyshare/delete/$id";
      var url = Uri.parse("$baseUrl$endPoint");

      var response = await http.delete(url);
      if (response.statusCode == 200) {
        showPopUp("$code cryptocurrency removed successfully.", false);
      }
    }
    } catch (e) {
      showPopUp("Unfortunately something went wrong.", true);
    }

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
      showPopUp("Unfortunately something went wrong.", true);
    }
  }

  void setClient(Client clientOne) {
    setState(() {
      client = clientOne;
    });
  }

  Future<void> getClientCrypto() async {
    clientCryptoRaw.clear();
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
            clientCryptoRaw = clientCryptos;
            availableCryptos = cryptoShares.keys.toList();
          });
          checkForEmptyCrypto();
          calculateCryptoSum();
        } else {
          showPopUp("Unfortunately something went wrong.", true);
        }
      }
    } catch (e) {
      showPopUp("Unfortunately something went wrong.", true);
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
        if (newAmount < 0.0) {
          showPopUp("You do not have that much of $code.", true);
          return;
        }
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
            showPopUp("$code cryptocurrency amount updated successfully.", false);
          }
        } else {
          showPopUp("Unfortunately something went wrong.", true);
        }
      } else {
        showPopUp("Unfortunately something went wrong.", true);
      }
    } catch (e) {
      showPopUp("Unfortunately something went wrong.", true);
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
    for (var cryptoShare in clientCryptoRaw) {
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
            showPopUp("New $code cryptocurrency added successfully.", false);
          }
        } else {
          showPopUp("Unfortunately something went wrong.", true);
        }
      } else {
        showPopUp("Unfortunately something went wrong.", true);
      }
    } catch (e) {
      showPopUp("Unfortunately something went wrong.", true);
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
        showPopUp("Unfortunately something went wrong.", true);
        return null;
      }
    } catch (e) {
      showPopUp("Unfortunately something went wrong.", true);
    }
    return null;
  }

  void showPopUp(String message, bool isError) {
    if (isError) {
      CustomSnackBar.showError(context: context, message: message);
    } else {
      CustomSnackBar.showSuccess(context: context, message: message);
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
                          Text( "${cryptoSum.toStringAsFixed(2)} €",
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
                                PopupEditInvestment(
                                    title: "Change cryptos amount",
                                    options: availableCryptos,
                                    errorMessage: "No cryptocurrencies added.",
                                    onSave: (bool isAddSelected, double amount, String code) {
                                      if (isAddSelected) {
                                        addCryptoAmount(amount, code);
                                      } else {
                                        addCryptoAmount(-amount, code);
                                      }
                                    },
                                ),
                                const SizedBox(width: 50),
                                PopupAddInvestment(
                                    title: "Add new Cryptocurrency",
                                    options: const ["ETH", "BTC", "SOL"],
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
                            if (cryptoShares.isEmpty)
                              const Text(
                                'You have not added any cryptocurrencies.',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            if (cryptoShares.isNotEmpty)
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
                                  double currentPrice = 0.0;
                                  Color circleColor = Colors.white;

                                  if (cryptoCode == "ETH") {
                                    cryptoName = "Ethereum";
                                    currentPrice = etheriumValue;
                                    circleColor = const Color(0xFF627EEA);
                                  } else if (cryptoCode == "BTC") {
                                    cryptoName = "Bitcoin";
                                    currentPrice = bitcoinValue;
                                    circleColor = const Color(0xFFF7931A);
                                  } else {
                                    cryptoName = "Solana";
                                    currentPrice = solanaValue;
                                    circleColor = const Color(0xFF47BAB1);
                                  }

                                  final completion = (shares*currentPrice*conversionRate)/cryptoSum;
                                  final percentage = ((completion * 100).round()).toInt();

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
                                                    color: circleColor,
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
                                                      "${(shares * currentPrice).toStringAsFixed(2)} €",
                                                      style: const TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 20,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 5),
                                                    Text(
                                                      "${shares.toStringAsFixed(5)} $cryptoCode \u2022 ${currentPrice.toStringAsFixed(2)} €",
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
                                  items: <String>['ETH', 'BTC', 'SOL'].map<DropdownMenuItem<String>>((String value) {
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
                                if (selectedCrypto == "BTC")
                                  Text("${bitcoinValue.toStringAsFixed(2)} €", style: const TextStyle(fontWeight: FontWeight.bold))
                                else if (selectedCrypto == "ETH")
                                  Text("${etheriumValue.toStringAsFixed(2)} €", style: const TextStyle(fontWeight: FontWeight.bold),)
                                else if (selectedCrypto == "SOL")
                                  Text("${solanaValue.toStringAsFixed(2)} €", style: const TextStyle(fontWeight: FontWeight.bold),)
                              ],
                            ),
                            CustomLineChart(
                              dataSpots: cryptoChartData[selectedCrypto] ?? [],
                              maxValue: cryptoChartMaxValues[selectedCrypto] ?? 0.0,
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

