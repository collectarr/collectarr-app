import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/library_kind_identity.dart';
import 'package:collectarr_app/features/library/workspace/layout/library_layout_snapshot.dart';
import 'package:flutter/material.dart';

/// The intentionally small composition boundary for one concrete kind.
///
/// Feature registries own Add, Edit, Owned, tracking, provider and other
/// semantic contributors. Registration only identifies a kind and builds its
/// library page.
abstract interface class LibraryKindRegistration {
  CatalogMediaKind get kind;
  LibraryKindIdentity get identity;

  Widget buildLibraryPage({
    required Widget topBar,
    required Color accent,
    required Uri routeUri,
    LibraryLayoutSnapshot? switchLayoutSnapshot,
  });
}
