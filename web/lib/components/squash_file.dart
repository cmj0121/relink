import 'package:flutter/material.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:web/web.dart' as web;

import 'squash_base.dart';

class SquashFile extends StatefulWidget {
  final String text;
  final List<String>? mime;
  final TextEditingController? controller;
  final VoidCallback? onLoaded;

  const SquashFile({super.key, required this.text, this.mime, this.controller, this.onLoaded});

  @override
  State<SquashFile> createState() => _SquashFileState();
}

class _SquashFileState extends State<SquashFile> {
  late final DropzoneViewController _controller;

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _hintController = TextEditingController();
  final TextEditingController _expiredController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _hintController.dispose();
    _expiredController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SquashBase(
      passwordController: _passwordController,
      hintController: _hintController,
      expiredController: _expiredController,
      child: buildContent(),
    );
  }

  Widget buildContent() {
    return ClipRRect(
      child: buildZone(),
    );
  }

  Widget buildZone() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 160),
      child: Stack(
        children: [
          dropZone(),
          Center(
            child: InkWell(
              child: Text(widget.text, style: const TextStyle(fontSize: 24)),
              onTap: () async {
                final files = await _controller.pickFiles(multiple: false, mime: widget.mime ?? const []);
                final file = files.first;
                final link = await _controller.createFileUrl(file);

                widget.controller?.text = link;
                widget.onLoaded?.call();
              }
            ),
          ),
        ],
      ),
    );
  }

  Widget dropZone() {
    return DropzoneView(
      onCreated: (ctrl) => _controller = ctrl,
      onDrop: (dynamic ev) async{
        if (ev is web.File) {
          final file = ev;
          final link = await _controller.createFileUrl(file);

          widget.controller?.text = link;
          widget.onLoaded?.call();
        }
      }
    );
  }
}

// vim: set ts=2 sw=2 expandtab:
