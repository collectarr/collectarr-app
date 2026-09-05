import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';
import 'package:collectarr_app/features/library/workspace/layout/library_layout_snapshot.dart';
import 'package:collectarr_app/features/library/config/library_kind_identity.dart';
import 'package:flutter/material.dart';

abstract interface class LibraryKindRegistration {
  CatalogMediaKind get kind;
  LibraryKindIdentity get identity;

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
}
