import 'package:collectarr_app/features/library/kinds/comic/domain/comic_catalog_item.dart';
import 'package:flutter/material.dart';

final class EditableComicCreator {
  EditableComicCreator({
    required this.nameController,
    required this.roleController,
    Map<String, dynamic>? metadata,
  }) : metadata = Map<String, dynamic>.from(metadata ?? const {});

  factory EditableComicCreator.custom({String name = '', String role = ''}) =>
      EditableComicCreator(
        nameController: TextEditingController(text: name),
        roleController: TextEditingController(text: role),
        metadata: const {'source_type': 'custom'},
      );

  factory EditableComicCreator.fromMetadata(Map<String, dynamic> metadata) =>
      EditableComicCreator(
        nameController:
            TextEditingController(text: metadata['name']?.toString() ?? ''),
        roleController: TextEditingController(
          text:
              metadata['role']?.toString() ?? metadata['job']?.toString() ?? '',
        ),
        metadata: metadata,
      );

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
      metadata: {...result, 'source_type': 'core'},
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

final class EditableComicCharacter {
  EditableComicCharacter({
    required this.nameController,
    required this.realNameController,
    Map<String, dynamic>? metadata,
  }) : metadata = Map<String, dynamic>.from(metadata ?? const {});

  factory EditableComicCharacter.custom(String name) => EditableComicCharacter(
        nameController: TextEditingController(text: name),
        realNameController: TextEditingController(),
        metadata: const {'source_type': 'custom'},
      );

  factory EditableComicCharacter.fromMetadata(Map<String, dynamic> metadata) =>
      EditableComicCharacter(
        nameController:
            TextEditingController(text: metadata['name']?.toString() ?? ''),
        realNameController: TextEditingController(
            text: metadata['real_name']?.toString() ?? ''),
        metadata: metadata,
      );

  factory EditableComicCharacter.fromLookupResult(
          Map<String, dynamic> result) =>
      EditableComicCharacter(
        nameController:
            TextEditingController(text: result['name']?.toString() ?? ''),
        realNameController:
            TextEditingController(text: result['real_name']?.toString() ?? ''),
        metadata: {...result, 'source_type': 'core'},
      );

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

List<EditableComicCreator> initComicCreators(ComicCatalogItem item) => [
      for (final creator in item.creators)
        EditableComicCreator.fromMetadata(creator.toJson()),
    ];

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
