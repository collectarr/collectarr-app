import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';

Map<String, dynamic> libraryKindMetadataPayload(LibraryMetadataItem item) {
  return item.kindMetadata.toSyncPayload();
}

DateTime? libraryKindReleaseDate(LibraryMetadataItem item) {
  final payload = libraryKindMetadataPayload(item);
  for (final key in const [
    'release_date',
    'first_air_date',
    'publication_date',
    'original_publication_date',
    'localized_release_date',
    'start_date',
  ]) {
    final value = payload[key];
    if (value is DateTime) {
      return value;
    }
    if (value is String) {
      final parsed = DateTime.tryParse(value);
      if (parsed != null) {
        return parsed;
      }
    }
  }
  return null;
}

int? libraryKindReleaseYear(LibraryMetadataItem item) {
  final payload = libraryKindMetadataPayload(item);
  final explicitYear = payload['release_year'];
  if (explicitYear is int) {
    return explicitYear;
  }
  if (explicitYear is num) {
    return explicitYear.toInt();
  }
  return libraryKindReleaseDate(item)?.year;
}

List<CatalogEditionDto> libraryKindEditions(LibraryMetadataItem item) {
  final rawEditions = libraryKindMetadataPayload(item)['editions'];
  if (rawEditions is! List) {
    return const [];
  }
  return [
    for (final raw in rawEditions)
      if (raw is Map)
        CatalogEditionDto.fromJson(Map<String, dynamic>.from(raw)),
  ];
}

String? libraryKindTitleExtension(LibraryMetadataItem item) {
  final payload = libraryKindMetadataPayload(item);
  final value = payload['title_extension'] ?? payload['edition_title'];
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? null : text;
}
