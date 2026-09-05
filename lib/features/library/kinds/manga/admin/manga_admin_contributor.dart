import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/library_admin_contributor.dart';

/// Manga-specific proposal fields used by the Admin host.
class MangaAdminContributor implements LibraryAdminContributor {
  const MangaAdminContributor();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.manga;

  @override
  List<LibraryAdminProposalField> get proposalFields => const [];
}
