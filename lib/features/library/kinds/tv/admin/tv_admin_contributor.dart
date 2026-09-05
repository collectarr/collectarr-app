import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/library_admin_contributor.dart';

/// TV-specific proposal fields used by the Admin host.
class TvAdminContributor implements LibraryAdminContributor {
  const TvAdminContributor();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.tv;

  @override
  List<LibraryAdminProposalField> get proposalFields => const [];
}
