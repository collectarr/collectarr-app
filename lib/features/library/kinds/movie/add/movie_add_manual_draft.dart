import 'package:collectarr_app/features/library/add/models/library_kind_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/movie/forms/movie_catalog_form_values.dart';

/// Movie's Add session owns catalog values; renderer widgets own input controllers.
final class MovieAddManualDraft implements LibraryKindAddDraft {
  MovieAddManualDraft({MovieCatalogFormValues? values})
      : values = values ?? MovieCatalogFormValues();

  final MovieCatalogFormValues values;

  @override
  void dispose() {}
}
