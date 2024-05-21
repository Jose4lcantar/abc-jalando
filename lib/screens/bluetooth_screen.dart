import 'dart:async';
import 'dart:convert'; // Asegúrate de importar esto para `utf8`
import 'dart:typed_data'; // Asegúrate de importar esto para `Uint8List`
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:abc/services/bluetooth_service.dart';
import 'package:abc/widgets/device_list.dart';
import 'package:abc/widgets/scan_button.dart';
import 'package:abc/widgets/temperature_gauge.dart';
import 'package:abc/widgets/temperature_text.dart';

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
  String temperature = '0';

  @override
  void initState() {
    super.initState();
    _initializeBluetooth();
  }

  Future<void> _initializeBluetooth() async {
    if (Platform.isAndroid) {
      PermissionStatus permissionStatus = await Permission.location.request();
      if (permissionStatus != PermissionStatus.granted) {
        throw Exception('Permiso de ubicación no concedido');
      }

      Map<Permission, PermissionStatus> permissionStatuses = await [
        Permission.bluetoothConnect,
        Permission.bluetoothScan,
      ].request();

      if (permissionStatuses[Permission.bluetoothConnect] != PermissionStatus.granted ||
          permissionStatuses[Permission.bluetoothScan] != PermissionStatus.granted) {
        throw Exception('Permisos de Bluetooth no concedidos');
      }
    }

    try {
      bool isBluetoothOn = (await FlutterBluetoothSerial.instance.isEnabled) ?? false;
      if (!isBluetoothOn) {
        bool enableBluetooth = (await FlutterBluetoothSerial.instance.requestEnable()) ?? false;
        if (!enableBluetooth) {
          print('Bluetooth no habilitado');
          return;
        }
      }
    } catch (e) {
      print("Error inicializando Bluetooth: $e");
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
      print("Error escaneando dispositivos: $e");
    }
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    try {
      connection = await BluetoothConnection.toAddress(device.address);
      setState(() {
        isConnected = true;
      });
      _startListening();
    } catch (ex) {
      print("Error al conectar: $ex");
    }
  }

  void _startListening() {
    connection?.input?.listen((Uint8List data) {
      String message = utf8.decode(data);
      print('Mensaje recibido: $message');
      setState(() {
        receivedData = message;
        if (_isValidTemperature(message)) {
          temperature = message.replaceAll(RegExp(r'[^0-9.]'), '');
        }
      });
    }).onDone(() {
      print('Conexión cerrada');
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Demostración de Bluetooth'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            DeviceList(
              devices: devices,
              isScanning: isScanning,
              onDeviceTap: _connectToDevice,
            ),
            SizedBox(height: 20),
            ScanButton(
              isScanning: isScanning,
              onScan: _startScan,
            ),
            SizedBox(height: 20),
            TemperatureGauge(temperature: temperature),
            SizedBox(height: 20),
            TemperatureText(temperature: temperature),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    connection?.dispose();
    super.dispose();
  }
}
