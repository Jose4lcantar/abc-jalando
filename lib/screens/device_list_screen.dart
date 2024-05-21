// screens/device_list_screen.dart
import 'package:flutter/material.dart';
import 'bluetooth_screen.dart';

class DeviceListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Device List'),
      ),
      body: BluetoothScreen(),
    );
  }
}
