import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BluetoothScreen(),
    );
  }
}

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
      // Solicitar permisos de ubicación
      PermissionStatus permissionStatus = await Permission.location.request();
      if (permissionStatus != PermissionStatus.granted) {
        throw Exception('Permiso de ubicación no concedido');
      }

      // Solicitar permisos de Bluetooth
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
          // El usuario no habilitó el Bluetooth, manejar según sea necesario
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
            _buildDeviceList(),
            SizedBox(height: 20),
            _buildScanButton(),
            SizedBox(height: 20),
            _buildTemperatureGauge(),
            SizedBox(height: 20),
            _buildTemperatureText(),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceList() {
    return isScanning
        ? CircularProgressIndicator()
        : devices.isEmpty
            ? Text('No se encontraron dispositivos Bluetooth cercanos')
            : Expanded(
                child: ListView.builder(
                  itemCount: devices.length,
                  itemBuilder: (context, index) {
                    final device = devices[index];
                    return ListTile(
                      title: Text(device.name ?? 'Dispositivo Desconocido'),
                      subtitle: Text(device.address),
                      onTap: () {
                        _connectToDevice(device);
                      },
                    );
                  },
                ),
              );
  }

  Widget _buildScanButton() {
    return ElevatedButton(
      onPressed: isScanning ? null : _startScan,
      child: Text('Iniciar Escaneo'),
    );
  }

  Widget _buildTemperatureGauge() {
    return SfRadialGauge(
      axes: <RadialAxis>[
        RadialAxis(
          minimum: 0,
          maximum: 100,
          ranges: <GaugeRange>[
            GaugeRange(startValue: 0, endValue: 100, color: Colors.green)
          ],
          pointers: <GaugePointer>[
            NeedlePointer(value: double.parse(temperature))
          ],
        )
      ],
    );
  }

  Widget _buildTemperatureText() {
    return Text(
      'Temperatura: $temperature °C',
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  @override
  void dispose() {
    connection?.dispose();
    super.dispose();
  }
}
