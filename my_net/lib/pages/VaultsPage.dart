import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:my_net/constants/constants.dart';
import 'package:my_net/models/Client.dart';
import 'package:my_net/widgets/PopupAddVault.dart';
import 'package:my_net/widgets/PopupEditVault.dart';
import '../models/UpdateAmountRequest.dart';
import '../models/Vault.dart';
import '../widgets/CustomAppBar.dart';
import 'package:http/http.dart' as http;

import 'SingleVaultPage.dart';

class VaultsPage extends StatefulWidget {
  final Client? client;

  const VaultsPage({
    Key? key,
    this.client,
  }) : super(key: key);

  @override
  _VaultsPageState createState() => _VaultsPageState();
}

class _VaultsPageState extends State<VaultsPage> {
  String currentScreen = '/vaults';
  List<Vault> clientVaults = [];
  double vaultsSum = 0.0;
  late Client client;

  @override
  void initState() {
    super.initState();
    setClient(widget.client!);
    getClientVaults();
  }

  void setClient(Client clientOne) {
    setState(() {
      client = clientOne;
    });
  }

  void getClientVaults() {
    vaultsSum = 0.0;
    clientVaults = client.vaults;
    for (Vault v in clientVaults) {
      vaultsSum += v.amount;
    }
    setState(() {
      vaultsSum = double.parse(vaultsSum.toStringAsFixed(2));
    });
    }

  Future<void> updateVaultAmount(bool isAddSelected, double amount, int vaultId) async {
    if (isAddSelected && amount > widget.client!.cashBalance){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Cash balance is not big enough."),
          duration: Duration(seconds: 3),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    double currentAmount = 0.0;
    for (Vault v in clientVaults){
      if (v.id == vaultId){
        currentAmount = v.amount;
      }
    }
    try {
      var endPoint = "/vault/updateAmount/$vaultId";
      var url = Uri.parse("$baseUrl$endPoint");
      double newAmount = amount + currentAmount;
      UpdateAmountRequest requestBody = UpdateAmountRequest(amount: newAmount);

      var response = await http.put(
          url,
          headers: <String, String>{
            'Content-Type': 'application/json',
          },
          body: jsonEncode(requestBody)
      );

      if (response.statusCode == 200){
        if (isAddSelected){
          updateCashBalance(-amount);
        } else {
          updateCashBalance(-amount);
        }
        getClient(client.id);
      } else {
        print(response.statusCode);
      }

    } catch(e){
      print("Error: $e");
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

        } else {
          print("Request failed with status: ${response.statusCode}");
        }
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> getClient(int id) async {
    try {
      var endPoint = "/client/$id";
      var url = Uri.parse("$baseUrl$endPoint");

      var response = await http.get(url);

      var jsonData = json.decode(response.body);

      if (response.statusCode == 200) {
        client = Client.fromJson(jsonData);
        setClient(client);
        getClientVaults();
      } else {
        print('Request failed with status: ${response.statusCode}');
      }
    } catch(e) {
      print("Error: $e");
    }
  }

  Future<void> addNewVault(Vault newVault) async {
    try {
      var endPoint = "/vault/add";
      var url = Uri.parse("$baseUrl$endPoint");

      var response = await http.post(
          url,
          headers: <String, String>{
            'Content-Type': 'application/json',
          },
          body: jsonEncode(newVault)
      );

      var jsonData = json.decode(response.body);

      if (response.statusCode == 200) {
        getClient(client.id);
        getClientVaults();
      } else {
        print('Request failed with status: ${response.statusCode}');
      }
    } catch(e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(90.0), // same as your CustomAppBar preferredSize
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
            }
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
                            'Total vault balance',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(
                            height: 2,
                          ),
                          Text(
                            widget.client != null ? "$vaultsSum €" : "Loading...",
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
                                PopupEditVault(
                                    title: "Change vault balance",
                                    vaults: clientVaults,
                                    onSave: (bool isAddSelected, double amount, int vaultId) {
                                      if (isAddSelected) {
                                        updateVaultAmount(true, amount, vaultId);
                                      } else {
                                        updateVaultAmount(false, -amount, vaultId);
                                      }
                                    },
                                ),
                                const SizedBox(width: 50),
                                PopupAddVault(
                                  title: "Add new vault",
                                  onSave: (String name, double goal, DateTime dueDate) {
                                    Vault newVault = Vault(name: name, goal: goal, amount: 0.0, dueDate: dueDate, icon: "", client: client);
                                    addNewVault(newVault);
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

                                  return GestureDetector(
                                    onTap: () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => SingleVaultPage(id: vault.id!),
                                        ),
                                      );

                                      if (result == null) {
                                        getClient(client.id);
                                      }
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
      )
    );
  }
}

