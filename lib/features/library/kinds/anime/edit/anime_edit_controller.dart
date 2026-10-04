import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:flutter/material.dart';

import 'package:collectarr_app/features/library/kinds/anime/domain/anime_metadata_children.dart';
import 'package:collectarr_app/features/library/kinds/anime/forms/anime_credit_draft.dart';

class AnimeEditController {
  AnimeEditController({
    this.initialCharacters = '',
    this.initialCreators = const <AnimeCreditInput>[],
    this.initialTrailerLinks = const <TrailerLinkDto>[],
  });

  final String initialCharacters;
  final List<AnimeCreditInput> initialCreators;
  final List<TrailerLinkDto> initialTrailerLinks;

  late final TextEditingController charactersController =
      TextEditingController(text: initialCharacters);
  final List<EditableAnimeCredit> castCredits = [];
  final List<EditableAnimeCredit> crewCredits = [];

  void initializeAnimeEditors() {
    final creators = initialCreators;
    castCredits.addAll(
      splitAnimeCredits(creators, kind: AnimeCreditKind.cast),
    );
    crewCredits.addAll(
      splitAnimeCredits(creators, kind: AnimeCreditKind.crew),
    );
  }

  List<AnimePersonMetadata> buildUpdatedCreators() {
    final edited = [
      ...castCredits,
      ...crewCredits,
    ].where((credit) => credit.nameController.text.trim().isNotEmpty).toList();
    final ordered = [
      for (var index = 0; index < edited.length; index++)
        (credit: edited[index], index: index),
    ]..sort((left, right) {
        final leftPosition =
            left.credit.originalIndex ?? initialCreators.length + left.index;
        final rightPosition =
            right.credit.originalIndex ?? initialCreators.length + right.index;
        return leftPosition.compareTo(rightPosition);
      });
    var nextSequence = initialCreators
            .map((credit) => credit.source?.sequence ?? -1)
            .fold<int>(
                -1, (current, value) => value > current ? value : current) +
        1;
    return [
      for (final row in ordered)
        row.credit.toMetadata(
          newSequence: row.credit.source == null ? nextSequence++ : null,
        ),
    ];
  }

  void dispose() {
    charactersController.dispose();
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
