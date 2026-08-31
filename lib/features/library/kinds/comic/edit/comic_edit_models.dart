import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/edit/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/edit/library_edit_models.dart';
import 'package:collectarr_app/features/library/kinds/comic/contracts/comic_contracts.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_metadata.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:flutter/material.dart';

class EditableComicCreator {
  EditableComicCreator({
    required this.nameController,
    required this.roleController,
    Map<String, dynamic>? metadata,
  }) : metadata = Map<String, dynamic>.from(metadata ?? const {});

  factory EditableComicCreator.custom({String name = '', String role = ''}) {
    return EditableComicCreator(
      nameController: TextEditingController(text: name),
      roleController: TextEditingController(text: role),
      metadata: const {'source_type': 'custom'},
    );
  }

  factory EditableComicCreator.fromMetadata(Map<String, dynamic> metadata) {
    return EditableComicCreator(
      nameController:
          TextEditingController(text: metadata['name']?.toString() ?? ''),
      roleController: TextEditingController(
        text: metadata['role']?.toString() ?? metadata['job']?.toString() ?? '',
      ),
      metadata: metadata,
    );
  }

  factory EditableComicCreator.fromLookupResult(Map<String, dynamic> result) {
    final role = result['role']?.toString().trim().isNotEmpty == true
        ? result['role']!.toString().trim()
        : result['job']?.toString().trim().isNotEmpty == true
            ? result['job']!.toString().trim()
            : '';
    return EditableComicCreator(
      nameController:
          TextEditingController(text: result['name']?.toString() ?? ''),
      roleController: TextEditingController(text: role),
      metadata: {
        ...result,
        'source_type': 'core',
      },
    );
  }

  final TextEditingController nameController;
  final TextEditingController roleController;
  final Map<String, dynamic> metadata;

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{
      ...metadata,
      'name': nameController.text.trim(),
      'role': roleController.text.trim(),
      'source_type': metadata['source_type']?.toString() ?? 'custom',
    };
    result.removeWhere(
      (key, value) =>
          value == null || (value is String && value.trim().isEmpty),
    );
    return result;
  }

  void dispose() {
    nameController.dispose();
    roleController.dispose();
  }
}

class EditableComicCharacter {
  EditableComicCharacter({
    required this.nameController,
    required this.realNameController,
    Map<String, dynamic>? metadata,
  }) : metadata = Map<String, dynamic>.from(metadata ?? const {});

  factory EditableComicCharacter.custom(String name) {
    return EditableComicCharacter(
      nameController: TextEditingController(text: name),
      realNameController: TextEditingController(),
      metadata: const {'source_type': 'custom'},
    );
  }

  factory EditableComicCharacter.fromMetadata(Map<String, dynamic> metadata) {
    return EditableComicCharacter(
      nameController:
          TextEditingController(text: metadata['name']?.toString() ?? ''),
      realNameController:
          TextEditingController(text: metadata['real_name']?.toString() ?? ''),
      metadata: metadata,
    );
  }

  factory EditableComicCharacter.fromLookupResult(Map<String, dynamic> result) {
    return EditableComicCharacter(
      nameController:
          TextEditingController(text: result['name']?.toString() ?? ''),
      realNameController:
          TextEditingController(text: result['real_name']?.toString() ?? ''),
      metadata: {
        ...result,
        'source_type': 'core',
      },
    );
  }

  final TextEditingController nameController;
  final TextEditingController realNameController;
  final Map<String, dynamic> metadata;

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{
      ...metadata,
      'name': nameController.text.trim(),
      'real_name': realNameController.text.trim(),
      'source_type': metadata['source_type']?.toString() ?? 'custom',
    };
    result.removeWhere(
      (key, value) =>
          value == null || (value is String && value.trim().isEmpty),
    );
    return result;
  }

  void dispose() {
    nameController.dispose();
    realNameController.dispose();
  }
}

List<EditableComicCreator> initComicCreators(ComicCatalogMetadata item) {
  final payload = item.toSyncPayload();
  final creators = payload['creators'];
  if (creators is List) {
    return [
      for (final creator in creators.whereType<Map<String, dynamic>>())
        EditableComicCreator.fromMetadata(creator),
    ];
  }
  return const [];
}

List<EditableComicCharacter> initComicCharacters(ComicCatalogMetadata item) {
  final payload = item.toSyncPayload();
  final characterDetails = payload['character_details'];
  if (characterDetails is List && characterDetails.isNotEmpty) {
    return [
      for (final character
          in characterDetails.whereType<Map<String, dynamic>>())
        EditableComicCharacter.fromMetadata(character),
    ];
  }
  final characters = payload['characters'];
  if (characters is List) {
    return [
      for (final characterName in characters.map((c) => c.toString()))
        EditableComicCharacter.custom(characterName),
    ];
  }
  return const [];
}

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
  final characterNames = characterDetails
      .map((character) => character['name']!.toString())
      .toList(growable: false);
  final current = selection.item.kindMetadata is ComicCatalogMetadata
      ? selection.item.kindMetadata as ComicCatalogMetadata
      : ComicCatalogMetadata.fromJson(selection.item.kindMetadata.toSyncPayload());

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
    creators: mappedCreators.isNotEmpty ? mappedCreators : current.creators,
    characterDetails:
        characterDetails.isNotEmpty ? characterDetails : current.characterDetails,
    characters: characterNames.isNotEmpty ? characterNames : current.characters,
    links: newComicLinks,
  );

  final effectiveTrailerUrls = newComicLinks.isNotEmpty
      ? [
          for (final l in newComicLinks)
            TrailerLinkDto(
              url: l.url,
              title: l.title,
              description: l.description,
              source: l.source,
              isAutomatic: l.isAutomatic,
              kind: l.kind,
            ),
        ]
      : selection.item.common.trailerUrls;

  final updatedItem = selection.item.copyWith(
    common: selection.item.common.copyWith(
      trailerUrls: effectiveTrailerUrls,
    ),
    kindMetadata: updatedMetadata,
  );
  return selection.copyWith(item: updatedItem);
}
