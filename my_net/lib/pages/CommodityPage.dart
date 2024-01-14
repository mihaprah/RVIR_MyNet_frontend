import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:my_net/models/Commodity.dart';
import 'package:my_net/models/CommodityShare.dart';
import 'package:my_net/providers/CommoditiesProvider.dart';
import 'package:provider/provider.dart';
import '../constants/constants.dart';
import '../models/Client.dart';
import '../models/UpdateAmountRequest.dart';
import '../widgets/CustomAppBar.dart';
import 'package:http/http.dart' as http;

import '../widgets/CustomLineChart.dart';
import '../widgets/PopupAddInvestment.dart';
import '../widgets/PopupEditInvestment.dart';


class CommodityPage extends StatefulWidget {
  final Client? client;

  const CommodityPage({
    Key? key,
    this.client
  }) : super(key: key);

  @override
  _CommodityPageState createState() => _CommodityPageState();
}

class _CommodityPageState extends State<CommodityPage> {
  String currentScreen = '/commodities';
  double commoditiesSum = 0.0;
  late Client client;
  Map<String, double> commoditiesShares = {};
  List<CommodityShare> clientCommoditiesRaw = [];
  String selectedCommodity = 'XAU';
  List<String> availableCommodities = [];
  List<double> goldResponse = [];
  List<double> silverResponse = [];
  List<double> platinumResponse = [];
  double goldValue = 0.0;
  double silverValue = 0.0;
  double platinumValue = 0.0;

  Map<String, List<FlSpot>> commoditiesChartData = {};
  Map<String, double> commoditiesChartMaxValues = {};

  @override
  void initState() {
    super.initState();
    setClient(widget.client!);
    fetchClient();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      fetchCommoditiesPrices();
    });
  }

  void fetchCommoditiesPrices() {
    CommoditiesProvider commoditiesProvider = Provider.of<CommoditiesProvider>(context, listen: false);
    goldResponse = commoditiesProvider.goldList;
    silverResponse = commoditiesProvider.silverList;
    platinumResponse = commoditiesProvider.platinumList;

    setState(() {
      goldValue = goldResponse[goldResponse.length - 1];
      silverValue = silverResponse[silverResponse.length -1];
      platinumValue = platinumResponse[platinumResponse.length - 1];
      commoditiesChartMaxValues = commoditiesProvider.commoditiesMaxValues;
      commoditiesChartData = {
        "XAU": commoditiesProvider.getYearChartData(goldResponse),
        "XAG": commoditiesProvider.getYearChartData(silverResponse),
        "XPT": commoditiesProvider.getYearChartData(platinumResponse),
      };
    });
  }


  void calculateCommoditiesSum() {
    double temp = 0.0;
    commoditiesShares.forEach((code, amount) {
      if (code == "XAU") {
        temp += amount * goldValue;
      } else if (code == "XAG") {
        temp += amount * silverValue;
      } else {
        temp += amount * platinumValue;
      }
    });
    setState(() {
      commoditiesSum = temp;
    });
  }

  void checkForEmptyCommodities() {
    commoditiesShares.forEach((code, amount) {
      if (amount == 0.0) {
        deleteShare(code);
      }
    });
    commoditiesShares.removeWhere((code, amount) => amount == 0.0);
  }

  Future<void> deleteShare(String code) async {
    int id = 0;
    clientCommoditiesRaw.forEach((element) {
      if (element.commodity.code == code) {
        id = element.id!;
      }
    });

    try {
      if (id != 0) {
        var endPoint = "/commodityshare/delete/$id";
        var url = Uri.parse("$baseUrl$endPoint");

        var response = await http.delete(url);
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("$code commodity removed successfully."),
              duration: const Duration(seconds: 3),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      print("Error: $e");
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
        commoditiesShares.clear();
        getClientCommodities();
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

  Future<void> getClientCommodities() async {
    clientCommoditiesRaw.clear();
    commoditiesShares.clear();
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
            setState(() {
              addOrUpdateCommodityShare(commodity.commodity.code, commodity.amount);
            });
          }
          setState(() {
            clientCommoditiesRaw = clientCommodities;
            availableCommodities = commoditiesShares.keys.toList();
          });
          checkForEmptyCommodities();
          calculateCommoditiesSum();
        } else {
          print("Request failed with status: ${response.statusCode}");
        }
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  void addOrUpdateCommodityShare(String code, double amount) {
    if (commoditiesShares.containsKey(code)) {
      commoditiesShares[code] = commoditiesShares[code]! + amount;
    } else {
      commoditiesShares[code] = amount;
    }
  }

  Future<void> addCommoditiesAmount(double amount, String code) async {
    try {
      if (code.isNotEmpty) {
        CommodityShare? share = getCommodityShare(code);
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
          var endPoint = "/commodityshare/updateAmount/${share.id}";
          var url = Uri.parse("$baseUrl$endPoint");

          var response = await http.put(
              url,
              headers: <String, String>{
                'Content-Type': 'application/json',
              },
              body: jsonEncode(requestBody)
          );

          if (response.statusCode == 200) {
            getClientCommodities();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("$code commodity amount updated successfully."),
                duration: const Duration(seconds: 3),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        } else {
          print('CommodityShare not found for code: $code');
        }
      } else {
        print('Empty code provided');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  double getOldAmount(String code) {
    if (commoditiesShares.containsKey(code)) {
      return commoditiesShares[code]!;
    } else {
      return 0.0;
    }
  }

  CommodityShare? getCommodityShare(String code) {
    for (var commodityShare in clientCommoditiesRaw) {
      if (commodityShare.commodity.code == code) {
        return commodityShare;
      }
    }
    return null;
  }

  Future<void> addNewCommodity(double amount, String code) async {
    try {
      if (code.isNotEmpty) {
        Commodity? commodity = await getCommodityByCode(code);
        if (commodity != null) {
          CommodityShare share = CommodityShare(amount: amount, client: client, commodity: commodity);
          var endPoint = "/commodityshare/add";
          var url = Uri.parse("$baseUrl$endPoint");
          var response = await http.post(
              url,
              headers: <String, String>{
                'Content-Type': 'application/json',
              },
              body: jsonEncode(share)
          );
          if (response.statusCode == 200) {
            getClientCommodities();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("New $code commodity added successfully."),
                duration: const Duration(seconds: 3),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        } else {
          print('CommodityShare not found for code: $code');
        }
      } else {
        print('Empty code provided.');
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<Commodity?> getCommodityByCode(String code) async {
    try {
      var endPoint = "/commodity/code/$code";
      var url = Uri.parse("$baseUrl$endPoint");

      var response = await http.get(url);
      var jsonData = json.decode(response.body);

      if (response.statusCode == 200) {
        return Commodity.fromJson(jsonData);
      } else {
        print('Failed to get commodity. Status code: ${response.statusCode}');
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
                              'Commodities balance',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(
                              height: 2,
                            ),
                            Text( "${commoditiesSum.toStringAsFixed(2)} €",
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
                                    title: "Change commodities amount",
                                    options: availableCommodities,
                                    errorMessage: "No commodities added.",
                                    onSave: (bool isAddSelected, double amount, String code) {
                                      if (isAddSelected) {
                                        addCommoditiesAmount(amount, code);
                                      } else {
                                        addCommoditiesAmount(-amount, code);
                                      }
                                    },
                                  ),
                                  const SizedBox(width: 50),
                                  PopupAddInvestment(
                                    title: "Add new Commodity   (troy ounces)",
                                    options: const ["XAU", "XAG", "XPT"],
                                    onSave: (double amount, String code) {
                                      addNewCommodity(amount, code);
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
                              if (commoditiesShares.isEmpty)
                                const Text(
                                  'You have not added any commodities.',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              if (commoditiesShares.isNotEmpty)
                                const Text(
                                  'Commodities',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ListView.builder(
                                  itemCount: commoditiesShares.length,
                                  shrinkWrap: true,
                                  itemBuilder: (BuildContext context, int index) {
                                    final List<MapEntry<String, double>> commoditiesList = commoditiesShares.entries.toList();
                                    final commodity = commoditiesList[index];
                                    final commodityCode = commodity.key;
                                    String commodityName = "";
                                    final shares = commodity.value;
                                    double currentPrice = 0.0;
                                    Color circleColor = Colors.white;

                                    if (commodityCode == "XAU") {
                                      commodityName = "Gold";
                                      currentPrice = goldValue;
                                      circleColor = const Color(0xFFFFD700);
                                    } else if (commodityCode == "XAG") {
                                      commodityName = "Silver";
                                      currentPrice = silverValue;
                                      circleColor = const Color(0xFF9F9F9F);
                                    } else {
                                      commodityName = "Platinum";
                                      currentPrice = platinumValue;
                                      circleColor = const Color(0xFFE5E4E2);
                                    }

                                    final completion = (shares*currentPrice)/commoditiesSum;
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
                                                      commodityCode,
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
                                                      commodityName,
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
                                                      "$shares oz t \u2022 ${currentPrice.toStringAsFixed(2)} €",
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
                                    value: selectedCommodity,
                                    onChanged: (String? newValue) {
                                      if (newValue != null) {
                                        setState(() {
                                          selectedCommodity = newValue;
                                        });
                                      }
                                    },
                                    items: <String>['XAU', 'XAG', 'XPT'].map<DropdownMenuItem<String>>((String value) {
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
                                  if (selectedCommodity == "XAU")
                                    Text("${goldValue.toStringAsFixed(2)} € (per oz t)", style: const TextStyle(fontWeight: FontWeight.bold))
                                  else if (selectedCommodity == "XAG")
                                    Text("${silverValue.toStringAsFixed(2)} € (per oz t)", style: const TextStyle(fontWeight: FontWeight.bold),)
                                  else if (selectedCommodity == "XPT")
                                      Text("${platinumValue.toStringAsFixed(2)} € (per oz t)", style: const TextStyle(fontWeight: FontWeight.bold),)
                                ],
                              ),
                              CustomLineChart(
                                dataSpots: commoditiesChartData[selectedCommodity] ?? [],
                                maxValue: commoditiesChartMaxValues[selectedCommodity] ?? 0.0,
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

