import 'package:collectarr_app/features/library/kinds/game/domain/game_metadata.dart';
import 'package:collectarr_app/features/library/kinds/game/forms/catalog_form_values.dart';
import 'package:collectarr_app/features/library/kinds/game/vocabulary/game_vocabularies.dart';

GameCatalogFormValues gameCatalogFormValuesFromMetadata(
  GameCatalogMetadata metadata,
) {
  return GameCatalogFormValues(
    title: metadata.title,
    sortTitle: metadata.sortKey ?? '',
    platform: metadata.platforms.firstOrNull ?? '',
    releaseDateParts: metadata.releaseDateParts,
    developers: List.of(metadata.developers),
    publishers: splitGamePublishers(metadata.publisher),
    series: metadata.seriesTitle ?? '',
    barcode: metadata.barcode ?? '',
    format: metadata.physicalFormatLabel ?? metadata.physicalFormat ?? '',
    editionTitle: metadata.editionTitle ?? '',
    region: metadata.releaseRegion ?? '',
    audienceRating: metadata.audienceRating ?? '',
    genres: List.of(metadata.genres),
    description: metadata.synopsis ?? metadata.description ?? '',
    coverImageUrl: metadata.coverImageUrl ?? '',
  );
}

GameCatalogMetadata gameMetadataFromManualFormValues({
  required GameCatalogFormValues values,
  required String id,
  required String title,
  List<GameCatalogLink> externalLinks = const [],
}) {
  return GameCatalogMetadata.fromJson({
    'id': id,
    'kind': 'game',
    'title': title.trim(),
    'platforms': [if (_optional(values.platform) case final value?) value],
    ..._editedFields(values),
    if (externalLinks.isNotEmpty)
      'external_links': [for (final link in externalLinks) link.toJson()],
  });
}

GameCatalogMetadata applyGameCatalogFormValues({
  required GameCatalogMetadata current,
  required GameCatalogFormValues values,
  required String title,
}) {
  final platform = _optional(values.platform);
  // A Core item may list several platforms; an unchanged first platform keeps
  // them, a new choice replaces them with the one the item now belongs to.
  final platforms = platform == current.platforms.firstOrNull
      ? current.platforms
      : [if (platform != null) platform];
  final originalDescription = current.synopsis ?? current.description ?? '';
  final descriptionChanged = values.description != originalDescription;
  final coverChanged = values.coverImageUrl != (current.coverImageUrl ?? '');
  final payload = current.toJson()
    ..addAll({
      'title': title.trim(),
      'platforms': platforms,
      ..._editedFields(values, includeDescription: descriptionChanged),
      // A removed or restored Core cover takes its thumbnail with it.
      if (coverChanged) 'cover_image_url': _optional(values.coverImageUrl),
      if (coverChanged) 'thumbnail_image_url': null,
    });
  return GameCatalogMetadata.fromJson(payload);
}

Map<String, Object?> _editedFields(
  GameCatalogFormValues values, {
  bool includeDescription = true,
}) {
  final releaseDate = values.releaseDateParts;
  final description = _optional(values.description);
  return {
    'sort_key': _optional(values.sortTitle),
    'release_date': releaseDate?.isoString,
    'release_date_parts': releaseDate?.toJson(),
    'developers': values.developers,
    'publisher': _optional(joinGamePublishers(values.publishers)),
    'series_title': _optional(values.series),
    'barcode': _optional(values.barcode),
    'physical_format': _optional(values.format),
    'physical_format_label': _optional(values.format),
    'edition_title': _optional(values.editionTitle),
    'release_region': _optional(values.region),
    'audience_rating': _optional(values.audienceRating),
    'genres': values.genres,
    if (includeDescription) 'synopsis': description,
    if (includeDescription) 'description': description,
  };
}

String? _optional(String value) {
  final normalized = value.trim();
  return normalized.isEmpty ? null : normalized;
}
