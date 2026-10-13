import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/metadata_field_id.dart';
import 'package:collectarr_app/features/library/config/library_admin_contributor.dart';

/// Movie-specific proposal fields used by the Admin host.
class MovieAdminContributor implements LibraryAdminContributor {
  const MovieAdminContributor();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.movie;

  @override
  List<LibraryAdminProposalField> get proposalFields => [
        adminTextProposalField(key: 'item_number', label: 'Item number'),
        adminTextProposalField(key: 'subtitle', label: 'Subtitle'),
        adminTextProposalField(key: 'publisher', label: 'Publisher'),
        adminTextProposalField(
          key: 'synopsis',
          label: 'Synopsis',
          minLines: 2,
          maxLines: 3,
        ),
        adminStringListProposalField(
          key: 'genres',
          label: 'Genres (comma separated)',
        ),
        adminExternalLinksProposalField(key: 'external_links'),
      ];

  @override
  List<LibraryAdminCorrectionField> get correctionFieldOverrides => [
        adminRequiredCorrectionField(
          key: 'title',
          read: (item) => item.title,
        ),
        adminCorrectionFieldReadOverride(
          key: 'edition_title',
          read: (item) =>
              item.canonicalFieldValues['edition_title'] ??
              item.canonicalFieldValues['title_extension'],
        ),
        adminCorrectionFieldReadOverride(
          key: 'publisher',
          read: (item) =>
              item.canonicalFieldValues['publisher'] ??
              item.canonicalFieldValues['studio'],
        ),
        adminCorrectionFieldReadOverride(
          key: 'variant_name',
          read: (item) =>
              item.canonicalFieldValues['variant_name'] ??
              item.canonicalFieldValues['variant'],
        ),
        adminPhysicalFormatCorrectionField(
          key: 'physical_format',
          read: (item) => item.canonicalFieldValues['physical_format'],
        ),
        adminRelatedListCorrectionField(
          key: 'series_tags',
          label: 'Series tags',
          relatedFieldKey: 'tags',
          relatedEntityId: (item) =>
              item.canonicalFieldValues['series_id']?.toString(),
          read: (item) =>
              item.canonicalFieldValues['series_tags'] ??
              item.canonicalFieldValues['tags'],
        ),
        adminUrlListCorrectionField(
          key: 'external_links',
          label: 'External links',
          linkKind: 'external',
          read: (item) => item.canonicalFieldValues['external_links'],
        ),
        adminUrlListCorrectionField(
          key: 'trailer_urls',
          label: 'Trailer URLs',
          linkKind: 'trailer',
          read: (item) => item.canonicalFieldValues['trailer_urls'],
        ),
      ];
  @override
  Map<String, Object?> serializeCoverCorrection({
    required String? coverImageUrl,
    required String? thumbnailImageUrl,
  }) =>
      {
        if (coverImageUrl != null) 'cover_image_url': coverImageUrl,
        if (thumbnailImageUrl != null) 'thumbnail_image_url': thumbnailImageUrl,
      };
  @override
  List<LibraryMetadataOverrideField> get metadataOverrideFields => [
        const LibraryMetadataOverrideField(
          id: MetadataFieldId(
            kind: CatalogMediaKind.movie,
            value: 'title',
          ),
          label: 'Title',
        ),
        for (final field in proposalFields)
          LibraryMetadataOverrideField(
            id: MetadataFieldId(
              kind: CatalogMediaKind.movie,
              value: field.key,
            ),
            label: field.label,
          ),
      ];
}
