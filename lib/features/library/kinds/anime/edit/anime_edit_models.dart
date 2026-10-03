import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:flutter/material.dart';

export 'package:collectarr_app/features/library/edit/draft/editable_user_external_link.dart';

enum AnimeCreditKind { cast, crew }

/// Structural credit input shared by the video editor host.
///
/// Each kind maps its typed credits into this editor value. The editor itself
/// never carries a generic metadata map that could become a second video
/// domain model.
@immutable
class AnimeCreditInput {
  const AnimeCreditInput({
    required this.name,
    this.role,
  });

  final String name;
  final String? role;
}

const _videoCastRoleTags = <String>{
  'actor',
  'voice',
  'voice actor',
  'guest star',
  'cameo',
  'narrator',
};

class EditableAnimeCredit {
  EditableAnimeCredit({
    required this.nameController,
    required this.roleController,
  });

  factory EditableAnimeCredit.custom({
    String name = '',
    String role = '',
  }) {
    return EditableAnimeCredit(
      nameController: TextEditingController(text: name),
      roleController: TextEditingController(text: role),
    );
  }

  factory EditableAnimeCredit.fromInput(AnimeCreditInput input) {
    return EditableAnimeCredit(
      nameController: TextEditingController(text: input.name),
      roleController: TextEditingController(
        text: input.role ?? '',
      ),
    );
  }

  final TextEditingController nameController;
  final TextEditingController roleController;

  AnimeCreditInput toInput() {
    return AnimeCreditInput(
      name: nameController.text.trim(),
      role: roleController.text.trim().isEmpty
          ? null
          : roleController.text.trim(),
    );
  }

  void dispose() {
    nameController.dispose();
    roleController.dispose();
  }
}

class EditableAnimeLink {
  EditableAnimeLink({
    required this.titleController,
    required this.urlController,
    required this.source,
    required this.isAutomatic,
  });

  factory EditableAnimeLink.fromTrailerLink(TrailerLinkDto link) {
    return EditableAnimeLink(
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

  TrailerLinkDto? toTrailerLink() {
    final url = urlController.text.trim();
    if (url.isEmpty) {
      return null;
    }
    final title = titleController.text.trim();
    return TrailerLinkDto(
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

bool isAnimeCastRole(String? role) {
  final normalized = role?.trim().toLowerCase() ?? '';
  if (normalized.isEmpty) {
    return true;
  }
  return _videoCastRoleTags.any(normalized.contains);
}

List<EditableAnimeCredit> splitAnimeCredits(
  List<AnimeCreditInput> creators, {
  required AnimeCreditKind kind,
}) {
  final credits = <EditableAnimeCredit>[];
  for (final creator in creators) {
    final role = creator.role;
    final isCast = isAnimeCastRole(role);
    if ((kind == AnimeCreditKind.cast && isCast) ||
        (kind == AnimeCreditKind.crew && !isCast)) {
      credits.add(EditableAnimeCredit.fromInput(creator));
    }
  }
  return credits;
}
