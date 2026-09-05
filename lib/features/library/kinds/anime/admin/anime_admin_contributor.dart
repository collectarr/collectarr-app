import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/library_admin_contributor.dart';

/// Anime-specific proposal fields used by the Admin host.
class AnimeAdminContributor implements LibraryAdminContributor {
  const AnimeAdminContributor();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.anime;

  @override
  List<LibraryAdminProposalField> get proposalFields => const [];
}
