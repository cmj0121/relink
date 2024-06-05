import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
            child = const SquashPage();
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
    final double width = 640.0;

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
          child: Container(
            constraints: BoxConstraints(maxWidth: width),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

// vim: set ts=2 sw=2 expandtab:
