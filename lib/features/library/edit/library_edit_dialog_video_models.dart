part of 'library_edit_dialog.dart';

enum VideoCreditKind { cast, crew }

const _videoCastRoleTags = <String>{
  'actor',
  'voice',
  'voice actor',
  'guest star',
  'cameo',
  'narrator',
};

class EditableVideoCredit {
  EditableVideoCredit({
    required this.nameController,
    required this.roleController,
    Map<String, dynamic>? metadata,
  }) : metadata = Map<String, dynamic>.from(metadata ?? const {});

  factory EditableVideoCredit.custom({
    String name = '',
    String role = '',
    String sourceType = 'custom',
  }) {
    return EditableVideoCredit(
      nameController: TextEditingController(text: name),
      roleController: TextEditingController(text: role),
      metadata: {'source_type': sourceType},
    );
  }

  factory EditableVideoCredit.fromMetadata(Map<String, dynamic> metadata) {
    return EditableVideoCredit(
      nameController:
          TextEditingController(text: metadata['name']?.toString() ?? ''),
      roleController: TextEditingController(
        text: metadata['role']?.toString() ?? metadata['job']?.toString() ?? '',
      ),
      metadata: metadata,
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
      (key, value) => value == null || (value is String && value.trim().isEmpty),
    );
    return result;
  }

  void dispose() {
    nameController.dispose();
    roleController.dispose();
  }
}

class EditableVideoLink {
  EditableVideoLink({
    required this.titleController,
    required this.urlController,
    required this.source,
    required this.isAutomatic,
  });

  factory EditableVideoLink.fromTrailerLink(TrailerLink link) {
    return EditableVideoLink(
      titleController: TextEditingController(text: link.title ?? ''),
      urlController: TextEditingController(text: link.url),
      source: link.source,
      isAutomatic: link.isAutomatic,
    );
  }

  final TextEditingController titleController;
  final TextEditingController urlController;
  final String? source;
  final bool isAutomatic;

  TrailerLink? toTrailerLink() {
    final url = urlController.text.trim();
    if (url.isEmpty) {
      return null;
    }
    final title = titleController.text.trim();
    return TrailerLink(
      url: url,
      title: title.isEmpty ? null : title,
      description: title.isEmpty ? null : title,
      source: source ?? 'manual',
      isAutomatic: isAutomatic,
      kind: 'external',
    );
  }

  void dispose() {
    titleController.dispose();
    urlController.dispose();
  }
}

class EditableUserExternalLink {
  EditableUserExternalLink({
    required this.labelController,
    required this.urlController,
    required this.kind,
    this.id,
    this.editionId,
    this.variantId,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory EditableUserExternalLink.fromUserExternalLink(UserExternalLink link) {
    return EditableUserExternalLink(
      id: link.id,
      labelController: TextEditingController(text: link.label),
      urlController: TextEditingController(text: link.url),
      kind: link.kind,
      editionId: link.editionId,
      variantId: link.variantId,
      createdAt: link.createdAt,
      updatedAt: link.updatedAt,
    );
  }

  factory EditableUserExternalLink.fromTrailerLink(
    TrailerLink link, {
    String kind = 'trailer',
  }) {
    return EditableUserExternalLink(
      labelController: TextEditingController(text: link.title ?? ''),
      urlController: TextEditingController(text: link.url),
      kind: kind,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  final String? id;
  final TextEditingController labelController;
  final TextEditingController urlController;
  String kind;
  final String? editionId;
  final String? variantId;
  final DateTime createdAt;
  DateTime updatedAt;

  UserExternalLink? toUserExternalLink({
    required String itemId,
  }) {
    final url = urlController.text.trim();
    if (url.isEmpty) {
      return null;
    }
    final label = labelController.text.trim();
    return UserExternalLink(
      id: id ?? const Uuid().v4(),
      itemId: itemId,
      editionId: editionId,
      variantId: variantId,
      label: label.isEmpty ? url : label,
      url: url,
      kind: kind.trim().isEmpty ? 'custom' : kind.trim(),
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  void dispose() {
    labelController.dispose();
    urlController.dispose();
  }
}

bool _isVideoCastRole(String? role) {
  final normalized = role?.trim().toLowerCase() ?? '';
  if (normalized.isEmpty) {
    return true;
  }
  return _videoCastRoleTags.any(normalized.contains);
}

List<EditableVideoCredit> splitVideoCredits(
  List<Map<String, dynamic>> creators, {
  required VideoCreditKind kind,
}) {
  final credits = <EditableVideoCredit>[];
  for (final creator in creators) {
    final role = creator['role']?.toString();
    final isCast = _isVideoCastRole(role);
    if ((kind == VideoCreditKind.cast && isCast) ||
        (kind == VideoCreditKind.crew && !isCast)) {
      credits.add(EditableVideoCredit.fromMetadata(creator));
    }
  }
  return credits;
}
