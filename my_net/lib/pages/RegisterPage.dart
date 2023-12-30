
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:my_net/constants/constants.dart';
import 'package:my_net/models/Client.dart';
import 'package:http/http.dart' as http;

import '../models/Vault.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nameEditingController = TextEditingController();
  final TextEditingController _lastnameEditingController = TextEditingController();
  final TextEditingController _repeatPasswordEditingController = TextEditingController();
  final TextEditingController _emailEditingController = TextEditingController();
  final TextEditingController _passwordEditingController = TextEditingController();

  var shadowDecoration = BoxDecoration(
    borderRadius: const BorderRadius.all(Radius.circular(10)),
    color: Colors.white,
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withOpacity(0.5),
        spreadRadius: 2,
        blurRadius: 3,
        offset: const Offset(0, 3),
      ),
    ],
  );

  Future<void> createNewClient() async {
    List<Vault> clientVaults = [];

    Client newClient = Client(
        name: _nameEditingController.text,
        lastname: _lastnameEditingController.text,
        address: "temp", // To be removed
        cashBalance: 0.0,
        email: _emailEditingController.text,
        password: _passwordEditingController.text,
        salt: "",
        vaults: clientVaults);

    if(await checkEmail(newClient)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Account with this email already exists."),
          duration: Duration(seconds: 3),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (!passwordMatch()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password and repeat password must match."),
          duration: Duration(seconds: 3),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (!validatePassword()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("First letter of password must be capital one and it must be at least 8 letters long."),
          duration: Duration(seconds: 3),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (!validateInput(newClient)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Fill out all the fields."),
          duration: Duration(seconds: 3),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      var endPoint = "/auth/register";
      var url = Uri.parse("$baseUrl$endPoint");

      var response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(newClient)
      );

      if (response.statusCode == 200) {
        Navigator.pushReplacementNamed(context, "/login");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("New account created successfully."),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Something went wrong with registration."),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      print("Error: $e");
    }
  }

    Future<bool> checkEmail(Client client) async {
    List<Client> allClients = [];

    try {
      var endPoint = "/client";
      var url = Uri.parse("$baseUrl$endPoint");

      var response = await http.get(url);
      var jsonData = json.decode(response.body);

      if (response.statusCode == 200) {
        allClients = (jsonData as List)
            .map((item) => Client.fromJson(item))
            .toList();
        for (var c in allClients) {
          if (c.email == client.email) {
            return true;
          }
        }
      } else {
        return true;
      }
    } catch (e) {
      print("Error: $e");
    }
    return false;
  }

  bool passwordMatch() {
    if (_passwordEditingController.text.isNotEmpty && _repeatPasswordEditingController.text.isNotEmpty) {
      if (_passwordEditingController.text == _repeatPasswordEditingController.text) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  bool validatePassword() {
    String pass = _passwordEditingController.text;
    if (pass[0] == pass[0].toUpperCase() && pass.length >= 8) {
      return true;
    } else {
      return false;
    }
  }

  bool validateInput(Client client) {
    if(client.name.isNotEmpty ||
      client.lastname.isNotEmpty ||
      client.email.isNotEmpty ||
      client.password.isNotEmpty
    ) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Register',
          style: TextStyle(fontSize: 25),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Create a new MyNet account.',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: shadowDecoration,
                child: TextFormField(
                  controller: _nameEditingController,
                  decoration: const InputDecoration(
                      labelText: 'First name',
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
                      labelText: 'Last name',
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
              const SizedBox(height: 16),
              Container(
                decoration: shadowDecoration,
                child: TextFormField(
                  obscureText: true,
                  controller: _passwordEditingController,
                  decoration: const InputDecoration(
                      labelText: 'Password',
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
                  obscureText: true,
                  controller: _repeatPasswordEditingController,
                  decoration: const InputDecoration(
                      labelText: 'Repeat password',
                      filled: true,
                      fillColor: Colors.white,
                      border: InputBorder.none
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  createNewClient();
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                    Theme.of(context).primaryColor,
                  ),
                ),
                child: const Text('Create new account'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: RichText(
                  text: const TextSpan(
                    text: 'Already have an account? ',
                    style: TextStyle(
                      color: Colors.black,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: 'Login here.',
                        style: TextStyle(
                          decoration: TextDecoration.underline, // Add underline
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
