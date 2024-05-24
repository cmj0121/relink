import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;

import 'components.dart';

class ReLinkApp extends StatelessWidget {
  static String title = "ReLink";
  const ReLinkApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      home: ReLinkHomePage(title: title),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}

class ReLinkHomePage extends StatefulWidget {
  final String title;
  const ReLinkHomePage({Key? key, required this.title});

  @override
  State<ReLinkHomePage> createState() => _ReLinkHomePageState();
}

class _ReLinkHomePageState extends State<ReLinkHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(
        child: SquashLink(),
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

// vim: set ts=2 sw=2 expandtab:
