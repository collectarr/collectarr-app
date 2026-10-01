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
  List<LibraryAdminCorrectionField> get correctionFields => [
        adminCorrectionFieldValueOverride(
          key: 'title',
          required: true,
          read: (item) => item.title,
        ),
        adminCorrectionFieldValueOverride(
          key: 'edition_title',
          read: (item) =>
              item.canonicalFieldValues['edition_title'] ??
              item.canonicalFieldValues['title_extension'],
        ),
        adminCorrectionFieldValueOverride(
          key: 'release_date',
          read: (item) => item.canonicalFieldValues['release_date'],
        ),
        adminCorrectionFieldValueOverride(
          key: 'publisher',
          read: (item) =>
              item.canonicalFieldValues['publisher'] ??
              item.canonicalFieldValues['studio'],
        ),
        adminCorrectionFieldValueOverride(
          key: 'subtitle',
          read: (item) => item.canonicalFieldValues['subtitle'],
        ),
        adminCorrectionFieldValueOverride(
          key: 'barcode',
          read: (item) => item.canonicalFieldValues['barcode'],
        ),
        adminCorrectionFieldValueOverride(
          key: 'variant_name',
          read: (item) =>
              item.canonicalFieldValues['variant_name'] ??
              item.canonicalFieldValues['variant'],
        ),
        adminCorrectionFieldValueOverride(
          key: 'runtime_minutes',
          read: (item) => item.canonicalFieldValues['runtime_minutes'],
        ),
        adminCorrectionFieldValueOverride(
          key: 'color',
          read: (item) => item.canonicalFieldValues['color'],
        ),
        adminCorrectionFieldValueOverride(
          key: 'nr_discs',
          read: (item) => item.canonicalFieldValues['nr_discs'],
        ),
        adminCorrectionFieldValueOverride(
          key: 'screen_ratio',
          read: (item) => item.canonicalFieldValues['screen_ratio'],
        ),
        adminCorrectionFieldValueOverride(
          key: 'audio_tracks',
          read: (item) => item.canonicalFieldValues['audio_tracks'],
        ),
        adminCorrectionFieldValueOverride(
          key: 'subtitles',
          read: (item) => item.canonicalFieldValues['subtitles'],
        ),
        adminCorrectionFieldValueOverride(
          key: 'layers',
          read: (item) => item.canonicalFieldValues['layers'],
        ),
        adminCorrectionFieldValueOverride(
          key: 'catalog_number',
          read: (item) => item.canonicalFieldValues['catalog_number'],
        ),
        adminCorrectionFieldValueOverride(
          key: 'release_status',
          read: (item) => item.canonicalFieldValues['release_status'],
        ),
        adminCorrectionFieldValueOverride(
          key: 'genres',
          read: (item) => item.canonicalFieldValues['genres'],
        ),
        adminCorrectionFieldValueOverride(
          key: 'cover_image_url',
          read: (item) => item.canonicalFieldValues['cover_image_url'],
        ),
        adminCorrectionFieldValueOverride(
          key: 'thumbnail_image_url',
          read: (item) => item.canonicalFieldValues['thumbnail_image_url'],
        ),
        adminPhysicalFormatCorrectionField(
          key: 'physical_format',
          read: (item) =>
              item.canonicalFieldValues['physical_format'] ??
              item.canonicalFieldValues['physical_format_label'],
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
