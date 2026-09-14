import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/metadata_field_id.dart';
import 'package:collectarr_app/features/library/config/library_admin_contributor.dart';

/// Anime-specific proposal fields used by the Admin host.
class AnimeAdminContributor implements LibraryAdminContributor {
  const AnimeAdminContributor();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.anime;

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
        adminExternalLinksProposalField(),
      ];

  @override
  List<LibraryMetadataOverrideField> get metadataOverrideFields => [
        const LibraryMetadataOverrideField(
          id: MetadataFieldId(
            kind: CatalogMediaKind.anime,
            value: 'title',
          ),
          label: 'Title',
        ),
        for (final field in proposalFields)
          LibraryMetadataOverrideField(
            id: MetadataFieldId(
              kind: CatalogMediaKind.anime,
              value: field.key,
            ),
            label: field.label,
          ),
      ];
}
