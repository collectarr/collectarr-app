import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/metadata_field_id.dart';
import 'package:collectarr_app/features/library/config/library_admin_contributor.dart';
import 'package:collectarr_app/features/library/config/library_metadata_correction_source.dart';

String _readGamePlatforms(LibraryMetadataCorrectionValues values) =>
    readAdminProposalStringList(values, 'platforms');

void _writeGamePlatforms(
  LibraryMetadataCorrectionValues values,
  String rawValue,
) =>
    writeAdminProposalStringList(values, 'platforms', rawValue);

/// Game owns the platform proposal field and its payload codec.
class GameAdminContributor implements LibraryAdminContributor {
  const GameAdminContributor();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.game;

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
        const LibraryAdminProposalField(
          key: 'platforms',
          label: 'Platforms (comma separated)',
          read: _readGamePlatforms,
          write: _writeGamePlatforms,
        ),
        adminExternalLinksProposalField(key: 'external_links'),
      ];

  @override
  List<LibraryAdminCorrectionField> get correctionFieldOverrides => [
        adminRequiredCorrectionField(
          key: 'title',
          read: (item) => item.title,
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
            kind: CatalogMediaKind.game,
            value: 'title',
          ),
          label: 'Title',
        ),
        for (final field in proposalFields)
          LibraryMetadataOverrideField(
            id: MetadataFieldId(
              kind: CatalogMediaKind.game,
              value: field.key,
            ),
            label: field.label,
          ),
      ];
}
