import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/music/catalog/music_catalog_mapper.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release_group.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release.dart';

/// Converts the transport envelope into Music's concrete release level.
final class MusicWorkspaceMapper {
  const MusicWorkspaceMapper._();

  static MusicRelease fromCatalogItem(
    CatalogItemDto item, {
    String? releaseId,
    CatalogEditionDto? edition,
  }) {
    final group = MusicCatalogMapper.mapMetadataItemToMusic(item);
    final requestedId = releaseId ?? edition?.id;
    final selected = _releaseFor(group, requestedId);
    if (selected != null && edition == null) return selected;

    final base = selected ?? group.primaryRelease;
    final resolvedId = requestedId ?? base?.id.value ?? '${item.id}:release';
    final payload = <String, dynamic>{
      ...(base?.toJson() ?? const <String, dynamic>{}),
      'id': resolvedId,
      'release_group_id': item.id,
      'kind': 'music',
      'title': edition?.title ?? base?.title ?? group.title,
      if (edition?.releaseDate != null)
        'release_date': edition!.releaseDate!.toIso8601String(),
      if (edition?.publisher != null) 'publisher': edition!.publisher,
      if (edition?.upc != null) 'barcode': edition!.upc,
      if (edition?.physicalFormat != null) 'packaging': edition!.physicalFormat,
    };
    return MusicRelease.fromJson(payload);
  }

  static MusicRelease? _releaseFor(
    MusicReleaseGroup group,
    String? requestedId,
  ) {
    if (group.releases.isEmpty) return null;
    if (requestedId == null) return group.releases.first;
    for (final release in group.releases) {
      if (release.id.value == requestedId) return release;
    }
    return null;
  }
}
