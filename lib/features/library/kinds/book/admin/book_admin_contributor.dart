import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/library_admin_contributor.dart';

/// Book-specific proposal fields used by the Admin host.
class BookAdminContributor implements LibraryAdminContributor {
  const BookAdminContributor();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.book;

  @override
  List<LibraryAdminProposalField> get proposalFields => const [];
}
