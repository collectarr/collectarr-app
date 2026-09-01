import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
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
    LibraryKindRuntime type,
  );

  List<Widget> buildCustomCards(
    BuildContext context,
    ShelfState state,
    LibraryKindRuntime type,
  );
}

class DefaultLibraryStatsCapability implements LibraryStatsCapability {
  const DefaultLibraryStatsCapability();

  @override
  List<LibraryStatsTileDescriptor> buildSummaryTiles(
    ShelfState state,
    LibraryKindRuntime type,
  ) =>
      const [];

  @override
  List<Widget> buildCustomCards(
    BuildContext context,
    ShelfState state,
    LibraryKindRuntime type,
  ) =>
      const [];
}
