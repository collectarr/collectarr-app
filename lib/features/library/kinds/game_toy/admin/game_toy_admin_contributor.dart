import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/metadata_field_id.dart';
import 'package:collectarr_app/features/library/config/library_admin_contributor.dart';

final class GameToyAdminContributor implements LibraryAdminContributor {
  const GameToyAdminContributor();
  @override
  CatalogMediaKind get kind => CatalogMediaKind.gameToy;
  @override
  List<LibraryAdminProposalField> get proposalFields => [
        adminTextProposalField(key: 'title', label: 'Title'),
        adminTextProposalField(key: 'sort_key', label: 'Sort Title'),
        adminTextProposalField(key: 'barcode', label: 'Barcode'),
        adminTextProposalField(key: 'series_title', label: 'Series'),
        adminTextProposalField(key: 'toy_type', label: 'Type'),
        adminTextProposalField(key: 'toy_subtype', label: 'Subtype'),
        adminTextProposalField(
            key: 'description', label: 'Description', minLines: 2, maxLines: 5),
        adminExternalLinksProposalField(key: 'external_links')
      ];
  @override
  List<LibraryAdminCorrectionField> get correctionFieldOverrides =>
      [adminRequiredCorrectionField(key: 'title', read: (item) => item.title)];
  @override
  Map<String, Object?> serializeCoverCorrection(
          {required String? coverImageUrl,
          required String? thumbnailImageUrl}) =>
      {'cover_image_url': coverImageUrl};
  @override
  List<LibraryMetadataOverrideField> get metadataOverrideFields => [
        for (final field in proposalFields)
          LibraryMetadataOverrideField(
              id: MetadataFieldId(
                  kind: CatalogMediaKind.gameToy, value: field.key),
              label: field.label)
      ];
}
