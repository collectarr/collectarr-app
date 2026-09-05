import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/library_admin_contributor.dart';

String _readGamePlatforms(Map<String, dynamic> payload) =>
    readAdminProposalStringList(payload, 'platforms');

void _writeGamePlatforms(Map<String, dynamic> payload, String rawValue) =>
    writeAdminProposalStringList(payload, 'platforms', rawValue);

/// Game owns the platform proposal field and its payload codec.
class GameAdminContributor implements LibraryAdminContributor {
  const GameAdminContributor();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.game;

  @override
  List<LibraryAdminProposalField> get proposalFields => const [
        LibraryAdminProposalField(
          key: 'platforms',
          label: 'Platforms (comma separated)',
          read: _readGamePlatforms,
          write: _writeGamePlatforms,
        ),
      ];
}
