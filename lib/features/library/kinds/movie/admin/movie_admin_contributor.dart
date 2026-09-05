import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/library_admin_contributor.dart';

/// Movie-specific proposal fields used by the Admin host.
class MovieAdminContributor implements LibraryAdminContributor {
  const MovieAdminContributor();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.movie;

  @override
  List<LibraryAdminProposalField> get proposalFields => const [];
}
