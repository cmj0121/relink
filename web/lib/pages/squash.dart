import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../components/all.dart';

enum SquashTab {
  link,
  text,
  image,
  video,
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
      case SquashTab.video:
        text = AppLocalizations.of(context)!.tab_video;
        icon = Icon(RecordIcon.video.icon);
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
          // const Loading(icon: Icons.keyboard_arrow_down_outlined),
          // const SizedBox(height: 20),
          // squashLinkField(),
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
          return workInProgress();
        case SquashTab.text:
          return workInProgress();
        case SquashTab.image:
          return workInProgress();
        case SquashTab.video:
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

  Widget squashLinkField() {
    final String squashedLink = _controller.text;

    return Opacity(
      opacity: squashedLink.isEmpty ? 0.0 : 1.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          IconButton(
            icon: Icon(RecordIcon.copy.icon),
            onPressed: squashedLink.isEmpty ? null : copyLink,
          ),
          const SizedBox(width: 10),
          Text(
            squashedLink,
            style: DefaultTextStyle.of(context).style.apply(fontSizeFactor: 2.0),
          ),
        ],
      ),
    );
  }

  void copyLink() {
    final String squashedLink = _controller.text;

    Clipboard.setData(ClipboardData(text: squashedLink));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.txt_copied_to_clipboard(squashedLink)),
      ),
    );
  }
}

// vim: set ts=2 sw=2 expandtab:
