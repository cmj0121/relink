import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../components/all.dart';

class Statistics {
  final String code;
  final int total;
  final List<ChartData> data;

  Statistics({
    required this.code,
    required this.total,
    required this.data,
  });

  static Statistics fromJson(Map<String, dynamic> json) {
    List<ChartData> data = [];
    if (json['chart'] != null) {
      data = (json['chart'] as List).map((e) => ChartData.fromJson(e)).toList();
    }

    return Statistics(
      code: json['code'],
      total: json['total'],
      data: data,
    );
  }
}

class StatisticsPage extends StatefulWidget {
  final String code;

  const StatisticsPage(this.code, {super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  Statistics? _statistics;

  @override
  void initState() {
    super.initState();
    loadStatistics();
  }

  @override
  Widget build(BuildContext context) {
    if (_statistics == null) {
      return const CircularProgressIndicator();
    }

    return buildContent();
  }

  Future<void> loadStatistics() async {
    final String endpoint = '/api/${widget.code}/statistics';
    final response = await http.get(Uri.parse(endpoint));

    setState(() {
      switch (response.statusCode) {
        case 200:
          final json = jsonDecode(response.body);
          _statistics = Statistics.fromJson(json);
          break;
        default:
          _statistics = null;
          break;
      }
    });
  }

  Widget buildContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Chart(_statistics!.data),
        const Divider(),
        Flexible(child: buildTotalCount()),
      ]
    );
  }

  Widget buildTotalCount() {
    final int total = _statistics!.total;
    const double fontSize = 24;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Total: ', style: TextStyle(fontSize: fontSize)),
        Text('$total', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize)),
      ],
    );
  }
}

// vim: set ts=2 sw=2 expandtab:
