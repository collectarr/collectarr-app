import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/library/edit/library_edit_draft.dart';
import 'package:collectarr_app/features/library/edit/library_edit_models.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:collectarr_app/features/collection/pick_list/pick_list_options.dart';
import 'package:flutter/material.dart';

class GameEditController {
  GameEditController({
    required String initialPlatforms,
  }) : platformsController = TextEditingController(text: initialPlatforms);

  final TextEditingController platformsController;
  List<String> developerOptions = const [];
  List<String> genreOptions = const [];
  List<String> platformOptions = const [];

  void initialize({
    required LibraryMetadataItem item,
    required LibraryEditDraft draft,
  }) {
    developerOptions = _mergePickListOptions(
      splitPickListValues(draft.developersController.text),
    );
    genreOptions = _mergePickListOptions(
      splitPickListValues(draft.genresEditController.text),
      item.genres ?? const <String>[],
    );
    platformOptions = splitPickListValues(platformsController.text);
  }

  void dispose() {
    platformsController.dispose();
  }

  LibraryEditSelection applySelectionEdits(LibraryEditSelection selection) {
    final currentGame = selection.item.game;
    final updatedGame = GameCatalogDetails(
      platforms: splitPickListValues(platformsController.text),
      toySubtype: currentGame?.toySubtype,
      toyType: currentGame?.toyType,
    );
    return LibraryEditSelection(
      scope: selection.scope,
      item: selection.item.copyWith(
        game: updatedGame.hasData ? updatedGame : null,
      ),
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
