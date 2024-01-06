import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class PopupAddInvestment extends StatefulWidget {
  final Function(double, String)? onSave;
  final String title;
  final List<String> options;

  const PopupAddInvestment({
    Key? key,
    this.onSave,
    required this.options,
    required this.title
  }) : super(key: key);

  @override
  _PopupAddInvestmentState createState() => _PopupAddInvestmentState();
}

class _PopupAddInvestmentState extends State<PopupAddInvestment> {
  double amount = 0;
  String selectedOption = "";

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
          _showPopup(context, widget.title);
          selectedOption = widget.options[0];
      },
      icon: Icon(
        Icons.add,
        color: Theme.of(context).primaryColor,
        size: 25,
      ),
    );
  }

  List<DropdownMenuItem<String>> buildDropdownMenuItems() {
    return widget.options.map((option) {
      return DropdownMenuItem<String>(
        value: option,
        child: Text(option),
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
                        widget.onSave!(amount, selectedOption);
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

