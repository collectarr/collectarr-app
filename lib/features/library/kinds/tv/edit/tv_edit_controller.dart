import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/tv/forms/tv_credit_draft.dart';

class TvEditController {
  TvEditController({
    this.initialCreators = const <TvCreditInput>[],
    this.initialTrailerLinks = const <TrailerLinkDto>[],
  });

  final List<TvCreditInput> initialCreators;
  final List<TrailerLinkDto> initialTrailerLinks;

  final List<EditableTvCredit> castCredits = [];
  final List<EditableTvCredit> crewCredits = [];

  void initializeTvEditors() {
    final creators = initialCreators;
    castCredits.addAll(
      splitTvCredits(creators, kind: TvCreditKind.cast),
    );
    crewCredits.addAll(
      splitTvCredits(creators, kind: TvCreditKind.crew),
    );
  }

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
    final preservedExternalLinks = existing
        .where(
          (link) =>
              link.isExternalLink && (link.isAutomatic || preserveManualLinks),
        )
        .toList(growable: false);
    final merged = <TrailerLinkDto>[
      ...preservedTrailers,
      ...preservedExternalLinks,
    ];
    return merged.isEmpty ? null : List<TrailerLinkDto>.unmodifiable(merged);
  }
}
