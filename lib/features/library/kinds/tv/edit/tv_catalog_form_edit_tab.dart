import 'package:collectarr_app/features/library/forms/library_field_spec_renderer.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_shell_state.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/kinds/tv/add/tv_add_schema.dart';
import 'package:collectarr_app/features/library/kinds/tv/edit/tv_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/tv/vocabulary/tv_vocabularies.dart';
import 'package:flutter/material.dart';

/// Renders TV catalog fields from the same schema in Manual Add and Edit.
final class TvCatalogFormEditTab extends StatelessWidget {
  const TvCatalogFormEditTab({
    super.key,
    required this.state,
    required this.draft,
    required this.itemId,
    required this.fieldIds,
    required this.sectionLabel,
    required this.markDirty,
  });

  final LibraryEditShellState state;
  final TvEditDraft draft;
  final String itemId;
  final Set<String> fieldIds;
  final String sectionLabel;
  final VoidCallback markDirty;

  @override
  Widget build(BuildContext context) => EditTabShell(
        children: [
          TvCatalogFormFields(
            state: state,
            draft: draft,
            itemId: itemId,
            fieldIds: fieldIds,
            sectionLabel: sectionLabel,
            markDirty: markDirty,
          ),
        ],
      );
}

/// Embedded TV schema content for tabs that compose other kind-owned editors.
final class TvCatalogFormFields extends StatelessWidget {
  const TvCatalogFormFields({
    super.key,
    required this.state,
    required this.draft,
    required this.itemId,
    required this.fieldIds,
    required this.sectionLabel,
    required this.markDirty,
  });

  final LibraryEditShellState state;
  final TvEditDraft draft;
  final String itemId;
  final Set<String> fieldIds;
  final String sectionLabel;
  final VoidCallback markDirty;

  @override
  Widget build(BuildContext context) {
    final physicalFormats = state.physicalFormats;
    final audioOptions = _options(
      TvVocabularyIds.audio.value,
      TvVocabularies.audio.builtIns,
    );
    final subtitleOptions = _options(
      TvVocabularyIds.subtitles.value,
      TvVocabularies.subtitles.builtIns,
    );
    final schema = tvAddSchemaFor<TvEditDraft>(
      fieldIds: fieldIds,
      sectionLabel: sectionLabel,
      formatOptions: physicalFormats.isEmpty
          ? TvVocabularies.physicalFormat.builtIns
          : [for (final format in physicalFormats) format.label],
      physicalFormatIdForValue: _physicalFormatId,
      audioTrackOptions: audioOptions,
      subtitleOptions: subtitleOptions,
    );

    return LibraryFieldSpecRenderer<TvEditDraft>.embedded(
      key: ValueKey('tv-fields-$itemId-$sectionLabel'),
      schema: schema,
      draft: draft,
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
    );
  }

  List<String> _options(String key, Iterable<String> fallback) =>
      state.kindVocabularies[key]?.toList(growable: false) ??
      fallback.toList(growable: false);

  List<String> _optionsFor(String fieldId) => switch (fieldId) {
        'audio_tracks' => _options(
            TvVocabularyIds.audio.value,
            TvVocabularies.audio.builtIns,
          ),
        'subtitles' => _options(
            TvVocabularyIds.subtitles.value,
            TvVocabularies.subtitles.builtIns,
          ),
        _ => const <String>[],
      };

  String? _physicalFormatId(String value) {
    final normalized = value.trim().toLowerCase();
    for (final format in state.physicalFormats) {
      if (format.label.trim().toLowerCase() == normalized ||
          format.id.trim().toLowerCase() == normalized ||
          format.aliases.any((alias) => alias.toLowerCase() == normalized)) {
        return format.id;
      }
    }
    return null;
  }
}
