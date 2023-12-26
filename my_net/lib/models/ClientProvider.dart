import 'package:flutter/material.dart';
import 'package:my_net/models/Client.dart';

class ClientProvider extends ChangeNotifier {
  late Client _client;

  Client get user => _client;

  void setUser(Client client) {
    _client = client;
    notifyListeners();
  }
}
