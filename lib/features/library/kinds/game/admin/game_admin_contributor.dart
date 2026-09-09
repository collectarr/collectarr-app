import 'package:collectarr_app/core/models/catalog_media_kind.dart';
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
        adminExternalLinksProposalField(),
      ];
}
