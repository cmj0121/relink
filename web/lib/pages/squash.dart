import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;

import '../components/all.dart';

enum SquashType {
  link,
}

class SquashPage extends StatefulWidget {
  const SquashPage({super.key});

  @override
  State<SquashPage> createState() => _SquashPageState();
}

class _SquashPageState extends State<SquashPage> {
  final _textController = TextEditingController();
  final _passwordController = TextEditingController();

  late bool showMenu = false;

  String? _squashedLink;
  final SquashType _squashType = SquashType.link;

  @override
  void dispose() {
    _textController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SquashMenu(_squashType),
          const Loading(icon: Icons.keyboard_arrow_down_outlined),
          const SizedBox(height: 20),
          squashLinkField(),
        ],
      ),
    );
  }

  Widget squashLinkField() {
    return Opacity(
      opacity: _squashedLink == null ? 0.0 : 1.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          IconButton(
            icon: Icon(RecordIcon.copy.icon),
            onPressed: _squashedLink == null ? null : copyLink,
          ),
          const SizedBox(width: 10),
          Text(
            _squashedLink ?? '',
            style: DefaultTextStyle.of(context).style.apply(fontSizeFactor: 2.0),
          ),
        ],
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

    final endpoint = Uri.parse('/api/squash?src=$url&password=${_passwordController.text}');
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

class SquashMenu extends StatefulWidget {
  final SquashType type;
  final ValueChanged<String>? onSquash;

  const SquashMenu(this.type, {super.key, this.onSquash});

  @override
  State<SquashMenu> createState() => _SquashMenuState();
}

class _SquashMenuState extends State<SquashMenu> {
  final _textController = TextEditingController();
  final _passwordController = TextEditingController();
  final _hintController = TextEditingController();
  final _expiredController = TextEditingController();

  late bool showMenu = false;

  @override
  void dispose() {
    _textController.dispose();
    _passwordController.dispose();
    _hintController.dispose();
    _expiredController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        linkField(),
        const SizedBox(height: 20),
        optionFields(),
      ],
    );
  }

  Widget linkField() {
    return TextField(
      controller: _textController,
      onSubmitted: widget.onSquash,
      textInputAction: TextInputAction.go,
      decoration: InputDecoration(
        hintText: AppLocalizations.of(context)?.txt_search_hint,
        prefixIcon: IconButton(
          icon: Icon(RecordIcon.settings.icon),
          onPressed: () {
            setState(() {
              showMenu = !showMenu;
            });
          },
        ),
        suffixIcon: IconButton(
          icon: Icon(RecordIcon.link.icon),
          onPressed: () {
            if (widget.onSquash != null) widget.onSquash!(_textController.text);
          },
        ),
      ),
    );
  }

  Widget optionFields() {
    if (!showMenu) return Container();

    return Column(
      children: [
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            if (constraints.maxWidth < 600) {
              return const Column(
                children: [
                  Password(),
                  SizedBox(height: 10),
                  TimePicker(),
                ],
              );
            }

            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(flex: 2, child: Password(textController: _passwordController, hintController: _hintController)),
                const SizedBox(width: 20),
                Flexible(flex: 1, child: TimePicker(controller: _expiredController)),
              ],
            );
          },
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

// vim: set ts=2 sw=2 expandtab:
