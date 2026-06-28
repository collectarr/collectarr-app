part of 'library_edit_dialog.dart';

// Mutable comic creator/character editing models used by the comic edit
// tabs. Extracted from library_edit_dialog.dart to keep the renderer file
// focused on widget behavior.

class _EditableComicCreator {
  _EditableComicCreator({
    required this.nameController,
    required this.roleController,
    Map<String, dynamic>? metadata,
  }) : metadata = Map<String, dynamic>.from(metadata ?? const {});

  factory _EditableComicCreator.custom({String name = '', String role = ''}) {
    return _EditableComicCreator(
      nameController: TextEditingController(text: name),
      roleController: TextEditingController(text: role),
      metadata: const {'source_type': 'custom'},
    );
  }

  factory _EditableComicCreator.fromMetadata(Map<String, dynamic> metadata) {
    return _EditableComicCreator(
      nameController:
          TextEditingController(text: metadata['name']?.toString() ?? ''),
      roleController: TextEditingController(
        text: metadata['role']?.toString() ?? metadata['job']?.toString() ?? '',
      ),
      metadata: metadata,
    );
  }

  factory _EditableComicCreator.fromLookupResult(Map<String, dynamic> result) {
    final role = result['role']?.toString().trim().isNotEmpty == true
        ? result['role']!.toString().trim()
        : result['job']?.toString().trim().isNotEmpty == true
            ? result['job']!.toString().trim()
            : '';
    return _EditableComicCreator(
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

class _EditableComicCharacter {
  _EditableComicCharacter({
    required this.nameController,
    required this.realNameController,
    Map<String, dynamic>? metadata,
  }) : metadata = Map<String, dynamic>.from(metadata ?? const {});

  factory _EditableComicCharacter.custom(String name) {
    return _EditableComicCharacter(
      nameController: TextEditingController(text: name),
      realNameController: TextEditingController(),
      metadata: const {'source_type': 'custom'},
    );
  }

  factory _EditableComicCharacter.fromMetadata(Map<String, dynamic> metadata) {
    return _EditableComicCharacter(
      nameController:
          TextEditingController(text: metadata['name']?.toString() ?? ''),
      realNameController:
          TextEditingController(text: metadata['real_name']?.toString() ?? ''),
      metadata: metadata,
    );
  }

  factory _EditableComicCharacter.fromLookupResult(
      Map<String, dynamic> result) {
    return _EditableComicCharacter(
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

extension _LibraryEditRendererComicHelpers on _LibraryEditRendererState {
  void _initializeComicEditorsForState() {
    if (!_isComicKind) {
      return;
    }
    for (final creator in widget.item.creators ?? const <Map<String, dynamic>>[]) {
      _comicCreators.add(_EditableComicCreator.fromMetadata(creator));
    }
    if (widget.item.characterDetails != null &&
        widget.item.characterDetails!.isNotEmpty) {
      for (final character in widget.item.characterDetails!) {
        _comicCharacters.add(_EditableComicCharacter.fromMetadata(character));
      }
    } else {
      for (final characterName in widget.item.characters ?? const <String>[]) {
        _comicCharacters.add(_EditableComicCharacter.custom(characterName));
      }
    }
    for (final link in widget.item.trailerUrls.where((entry) => entry.isExternalLink)) {
      _comicLinks.add(_createComicLinkControllers(
        title: link.title ?? link.description ?? '',
        url: link.url,
      ));
    }
  }

  LibraryEditSelection _applyComicSelectionEdits(
    LibraryEditSelection selection,
  ) {
    if (!_isComicKind) {
      return selection;
    }
    final creators = _comicCreators
        .map((creator) => creator.toMap())
        .where(
          (creator) => (creator['name']?.toString().trim().isNotEmpty ?? false),
        )
        .toList(growable: false);
    final characterDetails = _comicCharacters
        .map((character) => character.toMap())
        .where(
          (character) =>
              (character['name']?.toString().trim().isNotEmpty ?? false),
        )
        .toList(growable: false);
    final characters = characterDetails
        .map((character) => character['name']!.toString())
        .toList(growable: false);
    final trailerLinks = selection.item.trailerUrls
        .where((link) => link.isTrailerLink)
        .toList(growable: true);
    for (final link in _comicLinks) {
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
        creators: creators.isEmpty ? null : creators,
        characterDetails: characterDetails.isEmpty ? null : characterDetails,
        characters: characters.isEmpty ? null : characters,
        trailerUrls: trailerLinks,
      ),
      personal: selection.personal,
      wishlist: selection.wishlist,
      tracking: selection.tracking,
      customFieldEdits: selection.customFieldEdits,
      itemImageEdits: selection.itemImageEdits,
    );
  }
}
