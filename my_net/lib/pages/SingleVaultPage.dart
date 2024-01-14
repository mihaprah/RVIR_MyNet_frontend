import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:my_net/constants/constants.dart';
import 'package:http/http.dart' as http;
import 'package:my_net/widgets/PopupDeleteVault.dart';
import 'package:my_net/widgets/SlowLoadingBar.dart';

import '../models/Vault.dart';
import '../widgets/CustomSnackBar.dart';
import 'LoginPage.dart';

class SingleVaultPage extends StatefulWidget {
  final int id;
  const SingleVaultPage({required this.id, super.key});

  @override
  State<SingleVaultPage> createState() => _SingleVaultPageState();
}

class _SingleVaultPageState extends State<SingleVaultPage> {
  Vault? vault;
  String name = "";
  double goal = 0.0;
  DateTime? dueDate;
  double completion = 0.0;
  int percentage = 0;

  final TextEditingController _nameEditingController = TextEditingController();
  final TextEditingController _goalEditingController = TextEditingController();
  final TextEditingController _dueDateEditingController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () {
      getSingleVault();
    });
  }

  Future<void> getSingleVault() async {
    try {
      var endPoint = "/vault/${widget.id}";
      var url = Uri.parse("$baseUrl$endPoint");

      var response = await http.get(url);
      var jsonData = json.decode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          vault = Vault.fromJson(jsonData);
          if (vault != null) {
            _nameEditingController.text = vault!.name;
            _goalEditingController.text = vault!.goal.toString();
            _dueDateEditingController.text = DateFormat('yyyy-MM-dd').format(vault!.dueDate);
            _amountController.text = vault!.amount.toString();
            dueDate = DateTime(vault!.dueDate.year, vault!.dueDate.month, vault!.dueDate.day);
            completion = vault!.amount/vault!.goal;
            percentage = ((completion * 100).round()).toInt();
          }
        });
      }
    } catch (e) {
      showPopUp("Unfortunately something went wrong.", true);
    }
  }

  Future<void> saveChangesToVault() async {
    Vault updatedVault = Vault(
        id: vault!.id,
        name: _nameEditingController.text,
        goal: double.parse(_goalEditingController.text),
        amount: vault!.amount,
        dueDate: dueDate!,
        client: vault!.client);

    if (!checkVault(updatedVault)){
      return;
    }

    try {
      var endPoint = "/vault/update";
      var url = Uri.parse("$baseUrl$endPoint");

      var response = await http.put(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(updatedVault)
      );

      if (response.statusCode == 200){
        getSingleVault();
        showPopUp("Changes saved successfully.", false);
        Navigator.pop(context, null);
      }
    } catch(e){
      showPopUp("Unfortunately something went wrong.", true);
    }
  }

  bool checkVault(Vault vault) {
    if(vault.amount >= vault.goal){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Goal must be bigger the amount."),
          duration: Duration(seconds: 3),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return false;
    }
    return true;
  }

  Future<void> deleteVault() async {
    try {
      var endPoint = "/vault/delete/${vault!.id}";
      var url = Uri.parse("$baseUrl$endPoint");

      var response = await http.delete(url);

      if (response.statusCode == 200){
        Navigator.pop(context, null);
        showPopUp("Vault deleted successfully.", false);
      }
    } catch (e){
      showPopUp("Unfortunately something went wrong.", true);
    }
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
      appBar: AppBar(
        title: const Text('Vault Details', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),),
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
          child: vault == null
              ? SlowLoadingBar(duration: 1100,)
              : SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            height: 20,
                          ),
                          Container(
                            decoration: shadowDecoration,
                            child: TextFormField(
                              controller: _nameEditingController,
                              decoration: const InputDecoration(
                                  labelText: 'Vault name',
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: InputBorder.none
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            decoration: shadowDecoration,
                            child: TextFormField(
                              controller: _dueDateEditingController,
                              readOnly: true,
                              decoration: const InputDecoration(
                                labelText: 'Date',
                                filled: true,
                                fillColor: Colors.white,
                                border: InputBorder.none,
                              ),
                              onTap: () async {

                                DateTime? picked = await showDatePicker(
                                  context: context,
                                  initialDate: dueDate!,
                                  firstDate: dueDate!,
                                  lastDate: DateTime(2101),
                                );
                                if (picked != null && picked != dueDate) {
                                  setState(() {
                                    dueDate = picked;
                                    _dueDateEditingController.text = DateFormat('yyyy-MM-dd').format(dueDate!);
                                  });
                                }
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            decoration: shadowDecoration,
                            child: TextFormField(
                              controller: _goalEditingController,
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                              ],
                              decoration: const InputDecoration(
                                  labelText: 'Goal due date',
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: InputBorder.none
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            decoration: shadowDecoration,
                            child: TextFormField(
                              controller: _amountController,
                              readOnly: true,
                              decoration: const InputDecoration(
                                  labelText: 'Amount',
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: InputBorder.none
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text("$percentage% of goal reached"),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: 400,
                            height: 10,
                            child: LinearProgressIndicator(
                              value: completion,
                              backgroundColor: Colors.white70,
                              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              saveChangesToVault();
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                Theme.of(context).primaryColor,
                              ),
                            ),
                            child: const Text('Save changes', style: TextStyle(color: Colors.white),),
                          ),
                          const SizedBox(height: 16),
                          PopupDeleteVault(
                            title: "Are you sure you want to delete the vault?",
                            deleteVault: (delete) {
                              if (delete) {
                                deleteVault();
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                )
      ),
    );
  }
}
