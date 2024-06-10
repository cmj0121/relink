import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:universal_html/html.dart' as html;

import '../components/all.dart';

class ExpiredPage extends StatelessWidget {
  const ExpiredPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(code(), style: const TextStyle(fontSize: 24)),
          Text(AppLocalizations.of(context)!.txt_expired),
        ],
      ),
    );
  }

  String code() {
    var uri = Uri.dataFromString(html.window.location.href);
    var code = uri.queryParameters['code'];

    return code == null ? '-' : Uri.decodeComponent(code);
  }
}

// vim: set ts=2 sw=2 expandtab:
