import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_metadata.dart';
import 'package:flutter/material.dart';

final class BoardGameExternalLinkDraft {
  BoardGameExternalLinkDraft({BoardGameLink? original})
      : id = original?.id ?? 'boardgame-link-${_nextId++}',
        original = original,
        urlController = TextEditingController(text: original?.url ?? ''),
        descriptionController = TextEditingController(
          text: original?.description ?? '',
        );

  static int _nextId = 0;

  final String id;
  final BoardGameLink? original;
  final TextEditingController urlController;
  final TextEditingController descriptionController;

  BoardGameLink toModel(int position) => BoardGameLink(
        id: original?.id,
        label: original?.label,
        title: original?.title,
        url: urlController.text.trim(),
        site: original?.site,
        name: original?.name,
        kind: original?.kind,
        description: _nullable(descriptionController.text),
        position: position,
        linkType: original?.linkType,
      );

  void dispose() {
    urlController.dispose();
    descriptionController.dispose();
  }
}

String? _nullable(String value) {
  final normalized = value.trim();
  return normalized.isEmpty ? null : normalized;
}
