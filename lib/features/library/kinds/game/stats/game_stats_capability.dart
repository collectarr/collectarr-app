import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/library_stats_capability.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:flutter/material.dart';

class GameStatsCapability implements LibraryStatsCapability {
  const GameStatsCapability();

  @override
  List<LibraryStatsTileDescriptor> buildSummaryTiles(
    ShelfState state,
    LibraryTypeConfig type,
  ) {
    return [
      if (state.keyComicCount > 0)
        LibraryStatsTileDescriptor(
          icon: Icons.label_important,
          label: 'Key items',
          value: state.keyComicCount.toString(),
        ),
    ];
  }

  @override
  List<Widget> buildCustomCards(
    BuildContext context,
    ShelfState state,
    LibraryTypeConfig type,
  ) =>
      const [];
}
