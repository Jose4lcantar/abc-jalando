import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class DeviceList extends StatelessWidget {
  final List<BluetoothDevice> devices;
  final bool isScanning;
  final Function(BluetoothDevice) onDeviceTap;

  const DeviceList({
    Key? key,
    required this.devices,
    required this.isScanning,
    required this.onDeviceTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                      onTap: () => onDeviceTap(device),
                    );
                  },
                ),
              );
  }
}
