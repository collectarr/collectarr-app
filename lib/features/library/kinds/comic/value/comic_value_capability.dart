import 'package:collectarr_app/features/library/config/library_value_capability.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_metadata.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_workspace_dto.dart';

class ComicValueCapability implements LibraryValueCapability {
  const ComicValueCapability();

  @override
  int? resolveProviderValueCents(LibraryProjectionRuntime item) {
    if (item.dto case ComicWorkspaceDto dto) {
      return dto.metadata?.publishing?.coverPriceCents ??
          dto.comic.publishing.coverPriceCents;
    }
    final meta = item.source.catalogItem?.kindMetadata;
    if (meta is ComicCatalogMetadata) {
      return meta.publishing?.coverPriceCents;
    }
    final payload = meta?.toSyncPayload();
    final publishing = payload?['publishing'] as Map?;
    return (publishing?['cover_price_cents'] as num?)?.toInt();
  }
}
