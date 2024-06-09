import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:universal_html/html.dart' as html;

import '../components/all.dart';

class PasswordPage extends StatelessWidget {
  final String? code;

  const PasswordPage(this.code, {super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(AppLocalizations.of(context)!.txt_need_password(code!)),
          TextField(
            maxLength: 32,
            decoration: InputDecoration(
              prefixIcon: Icon(RecordIcon.lock.icon),
              hintText: AppLocalizations.of(context)?.txt_password,
              helperText: hint(),
              counterText: '',
            ),
            onSubmitted: to,
          ),
        ],
      ),
    );
  }

  void to(String password) {
    html.window.location.href = '/$code?password=$password';
  }

  String? hint() {
    var uri = Uri.dataFromString(html.window.location.href);
    var hint = uri.queryParameters['hint'];

    return hint == null ? null : Uri.decodeComponent(hint);
  }
}

// vim: set ts=2 sw=2 expandtab:
