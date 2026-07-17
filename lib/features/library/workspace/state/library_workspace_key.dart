import 'package:collectarr_app/core/models/catalog_media_kind.dart';

class LibraryWorkspaceKey {
  const LibraryWorkspaceKey({
    required this.kind,
    this.collectionId,
    this.scopeId,
    this.presentationLevelId,
  });

  final CatalogMediaKind kind;
  final String? collectionId;
  final String? scopeId;
  final String? presentationLevelId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LibraryWorkspaceKey &&
          runtimeType == other.runtimeType &&
          kind == other.kind &&
          collectionId == other.collectionId &&
          scopeId == other.scopeId &&
          presentationLevelId == other.presentationLevelId;

  @override
  int get hashCode =>
      kind.hashCode ^
      collectionId.hashCode ^
      scopeId.hashCode ^
      presentationLevelId.hashCode;

  @override
  String toString() {
    return 'LibraryWorkspaceKey(kind: $kind, collectionId: $collectionId, scopeId: $scopeId, presentationLevelId: $presentationLevelId)';
  }
}
