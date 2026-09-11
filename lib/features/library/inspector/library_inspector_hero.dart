import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/detail/library_detail_hero.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:flutter/material.dart';

class InspectorHero extends StatelessWidget {
  const InspectorHero({
    super.key,
    required this.type,
    required this.item,
    required this.ownedItem,
    required this.accent,
    this.contextLabel,
  });

  final LibraryKindRegistration type;
  final LibraryProjectionView item;
  final OwnedItemSummary? ownedItem;
  final Color accent;
  final String? contextLabel;

  @override
  Widget build(BuildContext context) {
    return LibraryDetailHero(
      type: type,
      item: item,
      ownedItem: ownedItem,
      accent: accent,
    );
  }
}
