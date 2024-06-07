import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'icons.dart';

class Password extends StatefulWidget {
  final int maxLength;
  final TextEditingController? textController;
  final TextEditingController? hintController;

  const Password({super.key, this.maxLength = 16, this.textController, this.hintController});

  @override
  State<Password> createState() => _PasswordState();
}

class _PasswordState extends State<Password> {
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
      controller: widget.textController,
      maxLength: widget.maxLength,
      decoration: InputDecoration(
        prefixIcon: Icon(RecordIcon.lock.icon),
        hintText: AppLocalizations.of(context)?.txt_password,
        counterText: '',
      ),
      onChanged: (value) {
        setState(() {
          if (value.isEmpty) {
            widget.hintController?.clear();
          }
        });
      },
    );
  }

  Widget passwordHint() {
    return TextField(
      enabled: widget.textController?.text.isNotEmpty ?? true,
      controller: widget.hintController,
      maxLength: widget.maxLength,
      decoration: InputDecoration(
        prefixIcon: Icon(RecordIcon.hint.icon),
        hintText: AppLocalizations.of(context)?.txt_password_hint,
        counterText: '',
      ),
    );
  }
}

// vim: set ts=2 sw=2 expandtab:
