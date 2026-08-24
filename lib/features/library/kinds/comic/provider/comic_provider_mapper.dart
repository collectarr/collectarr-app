import 'package:collectarr_app/features/library/kinds/comic/domain/comic_metadata.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:collectarr_app/features/providers/domain/models/normalized_provider_envelope_v1.dart';

class ComicLibraryKindProviderMapper implements LibraryKindProviderMapper {
  const ComicLibraryKindProviderMapper();

  @override
  LibraryMetadataItem metadataItemFromEnvelope(
      NormalizedProviderEnvelopeV1 envelope) {
    final norm = envelope.normalized;
    final title = norm['title']?.toString() ?? 'Unknown';
    final itemNumber = norm['item_number']?.toString();
    final synopsis = norm['synopsis']?.toString();
    final publisher = norm['publisher']?.toString();
    final editionTitle = norm['edition_title']?.toString();
    final physicalFormat = norm['physical_format']?.toString();
    final physicalFormatLabel = norm['physical_format_label']?.toString();
    final coverImageUrl = norm['cover_image_url']?.toString() ??
        (envelope.images.isNotEmpty ? envelope.images.first.url : null);
    final variant =
        norm['variant_name']?.toString() ?? norm['variant']?.toString();
    final country = norm['country']?.toString() ?? 'US';
    final language = norm['language']?.toString() ?? 'en';
    final ageRating = norm['age_rating']?.toString();
    final audienceRating = norm['audience_rating']?.toString();

    DateTime? releaseDate;
    if (norm['release_date'] != null) {
      releaseDate = DateTime.tryParse(norm['release_date'].toString());
    }

    final creators = <Map<String, dynamic>>[];
    if (norm['creators'] is List) {
      for (final c in norm['creators'] as List) {
        if (c is Map) {
          creators.add({
            'name': c['name']?.toString() ?? '',
            if (c['role'] != null) 'role': c['role']?.toString(),
            if (c['image_url'] != null) 'image_url': c['image_url']?.toString(),
          });
        }
      }
    }

    final characters = norm['characters'] is List
        ? (norm['characters'] as List).map((ch) => ch.toString()).toList()
        : null;

    final storyArcs = norm['story_arcs'] is List
        ? (norm['story_arcs'] as List).map((sa) => sa.toString()).toList()
        : null;

    final genres = norm['genres'] is List
        ? (norm['genres'] as List).map((g) => g.toString()).toList()
        : null;

    final comicMetadata = ComicCatalogMetadata.fromJson(norm);

    return LibraryMetadataItem(
      id: '',
      kind: 'comic',
      title: title,
      itemNumber: itemNumber,
      synopsis: synopsis,
      publisher: publisher,
      editionTitle: editionTitle,
      physicalFormat: physicalFormat,
      physicalFormatLabel: physicalFormatLabel,
      coverImageUrl: coverImageUrl,
      thumbnailImageUrl: coverImageUrl,
      releaseDate: releaseDate,
      releaseYear: releaseDate?.year,
      variant: variant,
      country: country,
      language: language,
      ageRating: ageRating,
      audienceRating: audienceRating,
      creators: creators,
      characters: characters,
      storyArcs: storyArcs,
      genres: genres,
      kindMetadata: comicMetadata,
    );
  }

  @override
  Map<String, Object?> buildCorrections({
    required LibraryMetadataItem preview,
    required LibraryMetadataItem edited,
  }) {
    final corrections = <String, Object?>{};
    if (edited.title != preview.title) corrections['title'] = edited.title;
    if (edited.synopsis != preview.synopsis) {
      corrections['synopsis'] = edited.synopsis;
    }
    if (edited.itemNumber != preview.itemNumber) {
      corrections['item_number'] = edited.itemNumber;
    }
    if (edited.publisher != preview.publisher) {
      corrections['publisher'] = edited.publisher;
    }
    if (edited.editionTitle != preview.editionTitle) {
      corrections['edition_title'] = edited.editionTitle;
    }
    if (edited.physicalFormat != preview.physicalFormat) {
      corrections['physical_format'] = edited.physicalFormat;
    }
    if (edited.releaseDate != preview.releaseDate) {
      corrections['release_date'] = edited.releaseDate?.toIso8601String();
    }
    if (edited.coverImageUrl != preview.coverImageUrl) {
      corrections['cover_image_url'] = edited.coverImageUrl;
    }
    return corrections;
  }
}
