import 'package:collectarr_app/features/library/kinds/book/contracts/book_contracts.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_metadata.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_provider_contract.dart';
import 'package:collectarr_app/features/library/models/library_item_identity.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/catalog/transport/library_add_catalog_transport.dart';
import 'package:collectarr_app/features/providers/transport/provider_metadata_envelope.dart';

class BookLibraryKindProviderMapper
    implements TypedLibraryKindProviderMapper<BookCatalog> {
  const BookLibraryKindProviderMapper();

  @override
  BookCatalog catalogFromEnvelope(ProviderMetadataEnvelope envelope) {
    validateLibraryKindProviderEnvelope(
      envelope: envelope,
      expectedKind: CatalogMediaKind.book,
    );
    final norm = envelope.normalized;
    final title = norm['title']?.toString() ?? 'Unknown';
    final coverImageUrl = norm['cover_image_url']?.toString() ??
        (envelope.images.isNotEmpty ? envelope.images.first.url : null);

    return BookCatalog.fromJson({
      'id': envelope.providerItemId,
      'title': title,
      'cover_image_url': coverImageUrl,
      'thumbnail_image_url': coverImageUrl,
      ...norm,
    });
  }

  CatalogItemDto metadataItemFromEnvelope(ProviderMetadataEnvelope envelope) {
    validateLibraryKindProviderEnvelope(
      envelope: envelope,
      expectedKind: CatalogMediaKind.book,
    );
    final norm = envelope.normalized;
    final title = norm['title']?.toString() ?? 'Unknown';
    final coverImageUrl = norm['cover_image_url']?.toString() ??
        (envelope.images.isNotEmpty ? envelope.images.first.url : null);
    final bookMetadata = BookCatalogMetadata.fromJson({
      ...norm,
      'title': title,
      if (coverImageUrl != null) 'cover_image_url': coverImageUrl,
      if (coverImageUrl != null) 'thumbnail_image_url': coverImageUrl,
    });

    return CatalogItemDto(
      identity: LibraryItemIdentity(
        id: envelope.providerItemId,
        mediaKind: CatalogMediaKind.book,
      ),
      kindMetadata: bookMetadata,
    );
  }

  ProviderCorrectionPatch buildCorrections({
    required LibraryAddCatalogTransport preview,
    required LibraryAddCatalogTransport edited,
  }) {
    final corrections = <String, Object?>{};
    if (edited.title != preview.title) corrections['title'] = edited.title;
    if (edited.synopsis != preview.synopsis) {
      corrections['synopsis'] = edited.synopsis;
    }
    final previewPayload = preview.mapTransport((dto) => dto.payload);
    final editedPayload = edited.mapTransport((dto) => dto.payload);
    for (final entry in editedPayload.entries) {
      if (previewPayload[entry.key] != entry.value) {
        corrections[entry.key] = entry.value;
      }
    }
    return ProviderCorrectionPatch(corrections);
  }
}
