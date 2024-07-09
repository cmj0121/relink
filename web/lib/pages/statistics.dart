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

class ChartTab extends StatefulWidget {
  final String code;

  const ChartTab(this.code, {super.key});

  @override
  State<ChartTab> createState() => _ChartTabState();
}

class _ChartTabState extends State<ChartTab> {
  Statistics? _statistics;

  @override
  void initState() {
    super.initState();
    loadStatistics();
  }

  @override
  Widget build(BuildContext context) {
    if (_statistics == null) {
      return const Center(
        child: CircularProgressIndicator()
      );
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(flex: 2, child: Chart(_statistics!.data)),
          const Divider(),
          Flexible(flex: 1, child: buildTotalCount()),
        ]
      ),
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

class AccessLog {
  final String ip;
  final String userAgent;
  final String createdAt;

  AccessLog({
    required this.ip,
    required this.userAgent,
    required this.createdAt,
  });

  static AccessLog fromJson(Map<String, dynamic> json) {
    return AccessLog(
      ip: json['ip'],
      userAgent: json['user_agent'],
      createdAt: json['created_at'],
    );
  }
}

class ListTab extends StatefulWidget {
  final String code;

  const ListTab(this.code, {super.key});

  @override
  State<ListTab> createState() => _ListTabState();
}

class _ListTabState extends State<ListTab> {
  List<AccessLog>? logs;
  bool loading = false;
  bool hasMore = true;

  Future<void> loadLogs() async {
    if (loading || !hasMore) {
      return;
    }

    const int size = 40;
    final int page = (logs?.length ?? 0) ~/ size;
    final String endpoint = '/api/${widget.code}/access-log?page=$page&size=$size';
    final response = await http.get(Uri.parse(endpoint));

    setState(() {
      switch (response.statusCode) {
        case 200:
          try {
            final List<dynamic> json = jsonDecode(response.body);
            final data = json.map((e) => AccessLog.fromJson(e)).toList();

            logs = [...logs ?? [], ...data];
            if (data.isEmpty) {
              hasMore = false;
            }
          } catch(e) {
            hasMore = false;
          }
      }

      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount + 1,
      itemBuilder: (context, index) {
        if (index >= itemCount && !hasMore) {
          return const SizedBox();
        }

        if (logs == null || (index >= itemCount && hasMore)) {
          loadLogs();
          return const Loading(icon: Icons.keyboard_arrow_down_outlined);
        }

        final log = logs![index];
        return Card(
          child: ListTile(
            title: Text(log.ip),
            subtitle: Text(log.userAgent),
          ),
        );
      },
    );
  }

  int get itemCount => logs?.length ?? 0;
}

class StatisticsPage extends StatefulWidget {
  final String code;
  const StatisticsPage(this.code, {super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.bar_chart)),
            Tab(icon: Icon(Icons.list)),
          ],
        ),
        Flexible(
          child: TabBarView(
            controller: _tabController,
            children: [
              ChartTab(widget.code),
              ListTab(widget.code),
            ],
          ),
        ),
      ],
    );
  }
}

// vim: set ts=2 sw=2 expandtab:
