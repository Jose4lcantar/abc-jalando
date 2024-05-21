// main.dart
import 'package:flutter/material.dart';
import 'screens/device_list_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DeviceListScreen(),
    );
  }
}
