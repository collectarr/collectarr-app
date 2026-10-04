import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/kinds/anime/edit/anime_edit_tab_helpers.dart';
import 'package:collectarr_app/features/library/kinds/anime/edit/anime_edit_draft_contract.dart';
import 'package:flutter/material.dart';

class AnimeEditSpecsTab extends StatelessWidget {
  const AnimeEditSpecsTab({
    super.key,
    required this.animeDraft,
    required this.accent,
  });

  final AnimeEditDraftContract animeDraft;
  final Color accent;

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
              buildAnimeResponsiveFields([
                LibraryEditTextField(
                  label: 'Audio tracks',
                  controller: animeDraft.audioTracksController,
                ),
                LibraryEditTextField(
                  label: 'Subtitles',
                  controller: animeDraft.subtitlesController,
                ),
              ]),
              const SizedBox(height: 10),
              buildAnimeResponsiveFields([
                LibraryEditTextField(
                  label: 'Layers',
                  controller: animeDraft.layersController,
                ),
                LibraryEditTextField(
                  label: 'Color',
                  controller: animeDraft.colorController,
                ),
                buildAnimeField(
                  controller: animeDraft.nrDiscsController,
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
