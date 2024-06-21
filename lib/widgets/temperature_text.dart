import 'package:flutter/material.dart';

class TemperatureText extends StatelessWidget {
  final String temperature;

  const TemperatureText({
    Key? key,
    required this.temperature,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      'Temperatura: $temperature °C',
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }
}
