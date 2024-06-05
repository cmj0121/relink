import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;

import '../components/all.dart';

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
  String? _squashedType = 'link';

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
          inputLinkField(),
          const SizedBox(height: 20),
          optionFields(),
          const Loading(icon: Icons.keyboard_arrow_down_outlined),
          const SizedBox(height: 20),
          squashLinkField(),
        ],
      ),
    );
  }

  Widget inputLinkField() {
    return TextField(
      controller: _textController,
      textInputAction: TextInputAction.go,
      onSubmitted: squashLink,
      decoration: InputDecoration(
        prefixIcon: squashTypes(),
        suffixIcon: IconButton(
          icon: Icon(RecordIcon.menu.icon),
          onPressed: () {
            setState(() {
              showMenu = !showMenu;
            });
          },
        ),
        hintText: AppLocalizations.of(context)?.txt_search_hint,
      ),
    );
  }

  Widget squashTypes() {
    final items = [
      DropdownMenuItem(
        value: 'link',
        child: Icon(RecordIcon.link.icon),
      ),
      DropdownMenuItem(
        value: 'text',
        enabled: false,
        child: Icon(RecordIcon.text.icon),
      ),
      DropdownMenuItem(
        value: 'image',
        enabled: false,
        child: Icon(RecordIcon.image.icon),
      ),
    ];

    return DropdownButton(
      value: _squashedType,
      items: items,
      onChanged: (String? value) {
        setState(() {
          _squashedType = value;
        });
      },
    );
  }

  Widget optionFields() {
    if (!showMenu) return Container();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 60),
      child: Column(
        children: [
          TextField(
            controller: _passwordController,
            maxLength: 32,
            decoration: InputDecoration(
              prefixIcon: Icon(RecordIcon.lock.icon),
              hintText: AppLocalizations.of(context)?.txt_password,
            ),
          ),
          const SizedBox(height: 20),
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

// vim: set ts=2 sw=2 expandtab:
