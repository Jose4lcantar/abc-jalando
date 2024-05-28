/* // screens/graph_screen.dart
import 'package:flutter/material.dart';
import 'package:abc/widgets/temperature_gauge.dart';
import 'package:abc/widgets/temperature_text.dart';

class GraphScreen extends StatelessWidget {
  final String temperature;

  GraphScreen({required this.temperature});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Gráfica',
          textAlign: TextAlign.center,),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TemperatureGauge(temperature: temperature),
            SizedBox(height: 20),
            TemperatureText(temperature: temperature),
          ],
        ),
      ),
    );
  }
}
 */