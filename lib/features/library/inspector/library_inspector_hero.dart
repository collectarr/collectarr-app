import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/detail/library_detail_hero.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
import 'package:flutter/material.dart';

class InspectorHero extends StatelessWidget {
  const InspectorHero({
    super.key,
    required this.type,
    required this.entry,
    required this.ownedItem,
    required this.accent,
    this.contextLabel,
  });

  final LibraryTypeConfig type;
  final LibraryWorkspaceEntry entry;
  final OwnedItem? ownedItem;
  final Color accent;
  final String? contextLabel;

  @override
  Widget build(BuildContext context) {
    return LibraryDetailHero(
      type: type,
      entry: entry,
      ownedItem: ownedItem,
      accent: accent,
    );
  }
}
