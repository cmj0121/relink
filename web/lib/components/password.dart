import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'icons.dart';

class Password extends StatefulWidget {
  final int maxLength;
  final _textController = TextEditingController();
  final _hintController = TextEditingController();

  Password({super.key, this.maxLength = 32});

  @override
  State<Password> createState() => _PasswordState();

  get password => _textController.text;
  get hint => _hintController.text;
}

class _PasswordState extends State<Password> {

  @override
  void dispose() {
    widget._textController.clear();
    widget._hintController.clear();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(child: passwordField()),
        const SizedBox(width: 10),
        Flexible(child: passwordHint()),
      ],
    );
  }

  Widget passwordField() {
    return TextField(
      controller: widget._textController,
      maxLength: widget.maxLength,
      decoration: InputDecoration(
        prefixIcon: Icon(RecordIcon.lock.icon),
        hintText: AppLocalizations.of(context)?.txt_password,
      ),
    );
  }

  Widget passwordHint() {
    return TextField(
      controller: widget._hintController,
      maxLength: widget.maxLength,
      decoration: InputDecoration(
        prefixIcon: Icon(RecordIcon.hint.icon),
        hintText: AppLocalizations.of(context)?.txt_password_hint,
      ),
    );
  }
}

// vim: set ts=2 sw=2 expandtab:
