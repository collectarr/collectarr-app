import 'package:collectarr_app/features/library/kinds/book/contracts/book_contracts.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_provider_contract.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/providers/transport/provider_raw_envelope.dart';
import 'book_provider_correction_patch.dart';

class BookLibraryKindProviderMapper
    implements TypedLibraryKindProviderMapper<BookCatalog> {
  const BookLibraryKindProviderMapper();

  @override
  BookCatalog catalogFromEnvelope(ProviderRawEnvelope envelope) {
    validateLibraryKindProviderEnvelope(
      envelope: envelope,
      expectedKind: CatalogMediaKind.book,
    );
    final norm = envelope.payload;
    final title = norm['title']?.toString() ?? 'Unknown';
    final coverImageUrl = norm['cover_image_url']?.toString() ??
        (envelope.images.isNotEmpty ? envelope.images.first.url : null);

    return BookCatalog.fromJson({
      'id': envelope.providerItemId,
      'title': title,
      'cover_image_url': coverImageUrl,
      'thumbnail_image_url': coverImageUrl,
      ...norm.toJson(),
    });
  }

  CatalogSearchCandidate catalogCandidateFromEnvelope(
    ProviderRawEnvelope envelope,
  ) {
    final catalog = catalogFromEnvelope(envelope);
    final edition = catalog.editions.firstOrNull;
    return providerCandidateFromTypedProjection(
      kind: catalog.mediaKind,
      id: catalog.id,
      title: catalog.title,
      synopsis: catalog.synopsis,
      coverImageUrl: catalog.displayCoverUrl,
      releaseDate: catalog.originalPublicationDate,
      publisher: edition?.publisher ?? catalog.originalPublisher,
      barcode: edition?.isbn ?? edition?.upc,
      physicalFormat: edition?.format,
      physicalFormatLabel: edition?.physicalFormatLabel,
      editionTitle: edition?.title,
      kindMetadata: catalog,
    );
  }

  ProviderCorrectionPatch buildCorrections({
    required CatalogSearchCandidate preview,
    required CatalogSearchCandidate edited,
  }) {
    return BookProviderCorrectionPatch.fromCandidates(
      preview: preview,
      edited: edited,
    );
  }
}
