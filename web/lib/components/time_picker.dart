import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum TimeChoice {
  unlimited,
  hour_1,
  hour_2,
  hour_6,
  day_1,
}

extension TimeChoiceExtension on TimeChoice {
  Widget build(BuildContext context) {
    return Center(child: Text(text(context)));
  }

  String text(BuildContext context) {
    late String text;

    switch (this) {
      case TimeChoice.unlimited:
        text = AppLocalizations.of(context)!.txt_unlimited;
      case TimeChoice.hour_1:
        text = AppLocalizations.of(context)!.txt_n_hour(1);
      case TimeChoice.hour_2:
        text = AppLocalizations.of(context)!.txt_n_hour(2);
      case TimeChoice.hour_6:
        text = AppLocalizations.of(context)!.txt_n_hour(6);
      case TimeChoice.day_1:
        text = AppLocalizations.of(context)!.txt_n_day(1);
      default:
        text = AppLocalizations.of(context)!.txt_unknown_error;
    }

    return text;
  }

  Duration? duration() {
    late Duration? duration;

    switch (this) {
      case TimeChoice.unlimited:
      case TimeChoice.hour_1:
        duration = const Duration(hours: 1);
      case TimeChoice.hour_2:
        duration = const Duration(hours: 2);
      case TimeChoice.hour_6:
        duration = const Duration(hours: 6);
      case TimeChoice.day_1:
        duration = const Duration(days: 1);
    }

    return duration;
  }
}

class TimePicker extends StatefulWidget {
  final TextEditingController? controller;

  const TimePicker({super.key, this.controller});

  @override
  State<TimePicker> createState() => _TimePickerState();
}

class _TimePickerState extends State<TimePicker> {
  int _selectedItem = 0;

  final List<TimeChoice> choices = TimeChoice.values;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: const EdgeInsets.all(0.0),
      child: TextField(
        enabled: false,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.timer),
          hintText: choices[_selectedItem].text(context),
        ),
      ),
      onPressed: () {
        showCupertinoModalPopup<void>(
          context: context,
          builder: (BuildContext context) => Container(
            height: 216,
            margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            color: CupertinoColors.systemBackground.resolveFrom(context),
            child: SafeArea(
              top: false,
              child: timePicker(),
            ),
          ),
        );
      },
    );
  }

  Widget timePicker() {
    final List<Widget> items = choices.map((item) => item.build(context)).toList();

    return CupertinoPicker(
      itemExtent: 32.0,
      onSelectedItemChanged: (int selectedItem) {
        setState(() {
          _selectedItem = selectedItem;

          final selected = choices[selectedItem];
          final duration = selected.duration();

          switch (duration) {
            case null:
              widget.controller?.text = '';
            default:
              widget.controller?.text = '${duration.inHours}';
          }
        });
      },
      children: items,
    );
  }
}

// vim: set ts=2 sw=2 expandtab:
