import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:my_net/constants/constants.dart';
import 'package:my_net/models/LoginRequest.dart';
import 'package:http/http.dart' as http;
import 'package:my_net/models/Client.dart';
import 'package:my_net/pages/LoadingPage.dart';
import 'package:my_net/services/crypto_api.dart';
import 'package:my_net/services/currency_api.dart';
import 'package:my_net/services/metals_api.dart';
import 'package:my_net/services/stock_api.dart';
import 'package:provider/provider.dart';

import '../providers/ClientProvider.dart';
import '../widgets/CustomSnackBar.dart';

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

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailEditingController = TextEditingController();
  final TextEditingController _passwordEditingController = TextEditingController();

  Future<void> clientLogin() async {
    LoginRequest loginRequest = LoginRequest(
        email: _emailEditingController.text,
        password: _passwordEditingController.text);
    if(!checkInput(loginRequest)){
      return;
    }

    try {
      var endPoint = "/auth/login";
      var url = Uri.parse("$baseUrl$endPoint");

      var response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(loginRequest)
      );
      var jsonData = json.decode(response.body);

      if (response.statusCode == 200) {
        Client client = Client.fromJson(jsonData);
        setGlobalConversionRate();
        setGlobalCrypto();
        setGlobalStocks();
        setGlobalCommodities();
        setGlobalClient(client);
      } else {
        showPopUp("Email or password incorrect.", true);
      }
    } catch (e) {
      showPopUp("Unfortunately something went wrong.", true);
    }
  }

  bool checkInput(LoginRequest loginRequest){
    if (loginRequest.email == "" || loginRequest.password == ""){
      showPopUp("Fill all the fields.", true);
      return false;
    } else {
      return true;
    }
  }

  void setGlobalConversionRate() {
    CurrencyApiService().getCurrencyConversion("EUR", context);
  }

  void setGlobalCrypto() {
    CryptoApiService().getYearlyCrypto("ETH", context);
    CryptoApiService().getYearlyCrypto("BTC", context);
    CryptoApiService().getYearlyCrypto("SOL", context);
  }

  void setGlobalStocks() {
    StockApiService().getYearlyStocks("AAPL", context);
    StockApiService().getYearlyStocks("MSFT", context);
    StockApiService().getYearlyStocks("TSLA", context);
  }

  void setGlobalCommodities() {
    CommoditiesApiService().getYearlyCommodities("XAU", context);
    CommoditiesApiService().getYearlyCommodities("XAG", context);
    CommoditiesApiService().getYearlyCommodities("XPT", context);
  }

  void setGlobalClient(Client client) {
    Provider.of<ClientProvider>(context, listen: false).setClient(client);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoadingPage(client: client,),
      ),
    );
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
        title: const Text(
          'Login',
          style: TextStyle(fontSize: 25, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Login into your MyNet account.',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 20,),
                  Container(
                    decoration: shadowDecoration,
                    child: TextFormField(
                      controller: _emailEditingController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        filled: true,
                        fillColor: Colors.white,
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: shadowDecoration,
                    child: TextFormField(
                      controller: _passwordEditingController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        filled: true,
                        fillColor: Colors.white,
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      clientLogin();
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                        Theme.of(context).primaryColor,
                      ),
                    ),
                    child: const Text('Login', style: TextStyle(color: Colors.white),),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/register');
                    },
                    child: RichText(
                      text: const TextSpan(
                        text: 'Don\'t have an account? ',
                        style: TextStyle(
                          color: Colors.black,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: 'Register here.',
                            style: TextStyle(
                              decoration: TextDecoration.underline,
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
        ),
      ),
    );
  }
}
