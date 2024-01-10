import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_net/constants/constants.dart';
import 'package:my_net/models/Client.dart';
import 'package:http/http.dart' as http;
import 'package:my_net/widgets/SlowLoadingBar.dart';
import 'package:provider/provider.dart';


import '../providers/ClientProvider.dart';
import 'LoginPage.dart';

class UserPage extends StatefulWidget {
  final int? id;

  const UserPage({
    this.id,
    super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  Client? client;

  final TextEditingController _nameEditingController = TextEditingController();
  final TextEditingController _lastnameEditingController = TextEditingController();
  final TextEditingController _emailEditingController = TextEditingController();

  @override void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () {
      getClient();
    });
  }

  Future<void> getClient() async {
    try {
      var endPoint = "/client/1";
      var url = Uri.parse("$baseUrl$endPoint");

      var response = await http.get(url);
      var jsonData = json.decode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          client = Client.fromJson(jsonData);
          if (client != null) {
            _nameEditingController.text = client!.name;
            _lastnameEditingController.text = client!.lastname;
            _emailEditingController.text = client!.email;
          }
        });
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> saveUserData() async {
    Client updatedClient = Client(
        id: client!.id,
        name: _nameEditingController.text,
        lastname: _lastnameEditingController.text,
        cashBalance: client!.cashBalance,
        email: _emailEditingController.text,
        password: client!.password,
        salt: client!.salt,
        vaults: client!.vaults
    );

    if (!checkClient(updatedClient)){
      return;
    }

    try {
      var endPoint = "/client/update";
      var url = Uri.parse("$baseUrl$endPoint");

      var response = await http.put(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(updatedClient)
      );

      if (response.statusCode == 200) {
        getClient();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Changes saved successfully."),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

    } catch (e) {
      print("Error: $e");
    }
  }

  bool checkClient(Client client) {
    if (client.name.isEmpty ||
        client.lastname.isEmpty ||
        client.email.isEmpty
    ) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("All fields must be filled."),
          duration: Duration(seconds: 3),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User profile', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),),
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
          child: client == null
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
                            labelText: 'First Name',
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
                        controller: _lastnameEditingController,
                        decoration: const InputDecoration(
                            labelText: 'Last Name',
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
                        controller: _emailEditingController,
                        decoration: const InputDecoration(
                            labelText: 'Email',
                            filled: true,
                            fillColor: Colors.white,
                            border: InputBorder.none
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () {
                        saveUserData();
                        print("Here");
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                          Theme.of(context).primaryColor,
                        ),
                      ),
                      child: const Text('Save changes', style: TextStyle(color: Colors.white),),
                    ),
                    const SizedBox(height: 16,),
                    ElevatedButton(
                      onPressed: () {
                        Provider.of<ClientProvider>(context, listen: false).logout();
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      style: ButtonStyle(
                        side: MaterialStateProperty.resolveWith<BorderSide>(
                              (Set<MaterialState> states) {
                            return const BorderSide(
                              color: Colors.red,
                            );
                          },
                        ),
                        backgroundColor: MaterialStateProperty.all<Color>(
                          Colors.white,
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.exit_to_app,
                            color: Colors.red,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Logout',
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          )),
    );
  }
}

class LoginScreen {
}
