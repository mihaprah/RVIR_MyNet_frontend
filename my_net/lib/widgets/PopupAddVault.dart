import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/Vault.dart';

class PopupAddVault extends StatefulWidget {
  final Function(String, double, DateTime)? onSave;
  final String title;

  const PopupAddVault({
    Key? key,
    this.onSave,
    required this.title,
  }) : super(key: key);

  @override
  _PopupAddVaultState createState() => _PopupAddVaultState();
}

class _PopupAddVaultState extends State<PopupAddVault> {
  double amount = 0;
  String name = "";
  DateTime? dueDate;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        _showPopup(context, widget.title);
        setState(() {
          dueDate = null;
        });
      },
      icon: Icon(
        Icons.add,
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
                  const SizedBox(height: 10),
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        name = value;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Enter vault name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
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
                      labelText: 'Enter amount goal',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (dueDate != null)
                    Text(
                        "Due date: ${dueDate?.day}.${dueDate?.month}.${dueDate?.year}",
                      style: const TextStyle(
                        fontWeight: FontWeight.w500
                      ),
                    ),
                    const SizedBox(height: 10,),
                  if (dueDate != null)
                    ElevatedButton(
                        onPressed: () async {
                          final DateTime picked = (await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2030)))!;
                          setState(() {
                            dueDate = picked;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor, elevation: 5),
                        child: const Text("Change the date",  style: TextStyle(fontWeight: FontWeight.bold))),
                 if (dueDate == null)
                    ElevatedButton(
                        onPressed: () async {
                          final DateTime picked = (await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2030)))!;
                          setState(() {
                            dueDate = picked;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor, elevation: 5),
                        child: const Text("Set a vault date")),
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
                    checkBeforeSave();
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

  void checkBeforeSave() {
    if (dueDate == null){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Date not selected"),
          duration: Duration(seconds: 3),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (amount == 0.0){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Amount must be provided"),
          duration: Duration(seconds: 3),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (name == ""){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Name must be provided"),
          duration: Duration(seconds: 3),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      if (widget.onSave != null){
        widget.onSave!(name, amount, dueDate!);
        amount = 0.0;
        dueDate = null;
        name = "";
      }
      Navigator.of(context).pop();
    }
  }
}

