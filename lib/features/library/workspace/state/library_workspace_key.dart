import 'package:collectarr_app/core/models/catalog_media_kind.dart';

class LibraryWorkspaceKey {
  const LibraryWorkspaceKey({
    required this.kind,
    this.collectionId,
  });

  final CatalogMediaKind kind;
  final String? collectionId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LibraryWorkspaceKey &&
          runtimeType == other.runtimeType &&
          kind == other.kind &&
          collectionId == other.collectionId;

  @override
  int get hashCode => kind.hashCode ^ collectionId.hashCode;

  @override
  String toString() {
    return 'LibraryWorkspaceKey(kind: $kind, collectionId: $collectionId)';
  }
}
