import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:universal_html/html.dart' as html;

import '../components/all.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  List<RelinkType>? _relinks;
  int? _error;

  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadRelinks();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_relinks != null) {
      return ListView(
        children: _relinks!.map((relink) => ClipRect(
          child: Relink(relink, onDeleted: () async {
            final endpoint = Uri.parse('$basehref/api/${relink.key}');
            final headers = {'Authorization': password()};
            final response = await http.delete(endpoint, headers: headers);

            setState(() {
              switch (response.statusCode) {
                case 202:
                  _relinks!.remove(relink);
              }
            });
          },
        ))).toList(),
      );
    }

    switch (_error) {
      case null:
        return const CircularProgressIndicator();
      case 401:
        return passwordField(AppLocalizations.of(context)?.txt_unauthorized);
      case 403:
        return passwordField(AppLocalizations.of(context)?.txt_forbidden);
      case 429:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(AppLocalizations.of(context)!.txt_too_many_requests, style: const TextStyle(fontSize: 32, color: Colors.red)),
              const SizedBox(height: 20),
              Text(AppLocalizations.of(context)!.txt_try_again_later),
            ],
          ),
        );
      default:
        return passwordField(AppLocalizations.of(context)?.txt_unknown_error);
    }
  }

  Widget passwordField(String? text) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(text!, style: const TextStyle(fontSize: 32, color: Colors.red)),

        const SizedBox(height: 20),

        TextField(
          controller: _textController,
          decoration: InputDecoration(
            prefixIcon: Icon(RecordIcon.password.icon),
            hintText: AppLocalizations.of(context)?.txt_password,
          ),
          onSubmitted: (String password) => loadRelinks(),
          obscureText: true,
          autocorrect: false,
          enableSuggestions: false,
        ),
      ],
    );
  }

  void loadRelinks() async {
    final endpoint = Uri.parse('$basehref/api/squash');
    final headers = {'Authorization': password()};
    final response = await http.get(endpoint, headers: headers);

    setState(() {
      switch (response.statusCode) {
        case 200:
          try {
            final List<dynamic> json = jsonDecode(response.body);

            _error = null;
            _relinks = json.map((e) => RelinkType.fromJson(e)).toList();

            // set the password cookie
            if (_textController.text.isNotEmpty) {
              html.document.cookie = 'password=${_textController.text}; samesite=strict; secure';
            }
          } catch (e) {
            _error = 500;
            _relinks = null;
            html.document.cookie = 'password=; samesite=strict; secure';
          }
          break;
        default:
          _error = response.statusCode;
          _relinks = null;
          html.document.cookie = 'password=; samesite=strict; secure';
          break;
      }
    });
  }

  String password() {
    final cookies = (html.document.cookie ?? '').split(';');
    final password = cookies.firstWhere((cookie) => cookie.startsWith('password='), orElse: () => 'password=');
    final parts = password.split('=');
    final value = parts.length == 2 ? parts[1] : '';

    return value.isEmpty ? _textController.text : value;
  }
}

// vim: set ts=2 sw=2 expandtab:
