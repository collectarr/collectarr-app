import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_browser_scope.dart';

sealed class LibraryNodeRef {
  const LibraryNodeRef();

  String get id;
  String get titleItemId;
  LibraryBrowserScope get scope;
}

final class LibraryTitleNodeRef extends LibraryNodeRef {
  const LibraryTitleNodeRef({
    required this.titleItemId,
  });

  @override
  final String titleItemId;

  @override
  String get id => titleItemId;

  @override
  LibraryBrowserScope get scope => LibraryBrowserScope.title;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LibraryTitleNodeRef && other.titleItemId == titleItemId;
  }

  @override
  int get hashCode => titleItemId.hashCode;
}

final class LibraryReleaseNodeRef extends LibraryNodeRef {
  const LibraryReleaseNodeRef({
    required this.titleItemId,
    required this.releaseId,
    required this.edition,
  });

  @override
  final String titleItemId;

  final String releaseId;
  final CatalogEdition edition;

  @override
  String get id => '$titleItemId:release:$releaseId';

  @override
  LibraryBrowserScope get scope => LibraryBrowserScope.release;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LibraryReleaseNodeRef &&
        other.titleItemId == titleItemId &&
        other.releaseId == releaseId;
  }

  @override
  int get hashCode => Object.hash(titleItemId, releaseId);
}

final class LibraryCopyNodeRef extends LibraryNodeRef {
  const LibraryCopyNodeRef({
    required this.titleItemId,
    required this.ownedItemId,
    this.copyId,
  });

  @override
  final String titleItemId;

  final String ownedItemId;
  final String? copyId;

  @override
  String get id => copyId ?? ownedItemId;

  @override
  LibraryBrowserScope get scope => LibraryBrowserScope.copy;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LibraryCopyNodeRef &&
        other.titleItemId == titleItemId &&
        other.ownedItemId == ownedItemId &&
        other.copyId == copyId;
  }

  @override
  int get hashCode => Object.hash(titleItemId, ownedItemId, copyId);
}
