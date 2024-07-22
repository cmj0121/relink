import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import 'squash_base.dart';
import 'squash_file.dart';
import 'defines.dart';


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
  final FileController _fileController = FileController();
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _hintController = TextEditingController();
  final TextEditingController _expiredController = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    _fileController.dispose();
    _passwordController.dispose();
    _hintController.dispose();
    _expiredController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_fileController.link == null) {
      return SquashFile(
        text: AppLocalizations.of(context)!.txt_select_or_drop_image,
        mime: const ['image/*'],
        controller: _fileController,
        onLoaded: () {
          setState(() {});
        },
      );
    }

    return SquashBase(
      controller: _controller,
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
          child: Center(child: ImageEditor(_fileController.link!)),
        ),
        IconButton(
          icon: const Icon(Icons.send),
          onPressed: () => squash(),
        ),
      ],
    );
  }

  void squash() async {
    final endpoint = Uri.parse('$basehref/api/squash');
    var request = http.MultipartRequest('POST', endpoint);

    // setup the JSON payload
    request.fields['type'] = 'image';
    request.fields['password'] = _passwordController.text;
    request.fields['pwd_hint'] = _hintController.text;
    request.fields['expired_hours'] = expiredHours()?.toString() ?? '';

    // setup the image file
    final image = http.MultipartFile.fromBytes(
      'image',
      _fileController.bytes!,
      filename: _fileController.name,
      contentType: MediaType.parse(_fileController.mime!),
    );
    request.files.add(image);

    final streamResposne = await request.send();
    final response = await http.Response.fromStream(streamResposne);
    setState(() {
      switch (response.statusCode) {
        case 201:
          _controller.text = jsonDecode(response.body) as String;
          break;
        case 400:
          _controller.text = '';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.txt_invalid_request),
            ),
          );
          break;
        default:
          _controller.text = '';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.txt_unknown_error),
            ),
          );
          break;
      }
    });
  }

  int? expiredHours() {
    final text = _expiredController.text;
    return text.isEmpty ? null : int.tryParse(text);
  }
}

// vim: set ts=2 sw=2 expandtab:
