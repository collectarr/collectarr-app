import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/library_admin_contributor.dart';

/// Comic-specific proposal fields used by the Admin host.
class ComicAdminContributor implements LibraryAdminContributor {
  const ComicAdminContributor();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.comic;

  @override
  List<LibraryAdminProposalField> get proposalFields => const [];
}
