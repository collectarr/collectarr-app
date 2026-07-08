import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/features/library/edit/library_edit_models.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:flutter/material.dart';

import 'comic_edit_models.dart';

class ComicEditController {
  ComicEditController({
    required this.item,
    required this.itemImages,
  });

  final LibraryMetadataItem item;
  final List<ItemImage> itemImages;

  final List<EditableComicCreator> creators = [];
  final List<EditableComicCharacter> characters = [];
  final List<Map<String, TextEditingController>> links = [];
  final TextEditingController characterDraftController =
      TextEditingController();

  void initialize() {
    creators.addAll(initComicCreators(item));
    characters.addAll(initComicCharacters(item));
    for (final link
        in item.trailerUrls.where((entry) => entry.isExternalLink)) {
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
    return applyComicSelectionEdits(
      selection,
      creators,
      characters,
      links,
    );
  }
}
