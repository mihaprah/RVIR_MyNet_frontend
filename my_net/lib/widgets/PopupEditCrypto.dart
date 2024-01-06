import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class PopupEditCrypto extends StatefulWidget {
  final Function(bool, double, String)? onSave;
  final String title;
  final List<String> options;
  final String errorMessage;

  const PopupEditCrypto({
    Key? key,
    this.onSave,
    required this.title,
    required this.options,
    required this.errorMessage
  }) : super(key: key);

  @override
  _PopupEditCryptoState createState() => _PopupEditCryptoState();
}

class _PopupEditCryptoState extends State<PopupEditCrypto> {
  bool isAddSelected = true;
  double amount = 0;
  String selectedOption = "";

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        if (widget.options.isNotEmpty) {
          _showPopup(context, widget.title);
          setState(() {
            selectedOption = widget.options[0];
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.errorMessage),
              duration: const Duration(seconds: 3),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }

      },
      icon: Icon(
        Icons.edit,
        color: Theme.of(context).primaryColor,
        size: 25,
      ),
    );
  }

  List<DropdownMenuItem<String>> buildDropdownMenuItems() {
    return widget.options.map((crypto) {
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
              title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isAddSelected = true;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isAddSelected ? Colors.green : Theme.of(context).primaryColor,
                        ),
                        child: const Text('Add', style: TextStyle(fontWeight: FontWeight.bold),),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isAddSelected = false;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: !isAddSelected ? Colors.red : Theme.of(context).primaryColor,
                        ),
                        child: const Text('Remove', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  DropdownButton<String>(
                    value: selectedOption,
                    items: buildDropdownMenuItems(),
                    onChanged: (String? newValue) {
                      setState(() {
                        if (newValue != null) {
                          selectedOption = newValue;
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
                        widget.onSave!(isAddSelected, amount, selectedOption);
                        amount = 0.0;
                        isAddSelected = true;
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

