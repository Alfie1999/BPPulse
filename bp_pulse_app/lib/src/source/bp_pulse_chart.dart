import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class BloodPressureChart extends StatelessWidget {
  final List<double> systolic = [120, 125, 118, 130];
  final List<double> diastolic = [80, 82, 78, 85];
  final List<double> pulse = [70, 72, 68, 75];

  final List<String> timeLabels = ['10:00', '12:00', '14:00', '16:00'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 400, // taller
          width: 350, // narrower
          child: LineChart(
            LineChartData(
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      int index = value.toInt();
                      if (index >= 0 && index < timeLabels.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(timeLabels[index]),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                    interval: 1,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              lineBarsData: [
                _buildLine(systolic, Colors.red),
                _buildLine(diastolic, Colors.blue),
                _buildLine(pulse, Colors.green),
              ],
              gridData: FlGridData(show: true),
              borderData: FlBorderData(show: true),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: const [
            LegendItem(color: Colors.red, text: 'Systolic'),
            LegendItem(color: Colors.blue, text: 'Diastolic'),
            LegendItem(color: Colors.green, text: 'Pulse'),
          ],
        ),
      ],
    );
  }

  LineChartBarData _buildLine(List<double> values, Color color) {
    return LineChartBarData(
      spots: List.generate(
        values.length,
        (i) => FlSpot(i.toDouble(), values[i]),
      ),
      isCurved: true,
      color: color,
      dotData: FlDotData(show: true),
    );
  }
}

class LegendItem extends StatelessWidget {
  final Color color;
  final String text;
  const LegendItem({required this.color, required this.text, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 16, height: 16, color: color),
        const SizedBox(width: 8),
        Text(text),
      ],
    );
  }
}
