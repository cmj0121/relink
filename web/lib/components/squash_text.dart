import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;

import 'squash_base.dart';

class SquashText extends StatefulWidget {
  const SquashText({super.key});

  @override
  State<SquashText> createState() => _SquashTextState();
}

class _SquashTextState extends State<SquashText> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _hintController = TextEditingController();
  final TextEditingController _expiredController = TextEditingController();

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
    return SquashBase(
      controller: _controller,
      passwordController: _passwordController,
      hintController: _hintController,
      expiredController: _expiredController,
      child: buildContent(),
    );
  }

  Widget buildContent() {
    return Row(
      children: [
        Flexible(child: textField()),
        IconButton(
          icon: const Icon(Icons.send),
          onPressed: () => squash(),
        ),
      ],
    );
  }

  Widget textField() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 160),
      child: TextField(
        controller: _textController,
        minLines: 5,
        maxLines: null,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
        ),
        onSubmitted: (value) => squash(),
      ),
    );
  }

  void squash() async {
    final endpoint = Uri.parse('/api/squash');
    final Map<String, dynamic> payload = {
      'type': 'text',
      'text': _textController.text,
      'password': _passwordController.text,
      'pwd_hint': _hintController.text,
      'expired_hours': expiredHours(),
    };

    final header = {'Content-Type': 'application/json'};
    final response = await http.post(endpoint, headers: header, body: jsonEncode(payload));
    setState(() {
      switch (response.statusCode) {
        case 201:
          _controller.text = jsonDecode(response.body) as String;
          break;
        case 400:
          _controller.text = '';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.txt_invalid_request),
            ),
          );
          break;
        default:
          _controller.text = '';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.txt_unknown_error),
            ),
          );
          break;
      }
    });
  }

  int? expiredHours() {
    final text = _expiredController.text;
    return text.isEmpty ? null : int.tryParse(text);
  }
}

// vim: set ts=2 sw=2 expandtab:
