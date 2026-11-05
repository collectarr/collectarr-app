import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';

/// A complete snapshot of the selected targets, never a supported subset.
class LibrarySelectionContext {
  LibrarySelectionContext(Iterable<LibraryWorkspaceContext> entries,
      {this.complete = true})
      : entries = List.unmodifiable(entries);
  final List<LibraryWorkspaceContext> entries;
  final bool complete;
  bool every(bool Function(LibraryWorkspaceContext) accepts) =>
      complete && entries.isNotEmpty && entries.every(accepts);
  CatalogMediaKind? get homogeneousKind =>
      every((entry) => entry.mediaKind == entries.first.mediaKind)
          ? entries.first.mediaKind
          : null;
  void requireEvery(
      String action, bool Function(LibraryWorkspaceContext) accepts) {
    if (!every(accepts)) {
      throw StateError(
          '$action is unavailable for this selection. Select compatible items and try again.');
    }
  }
}
