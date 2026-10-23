import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/metadata_field_id.dart';
import 'package:collectarr_app/features/library/config/library_admin_contributor.dart';

final class GameHardwareAdminContributor implements LibraryAdminContributor {
  const GameHardwareAdminContributor();
  @override
  CatalogMediaKind get kind => CatalogMediaKind.gameHardware;
  @override
  List<LibraryAdminProposalField> get proposalFields => [
        adminTextProposalField(key: 'title', label: 'Title'),
        adminTextProposalField(key: 'sort_key', label: 'Sort Title'),
        adminTextProposalField(key: 'barcode', label: 'Barcode'),
        adminTextProposalField(key: 'series_title', label: 'Series'),
        adminTextProposalField(key: 'platform', label: 'Platform'),
        adminTextProposalField(key: 'hardware_type', label: 'Hardware Type'),
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
                  kind: CatalogMediaKind.gameHardware, value: field.key),
              label: field.label)
      ];
}
