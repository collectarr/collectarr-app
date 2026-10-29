import 'package:collectarr_app/features/library/kinds/comic/domain/comic_catalog_item.dart';
import 'package:flutter/material.dart';

final class EditableComicCreator {
  EditableComicCreator({
    required this.nameController,
    required this.roleController,
    Map<String, dynamic>? metadata,
    TextEditingController? creditedNameController,
    TextEditingController? sortNameController,
    TextEditingController? joinPhraseController,
    TextEditingController? imageUrlController,
  })  : metadata = Map<String, dynamic>.from(metadata ?? const {}),
        creditedNameController = creditedNameController ??
            TextEditingController(
              text: metadata?['credited_name']?.toString() ?? '',
            ),
        sortNameController = sortNameController ??
            TextEditingController(
              text: metadata?['sort_name']?.toString() ?? '',
            ),
        joinPhraseController = joinPhraseController ??
            TextEditingController(
              text: metadata?['join_phrase']?.toString() ?? '',
            ),
        imageUrlController = imageUrlController ??
            TextEditingController(
              text: metadata?['image_url']?.toString() ?? '',
            );

  factory EditableComicCreator.blank() => EditableComicCreator(
        nameController: TextEditingController(),
        roleController: TextEditingController(),
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

  final TextEditingController nameController;
  final TextEditingController roleController;
  final TextEditingController creditedNameController;
  final TextEditingController sortNameController;
  final TextEditingController joinPhraseController;
  final TextEditingController imageUrlController;
  final Map<String, dynamic> metadata;

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{
      ...metadata,
      'name': nameController.text.trim(),
      'role': roleController.text.trim(),
      'credited_name': creditedNameController.text.trim(),
      'sort_name': sortNameController.text.trim(),
      'join_phrase': joinPhraseController.text.trim(),
      'image_url': imageUrlController.text.trim(),
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
    creditedNameController.dispose();
    sortNameController.dispose();
    joinPhraseController.dispose();
    imageUrlController.dispose();
  }
}

final class EditableComicCharacter {
  EditableComicCharacter({
    required this.nameController,
    required this.realNameController,
    Map<String, dynamic>? metadata,
    TextEditingController? aliasesController,
    TextEditingController? roleController,
    TextEditingController? descriptionController,
    TextEditingController? imageUrlController,
  })  : metadata = Map<String, dynamic>.from(metadata ?? const {}),
        aliasesController = aliasesController ??
            TextEditingController(
              text: _comicAliasesText(metadata?['aliases']),
            ),
        roleController = roleController ??
            TextEditingController(text: metadata?['role']?.toString() ?? ''),
        descriptionController = descriptionController ??
            TextEditingController(
              text: metadata?['description']?.toString() ?? '',
            ),
        imageUrlController = imageUrlController ??
            TextEditingController(
              text: metadata?['image_url']?.toString() ?? '',
            );

  factory EditableComicCharacter.blank() => EditableComicCharacter(
        nameController: TextEditingController(),
        realNameController: TextEditingController(),
      );

  factory EditableComicCharacter.fromMetadata(Map<String, dynamic> metadata) =>
      EditableComicCharacter(
        nameController:
            TextEditingController(text: metadata['name']?.toString() ?? ''),
        realNameController: TextEditingController(
            text: metadata['real_name']?.toString() ?? ''),
        metadata: metadata,
      );

  final TextEditingController nameController;
  final TextEditingController realNameController;
  final TextEditingController aliasesController;
  final TextEditingController roleController;
  final TextEditingController descriptionController;
  final TextEditingController imageUrlController;
  final Map<String, dynamic> metadata;

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{
      ...metadata,
      'name': nameController.text.trim(),
      'real_name': realNameController.text.trim(),
      'aliases': [
        for (final alias in aliasesController.text.split(RegExp(r'[,;\n]')))
          if (alias.trim().isNotEmpty) alias.trim(),
      ],
      'role': roleController.text.trim(),
      'description': descriptionController.text.trim(),
      'image_url': imageUrlController.text.trim(),
    };
    result.removeWhere(
      (key, value) =>
          value == null ||
          (value is String && value.trim().isEmpty) ||
          (key == 'aliases' && value is List && value.isEmpty),
    );
    return result;
  }

  void dispose() {
    nameController.dispose();
    realNameController.dispose();
    aliasesController.dispose();
    roleController.dispose();
    descriptionController.dispose();
    imageUrlController.dispose();
  }
}

String _comicAliasesText(Object? value) {
  if (value is! List) return '';
  return value.whereType<String>().join(', ');
}

List<EditableComicCreator> initComicCreators(ComicCatalogItem item) => [
      for (final creator in item.creators)
        EditableComicCreator.fromMetadata(creator.toJson()),
    ];

List<EditableComicCharacter> initComicCharacters(ComicCatalogItem item) => [
      for (final character in item.characters)
        if (character.name?.trim().isNotEmpty == true)
          EditableComicCharacter.fromMetadata(character.toJson()),
    ];
