import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:flutter/material.dart';

export 'package:collectarr_app/features/library/edit/draft/editable_user_external_link.dart';

class EditableTvLink {
  EditableTvLink({
    required this.titleController,
    required this.urlController,
    required this.source,
    required this.isAutomatic,
  });

  factory EditableTvLink.fromTrailerLink(TrailerLinkDto link) => EditableTvLink(
        titleController: TextEditingController(text: link.title ?? ''),
        urlController: TextEditingController(text: link.url),
        source: link.source,
        isAutomatic: link.isAutomatic,
      );

  final TextEditingController titleController;
  final TextEditingController urlController;
  final String? source;
  final bool isAutomatic;

  TrailerLinkDto? toTrailerLink() {
    final url = urlController.text.trim();
    if (url.isEmpty) return null;
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
