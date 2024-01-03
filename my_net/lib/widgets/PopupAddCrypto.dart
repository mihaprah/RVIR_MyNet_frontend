import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class PopupAddCrypto extends StatefulWidget {
  final Function(double, String)? onSave;
  final String title;

  const PopupAddCrypto({
    Key? key,
    this.onSave,
    required this.title
  }) : super(key: key);

  @override
  _PopupAddCryptoState createState() => _PopupAddCryptoState();
}

class _PopupAddCryptoState extends State<PopupAddCrypto> {
  double amount = 0;
  String selectedCrypto = "ETH";
  final List<String> cryptos = ["ETH", "BTC", "BNB"];

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
          _showPopup(context, widget.title);
      },
      icon: Icon(
        Icons.add,
        color: Theme.of(context).primaryColor,
        size: 25,
      ),
    );
  }

  List<DropdownMenuItem<String>> buildDropdownMenuItems() {
    return cryptos.map((crypto) {
      return DropdownMenuItem<String>(
        value: crypto,
        child: Text(crypto),
      );
    }).toList();
  }

  void _showPopup(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(title),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  DropdownButton<String>(
                    value: selectedCrypto,
                    items: buildDropdownMenuItems(),
                    onChanged: (String? newValue) {
                      setState(() {
                        if (newValue != null) {
                          selectedCrypto = newValue;
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 50),
                  TextField(
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        amount = double.tryParse(value) ?? 0.0;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Enter amount',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Close', style: TextStyle(color: Theme.of(context).primaryColor)),
                ),
                TextButton(
                  onPressed: () {
                    if (widget.onSave != null){
                      if( amount != 0.0) {
                        widget.onSave!(amount, selectedCrypto);
                        amount = 0.0;
                        Navigator.of(context).pop();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Amount must be provided."),
                            duration: Duration(seconds: 3),
                            backgroundColor: Colors.red,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    }
                  },
                  child: Text('Save', style: TextStyle(color: Theme.of(context).primaryColor)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

