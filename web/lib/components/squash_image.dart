import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'squash_base.dart';
import 'squash_file.dart';

class SquashImage extends StatefulWidget {
  const SquashImage({super.key});

  @override
  State<SquashImage> createState() => _SquashImageState();
}

class _SquashImageState extends State<SquashImage> {
  final TextEditingController _controller = TextEditingController();

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
    if (_controller.text.isEmpty) {
      return SquashFile(
        text: AppLocalizations.of(context)!.txt_select_or_drop_image,
        mime: const ['image/*'],
        controller: _controller,
        onLoaded: () {
          setState(() {});
        },
      );
    }

    final Image image = Image.network(_controller.text);
    return SquashBase(
      passwordController: _passwordController,
      hintController: _hintController,
      expiredController: _expiredController,
      child: Container(
        constraints: const BoxConstraints(maxHeight: 160),
        child: image,
      ),
    );
  }
}

// vim: set ts=2 sw=2 expandtab:
