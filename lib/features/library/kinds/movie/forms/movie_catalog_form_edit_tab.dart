import 'package:collectarr_app/features/library/add/schema/add_schema_renderer.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_shell_state.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/kinds/movie/forms/movie_catalog_form_schema.dart';
import 'package:collectarr_app/features/library/kinds/movie/forms/movie_catalog_form_values.dart';
import 'package:collectarr_app/features/library/kinds/movie/vocabulary/movie_vocabularies.dart';
import 'package:flutter/material.dart';

/// The Edit tab uses the same Movie field definitions and schema renderer as
/// Manual Add. Its containing edit dialog remains the owner of Save/Cancel.
final class MovieCatalogFormEditTab extends StatelessWidget {
  const MovieCatalogFormEditTab({
    super.key,
    required this.state,
    required this.values,
    required this.itemId,
    required this.fieldIds,
    required this.sectionLabel,
    required this.markDirty,
  });

  final LibraryEditShellState state;
  final MovieCatalogFormValues values;
  final String itemId;
  final Set<String> fieldIds;
  final String sectionLabel;
  final VoidCallback markDirty;

  @override
  Widget build(BuildContext context) {
    final schema = movieCatalogFormSchemaFor<MovieCatalogFormValues>(
      values: (draft) => draft,
      fieldIds: fieldIds,
      sectionLabel: sectionLabel,
      formatOptions: _options(
        MovieVocabularyIds.physicalFormat.value,
        MovieVocabularies.physicalFormat.builtIns,
      ),
      genreOptions: _options(
        MovieVocabularyIds.genre.value,
        MovieVocabularies.genre.builtIns,
      ),
      regionOptions: _options(
        MovieVocabularyIds.region.value,
        MovieVocabularies.region.builtIns,
      ),
      distributorOptions: _options(
        MovieVocabularyIds.distributor.value,
        MovieVocabularies.distributor.builtIns,
      ),
      audioTrackOptions: _options(
        MovieVocabularyIds.audio.value,
        MovieVocabularies.audio.builtIns,
      ),
      subtitleOptions: _options(
        MovieVocabularyIds.subtitles.value,
        MovieVocabularies.subtitles.builtIns,
      ),
    );

    return EditTabShell(
      children: [
        AddSchemaRenderer<MovieCatalogFormValues>.embedded(
          key: ValueKey('movie-fields-$itemId-$sectionLabel'),
          schema: schema,
          draft: values,
          mediaKind: state.type.kind.apiValue,
          onChanged: markDirty,
          onVocabularyValueChanged: ({
            required fieldId,
            required listName,
            required value,
          }) {
            state.recordPendingVocabularyValue(
              fieldId: fieldId,
              listName: listName,
              value: value,
              options: _optionsFor(fieldId),
              allowCustomValues: true,
              mediaKind: state.type.kind.apiValue,
            );
          },
          onVocabularyValuesChanged: ({
            required fieldId,
            required listName,
            required values,
          }) {
            state.recordPendingVocabularyValues(
              fieldId: fieldId,
              listName: listName,
              values: values,
              options: _optionsFor(fieldId),
              allowCustomValues: true,
              mediaKind: state.type.kind.apiValue,
            );
          },
        ),
      ],
    );
  }

  List<String> _options(String key, Iterable<String> fallback) =>
      state.kindVocabularies[key]?.toList(growable: false) ??
      fallback.toList(growable: false);

  List<String> _optionsFor(String fieldId) => switch (fieldId) {
        'physical_format' => _options(
            MovieVocabularyIds.physicalFormat.value,
            MovieVocabularies.physicalFormat.builtIns,
          ),
        'genres' => _options(
            MovieVocabularyIds.genre.value,
            MovieVocabularies.genre.builtIns,
          ),
        'country' => _options(
            MovieVocabularyIds.region.value,
            MovieVocabularies.region.builtIns,
          ),
        'publisher' => _options(
            MovieVocabularyIds.distributor.value,
            MovieVocabularies.distributor.builtIns,
          ),
        'audio_tracks' => _options(
            MovieVocabularyIds.audio.value,
            MovieVocabularies.audio.builtIns,
          ),
        'subtitles' => _options(
            MovieVocabularyIds.subtitles.value,
            MovieVocabularies.subtitles.builtIns,
          ),
        _ => const <String>[],
      };
}
