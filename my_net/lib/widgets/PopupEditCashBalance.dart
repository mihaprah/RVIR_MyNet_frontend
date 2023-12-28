import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PopupEditCashBalance extends StatefulWidget {
  final Function(bool, double)? onSave;
  final String title;

  const PopupEditCashBalance({
    Key? key,
    this.onSave,
    required this.title,
  }) : super(key: key);

  @override
  _PopupEditCashBalanceState createState() => _PopupEditCashBalanceState();
}

class _PopupEditCashBalanceState extends State<PopupEditCashBalance> {
  bool isAddSelected = true;
  double amount = 0;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        _showPopup(context, widget.title);
      },
      icon: Icon(
        Icons.edit,
        color: Theme.of(context).primaryColor,
        size: 25,
      ),
    );
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
                        child: const Text('Add', style: TextStyle(fontWeight: FontWeight.bold)),
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
                      widget.onSave!(isAddSelected, amount);
                      amount = 0.0;
                      isAddSelected = true;
                    }
                    Navigator.of(context).pop();
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

