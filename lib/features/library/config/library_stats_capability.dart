import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:flutter/material.dart';

class LibraryStatsTileDescriptor {
  const LibraryStatsTileDescriptor({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}

abstract interface class LibraryStatsCapability {
  List<LibraryStatsTileDescriptor> buildSummaryTiles(
    ShelfState state,
    LibraryTypeConfig type,
  );

  List<Widget> buildCustomCards(
    BuildContext context,
    ShelfState state,
    LibraryTypeConfig type,
  );
}

class DefaultLibraryStatsCapability implements LibraryStatsCapability {
  const DefaultLibraryStatsCapability();

  @override
  List<LibraryStatsTileDescriptor> buildSummaryTiles(
    ShelfState state,
    LibraryTypeConfig type,
  ) =>
      const [];

  @override
  List<Widget> buildCustomCards(
    BuildContext context,
    ShelfState state,
    LibraryTypeConfig type,
  ) =>
      const [];
}
