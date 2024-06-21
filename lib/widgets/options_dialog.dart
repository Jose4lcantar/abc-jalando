import 'package:flutter/material.dart';

class OptionsDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Options'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close the AlertDialog
              Navigator.pushNamed(context, '/bluetooth_screen');
            },
            child: const Text('Bluetooth'),
          ),
          ElevatedButton(
            onPressed: () {
              // Add functionality for "Historial" button
            },
            child: const Text('Historial'),
          ),
        ],
      ),
    );
  }
}
