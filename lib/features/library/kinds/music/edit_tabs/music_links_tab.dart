import 'package:collectarr_app/features/library/edit/edit_dialog_widgets.dart';
import 'package:flutter/material.dart';

class MusicLinksTab extends StatelessWidget {
  const MusicLinksTab({
    super.key,
    required this.sections,
    required this.sectionBuilder,
  });

  final List<String> sections;
  final Widget Function(String sectionId) sectionBuilder;

  @override
  Widget build(BuildContext context) {
    return EditTabShell(
      children: [
        for (final sectionId in sections) sectionBuilder(sectionId),
      ],
    );
  }
}
