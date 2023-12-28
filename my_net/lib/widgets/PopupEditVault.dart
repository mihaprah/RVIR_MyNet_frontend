import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/Vault.dart';

class PopupEditVault extends StatefulWidget {
  final Function(bool, double, int)? onSave;
  final String title;
  final List<Vault> vaults;

  const PopupEditVault({
    Key? key,
    this.onSave,
    required this.title,
    required this.vaults
  }) : super(key: key);

  @override
  _PopupEditVaultState createState() => _PopupEditVaultState();
}

class _PopupEditVaultState extends State<PopupEditVault> {
  bool isAddSelected = true;
  double amount = 0;
  int selectedVaultId = 0;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        _showPopup(context, widget.title);
        setState(() {
          selectedVaultId = widget.vaults[0].id!;
        });
        },
      icon: Icon(
        Icons.edit,
        color: Theme.of(context).primaryColor,
        size: 25,
      ),
    );
  }

  List<DropdownMenuItem<int>> buildDropdownMenuItems() {
    return widget.vaults.map((vault) {
      return DropdownMenuItem<int>(
        value: vault.id,
        child: Text(vault.name),
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
                  DropdownButton<int>(
                    value: selectedVaultId,
                    items: buildDropdownMenuItems(),
                    onChanged: (int? newValue) {
                      setState(() {
                        if (newValue != null) {
                          selectedVaultId = newValue;
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
                      widget.onSave!(isAddSelected, amount, selectedVaultId);
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

