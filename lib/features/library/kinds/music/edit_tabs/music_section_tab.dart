import 'package:collectarr_app/features/library/edit/edit_dialog_widgets.dart';
import 'package:flutter/material.dart';

class MusicSectionTab extends StatelessWidget {
  const MusicSectionTab({
    super.key,
    required this.sections,
    required this.sectionBuilder,
    this.cover,
  });

  final List<String> sections;
  final Widget Function(String sectionId) sectionBuilder;
  final Widget? cover;

  @override
  Widget build(BuildContext context) {
    return EditTabShell(
      cover: cover,
      children: [
        for (final sectionId in sections) sectionBuilder(sectionId),
      ],
    );
  }
}
