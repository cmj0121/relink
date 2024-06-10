import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../components/all.dart';

enum SquashTab {
  link,
  text,
  image,
}

extension SquashTypeExtension on SquashTab {
  Widget tab(BuildContext context) {
    late final String text;
    late final Icon icon;

    switch (this) {
      case SquashTab.link:
        text = AppLocalizations.of(context)!.tab_link;
        icon = Icon(RecordIcon.link.icon);
      case SquashTab.text:
        text = AppLocalizations.of(context)!.tab_text;
        icon = Icon(RecordIcon.text.icon);
      case SquashTab.image:
        text = AppLocalizations.of(context)!.tab_image;
        icon = Icon(RecordIcon.image.icon);
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth < 80) {
          return icon;
        }

        return Row(
          children: <Widget>[
            icon,
            const SizedBox(width: 10),
            Text(text),
          ],
        );
      },
    );
  }
}

class Squash extends StatefulWidget {
  final TextEditingController? controller;

  const Squash({super.key, this.controller});

  @override
  State<Squash> createState() => _SquashState();
}

class _SquashState extends State<Squash>  with SingleTickerProviderStateMixin {
  late final TextEditingController _controller;
  late final List<SquashTab> _tabs;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();

    _controller = widget.controller ?? TextEditingController();
    _tabs = SquashTab.values;
    _tabController = TabController(vsync: this, length: _tabs.length);
  }

  @override
  void dispose() {
    _tabController.dispose();

    if (widget.controller == null) {
      _controller.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          menuBar(),
          const SizedBox(height: 20),
          Flexible(child: squashBody()),
        ],
      ),
    );
  }

  Widget menuBar() {
    final tabs = _tabs.map((tab) => Tab(child: tab.tab(context))).toList();

    return TabBar(
      tabs: tabs,
      controller: _tabController,
    );
  }

  Widget squashBody() {
    final views = _tabs.map((tab) {
      switch (tab) {
        case SquashTab.link:
          return const SquashLink();
        case SquashTab.text:
          return const SquashText();
        case SquashTab.image:
          return workInProgress();
      }
    }).toList();

    return TabBarView(
      controller: _tabController,
      children: views,
    );
  }

  Widget workInProgress() {
    return Container(
      constraints: const BoxConstraints(minHeight: 400),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.txt_work_in_progress,
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(height: 120),
            Transform.scale(
              scale: 6.0,
              child: Icon(RecordIcon.workInProgress.icon),
            ),
          ],
        ),
      ),
    );
  }
}

// vim: set ts=2 sw=2 expandtab:
