import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/edit/library_edit_draft.dart';
import 'package:collectarr_app/features/library/edit/library_edit_models.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_metadata.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:collectarr_app/features/collection/pick_list/pick_list_options.dart';
import 'package:flutter/material.dart';

class GameEditController {
  GameEditController({
    required String initialPlatforms,
    String initialDevelopers = '',
    String initialSeriesTitle = '',
    String initialPublisher = '',
  })  : platformsController = TextEditingController(text: initialPlatforms),
        developersController = TextEditingController(text: initialDevelopers),
        seriesTitleController = TextEditingController(text: initialSeriesTitle),
        publisherController = TextEditingController(text: initialPublisher);

  final TextEditingController platformsController;
  final TextEditingController developersController;
  final TextEditingController seriesTitleController;
  final TextEditingController publisherController;
  List<String> developerOptions = const [];
  List<String> genreOptions = const [];
  List<String> platformOptions = const [];

  void initialize({
    required LibraryMetadataItem item,
    required LibraryEditDraft draft,
  }) {
    developerOptions = _mergePickListOptions(
      splitPickListValues(developersController.text),
    );
    genreOptions = _mergePickListOptions(
      (item.kindMetadata.toSyncPayload()['genres'] as List?)?.cast<String>() ??
          const <String>[],
    );
    platformOptions = splitPickListValues(platformsController.text);
  }

  void dispose() {
    platformsController.dispose();
    developersController.dispose();
    seriesTitleController.dispose();
    publisherController.dispose();
  }

  LibraryEditSelection applySelectionEdits(LibraryEditSelection selection) {
    final meta = selection.item.kindMetadata is GameCatalogMetadata
        ? (selection.item.kindMetadata as GameCatalogMetadata)
        : null;
    final platforms = splitPickListValues(platformsController.text);

    final existing = meta?.creators ?? const <Map<String, dynamic>>[];
    final preserved = <Map<String, dynamic>>[];
    for (final entry in existing) {
      final role = entry['role']?.toString().toLowerCase() ?? '';
      if (role.contains('developer')) {
        continue;
      }
      preserved.add(Map<String, dynamic>.from(entry));
    }

    final developerNames = developersController.text
        .split(RegExp(r'[,\r\n]+'))
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList(growable: false);

    final mergedCreators = <Map<String, dynamic>>[
      ...preserved,
      for (final name in developerNames)
        <String, dynamic>{'name': name, 'role': 'Developer'},
    ];

    final updatedPub = emptyToNull(publisherController.text);

    final updatedMetadata = meta?.copyWith(
      platforms: platforms,
      platform: platforms.firstOrNull ?? meta.platform,
      creators: mergedCreators.isNotEmpty ? mergedCreators : meta.creators,
      series: emptyToNull(seriesTitleController.text) ?? meta.series,
      publishers: updatedPub != null ? [updatedPub] : meta.publishers,
    ) ?? selection.item.kindMetadata;

    final updatedItem = selection.item.copyWith(
      kindMetadata: updatedMetadata,
    );

    return LibraryEditSelection(
      scope: selection.scope,
      item: updatedItem,
      personal: selection.personal,
      wishlist: selection.wishlist,
      tracking: selection.tracking,
      customFieldEdits: selection.customFieldEdits,
      itemImageEdits: selection.itemImageEdits,
      submitAction: selection.submitAction,
    );
  }

  List<String> _mergePickListOptions(
    Iterable<String> seed, [
    Iterable<String>? b,
    Iterable<String>? c,
    Iterable<String>? d,
  ]) {
    final merged = <String>[
      ...seed,
      if (b != null) ...b,
      if (c != null) ...c,
      if (d != null) ...d,
    ];
    final seen = <String>{};
    final output = <String>[];
    for (final candidate in merged) {
      final value = candidate.trim();
      if (value.isEmpty) {
        continue;
      }
      final key = value.toLowerCase();
      if (!seen.add(key)) {
        continue;
      }
      output.add(value);
    }
    return output;
  }
}
