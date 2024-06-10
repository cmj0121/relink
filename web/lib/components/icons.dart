import 'package:flutter/material.dart';

enum RecordIcon {
  home,
  adminPanel,
  lock,
  menu,
  copy,
  hint,
  link,
  text,
  image,
  video,
  timer,
  unknown,
  password,
  settings,
  workInProgress,
}

extension RecordIconExtension on RecordIcon {
  static final values = {
    RecordIcon.home: Icons.home,
    RecordIcon.adminPanel: Icons.admin_panel_settings,
    RecordIcon.lock: Icons.lock,
    RecordIcon.menu: Icons.menu,
    RecordIcon.copy: Icons.copy,
    RecordIcon.hint: Icons.help_outline,
    RecordIcon.link: Icons.keyboard_double_arrow_right_rounded,
    RecordIcon.text: Icons.article_outlined,
    RecordIcon.image: Icons.image_outlined,
    RecordIcon.video: Icons.video_collection_outlined,
    RecordIcon.timer: Icons.timer,
    RecordIcon.unknown: Icons.error_outline,
    RecordIcon.password: Icons.key_sharp,
    RecordIcon.settings: Icons.settings,
    RecordIcon.workInProgress: Icons.build_sharp,
  };

  IconData get icon => values[this]!;
}

// vim: set ts=2 sw=2 expandtab:
