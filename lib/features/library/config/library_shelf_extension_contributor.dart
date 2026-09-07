import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:flutter/material.dart';

/// A kind-owned contribution to the mixed Collection shelf.
///
/// The Collection feature owns the row lifecycle and the extension slot. The
/// contributor owns any kind-specific hierarchy, hydration, and presentation.
abstract interface class LibraryShelfExtensionContributor {
  CatalogMediaKind get kind;

  Widget? build(
    ShelfEntry entry, {
    required bool expanded,
    required VoidCallback onToggle,
  });
}
