import 'package:collectarr_app/features/library/schema/library_field_spec_renderer.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_shell_state.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/kinds/anime/add/anime_add_schema.dart';
import 'package:collectarr_app/features/library/kinds/anime/edit/anime_edit_draft_contract.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:flutter/material.dart';

/// Renders a subset of Anime's Add schema inside the parent Edit dialog.
final class AnimeCatalogFormEditTab extends StatelessWidget {
  const AnimeCatalogFormEditTab({
    super.key,
    required this.state,
    required this.draft,
    required this.itemId,
    required this.fieldIds,
    required this.sectionLabel,
    required this.markDirty,
    this.physicalFormatOptions,
  });

  final LibraryEditShellState state;
  final AnimeEditDraftContract draft;
  final String itemId;
  final Set<String> fieldIds;
  final String sectionLabel;
  final VoidCallback markDirty;
  final Iterable<String>? physicalFormatOptions;

  @override
  Widget build(BuildContext context) => EditTabShell(
        children: [
          LibraryFieldSpecRenderer<AnimeEditDraftContract>.embedded(
            key: ValueKey('anime-fields-$itemId-$sectionLabel'),
            schema: animeAddSchemaFor<AnimeEditDraftContract>(
              fieldIds: fieldIds,
              sectionLabel: sectionLabel,
              physicalFormatOptions: physicalFormatOptions,
            ),
            draft: draft,
            mediaKind: state.type.kind.apiValue,
            onChanged: () {
              if (fieldIds.contains('physical_format')) {
                _updatePhysicalFormatId();
              }
              markDirty();
            },
          ),
        ],
      );

  void _updatePhysicalFormatId() {
    final previousFormat = state.physicalFormats.where(
      (format) => format.id == draft.physicalFormatId,
    );
    final previousLabel =
        previousFormat.isEmpty ? null : previousFormat.first.label;
    final value = (draft.metadata.physicalFormatLabel ??
            draft.metadata.physicalFormat ??
            '')
        .trim()
        .toLowerCase();
    PhysicalMediaFormat? selected;
    for (final format in state.physicalFormats) {
      if (format.label.trim().toLowerCase() == value ||
          format.id.trim().toLowerCase() == value ||
          format.aliases.contains(value)) {
        selected = format;
        break;
      }
    }
    draft.physicalFormatId = selected?.id;
    final variant = draft.metadata.variant?.trim() ?? '';
    if (selected != null && (variant.isEmpty || variant == previousLabel)) {
      draft.metadata = draft.metadata.copyWith(variant: selected.label);
    }
  }
}
