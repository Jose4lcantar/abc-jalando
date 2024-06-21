import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class GraphScreen extends StatelessWidget {
  final String temperature; //temperatura de la olla
  final String ambientTemperature; // temperatura ambiente
  final String humidity; // humedad
  final String windSpeed;
  final String ultraVioletRadiation; // velocidad del viento

  const GraphScreen(
      {required this.temperature,
      required this.ambientTemperature,
      required this.humidity,
      required this.windSpeed,
      required this.ultraVioletRadiation});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Gráfica',
          textAlign: TextAlign.center,
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SfCartesianChart(
                  title: const ChartTitle(text: 'Temperatura de Olla'),
                  series: <CartesianSeries>[
                    SplineAreaSeries<ChartData, double>(
                      dataSource: _getChartData(temperature),
                      xValueMapper: (ChartData data, _) => data.time,
                      yValueMapper: (ChartData data, _) => data.value,
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SfCartesianChart(
                  title: const ChartTitle(text: 'Temperatura Ambiente'),
                  series: <CartesianSeries>[
                    SplineAreaSeries<ChartData, double>(
                      dataSource: _getChartData(ambientTemperature),
                      xValueMapper: (ChartData data, _) => data.time,
                      yValueMapper: (ChartData data, _) => data.value,
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SfCartesianChart(
                  title: const ChartTitle(text: 'Humedad'),
                  series: <CartesianSeries>[
                    SplineAreaSeries<ChartData, double>(
                      dataSource: _getChartData(humidity),
                      xValueMapper: (ChartData data, _) => data.time,
                      yValueMapper: (ChartData data, _) => data.value,
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SfCartesianChart(
                  title: const ChartTitle(text: "Velocidad del Viento"),
                  series: <CartesianSeries>[
                    SplineAreaSeries<ChartData, double>(
                      dataSource: _getChartData(windSpeed),
                      xValueMapper: (ChartData data, _) => data.time,
                      yValueMapper: (ChartData data, _) => data.value,
                    )
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SfCartesianChart(
                  title: const ChartTitle(text: "Radiacion solar"),
                  series: <CartesianSeries>[
                    SplineAreaSeries<ChartData, double>(
                      dataSource: _getChartData(ultraVioletRadiation),
                      xValueMapper: (ChartData data, _) => data.time,
                      yValueMapper: (ChartData data, _) => data.value,
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<ChartData> _getChartData(String value) {
    double temp = double.tryParse(value) ?? 0;
    return [
      ChartData(time: 1, value: temp),
      ChartData(time: 2, value: temp + 1),
      ChartData(time: 3, value: temp + 2),
    ];
  }
}

class ChartData {
  final double time;
  final double value;

  ChartData({required this.time, required this.value});
}
