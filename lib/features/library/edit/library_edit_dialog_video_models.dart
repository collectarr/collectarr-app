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

extension _LibraryEditRendererVideoHelpers on _LibraryEditRendererState {
  void _initializeVideoEditorsForState() {
    if (!_isVideoKind) {
      return;
    }
    final creators = widget.item.creators ?? const <Map<String, dynamic>>[];
    _videoCastCredits.addAll(
      splitVideoCredits(creators, kind: VideoCreditKind.cast),
    );
    _videoCrewCredits.addAll(
      splitVideoCredits(creators, kind: VideoCreditKind.crew),
    );
  }

  LibraryEditSelection _applyVideoSelectionEdits(
    LibraryEditSelection selection,
  ) {
    if (!_isVideoKind) {
      return selection;
    }
    return LibraryEditSelection(
      scope: selection.scope,
      item: selection.item.copyWith(
        creators: _buildUpdatedVideoCreators(),
      ),
      personal: selection.personal,
      wishlist: selection.wishlist,
      tracking: selection.tracking,
      customFieldEdits: selection.customFieldEdits,
      itemImageEdits: selection.itemImageEdits,
    );
  }

  List<Map<String, dynamic>>? _buildUpdatedVideoCreators() {
    final merged = <Map<String, dynamic>>[
      for (final credit in _videoCastCredits) credit.toMap(),
      for (final credit in _videoCrewCredits) credit.toMap(),
    ];
    return merged.isEmpty
        ? null
        : List<Map<String, dynamic>>.unmodifiable(merged);
  }
}
