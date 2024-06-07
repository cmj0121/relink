import 'package:flutter/material.dart';

import 'squash_base.dart';

class SquashText extends StatefulWidget {
  const SquashText({super.key});

  @override
  State<SquashText> createState() => _SquashTextState();
}

class _SquashTextState extends State<SquashText> {
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
        Flexible(child: textField()),
        IconButton(
          icon: const Icon(Icons.send),
          onPressed: () => squash(),
        ),
      ],
    );
  }

  Widget textField() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 160),
      child: TextField(
        controller: _controller,
        minLines: 5,
        maxLines: null,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
        ),
        onSubmitted: (value) => squash(),
      ),
    );
  }

  void squash() {
  }
}

// vim: set ts=2 sw=2 expandtab:
