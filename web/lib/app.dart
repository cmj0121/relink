import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

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

  bool _error = false;
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
        hintText: 'Enter a URL',
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: _error ? Colors.red : Colors.grey),
        ),
      ),
      textInputAction: TextInputAction.go,
      onSubmitted: squashLink,
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
        content: Text('Copied to clipboard: $_squashedLink'),
      ),
    );
  }

  void squashLink(String url) async {
    final endpoint = Uri.parse('/api/squash?src=$url');
    final response = await http.post(endpoint);

    setState(() {
      switch (response.statusCode) {
        case 201:
          _error = false;
          _squashedLink = jsonDecode(response.body) as String;
          break;
        default:
          _error = true;
          _squashedLink = null;
          break;
      }
    });
  }
}

class Loading extends StatefulWidget {
  final int size;
  final duration;
  final IconData icon;

  Loading({Key? key, required this.icon, this.size = 5, this.duration = const Duration(seconds: 1)}) : super(key: key);

  @override
  State<Loading> createState() => _LoadingState();
}

class _LoadingState extends State<Loading> with TickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        child: buildAnimation(),
      ),
    );
  }

  Widget buildAnimation() {
    List<Color> colors = [
      Colors.grey.shade100,
      Colors.grey.shade200,
      Colors.grey.shade300,
      Colors.grey.shade400,
      Colors.grey.shade500,
      Colors.grey.shade600,
      Colors.grey.shade700,
      Colors.grey.shade800,
      Colors.grey.shade900,
    ];
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        int index = (_controller.value * 10).toInt();

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List<Widget>.generate(widget.size, (i) {
            return Icon(
              widget.icon,
              color: colors[(index - i) % colors.length],
            );
          }),
        );
      },
    );
  }
}

// vim: set ts=2 sw=2 expandtab:
