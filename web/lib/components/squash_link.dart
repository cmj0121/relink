import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;

import 'squash_base.dart';

class SquashLink extends StatefulWidget {
  const SquashLink({super.key});

  @override
  State<SquashLink> createState() => _SquashLinkState();
}

class _SquashLinkState extends State<SquashLink> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _linkController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _hintController = TextEditingController();
  final TextEditingController _expiredController = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
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
    return TextField(
      controller: _linkController,
      onSubmitted: (value) => squash(),
      textInputAction: TextInputAction.go,
      decoration: InputDecoration(
        hintText: AppLocalizations.of(context)?.txt_search_hint,
        suffixIcon: IconButton(
          icon: const Icon(Icons.send),
          onPressed: () => squash(),
        ),
      ),
    );
  }

  void squash() async {
    final endpoint = Uri.parse('/api/squash');
    final Map<String, dynamic> payload = {
      'type': 'link',
      'link': _linkController.text,
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
