import 'package:flutter/material.dart';

class ScanButton extends StatelessWidget {
  final bool isScanning;
  final VoidCallback onScan;

  const ScanButton({
    Key? key,
    required this.isScanning,
    required this.onScan,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isScanning ? null : onScan,
      child: const Text('Iniciar Escaneo'),
    );
  }
}
