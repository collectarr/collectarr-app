import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/movie/forms/movie_credit_draft.dart';
import 'package:collectarr_app/features/library/kinds/movie/forms/movie_catalog_form_values.dart';

/// Edit state for Movie credits and automatic/manual trailer links.
///
/// Scalar catalog metadata is owned by [MovieCatalogFormValues] and rendered
/// from the same field schema as Manual Add.
class MovieEditController {
  MovieEditController({
    List<MovieCreditInput> initialCreators = const <MovieCreditInput>[],
    this.initialTrailerLinks = const <TrailerLinkDto>[],
  }) {
    castCredits.addAll(
      splitMovieCredits(initialCreators, kind: MovieCreditKind.cast),
    );
    crewCredits.addAll(
      splitMovieCredits(initialCreators, kind: MovieCreditKind.crew),
    );
  }

  final List<TrailerLinkDto> initialTrailerLinks;
  final List<EditableMovieCredit> castCredits = [];
  final List<EditableMovieCredit> crewCredits = [];

  void dispose() {
    for (final credit in castCredits) {
      credit.dispose();
    }
    for (final credit in crewCredits) {
      credit.dispose();
    }
  }

  List<TrailerLinkDto>? buildUpdatedTrailerUrls(
    List<TrailerLinkDto> existing, {
    required bool preserveManualLinks,
  }) {
    final preservedTrailers = existing
        .where(
          (link) =>
              link.isTrailerLink && (link.isAutomatic || preserveManualLinks),
        )
        .toList(growable: false);
    final providerExternalLinks = existing
        .where(
          (link) =>
              link.isExternalLink && (link.isAutomatic || preserveManualLinks),
        )
        .toList(growable: false);
    final merged = <TrailerLinkDto>[
      ...preservedTrailers,
      ...providerExternalLinks,
    ];
    return merged.isEmpty ? null : List<TrailerLinkDto>.unmodifiable(merged);
  }
}
