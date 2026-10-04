import 'package:collectarr_app/features/library/edit/contracts/library_edit_kind_draft.dart';
import 'package:collectarr_app/features/library/kinds/movie/edit/movie_edit_controller.dart';
import 'package:collectarr_app/features/library/kinds/movie/forms/movie_catalog_form_values.dart';

abstract class MovieEditDraftContract
    implements LibraryCatalogItemEditSession, LibraryEntryEditSession {
  MovieCatalogFormValues get catalogValues;
  MovieEditController get movieEdit;
}
