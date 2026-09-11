import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/config/library_kind_identity.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';
import 'package:collectarr_app/features/library/workspace/layout/library_layout_snapshot.dart';
import 'package:flutter/material.dart';

/// Identity boundary for one concrete kind.
///
/// This is intentionally smaller than the navigation boundary. Generic
/// capability registries can use it without gaining access to widget
/// construction or edit dialogs.
abstract interface class LibraryKindRegistration {
  CatalogMediaKind get kind;
  LibraryKindIdentity get identity;
}

/// Navigation boundary for a concrete kind registration.
///
/// Only concrete kind registrations implement this interface. The public
/// registry exposes [LibraryKindRegistration] for structural dispatch; page
/// routing opts into this narrower contract explicitly.
abstract interface class LibraryKindNavigationRegistration
    implements LibraryKindRegistration {
  Widget buildLibraryPage({
    required Widget topBar,
    required Color accent,
    required Uri routeUri,
    LibraryLayoutSnapshot? switchLayoutSnapshot,
  });

  Widget buildAdd({
    required BuildContext context,
    required LibraryAddDialogRequest request,
  });

  Future<LibraryEditSelection?> openMediaEdit({
    required BuildContext context,
    required LibraryEditDialogRequest request,
  });

  Future<LibraryEditSelection?> openReleaseEdit({
    required BuildContext context,
    required LibraryEditDialogRequest request,
  });

  Future<LibraryEditSelection?> openOwnedEdit({
    required BuildContext context,
    required LibraryEditDialogRequest request,
  });
}
