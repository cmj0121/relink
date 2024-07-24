import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

import 'icons.dart';
import 'loading.dart';
import 'password.dart';
import 'time_picker.dart';

class SquashBase extends StatefulWidget {
  final Widget child;
  final TextEditingController? controller;
  final TextEditingController? passwordController;
  final TextEditingController? hintController;
  final TextEditingController? expiredController;

  const SquashBase({super.key, required this.child, this.controller, this.passwordController, this.hintController, this.expiredController});

  @override
  State<SquashBase> createState() => _SquashBaseState();
}

class _SquashBaseState extends State<SquashBase> {
  late bool _showMenu;
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _showMenu = false;
    _controller = widget.controller ?? TextEditingController();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        widget.child,
        Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: Icon(RecordIcon.menu.icon),
                onPressed: () => setState(() => _showMenu = !_showMenu),
              ),
              const SizedBox(width: 10),
              Flexible(child: optionFields()),
            ],
          ),
        const SizedBox(height: 10),
        const Loading(icon: Icons.keyboard_arrow_down_outlined),
        const SizedBox(height: 10),
        Flexible(child: squashLinkField()),
      ],
    );
  }

  Widget optionFields() {
    return Opacity(
      opacity: !_showMenu ? 0.0 : 1.0,
      child: Column(
        children: [
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              if (constraints.maxWidth < 400) {
                return const Column(
                  children: [
                    Password(),
                    SizedBox(height: 10),
                    TimePicker(),
                  ],
                );
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(flex: 2, child: Password(textController: widget.passwordController, hintController: widget.hintController)),
                  const SizedBox(width: 20),
                  Flexible(flex: 1, child: TimePicker(controller: widget.expiredController)),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget squashLinkField() {
    final String link = _controller.text;

    return Opacity(
      opacity: link.isEmpty ? 0.0 : 1.0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(child: squashedLink(link)),
          Expanded(child: squashedQRCode(link)),
        ]
      ),
    );
  }

  Widget squashedLink(String link) {
    final style = DefaultTextStyle.of(context).style.apply(fontSizeFactor: 2.0);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        IconButton(
          icon: Icon(RecordIcon.copy.icon),
          onPressed: copyLink,
        ),
        const SizedBox(width: 10),
        Text(link, style: style),
      ],
    );
  }

  Widget squashedQRCode(String link) {
    return InkWell(
      child: buildQRCode(link),
      onTap: () => floatImage(link),
    );
  }

  Future<void> floatImage(String link) {
    final double size = MediaQuery.of(context).size.width * 0.8;

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SizedBox(
            width: size,
            height: size,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(link),
                  const SizedBox(height: 10),
                  Flexible(child: buildQRCode(link)),
                ],
              ),
            )
          ),
        );
      }
    );
  }

  Widget buildQRCode(String link) {
    final qrCode = QrCode(
      8,
      QrErrorCorrectLevel.H,
    )..addData(link);

    return PrettyQrView(
      qrImage: QrImage(qrCode),
      decoration: const PrettyQrDecoration(
        image: PrettyQrDecorationImage(
          image: AssetImage('assets/images/logo.png'),
          position: PrettyQrDecorationImagePosition.embedded,
        ),
      ),
    );
  }

  void copyLink() {
    final String squashedLink = _controller.text;

    Clipboard.setData(ClipboardData(text: squashedLink));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.txt_copied_to_clipboard(squashedLink)),
      ),
    );
  }
}

// vim: set ts=2 sw=2 expandtab:
