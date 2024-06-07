import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class TimePicker extends StatefulWidget {
  final TextEditingController? controller;

  const TimePicker({super.key, this.controller});

  @override
  State<TimePicker> createState() => _TimePickerState();
}

class _TimePickerState extends State<TimePicker> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextField(
        controller: widget.controller,
        readOnly: true,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.timer),
          hintText: AppLocalizations.of(context)?.txt_unlimited,
        ),
      ),
    );
  }
}

// vim: set ts=2 sw=2 expandtab:
