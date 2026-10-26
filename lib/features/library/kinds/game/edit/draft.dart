import 'package:collectarr_app/features/library/edit/fields/library_external_links_draft_editor.dart';
import 'package:collectarr_app/features/library/edit/session/library_vocabulary_edit_accumulator.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_metadata.dart';
import 'package:collectarr_app/features/library/kinds/game/forms/catalog_form_adapters.dart';
import 'package:collectarr_app/features/library/kinds/game/forms/catalog_form_values.dart';

/// Catalog state of the Game editor: Main and Description values, links and
/// YouTube trailers.
final class GameItemEditDraft {
  GameItemEditDraft.fromMetadata(GameCatalogMetadata metadata)
      : original = metadata,
        values = gameCatalogFormValuesFromMetadata(metadata),
        links = [
          for (final link in metadata.links)
            if (link.isExternalLink) _linkValue(link),
        ],
        trailers = [
          for (final link in metadata.links)
            if (link.isTrailerLink) _linkValue(link),
        ];

  final GameCatalogMetadata original;
  final GameCatalogFormValues values;
  List<LibraryExternalLinkValue> links;
  List<LibraryExternalLinkValue> trailers;
  LibraryVocabularyEditAccumulator vocabularyEdits =
      LibraryVocabularyEditAccumulator();

  GameCatalogMetadata toMetadata() {
    final updated = applyGameCatalogFormValues(
      current: original,
      values: values,
      title: values.title,
    );
    return GameCatalogMetadata.fromJson(updated.toJson()
      ..['external_links'] = _linkJson(links, kind: 'external')
      ..['trailer_urls'] = _linkJson(trailers, kind: 'trailer'));
  }
}

LibraryExternalLinkValue _linkValue(GameCatalogLink link) =>
    LibraryExternalLinkValue(
      url: link.url,
      title: link.title ?? link.label ?? link.name ?? '',
      description: link.description ?? '',
    );

List<Map<String, dynamic>> _linkJson(
  List<LibraryExternalLinkValue> values, {
  required String kind,
}) =>
    [
      for (final (index, value)
          in values.where((value) => value.url.trim().isNotEmpty).indexed)
        GameCatalogLink(
          url: value.url.trim(),
          title: _optional(value.title),
          label: _optional(value.title),
          description: _optional(value.description),
          kind: kind,
          linkType: kind,
          position: index + 1,
        ).toJson(),
    ];

String? _optional(String value) {
  final normalized = value.trim();
  return normalized.isEmpty ? null : normalized;
}
