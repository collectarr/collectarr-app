import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/kinds/tv/edit/tv_edit_tab_helpers.dart';
import 'package:collectarr_app/features/library/kinds/tv/edit/tv_edit_draft_contract.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_selection_fields.dart';
import 'package:flutter/material.dart';

class TvEditSpecsTab extends StatelessWidget {
  const TvEditSpecsTab({
    super.key,
    required this.tvDraft,
    required this.accent,
    required this.audioTrackOptions,
    required this.subtitleOptions,
  });

  final TvEditDraftContract tvDraft;
  final Color accent;
  final List<String> audioTrackOptions;
  final List<String> subtitleOptions;

  @override
  Widget build(BuildContext context) {
    return EditTabShell(
      children: [
        EditSection(
          title: 'Specs',
          accent: accent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildTvResponsiveFields([
                LibraryVocabularyField(
                  label: 'Audio tracks',
                  controller: tvDraft.audioTracksController,
                  options: audioTrackOptions,
                  multiSelect: true,
                ),
                LibraryVocabularyField(
                  label: 'Subtitles',
                  controller: tvDraft.subtitlesController,
                  options: subtitleOptions,
                  multiSelect: true,
                ),
              ]),
              const SizedBox(height: 10),
              buildTvResponsiveFields([
                LibraryEditTextField(
                  label: 'Layers',
                  controller: tvDraft.layersController,
                ),
                LibraryEditTextField(
                  label: 'Color',
                  controller: tvDraft.colorController,
                ),
                buildTvField(
                  controller: tvDraft.nrDiscsController,
                  label: 'Discs',
                  validator: optionalIntValidator,
                ),
              ]),
            ],
          ),
        ),
      ],
    );
  }
}
