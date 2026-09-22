import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/metadata_field_id.dart';
import 'package:collectarr_app/features/library/config/library_admin_contributor.dart';

/// Comic-specific proposal fields used by the Admin host.
class ComicAdminContributor implements LibraryAdminContributor {
  const ComicAdminContributor();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.comic;

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
  List<LibraryAdminCorrectionField> get correctionFields => [
        adminCorrectionFieldValueOverride(
          key: 'title',
          required: true,
          read: (item) => item.title,
        ),
        adminCorrectionFieldValueOverride(
          key: 'edition_title',
          read: (item) =>
              item.primaryEdition?.title ??
              item.canonicalFieldValues['edition_title'],
        ),
        adminCorrectionFieldValueOverride(
          key: 'release_date',
          read: (item) =>
              item.primaryEdition?.releaseDateParts ??
              item.primaryEdition?.releaseDate ??
              item.coverDate ??
              item.canonicalFieldValues['release_date'],
        ),
        adminCorrectionFieldValueOverride(
          key: 'publisher',
          read: (item) =>
              item.primaryEdition?.publisher ??
              item.publisher ??
              item.canonicalFieldValues['publisher'],
        ),
        adminCorrectionFieldValueOverride(
          key: 'imprint',
          read: (item) =>
              item.publishing?.imprint ?? item.canonicalFieldValues['imprint'],
        ),
        adminCorrectionFieldValueOverride(
          key: 'subtitle',
          read: (item) =>
              item.publishing?.subtitle ??
              item.canonicalFieldValues['subtitle'],
        ),
        adminCorrectionFieldValueOverride(
          key: 'series_group',
          read: (item) =>
              item.publishing?.seriesGroup ??
              item.canonicalFieldValues['series_group'],
        ),
        adminCorrectionFieldValueOverride(
          key: 'barcode',
          read: (item) =>
              item.primaryVariant?.barcode ??
              item.barcode ??
              item.canonicalFieldValues['barcode'],
        ),
        adminCorrectionFieldValueOverride(
          key: 'variant_name',
          read: (item) =>
              item.primaryVariant?.name ??
              item.canonicalFieldValues['variant_name'],
        ),
        adminCorrectionFieldValueOverride(
          key: 'page_count',
          read: (item) =>
              item.publishing?.pageCount ??
              item.canonicalFieldValues['page_count'],
        ),
        adminCorrectionFieldValueOverride(
          key: 'catalog_number',
          read: (item) =>
              item.music?.catalogNumber ??
              item.canonicalFieldValues['catalog_number'],
        ),
        adminCorrectionFieldValueOverride(
          key: 'release_status',
          read: (item) =>
              item.music?.releaseStatus ??
              item.canonicalFieldValues['release_status'],
        ),
        adminCorrectionFieldValueOverride(
          key: 'genres',
          read: (item) => item.genres.isNotEmpty
              ? item.genres
              : item.canonicalFieldValues['genres'],
        ),
        adminCorrectionFieldValueOverride(
          key: 'cover_image_url',
          read: (item) =>
              item.primaryVariant?.coverImageUrl ??
              item.canonicalFieldValues['cover_image_url'],
        ),
        adminCorrectionFieldValueOverride(
          key: 'thumbnail_image_url',
          read: (item) =>
              item.primaryVariant?.thumbnailImageUrl ??
              item.canonicalFieldValues['thumbnail_image_url'],
        ),
        adminPhysicalFormatCorrectionField(
          key: 'physical_format',
          read: (item) =>
              item.primaryEdition?.physicalFormat ??
              item.primaryEdition?.physicalFormatLabel ??
              item.canonicalFieldValues['physical_format'],
        ),
        adminRelatedListCorrectionField(
          key: 'series_tags',
          label: 'Series tags',
          relatedFieldKey: 'tags',
          relatedEntityId: (item) => item.series?.seriesId,
          read: (item) =>
              item.series?.tags ?? item.canonicalFieldValues['series_tags'],
        ),
        adminUrlListCorrectionField(
          key: 'external_links',
          label: 'External links',
          linkKind: 'external',
          read: (item) => item.externalLinks,
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
            kind: CatalogMediaKind.comic,
            value: 'title',
          ),
          label: 'Title',
        ),
        for (final field in proposalFields)
          LibraryMetadataOverrideField(
            id: MetadataFieldId(
              kind: CatalogMediaKind.comic,
              value: field.key,
            ),
            label: field.label,
          ),
      ];
}
