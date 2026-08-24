import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:collectarr_app/features/providers/domain/models/normalized_provider_envelope_v1.dart';

class BoardGameLibraryKindProviderMapper implements LibraryKindProviderMapper {
  const BoardGameLibraryKindProviderMapper();

  @override
  LibraryMetadataItem metadataItemFromEnvelope(
      NormalizedProviderEnvelopeV1 envelope) {
    final norm = envelope.normalized;
    final title = norm['title']?.toString() ?? 'Unknown';
    final synopsis = norm['synopsis']?.toString();
    final publisher = norm['publisher']?.toString();
    final coverImageUrl = norm['cover_image_url']?.toString() ??
        (envelope.images.isNotEmpty ? envelope.images.first.url : null);
    DateTime? releaseDate;
    if (norm['release_date'] != null) {
      releaseDate = DateTime.tryParse(norm['release_date'].toString());
    }

    return LibraryMetadataItem(
      id: '',
      kind: 'boardgame',
      title: title,
      synopsis: synopsis,
      publisher: publisher,
      coverImageUrl: coverImageUrl,
      thumbnailImageUrl: coverImageUrl,
      releaseDate: releaseDate,
      genres: norm['genres'] is List
          ? (norm['genres'] as List).map((g) => g.toString()).toList()
          : null,
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
    if (edited.publisher != preview.publisher) {
      corrections['publisher'] = edited.publisher;
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
