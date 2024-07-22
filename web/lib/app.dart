import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'page.dart';
import '../components/icons.dart';

enum Routes {
  pageIndex,
  pageAdminList,
  pageExpired,
  pageStatistics,
}

void routeTo(Routes route, BuildContext context) {
  switch (route) {
    case Routes.pageIndex:
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      break;
    case Routes.pageAdminList:
      Navigator.of(context).pushNamedAndRemoveUntil('/_admin/list', (route) => false);
      break;
    case Routes.pageExpired:
      Navigator.of(context).pushNamedAndRemoveUntil('/expired', (route) => false);
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
            child = const Squash();
            break;
          case '/_admin/list':
            child = const AdminPage();
            break;
          case '/expired':
            child = const ExpiredPage();
            break;
          default:
            final matchPassword = RegExp(r'^/need-password-(\w+)');
            final matchStatistics = RegExp(r'^/statistics-(\w+)');

            if (matchPassword.hasMatch(name)) {
              final code = matchPassword.firstMatch(name)!.group(1);
              child = PasswordPage(code);
            } else if (matchStatistics.hasMatch(name)) {
              final code = matchStatistics.firstMatch(name)!.group(1);
              child = StatisticsPage(code!);
            } else {
              Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
              child = Container();
            }
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
    const double width = 640.0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFCFCFE9),
        title: Text(widget.title),
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0),
          child: Container(
            color: Colors.black,
            height: 2,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(16),
            constraints: const BoxConstraints(maxWidth: width),
            child: widget.child,
          ),
        ),
      ),
      bottomSheet: footer(),
    );
  }

  Widget footer() {
    return Container(
      color: Colors.transparent,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('Copyright cmj <cmj@cmj.tw>', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

// vim: set ts=2 sw=2 expandtab:
