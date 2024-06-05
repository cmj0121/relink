import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;

import 'components.dart';
import 'icons.dart';
import 'page.dart';

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
  static String title = 'ReLink';
  const ReLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFEFF2F9),
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        final name = settings.name ?? '/';
        final Widget child;

        switch (name) {
          case '/':
            child = const SquashLink();
            break;
          case '/_admin/list':
            child = const AdminPage();
            break;
          default:
            final match = RegExp(r'^/need-password-(\w+)');

            if (!match.hasMatch(name)) {
              Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
            }

            final code = match.firstMatch(name)!.group(1);
            child = PasswordPage(code);
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
  const ReLinkHomePage({super.key, required this.title, required this.child});

  @override
  State<ReLinkHomePage> createState() => _ReLinkHomePageState();
}

class _ReLinkHomePageState extends State<ReLinkHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFCFCFE9),
        actions: <Widget>[
          IconButton(
            icon: Icon(RecordIcon.home.icon),
            onPressed: () { routeTo(Routes.pageIndex, context); },
          ),
          IconButton(
            icon: Icon(RecordIcon.adminPanel.icon),
            onPressed: () { routeTo(Routes.pageAdminList, context); },
          ),
        ],
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: widget.child,
        ),
      ),
    );
  }
}

class SquashLink extends StatefulWidget {
  final double maxWidth;

  const SquashLink({super.key, this.maxWidth=600});

  @override
  State<SquashLink> createState() => _SquashLinkState();
}

class _SquashLinkState extends State<SquashLink> {
  final _textController = TextEditingController();
  final _passwordController = TextEditingController();
  late bool showMenu = false;

  String? _squashedLink;
  String? _squashedType = 'link';

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
            const SizedBox(height: 20),
            optionFields(),
            const Loading(icon: Icons.keyboard_arrow_down_outlined),
            const SizedBox(height: 20),
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
      textInputAction: TextInputAction.go,
      onSubmitted: squashLink,
    );
  }

  Widget squashTypes() {
    return DropdownButton(
      value: _squashedType,
      items: [
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
      ],
      onChanged: (String? value) {
        _squashedType = value;
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
