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
  bool filterLink = true;
  bool filterText = true;
  bool filterImage = true;
  bool filterDeleted = false;

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
      return Column(
        children: [
          Flexible(flex: 1, child: filterContent()),
          const Divider(),
          Flexible(flex: 4, child: buildContent()),
        ],
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

  Widget filterContent() {
    final icoms = [
      RecordIcon.link,
      RecordIcon.text,
      RecordIcon.image,
      RecordIcon.deleted,
    ];

    return Row(
      children: icoms.map((icon) {
        late bool value;

        switch (icon) {
          case RecordIcon.link:
            value = filterLink;
            break;
          case RecordIcon.text:
            value = filterText;
            break;
          case RecordIcon.image:
            value = filterImage;
            break;
          case RecordIcon.deleted:
            value = filterDeleted;
            break;
          default:
            value = false;
        }

        return Flexible(
          child: CheckboxListTile(
            value: value,
            title: Icon(icon.icon),
            onChanged: (v) {
              setState(() {
                switch (icon) {
                  case RecordIcon.link:
                    filterLink = v!;
                    break;
                  case RecordIcon.text:
                    filterText = v!;
                    break;
                  case RecordIcon.image:
                    filterImage = v!;
                    break;
                  case RecordIcon.deleted:
                    filterDeleted = v!;
                    break;
                  default:
                    break;
                }
              });

              loadRelinks();
            },
          ),
        );
      }).toList(),
    );
  }

  Widget buildContent() {
    return ListView(
      children: _relinks!.map((relink) => ClipRect(
        child: Relink(relink, onDeleted: () async {
          final endpoint = Uri.parse('$basehref/api/${relink.key}');
          final headers = {'Authorization': password()};
          final response = await http.delete(endpoint, headers: headers);

          switch (response.statusCode) {
            case 202:
              loadRelinks();
          }
        },
      ))).toList(),
    );
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
    final endpoint = Uri.parse('$basehref/api/squash').replace(queryParameters: queries());
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

  Map<String, String> queries() {
    return {
      'link': filterLink ? '1' : '0',
      'text': filterText ? '1' : '0',
      'image': filterImage ? '1' : '0',
      'deleted': filterDeleted ? '1' : '0',
    };
  }
}

// vim: set ts=2 sw=2 expandtab:
