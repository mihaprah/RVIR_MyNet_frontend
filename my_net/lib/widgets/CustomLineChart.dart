import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomLineChart extends StatelessWidget {
  final List<FlSpot> dataSpots;
  final double maxValue;

  const CustomLineChart({
    Key? key,
    required this.dataSpots,
    required this.maxValue
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.70,
      child: Padding(
          padding: const EdgeInsets.only(
            right: 18,
            left: 12,
            top: 24,
            bottom: 12,
          ),
          child: AspectRatio(
            aspectRatio: 1,
            child: LineChart(LineChartData(
                lineBarsData: [
                  LineChartBarData(
                      spots: dataSpots,
                      isCurved: true,
                      dotData: const FlDotData(show: true),
                      color: Theme.of(context).primaryColor,
                      barWidth: 2,
                      belowBarData: BarAreaData(
                          show: true,
                          color: Theme.of(context).primaryColor.withOpacity(0.7)
                      )
                  )
                ],
                minX: 0,
                maxX: 11,
                minY: 0,
                maxY: maxValue,
                backgroundColor: const Color(0xFFECECEC),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          interval: 3,
                          getTitlesWidget: (value, meta) {
                            String text = '';
                            switch (value.toInt()) {
                              case 0:
                                text = 'Jan';
                                break;
                              case 3:
                                text = 'Apr';
                                break;
                              case 6:
                                text = 'Jul';
                                break;
                              case 9:
                                text = 'Oct';
                                break;
                              case 11:
                                text = 'Dec';
                                break;
                            }
                            return Text(text);
                          }
                      )
                  ),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)
                  ),
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                      )
                  ),
                ),
                gridData: const FlGridData(
                  show: true,
                  drawHorizontalLine: false,
                  drawVerticalLine: false,
                ),
                borderData: FlBorderData(
                    show: false,
                    border: Border.all(
                        color: Colors.red,
                        width: 5
                    )
                )
            )
            ),
          )
      ),
    );
  }
}