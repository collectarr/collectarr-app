import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_metadata.dart';
import 'package:flutter/material.dart';

export 'package:collectarr_app/features/library/edit/draft/editable_user_external_link.dart';

enum TvCreditKind { cast, crew }

/// Editable values derived from the TV kind's typed catalog credits.
@immutable
class TvCreditInput {
  const TvCreditInput({
    required this.name,
    this.role,
    this.originalCredit,
  });

  final String name;
  final String? role;
  final TvPersonCredit? originalCredit;
}

const _videoCastRoleTags = <String>{
  'actor',
  'voice',
  'voice actor',
  'guest star',
  'cameo',
  'narrator',
};

class EditableTvCredit {
  EditableTvCredit({
    required this.nameController,
    required this.roleController,
    this.originalCredit,
  });

  factory EditableTvCredit.custom({
    String name = '',
    String role = '',
  }) {
    return EditableTvCredit(
      nameController: TextEditingController(text: name),
      roleController: TextEditingController(text: role),
    );
  }

  factory EditableTvCredit.fromInput(TvCreditInput input) {
    return EditableTvCredit(
      nameController: TextEditingController(text: input.name),
      roleController: TextEditingController(
        text: input.role ?? '',
      ),
      originalCredit: input.originalCredit,
    );
  }

  final TextEditingController nameController;
  final TextEditingController roleController;
  final TvPersonCredit? originalCredit;

  TvCreditInput toInput() {
    return TvCreditInput(
      name: nameController.text.trim(),
      role: roleController.text.trim().isEmpty
          ? null
          : roleController.text.trim(),
      originalCredit: originalCredit,
    );
  }

  void dispose() {
    nameController.dispose();
    roleController.dispose();
  }
}

class EditableTvLink {
  EditableTvLink({
    required this.titleController,
    required this.urlController,
    required this.source,
    required this.isAutomatic,
  });

  factory EditableTvLink.fromTrailerLink(TrailerLinkDto link) {
    return EditableTvLink(
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

bool isTvCastRole(String? role) {
  final normalized = role?.trim().toLowerCase() ?? '';
  if (normalized.isEmpty) {
    return true;
  }
  return _videoCastRoleTags.any(normalized.contains);
}

List<EditableTvCredit> splitTvCredits(
  List<TvCreditInput> creators, {
  required TvCreditKind kind,
}) {
  final credits = <EditableTvCredit>[];
  for (final creator in creators) {
    final role = creator.role;
    final isCast = isTvCastRole(role);
    if ((kind == TvCreditKind.cast && isCast) ||
        (kind == TvCreditKind.crew && !isCast)) {
      credits.add(EditableTvCredit.fromInput(creator));
    }
  }
  return credits;
}
