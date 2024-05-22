import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:abc/widgets/device_list.dart';
import 'package:abc/widgets/scan_button.dart';
import 'package:abc/screens/graph_screen.dart';

class BluetoothScreen extends StatefulWidget {
  @override
  _BluetoothScreenState createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen> {
  List<BluetoothDevice> devices = [];
  bool isScanning = false;
  bool isConnected = false;
  BluetoothConnection? connection;
  String receivedData = '';
  ValueNotifier<String> temperatureNotifier = ValueNotifier<String>('0');
  bool showMessage = false;

  @override
  void initState() {
    super.initState();
    _initializeBluetooth();
  }

  Future<void> _initializeBluetooth() async {
    if (Platform.isAndroid) {
      PermissionStatus permissionStatus = await Permission.location.request();
      if (permissionStatus != PermissionStatus.granted) {
        throw Exception('Location permission not granted');
      }

      Map<Permission, PermissionStatus> permissionStatuses = await [
        Permission.bluetoothConnect,
        Permission.bluetoothScan,
      ].request();

      if (permissionStatuses[Permission.bluetoothConnect] != PermissionStatus.granted ||
          permissionStatuses[Permission.bluetoothScan] != PermissionStatus.granted) {
        throw Exception('Bluetooth permissions not granted');
      }
    }

    try {
      bool isBluetoothOn = (await FlutterBluetoothSerial.instance.isEnabled) ?? false;
      if (!isBluetoothOn) {
        bool enableBluetooth = (await FlutterBluetoothSerial.instance.requestEnable()) ?? false;
        if (!enableBluetooth) {
          print('Bluetooth not enabled');
          return;
        }
      }
    } catch (e) {
      print("Error initializing Bluetooth: $e");
    }
  }

  Future<void> _startScan() async {
    setState(() {
      isScanning = true;
      devices.clear();
    });

    try {
      List<BluetoothDevice> bondedDevices = await FlutterBluetoothSerial.instance.getBondedDevices();
      setState(() {
        devices.addAll(bondedDevices);
        isScanning = false;
      });
    } catch (e) {
      print("Error scanning devices: $e");
    }
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    try {
      connection = await BluetoothConnection.toAddress(device.address);
      setState(() {
        isConnected = true;
        showMessage = true;
      });
      _startListening();
    } catch (ex) {
      print("Error connecting: $ex");
    }
  }

  void _startListening() {
    connection?.input?.listen((Uint8List data) {
      String message = utf8.decode(data);
      print('Received message: $message');
      setState(() {
        receivedData = message;
        if (_isValidTemperature(message)) {
          temperatureNotifier.value = message.replaceAll(RegExp(r'[^0-9.]'), '');
        }
      });
    }).onDone(() {
      print('Connection closed');
      setState(() {
        isConnected = false;
      });
    });
  }

  bool _isValidTemperature(String data) {
    try {
      double.parse(data.replaceAll(RegExp(r'[^0-9.]'), ''));
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      children: <Widget>[
        ScanPage(
          devices: devices,
          isScanning: isScanning,
          isConnected: isConnected,
          showMessage: showMessage,
          onDeviceTap: _connectToDevice,
          onScan: _startScan,
        ),
        ValueListenableBuilder<String>(
          valueListenable: temperatureNotifier,
          builder: (context, temperature, child) {
            return GraphScreen(temperature: temperature);
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    connection?.dispose();
    temperatureNotifier.dispose();
    super.dispose();
  }
}

class ScanPage extends StatelessWidget {
  final List<BluetoothDevice> devices;
  final bool isScanning;
  final bool isConnected;
  final bool showMessage;
  final Function(BluetoothDevice) onDeviceTap;
  final VoidCallback onScan;

  ScanPage({
    required this.devices,
    required this.isScanning,
    required this.isConnected,
    required this.showMessage,
    required this.onDeviceTap,
    required this.onScan,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          DeviceList(
            devices: devices,
            isScanning: isScanning,
            onDeviceTap: onDeviceTap,
          ),
          SizedBox(height: 20),
          ScanButton(
            isScanning: isScanning,
            onScan: onScan,
          ),
          if (isConnected)
            Column(
              children: <Widget>[
                SizedBox(height: 20),
                Text(
                  'Conexión exitosa',
                  style: TextStyle(color: Colors.green, fontSize: 16),
                ),
                SizedBox(height: 10),
                Text(
                  'Desliza hacia la izquierda para ver la gráfica',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
