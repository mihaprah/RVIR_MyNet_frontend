import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:my_net/models/Client.dart';
import 'package:my_net/models/PolygonApiResponse.dart';
import 'package:my_net/models/Stock.dart';
import 'package:my_net/models/StockShare.dart';
import 'package:my_net/models/UpdateAmountRequest.dart';
import 'package:my_net/providers/StocksProvider.dart';
import 'package:my_net/widgets/CustomLineChart.dart';
import 'package:my_net/widgets/PopupAddInvestment.dart';
import 'package:my_net/widgets/PopupEditInvestment.dart';
import 'package:provider/provider.dart';
import '../constants/constants.dart';
import '../providers/CurrencyProvider.dart';
import '../widgets/CustomAppBar.dart';
import 'package:http/http.dart' as http;

import '../widgets/CustomSnackBar.dart';


class StocksPage extends StatefulWidget {
  final Client? client;

  const StocksPage({
    Key? key,
    this.client,
  }) : super(key: key);

  @override
  _StocksPageState createState() => _StocksPageState();
}

class _StocksPageState extends State<StocksPage> {
  String currentScreen = '/stocks';
  double conversionRate = 0.0;
  double stocksSum = 0.0;
  late Client client;
  Map<String, double> stocksShares = {};
  List<StockShare> clientStocksRaw = [];
  String selectedStock = 'AAPL';
  List<String> availableStocks = [];
  List<PolygonApiResponse> appleResponse = [];
  List<PolygonApiResponse> microsoftResponse = [];
  List<PolygonApiResponse> teslaResponse = [];
  double appleValue = 0.0;
  double microsoftValue = 0.0;
  double teslaValue = 0.0;

  Map<String, List<FlSpot>> stocksChartData = {};
  Map<String, double> stocksChartMaxValues = {};

  @override
  void initState() {
    super.initState();
    setClient(widget.client!);
    fetchClient();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getConversionRate();
      fetchStocksPrices();
    });
  }

  void getConversionRate() {
    CurrencyProvider currencyProvider = Provider.of<CurrencyProvider>(context, listen: false);

    setState(() {
      conversionRate = currencyProvider.usdToEurConversion;
    });
  }

  void fetchStocksPrices() {
    StocksProvider stocksProvider = Provider.of<StocksProvider>(context, listen: false);
    appleResponse = stocksProvider.appleList;
    microsoftResponse = stocksProvider.microsoftList;
    teslaResponse = stocksProvider.teslaList;

    setState(() {
      appleValue = appleResponse[appleResponse.length - 1].c;
      microsoftValue = microsoftResponse[microsoftResponse.length -1].c;
      teslaValue = teslaResponse[teslaResponse.length - 1].c;
      stocksChartMaxValues = stocksProvider.stocksMaxValues;
      stocksChartData = {
        "MSFT": stocksProvider.getYearChartData(microsoftResponse),
        "AAPL": stocksProvider.getYearChartData(appleResponse),
        "TSLA": stocksProvider.getYearChartData(teslaResponse),
      };
    });
  }


  void calculateStocksSum() {
    double temp = 0.0;
    stocksShares.forEach((code, amount) {
      if (code == "MSFT") {
        temp += amount * microsoftValue;
      } else if (code == "AAPL") {
        temp += amount * appleValue;
      } else {
        temp += amount * teslaValue;
      }
    });
    setState(() {
      stocksSum = temp*conversionRate;
    });
  }

  void checkForEmptyStocks() {
    stocksShares.forEach((code, amount) {
      if (amount == 0.0) {
        deleteShare(code);
      }
    });
    stocksShares.removeWhere((code, amount) => amount == 0.0);
  }

  Future<void> deleteShare(String code) async {
    int id = 0;
    clientStocksRaw.forEach((element) {
      if (element.stock.code == code) {
        id = element.id!;
      }
    });

    try {
      if (id != 0) {
        var endPoint = "/stockshare/delete/$id";
        var url = Uri.parse("$baseUrl$endPoint");

        var response = await http.delete(url);
        if (response.statusCode == 200) {
          showPopUp("$code stock removed successfully.", false);
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
        stocksShares.clear();
        getClientStocks();
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

  Future<void> getClientStocks() async {
    clientStocksRaw.clear();
    stocksShares.clear();
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
            setState(() {
              addOrUpdateStockShare(stock.stock.code, stock.amount);
            });
          }
          setState(() {
            clientStocksRaw = clientStocks;
            availableStocks = stocksShares.keys.toList();
          });
          checkForEmptyStocks();
          calculateStocksSum();
        } else {
          showPopUp("Unfortunately something went wrong.", true);
        }
      }
    } catch (e) {
      showPopUp("Unfortunately something went wrong.", true);
    }
  }

  void addOrUpdateStockShare(String code, double amount) {
    if (stocksShares.containsKey(code)) {
      stocksShares[code] = stocksShares[code]! + amount;
    } else {
      stocksShares[code] = amount;
    }
  }

  Future<void> addStocksAmount(double amount, String code) async {
    try {
      if (code.isNotEmpty) {
        StockShare? share = getStockShare(code);
        double oldAmount = getOldAmount(code);
        double newAmount = oldAmount + amount;
        if (newAmount < 0.0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("You do not have that much of $code."),
              duration: const Duration(seconds: 3),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }
        if (share != null) {
          UpdateAmountRequest requestBody = UpdateAmountRequest(amount: newAmount);
          var endPoint = "/stockshare/updateAmount/${share.id}";
          var url = Uri.parse("$baseUrl$endPoint");

          var response = await http.put(
              url,
              headers: <String, String>{
                'Content-Type': 'application/json',
              },
              body: jsonEncode(requestBody)
          );

          if (response.statusCode == 200) {
            getClientStocks();
            showPopUp("$code stock amount updated successfully.", false);
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
    if (stocksShares.containsKey(code)) {
      return stocksShares[code]!;
    } else {
      return 0.0;
    }
  }

  StockShare? getStockShare(String code) {
    for (var stockShare in clientStocksRaw) {
      if (stockShare.stock.code == code) {
        return stockShare;
      }
    }
    return null;
  }

  Future<void> addNewStock(double amount, String code) async {
    try {
      if (code.isNotEmpty) {
        Stock? stock = await getStockByCode(code);
        if (stock != null) {
          StockShare share = StockShare(amount: amount, client: client, stock: stock);
          var endPoint = "/stockshare/add";
          var url = Uri.parse("$baseUrl$endPoint");
          var response = await http.post(
              url,
              headers: <String, String>{
                'Content-Type': 'application/json',
              },
              body: jsonEncode(share)
          );
          if (response.statusCode == 200) {
            getClientStocks();
            showPopUp("New $code stock added successfully.", false);
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

  Future<Stock?> getStockByCode(String code) async {
    try {
      var endPoint = "/stock/code/$code";
      var url = Uri.parse("$baseUrl$endPoint");

      var response = await http.get(url);
      var jsonData = json.decode(response.body);

      if (response.statusCode == 200) {
        return Stock.fromJson(jsonData);
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
                              'Stocks balance',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(
                              height: 2,
                            ),
                            Text( "${stocksSum.toStringAsFixed(2)} €",
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
                                    options: availableStocks,
                                    errorMessage: "No stocks added.",
                                    onSave: (bool isAddSelected, double amount, String code) {
                                      if (isAddSelected) {
                                        addStocksAmount(amount, code);
                                      } else {
                                        addStocksAmount(-amount, code);
                                      }
                                    },
                                  ),
                                  const SizedBox(width: 50),
                                  PopupAddInvestment(
                                    title: "Add new Stock",
                                    options: const ["AAPL", "MSFT", "TSLA"],
                                    onSave: (double amount, String code) {
                                      addNewStock(amount, code);
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
                              if (stocksShares.isEmpty)
                                const Text(
                                  'You have not added any stocks.',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              if (stocksShares.isNotEmpty)
                                const Text(
                                  'Stocks',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ListView.builder(
                                  itemCount: stocksShares.length,
                                  shrinkWrap: true,
                                  itemBuilder: (BuildContext context, int index) {
                                    final List<MapEntry<String, double>> stocksList = stocksShares.entries.toList();
                                    final stock = stocksList[index];
                                    final stockCode = stock.key;
                                    String stockName = "";
                                    final shares = stock.value;
                                    double currentPrice = 0.0;
                                    Color circleColor = Colors.white;

                                    if (stockCode == "MSFT") {
                                      stockName = "Microsoft Corp";
                                      currentPrice = microsoftValue;
                                      circleColor = const Color(0xFF015AA4);
                                    } else if (stockCode == "AAPL") {
                                      stockName = "Apple Inc.";
                                      currentPrice = appleValue;
                                      circleColor = const Color(0xFF959595);
                                    } else {
                                      stockName = "Tesla Inc.";
                                      currentPrice = teslaValue;
                                      circleColor = const Color(0xFFE31A37);
                                    }

                                    final completion = (shares*currentPrice*conversionRate)/stocksSum;
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
                                                        stockCode,
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 16,
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
                                                        stockName,
                                                        style: const TextStyle(
                                                          fontWeight: FontWeight.normal,
                                                          fontSize: 15,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 5),
                                                      Text(
                                                        "${(shares * currentPrice * conversionRate).toStringAsFixed(2)} €",
                                                        style: const TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 20,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 5),
                                                      Text(
                                                        "$shares $stockCode \u2022 $currentPrice €",
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
                                    value: selectedStock,
                                    onChanged: (String? newValue) {
                                      if (newValue != null) {
                                        setState(() {
                                          selectedStock = newValue;
                                        });
                                      }
                                    },
                                    items: <String>['AAPL', 'MSFT', 'TSLA'].map<DropdownMenuItem<String>>((String value) {
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
                                  if (selectedStock == "AAPL")
                                    Text("$appleValue €", style: const TextStyle(fontWeight: FontWeight.bold))
                                  else if (selectedStock == "MSFT")
                                    Text("$microsoftValue €", style: const TextStyle(fontWeight: FontWeight.bold),)
                                  else if (selectedStock == "TSLA")
                                      Text("$teslaValue €", style: const TextStyle(fontWeight: FontWeight.bold),)
                                ],
                              ),
                              CustomLineChart(
                                dataSpots: stocksChartData[selectedStock] ?? [],
                                maxValue: stocksChartMaxValues[selectedStock] ?? 0.0,
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

