import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_link.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_catalog_item.dart';
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

List<EditableComicCreator> initComicCreators(ComicCatalogItem item) {
  return [
    for (final creator in item.creators)
      EditableComicCreator.fromMetadata(creator.toJson()),
  ];
}

List<EditableComicCharacter> initComicCharacters(ComicCatalogItem item) {
  if (item.characterDetails.isNotEmpty) {
    return [
      for (final character in item.characterDetails)
        EditableComicCharacter.fromMetadata(character.toJson()),
    ];
  }
  if (item.characters.isNotEmpty) {
    return [
      for (final character in item.characters)
        if (character.name?.trim().isNotEmpty == true)
          EditableComicCharacter.fromMetadata(character.toJson()),
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
    creators: typedCreators.isNotEmpty ? typedCreators : current.creators,
    characterDetails: typedCharacterDetails.isNotEmpty
        ? typedCharacterDetails
        : current.characterDetails,
    characters: typedCharacterDetails.isNotEmpty
        ? typedCharacterDetails
        : current.characters,
    links: newComicLinks,
  );

  final updatedItem = selection.kindItem.kindCapability.mapTransport(
    (transport) => CatalogSearchCandidate.fromItem(
      transport.replacingKindData(updatedMetadata),
    ),
  );
  return selection.copyWith(kindItem: updatedItem);
}
