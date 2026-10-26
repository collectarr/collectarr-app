import 'package:collectarr_app/features/library/edit/contracts/library_edit_kind_draft.dart';
import 'package:collectarr_app/features/library/kinds/movie/edit/controller.dart';
import 'package:collectarr_app/features/library/kinds/movie/forms/catalog_form_values.dart';

abstract class MovieEditDraftContract
    implements LibraryCatalogItemEditSession, LibraryEntryEditSession {
  MovieCatalogFormValues get catalogValues;
  MovieEditController get movieEdit;
}
