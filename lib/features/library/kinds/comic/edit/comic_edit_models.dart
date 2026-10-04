import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_link.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/forms/comic_person_draft.dart';
import 'package:flutter/material.dart';

LibraryEditSelection applyComicSelectionEdits(
  LibraryEditSelection selection,
  List<EditableComicCreator> creators,
  List<EditableComicCharacter> characters,
  List<Map<String, TextEditingController>> links,
) {
  final mappedCreators = creators
      .map((creator) => creator.toMap())
      .where(
        (creator) => (creator['name']?.toString().trim().isNotEmpty ?? false),
      )
      .toList(growable: false);
  final characterDetails = characters
      .map((character) => character.toMap())
      .where(
        (character) =>
            (character['name']?.toString().trim().isNotEmpty ?? false),
      )
      .toList(growable: false);
  final typedCharacterDetails =
      characterDetails.map(ComicCharacter.fromValue).toList(growable: false);
  final typedCreators =
      mappedCreators.map(ComicCreator.fromValue).toList(growable: false);
  final current = selection.kindItem.kindCapability.mapTransport(
    (transport) => ComicCatalogItem.fromJson(transport.kindData),
  );

  final existingTrailerLinks = current.links.where((l) => l.isTrailerLink);
  final newComicLinks = <ComicLink>[
    ...existingTrailerLinks,
    for (final l in links)
      if ((l['url']?.text.trim() ?? '').isNotEmpty)
        ComicLink(
          url: l['url']!.text.trim(),
          title: emptyToNull(l['title']?.text ?? ''),
          description: emptyToNull(l['title']?.text ?? ''),
          source: 'manual',
          isAutomatic: false,
          kind: 'external',
        ),
  ];

  final updatedMetadata = current.copyWith(
    creators: typedCreators,
    characterDetails: typedCharacterDetails,
    characters: typedCharacterDetails,
    links: newComicLinks,
  );

  final updatedItem = selection.kindItem.kindCapability.mapTransport(
    (transport) => CatalogSearchCandidate.fromItem(
      transport.replacingKindData(updatedMetadata),
    ),
  );
  return selection.copyWith(kindItem: updatedItem);
}
