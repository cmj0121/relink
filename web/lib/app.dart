import 'package:flutter/material.dart';

class ReLinkApp extends StatelessWidget {
  static String title = 'ReLink';
  const ReLinkApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      home: ReLinkHomePage(title: title),
    );
  }
}

class ReLinkHomePage extends StatefulWidget {
  final String title;
  const ReLinkHomePage({Key? key, required this.title});

  @override
  State<ReLinkHomePage> createState() => _ReLinkHomePageState();
}

class _ReLinkHomePageState extends State<ReLinkHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(
        child: SquashLink(),
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

  String? _errorText;

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
          ],
        ),
      ),
    );
  }

  Widget inputLinkField() {
    return TextField(
      controller: _textController,
      decoration: InputDecoration(
        labelText: 'Enter a URL',
        errorText: _errorText,
      ),
      textInputAction: TextInputAction.go,
      onSubmitted: squashLink,
    );
  }

  void squashLink(String url) {
    final target = Uri.parse(url);

    setState(() {
      _errorText = null;

      if (target.scheme.isEmpty || target.host.isEmpty) {
        _errorText = 'You must enter a valid URL';
      }
    });
  }
}


// vim: set ts=2 sw=2 expandtab:
