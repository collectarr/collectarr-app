import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/add/models/library_kind_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/movie/add/movie_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/movie/add/movie_add_schema.dart';
import 'package:collectarr_app/features/library/kinds/movie/forms/movie_catalog_form_adapters.dart';
import 'package:collectarr_app/features/library/models/library_item_identity.dart';

CatalogSearchCandidate? buildMovieManualCandidate(
  LibraryKindAddDraft draft, {
  required String title,
}) {
  if (draft is! MovieAddManualDraft || title.trim().isEmpty) return null;
  if (movieAddSchema.validate?.call(draft) != null) return null;

  final id = 'manual-movie-${DateTime.now().microsecondsSinceEpoch}';
  final movie = movieMediaFromManualCatalogFormValues(
    values: draft.values,
    id: id,
    title: title,
  );
  final item = CatalogItemDto(
    identity: LibraryItemIdentity(
      id: id,
      mediaKind: CatalogMediaKind.movie,
    ),
    kindMetadata: movie,
  );
  return CatalogSearchCandidate.fromItem(item);
}
