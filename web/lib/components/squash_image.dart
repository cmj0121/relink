import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'squash_base.dart';
import 'squash_file.dart';


class ImageEditor extends StatefulWidget {
  final String link;
  final double size;

  const ImageEditor(this.link, {super.key, this.size = 160.0});

  @override
  State<ImageEditor> createState() => _ImageEditor();
}

class _ImageEditor extends State<ImageEditor> {
  late final Image image;

  @override
  void initState() {
    super.initState();

    image = Image.network(widget.link);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: widget.size, maxHeight: widget.size),
      child: InkWell(
        child: image,
        onTap: () => floatImage(context),
      ),
    );
  }

  Future<void> floatImage(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: image,
          actions: [
            TextButton(
              child: Text(AppLocalizations.of(context)!.btn_cancel),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(AppLocalizations.of(context)!.btn_confirm),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ]
        );
      }
    );
  }
}

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

    return SquashBase(
      passwordController: _passwordController,
      hintController: _hintController,
      expiredController: _expiredController,
      child: buildContent(),
    );
  }

  Widget buildContent() {
    return Row(
      children: [
        Flexible(
          child: Center(child: ImageEditor(_controller.text)),
        ),
        IconButton(
          icon: const Icon(Icons.send),
          onPressed: () => squash(),
        ),
      ],
    );
  }

  void squash() {
  }
}

// vim: set ts=2 sw=2 expandtab:
