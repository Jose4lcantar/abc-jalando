import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:abc/widgets/device_list.dart';

class ScanPage extends StatelessWidget {
  final List<BluetoothDevice> devices;
  final bool isScanning;
  final bool isConnected;
  final bool showMessage;
  final Function(BluetoothDevice) onDeviceTap;

  const ScanPage({
    required this.devices,
    required this.isScanning,
    required this.isConnected,
    required this.showMessage,
    required this.onDeviceTap,
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
          if (isConnected)
            const Column(
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
