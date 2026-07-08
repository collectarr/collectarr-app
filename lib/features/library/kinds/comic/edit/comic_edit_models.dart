import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/library/edit/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/edit/library_edit_models.dart';
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

  factory EditableComicCharacter.fromLookupResult(
      Map<String, dynamic> result) {
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

List<EditableComicCreator> initComicCreators(LibraryMetadataItem item) {
  return [
    for (final creator in item.creators ?? const <Map<String, dynamic>>[])
      EditableComicCreator.fromMetadata(creator),
  ];
}

List<EditableComicCharacter> initComicCharacters(LibraryMetadataItem item) {
  if (item.characterDetails != null && item.characterDetails!.isNotEmpty) {
    return [
      for (final character in item.characterDetails!)
        EditableComicCharacter.fromMetadata(character),
    ];
  }
  return [
    for (final characterName in item.characters ?? const <String>[])
      EditableComicCharacter.custom(characterName),
  ];
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
  final trailerLinks = selection.item.trailerUrls
      .where((link) => link.isTrailerLink)
      .toList(growable: true);
  for (final link in links) {
    final title = link['title']?.text.trim() ?? '';
    final url = link['url']?.text.trim() ?? '';
    if (url.isEmpty) {
      continue;
    }
    trailerLinks.add(
      TrailerLink(
        url: url,
        title: emptyToNull(title),
        description: emptyToNull(title),
        source: 'manual',
        isAutomatic: false,
        kind: 'external',
      ),
    );
  }
  return LibraryEditSelection(
    scope: selection.scope,
    item: selection.item.copyWith(
      creators: mappedCreators.isEmpty ? null : mappedCreators,
      characterDetails: characterDetails.isEmpty ? null : characterDetails,
      characters: characterNames.isEmpty ? null : characterNames,
      trailerUrls: trailerLinks,
    ),
    personal: selection.personal,
    wishlist: selection.wishlist,
    tracking: selection.tracking,
    customFieldEdits: selection.customFieldEdits,
    itemImageEdits: selection.itemImageEdits,
    submitAction: selection.submitAction,
  );
}