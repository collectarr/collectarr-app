import 'package:collectarr_app/features/library/kinds/comic/domain/comic_link.dart';
import 'package:flutter/material.dart';

final class ComicExternalLinkDraft {
  ComicExternalLinkDraft({String url = '', String title = ''})
      : id = 'comic-link-${_nextId++}',
        urlController = TextEditingController(text: url),
        titleController = TextEditingController(text: title);

  static int _nextId = 0;

  final String id;
  final TextEditingController urlController;
  final TextEditingController titleController;

  ComicLink toModel() {
    final title = _nullable(titleController.text);
    return ComicLink(
      url: urlController.text.trim(),
      title: title,
      description: title,
      source: 'manual',
      isAutomatic: false,
      kind: 'external',
    );
  }

  void dispose() {
    urlController.dispose();
    titleController.dispose();
  }
}

String? _nullable(String value) {
  final normalized = value.trim();
  return normalized.isEmpty ? null : normalized;
}
