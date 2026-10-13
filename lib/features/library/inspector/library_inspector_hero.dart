import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_capability_types.dart';
import 'package:collectarr_app/features/library/detail/library_detail_hero.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:flutter/material.dart';

class InspectorHero extends StatelessWidget {
  const InspectorHero({
    super.key,
    required this.type,
    required this.item,
    required this.libraryEntry,
    required this.accent,
    this.contextLabel,
  });

  final LibraryKindRegistration type;
  final LibraryProjectionView item;
  final LibraryEntrySummary? libraryEntry;
  final Color accent;
  final String? contextLabel;

  @override
  Widget build(BuildContext context) {
    return LibraryDetailHero(
      type: type,
      item: item,
      libraryEntry: libraryEntry,
      accent: accent,
    );
  }
}
