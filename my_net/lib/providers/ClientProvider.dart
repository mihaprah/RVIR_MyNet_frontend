import 'package:flutter/material.dart';
import 'package:my_net/models/Client.dart';

class ClientProvider extends ChangeNotifier {
  late Client _client;

  Client get client => _client;

  void setClient(Client client) {
    _client = client;
    notifyListeners();
  }

  Future<void> updateClient(Client newClient) async {
    _client = newClient;
    notifyListeners();
  }

  void logout() {
    _client = Client(name: '', lastname: '', email: '', cashBalance: 0, password: '', salt: '', vaults: []);
    notifyListeners();
  }
}
