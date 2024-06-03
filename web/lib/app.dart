import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'dart:html' as html;

import 'components.dart';

enum Routes {
  pageIndex,
  pageAdminList,
}

void routeTo(Routes route, BuildContext context) {
  switch (route) {
    case Routes.pageIndex:
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      break;
    case Routes.pageAdminList:
      Navigator.of(context).pushNamedAndRemoveUntil('/_admin/list', (route) => false);
      break;
    default:
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }
}

class ReLinkApp extends StatelessWidget {
  static String title = "ReLink";
  const ReLinkApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        final name = settings.name ?? '/';
        final Widget child;

        switch (name) {
          case '/':
            child = SquashLink();
            break;
          case '/_admin/list':
            child = SquashList();
            break;
          default:
            final match = RegExp(r'^/need-password-(\w+)');

            if (!match.hasMatch(name)) {
              Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
            }

            final code = match.firstMatch(name)!.group(1);
            child = PasswordPage(code: code);
        }

        return MaterialPageRoute(
          builder: (context) => ReLinkHomePage(title: title, child: child),
        );
      },
    );
  }
}

class ReLinkHomePage extends StatefulWidget {
  final String title;
  final Widget child;
  const ReLinkHomePage({Key? key, required this.title, required this.child});

  @override
  State<ReLinkHomePage> createState() => _ReLinkHomePageState();
}

class _ReLinkHomePageState extends State<ReLinkHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.home),
            onPressed: () { routeTo(Routes.pageIndex, context); },
          ),
          IconButton(
            icon: Icon(Icons.admin_panel_settings),
            onPressed: () { routeTo(Routes.pageAdminList, context); },
          ),
        ],
      ),
      body: Center(
        child: widget.child,
      ),
    );
  }
}

class SquashLink extends StatefulWidget {
  final double maxWidth;

  const SquashLink({Key? key, this.maxWidth=600}) : super(key: key);

  @override
  State<SquashLink> createState() => _SquashLinkState();
}

class _SquashLinkState extends State<SquashLink> {
  final _textController = TextEditingController();
  final _passwordController = TextEditingController();
  late bool showMenu = false;

  String? _squashedLink;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: widget.maxWidth),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            inputLinkField(),
            SizedBox(height: 20),
            optionFields(),
            Loading(icon: Icons.keyboard_arrow_down_outlined),
            SizedBox(height: 20),
            squashLinkField(),
          ],
        ),
      ),
    );
  }

  Widget inputLinkField() {
    return TextField(
      controller: _textController,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.arrow_forward_ios_outlined),
        suffixIcon: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            setState(() {
              showMenu = !showMenu;
            });
          },
        ),
        hintText: AppLocalizations.of(context)?.txt_search_hint,
      ),
      textInputAction: TextInputAction.go,
      onSubmitted: squashLink,
    );
  }

  Widget optionFields() {
    if (!showMenu) return Container();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 60),
      child: Column(
        children: [
          TextField(
            controller: _passwordController,
            maxLength: 32,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.lock),
              hintText: AppLocalizations.of(context)?.txt_password,
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget squashLinkField() {
    return Opacity(
      opacity: _squashedLink == null ? 0.0 : 1.0,
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.copy),
              onPressed: _squashedLink == null ? null : copyLink,
            ),
            SizedBox(width: 10),
            Text(
              _squashedLink ?? '',
              style: DefaultTextStyle.of(context).style.apply(fontSizeFactor: 2.0),
            ),
          ],
        ),
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

class SquashList extends StatefulWidget {
  final double maxWidth;
  const SquashList({Key? key, this.maxWidth=600});

  @override
  State<SquashList> createState() => _SquashListState();
}

class _SquashListState extends State<SquashList> {
  final _textController = TextEditingController();
  late Widget _content = CircularProgressIndicator();

  @override
  void initState() {
    super.initState();
    loadContent();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: widget.maxWidth),
      child: _content,
    );
  }

  void loadContent() async {
    final endpoint = Uri.parse('/api/squash');
    final headers = {"Authorization": "${_textController.text}"};
    final response = await http.get(endpoint, headers: headers);

    setState(() {
      switch (response.statusCode) {
        case 200:
          _content = ListView(
            children: (jsonDecode(response.body) as List<dynamic>).map((item) {
              return ListTile(
                title: Row(
                  children: <Widget>[
                    InkWell(
                      child: Text("${item['hashed']}"),
                      onTap: () {
                        html.window.location.href = '/${item['hashed']}';
                      },
                    ),
                    Icon(Icons.arrow_back_outlined),
                    Text("${item['source']}", overflow: TextOverflow.ellipsis),
                  ],
                ),
                subtitle: Text("${item['ip']}"),
                trailing: Container(
                  padding: EdgeInsets.only(top: 20),
                  child: Text("${item['created_at']}"),
                ),
              );
            }).toList(),
          );
          break;
        case 401:
          _content = buildSignin(AppLocalizations.of(context)!.txt_unauthorized);
          break;
        case 403:
          _content = buildSignin(AppLocalizations.of(context)!.txt_forbidden);
          break;
        case 429:
          _content = Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(AppLocalizations.of(context)!.txt_too_many_requests, style: TextStyle(fontSize: 32, color: Colors.red)),
                SizedBox(height: 20),
                Text(AppLocalizations.of(context)!.txt_try_again_later),
              ],
            ),
          );
          break;
        default:
          _content = buildSignin(AppLocalizations.of(context)!.txt_unknown_error);
          break;
      }
    });
  }

  Widget buildSignin(String text) {
    return Container(
      constraints: BoxConstraints(maxWidth: widget.maxWidth),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(text, style: TextStyle(fontSize: 32, color: Colors.red)),
          SizedBox(height: 20),
          TextField(
            controller: _textController,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.key_sharp),
              hintText: AppLocalizations.of(context)?.txt_password,
            ),
            onSubmitted: (String password) => loadContent(),
            obscureText: true,
            autocorrect: false,
            enableSuggestions: false,
          ),
        ],
      ),
    );
  }
}

class PasswordPage extends StatelessWidget {
  final String? code;
  final double maxWidth;

  const PasswordPage({Key? key, required this.code, this.maxWidth=600}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(AppLocalizations.of(context)!.txt_need_password(code!)),
            TextField(
              maxLength: 32,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.lock),
                hintText: AppLocalizations.of(context)?.txt_password,
              ),
              onSubmitted: (password) {
                html.window.location.href = '/${code}?password=${password}';
              },
            ),
          ],
        ),
      ),
    );
  }
}

// vim: set ts=2 sw=2 expandtab:
