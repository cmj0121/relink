import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'icons.dart';
import 'squash_base.dart';

class SquashLink extends StatefulWidget {
  const SquashLink({super.key});

  @override
  State<SquashLink> createState() => _SquashLinkState();
}

class _SquashLinkState extends State<SquashLink> {
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
    return TextField(
      controller: _controller,
      onSubmitted: (value) => squash(),
      textInputAction: TextInputAction.go,
      decoration: InputDecoration(
        hintText: AppLocalizations.of(context)?.txt_search_hint,
        suffixIcon: IconButton(
          icon: Icon(RecordIcon.link.icon),
          onPressed: () => squash(),
        ),
      ),
    );
  }

  void squash() {
  }
}

// vim: set ts=2 sw=2 expandtab:
