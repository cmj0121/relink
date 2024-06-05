import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:universal_html/html.dart' as html;

import 'icons.dart';

class RelinkType {
  final String source;
  final String hashed;
  final String ip;
  final String type;
  final String password;
  final String createdAt;

  RelinkType({
    required this.source,
    required this.hashed,
    required this.ip,
    required this.type,
    required this.password,
    required this.createdAt,
  });

  static RelinkType fromJson(Map<String, dynamic> json) {
    return RelinkType(
      source: json['source'],
      hashed: json['hashed'],
      ip: json['ip'],
      type: json['type'],
      password: json['password'],
      createdAt: json['created_at'],
    );
  }
}

class Relink extends StatelessWidget {
  final RelinkType relink;

  const Relink(this.relink, {super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: passwordIcon(context),
      title: contentText(context),
      subtitle: Text(relink.ip),
      trailing: createdText(context),
    );
  }

  Widget passwordIcon(BuildContext context) {
    final String password = relink.password;
    final Widget passwordIcon = IconButton(
      icon: Icon(RecordIcon.lock.icon),
      onPressed: password.isEmpty ? null : () {
        Clipboard.setData(ClipboardData(text: password));

        // pop-up the message that the password has been copied to the clipboard
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.txt_copied_password),
          ),
        );
      },
    );

    return Opacity(
      opacity: password.isEmpty ? 0.0 : 1.0,
      child: passwordIcon,
    );
  }

  Widget contentText(BuildContext context) {
    return Row(
      children: <Widget>[
        TextButton.icon(
          icon: Icon(RecordIcon.link.icon),
          label: Text(relink.hashed),
          onPressed: () {
            html.window.location.href = '/need-password-${relink.hashed}';
          },
        ),
        Text(relink.source, overflow: TextOverflow.ellipsis),
      ],
    );
  }

  Widget createdText(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 20),
      child: Text(relink.createdAt),
    );
  }
}

// vim: set ts=2 sw=2 expandtab:
