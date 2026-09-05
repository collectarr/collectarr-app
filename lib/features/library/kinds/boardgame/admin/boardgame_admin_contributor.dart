import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/library_admin_contributor.dart';

/// Board game-specific proposal fields used by the Admin host.
class BoardGameAdminContributor implements LibraryAdminContributor {
  const BoardGameAdminContributor();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.boardgame;

  @override
  List<LibraryAdminProposalField> get proposalFields => const [];
}
