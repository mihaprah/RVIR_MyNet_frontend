import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PopupDeleteVault extends StatefulWidget {
  final Function(bool)? deleteVault;
  final String title;

  const PopupDeleteVault({
    Key? key,
    this.deleteVault,
    required this.title,
  }) : super(key: key);

  @override
  _PopupDeleteVaultState createState() => _PopupDeleteVaultState();
}

class _PopupDeleteVaultState extends State<PopupDeleteVault> {
  bool isAddSelected = true;
  double amount = 0;
  int selectedVaultId = 0;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        _showPopup(context, widget.title);
      },
      style: ButtonStyle(
        side:
        MaterialStateProperty.resolveWith<BorderSide>(
              (Set<MaterialState> states) {
            return const BorderSide(
                color: Colors.red);
          },
        ),
        backgroundColor: MaterialStateProperty.all<Color>(
          Colors.white,
        ),
      ),
      child: const Text('Delete vault', style: TextStyle(color: Colors.red),),
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
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Close', style: TextStyle(color: Theme.of(context).primaryColor)),
                ),
                TextButton(
                  onPressed: () {
                    if (widget.deleteVault != null){
                      widget.deleteVault!(true);
                    }
                    Navigator.of(context).pop();
                  },
                  child: Text('Delete', style: TextStyle(color: Theme.of(context).primaryColor)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

