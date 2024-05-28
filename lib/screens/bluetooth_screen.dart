import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:abc/widgets/device_list.dart';
import 'package:abc/widgets/scan_button.dart';
import 'package:abc/screens/scan_page.dart';

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
  ValueNotifier<String> ambientTemperatureNotifier = ValueNotifier<String>('0');
  ValueNotifier<String> humidityNotifier = ValueNotifier<String>('0');
  bool showMessage = false;
  int _selectedIndex = 0;

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
        _parseReceivedData(message);
      });
    }).onDone(() {
      print('Connection closed');
      setState(() {
        isConnected = false;
      });
    });
  }

  void _parseReceivedData(String message) {
    List<String> parts = message.split(',');
    for (String part in parts) {
      List<String> keyValue = part.trim().split(':');
      if (keyValue.length == 2) {
        String key = keyValue[0].trim();
        String value = keyValue[1].trim();
        if (key == 'T') {
          _saveTemperatureOfPot(value);
        } else if (key == 'A') {
          _saveAmbientTemperature(value);
        } else if (key == 'H') {
          _saveHumidity(value);
        }
      }
    }
  }

  void _saveTemperatureOfPot(String value) {
    temperatureNotifier.value = value;
  }

  void _saveAmbientTemperature(String value) {
    ambientTemperatureNotifier.value = value;
  }

  void _saveHumidity(String value) {
    humidityNotifier.value = value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: _selectedIndex == 0
          ? ScanPage(
              devices: devices,
              isScanning: isScanning,
              isConnected: isConnected,
              showMessage: showMessage,
              onDeviceTap: _connectToDevice,
              onScan: _startScan,
            )
          : SizedBox(
              height: 200, // Altura de la gráfica de temperatura
              child: Column(
                children: [
                  Expanded(
                    child: ValueListenableBuilder<String>(
                      valueListenable: temperatureNotifier,
                      builder: (context, temperature, child) {
                        return Center(child: Text('Temperatura de Olla: $temperature'));
                      },
                    ),
                  ),
                  Expanded(
                    child: ValueListenableBuilder<String>(
                      valueListenable: ambientTemperatureNotifier,
                      builder: (context, temperature, child) {
                        return Center(child: Text('Temperatura Ambiente: $temperature'));
                      },
                    ),
                  ),
                  Expanded(
                    child: ValueListenableBuilder<String>(
                      valueListenable: humidityNotifier,
                      builder: (context, humidity, child) {
                        return Center(child: Text('Humedad: $humidity'));
                      },
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.devices),
            label: 'Dispositivos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.graphic_eq),
            label: 'Gráfica',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }

  @override
  void dispose() {
    connection?.dispose();
    temperatureNotifier.dispose();
    ambientTemperatureNotifier.dispose();
    humidityNotifier.dispose();
    super.dispose();
  }
}
