import 'package:collectarr_app/features/library/edit/edit_dialog_widgets.dart';
import 'package:flutter/material.dart';

class BookSectionTab extends StatelessWidget {
  const BookSectionTab({
    super.key,
    required this.sections,
    required this.sectionBuilder,
    this.cover,
    this.header = const <Widget>[],
  });

  final List<String> sections;
  final Widget Function(String sectionId) sectionBuilder;
  final Widget? cover;
  final List<Widget> header;

  @override
  Widget build(BuildContext context) {
    return EditTabShell(
      cover: cover,
      children: [
        ...header,
        for (final sectionId in sections) sectionBuilder(sectionId),
      ],
    );
  }
}
