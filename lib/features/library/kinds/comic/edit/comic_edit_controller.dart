import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/features/library/edit/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/edit/library_edit_models.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_metadata.dart';
import 'package:collectarr_app/features/library/models/library_kind_metadata_runtime.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:flutter/material.dart';

import 'comic_edit_models.dart';

class ComicEditController {
  ComicEditController({
    required this.item,
    required this.itemImages,
  })  : crossoverController = TextEditingController(
            text: (item.toSyncPayload()['crossover'] as String?) ?? ''),
        storyArcsController = TextEditingController(
            text: ((item.toSyncPayload()['story_arcs'] as List?)
                        ?.map((e) => e.toString()) ??
                    const <String>[])
                .join(', ')),
        imprintController = TextEditingController(
            text: (item.toSyncPayload()['imprint'] as String?) ?? ''),
        pageCountController = TextEditingController(
            text: item.toSyncPayload()['page_count']?.toString() ?? ''),
        ageRatingController = TextEditingController(text: item.ageRating ?? ''),
        genresEditController = TextEditingController(
            text: ((item.toSyncPayload()['genres'] as List?)
                        ?.map((e) => e.toString()) ??
                    const <String>[])
                .join(', ')),
        seriesGroupController = TextEditingController(
            text: (item.toSyncPayload()['series_group'] as String?) ?? '');

  final ComicCatalogMetadata item;
  final List<ItemImage> itemImages;

  final TextEditingController crossoverController;
  final TextEditingController storyArcsController;
  final TextEditingController imprintController;
  final TextEditingController pageCountController;
  final TextEditingController ageRatingController;
  final TextEditingController genresEditController;
  final TextEditingController seriesGroupController;

  final List<EditableComicCreator> creators = [];
  final List<EditableComicCharacter> characters = [];
  final List<Map<String, TextEditingController>> links = [];
  final TextEditingController characterDraftController =
      TextEditingController();

  void initialize() {
    creators.addAll(initComicCreators(item));
    characters.addAll(initComicCharacters(item));
    for (final link in item.links.where((entry) => entry.isExternalLink)) {
      links.add(createLinkControllers(
        title: link.title ?? link.description ?? '',
        url: link.url,
      ));
    }
  }

  Map<String, TextEditingController> createLinkControllers({
    String title = '',
    String url = '',
  }) {
    return <String, TextEditingController>{
      'title': TextEditingController(text: title),
      'url': TextEditingController(text: url),
    };
  }

  void dispose() {
    crossoverController.dispose();
    storyArcsController.dispose();
    imprintController.dispose();
    pageCountController.dispose();
    ageRatingController.dispose();
    genresEditController.dispose();
    seriesGroupController.dispose();
    characterDraftController.dispose();
    for (final creator in creators) {
      creator.dispose();
    }
    for (final character in characters) {
      character.dispose();
    }
    for (final link in links) {
      link['title']?.dispose();
      link['url']?.dispose();
    }
  }

  LibraryEditSelection applySelectionEdits(LibraryEditSelection selection) {
    final parsedStoryArcs = storyArcsController.text
        .split(RegExp(r'[,\r\n]+'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    final parsedGenres = genresEditController.text
        .split(RegExp(r'[,\r\n]+'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    final payload = selection.item.kindMetadata.toSyncPayload();
    final updatedPayload = {
      ...payload,
      'crossover': emptyToNull(crossoverController.text),
      'story_arcs': parsedStoryArcs.isNotEmpty
          ? parsedStoryArcs
          : (payload['story_arcs'] as List?) ?? const <String>[],
      'age_rating': emptyToNull(ageRatingController.text),
      'genres': parsedGenres.isNotEmpty
          ? parsedGenres
          : (payload['genres'] as List?) ?? const <String>[],
      if (emptyToNull(imprintController.text) != null)
        'imprint': emptyToNull(imprintController.text),
      if (int.tryParse(pageCountController.text) != null)
        'page_count': int.tryParse(pageCountController.text),
      if (emptyToNull(seriesGroupController.text) != null)
        'series_group': emptyToNull(seriesGroupController.text),
    };
    final updatedItem = LibraryMetadataItem(
      identity: selection.item.identity,
      common: selection.item.common,
      kindMetadata: LibraryKindMetadataDecoders.decode(
        selection.item.mediaKind,
        updatedPayload,
      ),
    );
    final withMetadata = selection.copyWith(item: updatedItem);
    return applyComicSelectionEdits(
      withMetadata,
      creators,
      characters,
      links,
    );
  }
}
