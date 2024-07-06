import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ChartData {
  final String range;
  final int count;

  ChartData({
    required this.range,
    required this.count,
  });

  static ChartData fromJson(Map<String, dynamic> json) {
    return ChartData(
      range: json['range'],
      count: json['count'],
    );
  }
}

class Chart extends StatelessWidget {
  final List<ChartData> data;

  const Chart(this.data, {super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints.expand(height: 200),
      child: BarChart(
        BarChartData(
          barTouchData: barTouchData,
          titlesData: titlesData,
          borderData: FlBorderData(show: false),
          barGroups: barGroups,
          gridData: const FlGridData(show: false),
          alignment: BarChartAlignment.spaceAround,
          maxY: 20,
        ),
      ),
    );
  }

  Widget getTitles(double value, TitleMeta meta) {
    const TextStyle style = TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    final int index = value.toInt();

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(data[index].range, style: style),
    );
  }

  BarTouchData get barTouchData => BarTouchData(
    enabled: false,
    touchTooltipData: BarTouchTooltipData(
      getTooltipColor: (group) => Colors.transparent,
      tooltipPadding: EdgeInsets.zero,
      tooltipMargin: 8,
      getTooltipItem: (BarChartGroupData group, int groupIndex, BarChartRodData rod, int rodIndex) {
        return BarTooltipItem(
          rod.toY.round().toString(),
          const TextStyle(fontWeight: FontWeight.bold),
        );
      },
    ),
  );

  List<BarChartGroupData> get barGroups => data.map((chart) {
    return BarChartGroupData(
      x: data.indexOf(chart),
      showingTooltipIndicators: [0],
      barRods: [
        BarChartRodData(
          toY: chart.count.toDouble(),
          color: Colors.blue,
        ),
      ],
    );
  }).toList();

  FlTitlesData get titlesData => FlTitlesData(
    show: true,
    bottomTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 30,
        getTitlesWidget: getTitles,
      ),
    ),
    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
  );
}

// vim: set ts=2 sw=2 expandtab:
