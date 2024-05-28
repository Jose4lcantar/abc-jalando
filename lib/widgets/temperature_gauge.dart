/* import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class TemperatureGauge extends StatelessWidget {
  final String temperature;

  const TemperatureGauge({
    Key? key,
    required this.temperature,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150, // Ancho ajustado
      height: 150, // Alto ajustado
      child: SfRadialGauge(
        axes: <RadialAxis>[
          RadialAxis(
            minimum: 0,
            maximum: 100,
            ranges: _getGradientRanges(),
            pointers: <GaugePointer>[
              NeedlePointer(
                value: double.parse(temperature),
                needleLength: 0.6, // Longitud de la aguja ajustada
                needleColor: Colors.black, // Color de la aguja ajustado
                knobStyle: KnobStyle(knobRadius: 0.08), // Tamaño del nudo ajustado
              ),
            ],
            annotations: <GaugeAnnotation>[
              GaugeAnnotation(
                angle: 90,
                positionFactor: 0.2,
                widget: Text(
                  'Temperatura Olla = $temperature',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<GaugeRange> _getGradientRanges() {
    return [
      // Green
      GaugeRange(startValue: 0, endValue: 33, color: Color(0xFF00FF00)),
      GaugeRange(startValue: 5, endValue: 35, color: Color(0xFF22FF00)),
      GaugeRange(startValue: 10, endValue: 37, color: Color(0xFF44FF00)),
      GaugeRange(startValue: 15, endValue: 39, color: Color(0xFF66FF00)),
      GaugeRange(startValue: 20, endValue: 41, color: Color(0xFF88FF00)),

      // Yellow-Green to Yellow
      GaugeRange(startValue: 25, endValue: 50, color: Color(0xFFB0EE50)),
      GaugeRange(startValue: 30, endValue: 52, color: Color(0xFFC0EE30)),
      GaugeRange(startValue: 35, endValue: 54, color: Color(0xFFD0EE10)),
      GaugeRange(startValue: 40, endValue: 56, color: Color(0xFFE0EE00)),
      GaugeRange(startValue: 45, endValue: 58, color: Color(0xFFFFFF00)),

      // Yellow to Orange
      GaugeRange(startValue: 50, endValue: 67, color: Color(0xFFFFFF00)),
      GaugeRange(startValue: 55, endValue: 69, color: Color(0xFFFFEE00)),
      GaugeRange(startValue: 60, endValue: 71, color: Color(0xFFFFDD00)),
      GaugeRange(startValue: 65, endValue: 73, color: Color(0xFFFFCC00)),
      GaugeRange(startValue: 70, endValue: 80, color: Color(0xFFFFBB00)),
      GaugeRange(startValue: 75, endValue: 85, color: Color(0xFFFFAA00)),
      GaugeRange(startValue: 80, endValue: 90, color: Color(0xFFFF9900)),

      // Orange to Red
      GaugeRange(startValue: 84, endValue: 100, color: Color(0xFFFF8800)),
      
      // Red
      GaugeRange(startValue: 88, endValue: 100, color: Color.fromARGB(255, 255, 55, 0)),
      GaugeRange(startValue: 92, endValue: 100, color: Color(0xFFFF0000)),
    ];
  }
}
 */