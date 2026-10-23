import 'package:collectarr_app/features/library/edit/fields/library_external_links_draft_editor.dart';
import 'package:collectarr_app/features/library/edit/session/library_vocabulary_edit_accumulator.dart';
import 'package:collectarr_app/features/library/kinds/game_hardware/domain/game_hardware_metadata.dart';

import 'package:collectarr_app/features/library/kinds/game_hardware/forms/game_hardware_catalog_form_values.dart';

/// Catalog state of the GameHardware editor: Main and Description values, links and
/// YouTube trailers.
final class GameHardwareItemEditDraft {
  GameHardwareItemEditDraft.fromMetadata(GameHardwareCatalogMetadata metadata)
      : original = metadata,
        values = GameHardwareCatalogFormValues.fromMetadata(metadata),
        links = [
          for (final link in metadata.links)
            if (link.isExternalLink) _linkValue(link),
        ],
        trailers = [
          for (final link in metadata.links)
            if (link.isTrailerLink) _linkValue(link),
        ];

  final GameHardwareCatalogMetadata original;
  final GameHardwareCatalogFormValues values;
  List<LibraryExternalLinkValue> links;
  List<LibraryExternalLinkValue> trailers;
  LibraryVocabularyEditAccumulator vocabularyEdits =
      LibraryVocabularyEditAccumulator();

  GameHardwareCatalogMetadata toMetadata() {
    final updated = values.toMetadata(title: values.title);
    return GameHardwareCatalogMetadata.fromJson(updated.toJson()
      ..['external_links'] = _linkJson(links, kind: 'external')
      ..['trailer_urls'] = _linkJson(trailers, kind: 'trailer'));
  }
}

LibraryExternalLinkValue _linkValue(GameHardwareCatalogLink link) =>
    LibraryExternalLinkValue(
      url: link.url,
      title: link.title ?? '',
      description: link.description ?? '',
    );

List<Map<String, dynamic>> _linkJson(
  List<LibraryExternalLinkValue> values, {
  required String kind,
}) =>
    [
      for (final value in values.where((value) => value.url.trim().isNotEmpty))
        GameHardwareCatalogLink(
          url: value.url.trim(),
          title: _optional(value.title),
          description: _optional(value.description),
          kind: kind,
        ).toJson(),
    ];

String? _optional(String value) {
  final normalized = value.trim();
  return normalized.isEmpty ? null : normalized;
}
