import 'package:collectarr_app/features/library/add/models/library_kind_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/movie/forms/movie_credit_draft.dart';
import 'package:collectarr_app/features/library/kinds/movie/forms/movie_catalog_form_values.dart';

/// Movie's Add session owns catalog values; renderer widgets own input controllers.
final class MovieAddManualDraft implements LibraryKindAddDraftWithResources {
  MovieAddManualDraft({
    MovieCatalogFormValues? values,
    this.catalogTitle = '',
  }) : values = values ?? MovieCatalogFormValues();

  final MovieCatalogFormValues values;
  final List<EditableMovieCredit> castCredits = [];
  final List<EditableMovieCredit> crewCredits = [];
  @override
  String catalogTitle;

  @override
  void dispose() {
    for (final credit in [...castCredits, ...crewCredits]) {
      credit.dispose();
    }
  }
}
