import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:abc/widgets/device_list.dart';
import 'package:abc/widgets/scan_button.dart';

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
