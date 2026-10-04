import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/add/panes/library_add_manual_pane_shell.dart';
import 'package:collectarr_app/features/library/add/schema/add_schema_renderer.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/add/boardgame_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/add/boardgame_add_schema.dart';
import 'package:flutter/material.dart';

const _boardGameMainFields = {
  'catalog_title',
  'original_title',
  'sort_title',
  'subtitle',
  'publisher',
  'platforms',
  'series_title',
  'year_published',
  'categories',
  'designers',
  'artists',
  'contributors',
  'characters',
  'mechanics',
  'families',
  'themes',
  'expansions',
  'expansion_for',
  'rankings',
  'search_aliases',
  'original_language',
  'country',
  'language',
  'age_rating',
  'audience_rating',
  'release_status',
};
const _boardGameEditionFields = {
  'item_number',
  'barcode',
  'catalog_number',
  'variant',
  'format',
  'release_date',
};
const _boardGamePlayFields = {
  'min_players',
  'max_players',
  'recommended_players',
  'best_players',
  'min_playtime_minutes',
  'max_playtime_minutes',
  'min_age',
  'complexity_weight',
  'bgg_rating',
  'bgg_rating_count',
  'bgg_rank',
};

class BoardgameAddManualPane extends StatelessWidget {
  const BoardgameAddManualPane({super.key, required this.request});

  final LibraryAddManualPaneRequest request;

  @override
  Widget build(BuildContext context) {
    final draft = request.manualDraftAs<BoardgameAddManualDraft>();
    Widget buildFields(
      Set<String> fieldIds, {
      required String sectionLabel,
    }) =>
        AddSchemaRenderer<BoardgameAddManualDraft>.embedded(
          schema: boardGameAddSchemaFor(
            fieldIds: fieldIds,
            sectionLabels: {'catalog_item': sectionLabel},
          ),
          draft: draft,
          mediaKind: request.kind.apiValue,
          onVocabularyValueChanged: request.onVocabularyValueChanged,
          onVocabularyValuesChanged: request.onVocabularyValuesChanged,
          onChanged: request.onManualDraftChanged,
        );

    return LibraryAddManualPaneShell(
      request: request,
      tabs: [
        LibraryAddManualPaneTab.main(
          content: buildFields(
            _boardGameMainFields,
            sectionLabel: 'Main',
          ),
        ),
        LibraryAddManualPaneTab(
          id: 'edition',
          label: 'Edition Details',
          icon: Icons.inventory_2_outlined,
          content: buildFields(
            _boardGameEditionFields,
            sectionLabel: 'Edition',
          ),
        ),
        LibraryAddManualPaneTab(
          id: 'gameplay',
          label: 'Gameplay & Ratings',
          icon: Icons.casino_outlined,
          content: buildFields(
            _boardGamePlayFields,
            sectionLabel: 'Gameplay and ratings',
          ),
        ),
        LibraryAddManualPaneTab(
          id: 'description',
          label: 'Description',
          icon: Icons.description_outlined,
          content: buildFields(
            const {'description'},
            sectionLabel: 'Description',
          ),
        ),
        LibraryAddManualPaneTab(
          id: 'covers',
          label: 'Covers',
          icon: Icons.camera_alt_outlined,
          content: buildFields(
            const {'cover_image_url'},
            sectionLabel: 'Cover',
          ),
        ),
      ],
    );
  }
}

Widget buildBoardgameAddManualPane(
  BuildContext context,
  LibraryAddManualPaneRequest request,
) =>
    BoardgameAddManualPane(request: request);
