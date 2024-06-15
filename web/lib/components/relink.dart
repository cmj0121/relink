import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:universal_html/html.dart' as html;

import 'icons.dart';

class RelinkType {
  final String key;
  final String ip;
  final String type;

  final String? password;
  final String? hint;

  final String? link;
  final String? text;

  final String createdAt;
  final String? deletedAt;
  final String? expiredAt;

  RelinkType({
    required this.key,
    required this.ip,
    required this.type,
    this.password,
    this.hint,
    this.link,
    this.text,
    required this.createdAt,
    this.deletedAt,
    this.expiredAt,
  });

  static RelinkType fromJson(Map<String, dynamic> json) {
    return RelinkType(
      key: json['key'],
      ip: json['ip'],
      type: json['type'],
      password: json['password']?.isEmpty == true ? null : json['password'],
      hint: json['hint'],
      link: json['link'],
      text: json['text'],
      createdAt: json['created_at'],
      deletedAt: json['deleted_at'],
      expiredAt: json['expired_at'],
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
    final Widget passwordIcon = IconButton(
      icon: Icon(RecordIcon.lock.icon),
      onPressed: relink.password == null ? null : () {
        Clipboard.setData(ClipboardData(text: relink.password!));

        // pop-up the message that the password has been copied to the clipboard
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.txt_copied_password),
          ),
        );
      },
    );

    return Opacity(
      opacity: relink.password == null ? 0.0 : 1.0,
      child: passwordIcon,
    );
  }

  Widget contentText(BuildContext context) {
    final String text = relink.text ?? relink.link ?? '-';

    return Row(
      children: <Widget>[
        TextButton.icon(
          icon: relinkIcon(),
          label: Text(relink.key),
          onPressed: () {
            html.window.location.href = '/${relink.key}';
          },
        ),
        Flexible(child: Text(text, overflow: TextOverflow.ellipsis)),
      ],
    );
  }

  Widget createdText(BuildContext context) {
    final DateFormat formatter = DateFormat('MM-dd HH:mm z');
    final DateTime createdAt = DateTime.parse(relink.createdAt);
    final DateTime? expiredAt = relink.expiredAt == null ? null : DateTime.parse(relink.expiredAt!);

    return Container(
      padding: const EdgeInsets.only(top: 20),
      child: Text(
        formatter.format(expiredAt ?? createdAt),
        style: TextStyle(
          color: expiredAt == null ? Colors.black : Colors.red,
        ),
      ),
    );
  }

  Widget relinkIcon() {
    late IconData icon;

    switch (relink.type) {
      case 'link':
        icon = RecordIcon.link.icon;
        break;
      case 'text':
        icon = RecordIcon.text.icon;
        break;
    default:
      icon = RecordIcon.unknown.icon;
      break;
    }

    return Icon(icon);
  }
}

// vim: set ts=2 sw=2 expandtab:
