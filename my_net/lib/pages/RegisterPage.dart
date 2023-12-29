
import 'package:flutter/material.dart';
import 'package:my_net/models/Client.dart';

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
        address: "", // To be removed
        cashBalance: 0.0,
        email: _emailEditingController.text,
        password: _passwordEditingController.text,
        salt: "",
        vaults: clientVaults);

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

  //   TODO -> Add backend call ro /auth/register

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
      client.password.isNotEmpty ||
      _repeatPasswordEditingController.text.isNotEmpty
    ) {
      return false;
    }
    return true;
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
                  Navigator.pushReplacementNamed(context, '/login');
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
                  createNewClient();
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
