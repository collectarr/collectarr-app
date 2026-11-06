import 'package:collectarr_app/features/library/workspace/config/view_enums.dart';
import 'package:flutter/material.dart';

/// The library presentations of the native phone app, as in the reference.
/// Desktop's other layouts are never offered here; a layout stored by an
/// earlier version opens as its closest phone presentation.
enum LibraryMobileViewMode {
  list('List', Icons.view_list, LibraryViewMode.list),
  cards('Cards', Icons.view_module, LibraryViewMode.card),
  images('Images', Icons.apps, LibraryViewMode.grid);

  const LibraryMobileViewMode(this.label, this.icon, this.workspaceMode);

  factory LibraryMobileViewMode.from(LibraryViewMode mode) => switch (mode) {
        LibraryViewMode.list => LibraryMobileViewMode.list,
        LibraryViewMode.card ||
        LibraryViewMode.horizontalCards =>
          LibraryMobileViewMode.cards,
        LibraryViewMode.grid ||
        LibraryViewMode.cardFlow ||
        LibraryViewMode.shelves =>
          LibraryMobileViewMode.images,
      };

  final String label;
  final IconData icon;
  final LibraryViewMode workspaceMode;
}
