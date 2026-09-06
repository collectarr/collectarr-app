import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/add/library_add_dialog.dart';
import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';
import 'package:collectarr_app/features/library/edit/library_edit_launcher.dart';
import 'package:collectarr_app/features/library/edit/library_edit_scope.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_registration.dart';
import 'package:collectarr_app/features/library/workspace/layout/library_layout_snapshot.dart';
import 'package:collectarr_app/features/library/config/library_kind_identity.dart';
import 'package:flutter/material.dart';

typedef LibraryKindPageBuilder = Widget Function({
  required LibraryKindModule type,
  required Widget topBar,
  required Color accent,
  required Uri routeUri,
  LibraryLayoutSnapshot? switchLayoutSnapshot,
});

/// Structural adapter shared by generated kind registrations.
///
/// The generated source supplies each concrete page constructor and module.
/// This adapter owns only the navigation lifecycle that is identical for all
/// kinds; it does not expose kind semantics to generic callers.
final class LibraryKindRegistrationAdapter implements LibraryKindRegistration {
  const LibraryKindRegistrationAdapter({
    required this.kind,
    required this.module,
    required this.pageBuilder,
  });

  @override
  final CatalogMediaKind kind;
  final LibraryKindModule module;
  final LibraryKindPageBuilder pageBuilder;

  @override
  LibraryKindIdentity get identity => module.identity;

  @override
  Widget buildLibraryPage({
    required Widget topBar,
    required Color accent,
    required Uri routeUri,
    LibraryLayoutSnapshot? switchLayoutSnapshot,
  }) {
    return pageBuilder(
      type: module,
      topBar: topBar,
      accent: accent,
      routeUri: routeUri,
      switchLayoutSnapshot: switchLayoutSnapshot,
    );
  }

  @override
  Widget buildAdd({
    required BuildContext context,
    required LibraryAddDialogRequest request,
  }) {
    return LibraryAddDialog(
      type: module,
      accent: request.accent,
      initialQuery: request.initialQuery,
      initialBarcode: request.initialBarcode,
    );
  }

  @override
  Future<LibraryEditSelection?> openMediaEdit({
    required BuildContext context,
    required LibraryEditDialogRequest request,
  }) {
    return _openEdit(
      context: context,
      request: request,
      scope: LibraryEditScope.media,
    );
  }

  @override
  Future<LibraryEditSelection?> openReleaseEdit({
    required BuildContext context,
    required LibraryEditDialogRequest request,
  }) {
    return _openEdit(
      context: context,
      request: request,
      scope: LibraryEditScope.release,
    );
  }

  @override
  Future<LibraryEditSelection?> openOwnedEdit({
    required BuildContext context,
    required LibraryEditDialogRequest request,
  }) {
    return _openEdit(
      context: context,
      request: request,
      scope: LibraryEditScope.all,
    );
  }

  Future<LibraryEditSelection?> _openEdit({
    required BuildContext context,
    required LibraryEditDialogRequest request,
    required LibraryEditScope scope,
  }) {
    return showLibraryEditDialog(
      context: context,
      request: request.copyWith(scope: scope),
    );
  }
}
