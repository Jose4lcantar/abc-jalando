import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:abc/screens/graph_screen.dart';
import 'package:abc/screens/scan_page.dart';

class BluetoothScreen extends StatefulWidget {
  const BluetoothScreen({super.key});
  @override
  BluetoothScreenState createState() => BluetoothScreenState();
}

class BluetoothScreenState extends State<BluetoothScreen> {
  List<BluetoothDevice> devices = [];
  bool isScanning = false;
  bool isConnected = false;
  BluetoothConnection? connection;
  String receivedData = '';
  ValueNotifier<String> temperatureNotifier =
      ValueNotifier<String>('0'); //valor de temperatura de la olla
  ValueNotifier<String> ambientTemperatureNotifier =
      ValueNotifier<String>('0'); // valor de sensor de temperatura ambiente
  ValueNotifier<String> humidityNotifier =
      ValueNotifier<String>('0'); // valor de sensor de humedad
  ValueNotifier<String> windSpeedNotifier =
      ValueNotifier<String>('0'); // valor de la velocidad del viento
  ValueNotifier<String> ultraVioletRadiation =
      ValueNotifier<String>('0'); //valor de la radiacion solar
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
        throw Exception('Permisos de localizacion denegadas');
      }

      Map<Permission, PermissionStatus> permissionStatuses = await [
        Permission.bluetoothConnect,
        Permission.bluetoothScan,
      ].request();

      if (permissionStatuses[Permission.bluetoothConnect] !=
              PermissionStatus.granted ||
          permissionStatuses[Permission.bluetoothScan] !=
              PermissionStatus.granted) {
        throw Exception('Permisos Bluetooth no concedidos');
      }
    }

    try {
      bool isBluetoothOn =
          (await FlutterBluetoothSerial.instance.isEnabled) ?? false;
      if (!isBluetoothOn) {
        bool enableBluetooth =
            (await FlutterBluetoothSerial.instance.requestEnable()) ?? false;
        if (!enableBluetooth) {
          print('Bluetooth no disponible');
          return;
        }
      }
      // Llama a _startScan después de inicializar Bluetooth
      _startScan();
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
      List<BluetoothDevice> bondedDevices =
          await FlutterBluetoothSerial.instance.getBondedDevices();
      setState(() {
        devices.addAll(bondedDevices);
        isScanning = false;
      });
    } catch (e) {
      print("Error escaneando dispositivos: $e");
      setState(() {
        isScanning = false;
      });
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
      print("Error connectando: $ex");
    }
  }

  void _startListening() {
    connection?.input?.listen((Uint8List data) {
      String message = utf8.decode(data);
      print('Recibiendo Temperatura: $message');
      setState(() {
        receivedData = message;
        _parseReceivedData(message);
      });
    }).onDone(() {
      print('Coneccion cerrada');
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
        } else if (key == 'V') {
          _saveWindSpeed(value);
        } else if (key == 'U') {
          _saveUltraVioletRadiation(value);
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

  void _saveWindSpeed(String value) {
    windSpeedNotifier.value = value;
  }

  void _saveUltraVioletRadiation(String value) {
    ultraVioletRadiation.value = value;
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
            )
          : ValueListenableBuilder<String>(
              valueListenable: temperatureNotifier,
              builder: (context, temperature, child) {
                return ValueListenableBuilder<String>(
                  valueListenable: ambientTemperatureNotifier,
                  builder: (context, ambientTemperature, child) {
                    return ValueListenableBuilder<String>(
                      valueListenable: humidityNotifier,
                      builder: (context, humidity, child) {
                        return ValueListenableBuilder<String>(
                          valueListenable: windSpeedNotifier,
                          builder: (context, windSpeed, child) {
                            return ValueListenableBuilder<String>(
                              valueListenable: ultraVioletRadiation,
                              builder: (context, ultraVioletRadiation, child) {
                                return GraphScreen(
                                  temperature: temperature,
                                  ambientTemperature: ambientTemperature,
                                  humidity: humidity,
                                  windSpeed: windSpeed,
                                  ultraVioletRadiation: ultraVioletRadiation,
                                );
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
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
    windSpeedNotifier.dispose();
    ultraVioletRadiation.dispose();
    super.dispose();
  }
}
