import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;

import 'components.dart';

enum Routes {
  pageIndex,
  pageAdminList,
}

Map<Routes, String> RoutesPath = {
  Routes.pageIndex: '/',
  Routes.pageAdminList: '/_admin/list',
};

class ReLinkApp extends StatelessWidget {
  static String title = "ReLink";
  const ReLinkApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      initialRoute: RoutesPath[Routes.pageIndex],
      routes: {
        RoutesPath[Routes.pageIndex]!: (context) => ReLinkHomePage(title: title, child: SquashLink()),
        RoutesPath[Routes.pageAdminList]!: (context) => ReLinkHomePage(title: title, child: SquashList()),
      },
    );
  }
}

class ReLinkHomePage extends StatefulWidget {
  final String title;
  final Widget child;
  const ReLinkHomePage({Key? key, required this.title, required this.child});

  @override
  State<ReLinkHomePage> createState() => _ReLinkHomePageState();
}

class _ReLinkHomePageState extends State<ReLinkHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.home),
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil(RoutesPath[Routes.pageIndex]!, (route) => false);
            },
          ),
          IconButton(
            icon: Icon(Icons.admin_panel_settings),
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil(RoutesPath[Routes.pageAdminList]!, (route) => false);
            },
          ),
        ],
      ),
      body: Center(
        child: widget.child,
      ),
    );
  }
}

class SquashLink extends StatefulWidget {
  final double maxWidth;

  const SquashLink({Key? key, this.maxWidth=600}) : super(key: key);

  @override
  State<SquashLink> createState() => _SquashLinkState();
}

class _SquashLinkState extends State<SquashLink> {
  final _textController = TextEditingController();

  String? _squashedLink;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: widget.maxWidth),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            inputLinkField(),
            SizedBox(height: 20),
            Loading(icon: Icons.keyboard_arrow_down_outlined),
            SizedBox(height: 20),
            squashLinkField(),
          ],
        ),
      ),
    );
  }

  Widget inputLinkField() {
    return TextField(
      controller: _textController,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.arrow_forward_ios_outlined),
        hintText: AppLocalizations.of(context)?.txt_search_hint,
      ),
      textInputAction: TextInputAction.go,
      onSubmitted: squashLink,
    );
  }

  Widget squashLinkField() {
    return Opacity(
      opacity: _squashedLink == null ? 0.0 : 1.0,
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.copy),
              onPressed: _squashedLink == null ? null : copyLink,
            ),
            SizedBox(width: 10),
            Text(
              _squashedLink ?? '',
              style: DefaultTextStyle.of(context).style.apply(fontSizeFactor: 2.0),
            ),
          ],
        ),
      ),
    );
  }

  void copyLink() {
    if (_squashedLink == null) return;

    Clipboard.setData(ClipboardData(text: _squashedLink!));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.txt_copied_to_clipboard(_squashedLink!)),
      ),
    );
  }

  void squashLink(String url) async {
    final uri = Uri.parse(url);
    if (uri.scheme.isEmpty) {
      setState(() {
        _squashedLink = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.err_invalid_url(url)),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final endpoint = Uri.parse('/api/squash?src=$url');
    final response = await http.post(endpoint);

    setState(() {
      switch (response.statusCode) {
        case 201:
          _squashedLink = jsonDecode(response.body) as String;
          break;
        default:
          _squashedLink = null;
          break;
      }
    });
  }
}

class SquashList extends StatefulWidget {
  final double maxWidth;
  const SquashList({Key? key, this.maxWidth=600});

  @override
  State<SquashList> createState() => _SquashListState();
}

class _SquashListState extends State<SquashList> {
  final _textController = TextEditingController();
  late Widget _content = CircularProgressIndicator();

  @override
  void initState() {
    super.initState();
    loadContent();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: widget.maxWidth),
      child: _content,
    );
  }

  void loadContent() async {
    final endpoint = Uri.parse('/api/squash');
    final headers = {"Authorization": "${_textController.text}"};
    final response = await http.get(endpoint, headers: headers);

    setState(() {
      switch (response.statusCode) {
        case 200:
          _content = ListView(
            children: (jsonDecode(response.body) as List<dynamic>).map((item) {
              return ListTile(
                title: Row(
                  children: <Widget>[
                    Text("${item['hashed']}"),
                    Icon(Icons.arrow_back_outlined),
                    Text("${item['source']}"),
                  ],
                ),
                subtitle: Text("${item['ip']}"),
                trailing: Text("${item['created_at']}"),
              );
            }).toList(),
          );
          break;
        case 401:
          _content = buildSignin(AppLocalizations.of(context)!.txt_unauthorized);
          break;
        case 403:
          _content = buildSignin(AppLocalizations.of(context)!.txt_forbidden);
          break;
        case 429:
          _content = Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(AppLocalizations.of(context)!.txt_too_many_requests, style: TextStyle(fontSize: 32, color: Colors.red)),
                SizedBox(height: 20),
                Text(AppLocalizations.of(context)!.txt_try_again_later),
              ],
            ),
          );
          break;
        default:
          _content = buildSignin(AppLocalizations.of(context)!.txt_unknown_error);
          break;
      }
    });
  }

  Widget buildSignin(String text) {
    return Container(
      constraints: BoxConstraints(maxWidth: widget.maxWidth),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(text, style: TextStyle(fontSize: 32, color: Colors.red)),
          SizedBox(height: 20),
          TextField(
            controller: _textController,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.key_sharp),
              hintText: AppLocalizations.of(context)?.txt_password,
            ),
            onSubmitted: (String password) => loadContent(),
          ),
        ],
      ),
    );
  }
}

// vim: set ts=2 sw=2 expandtab:
