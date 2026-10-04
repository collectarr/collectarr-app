import 'package:collectarr_app/features/library/edit/draft/library_edit_shell_state.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/edit/fields/library_edit_field_groups.dart';
import 'package:collectarr_app/features/library/kinds/anime/edit/anime_edit_draft.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_selection_fields.dart';
import 'package:flutter/material.dart';

class AnimeEditMediaTab extends StatelessWidget {
  const AnimeEditMediaTab({
    super.key,
    required this.draft,
    required this.accent,
  });

  final LibraryEditShellState draft;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return EditTabShell(
      children: [
        EditSection(
          title: 'Main',
          accent: accent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LibraryTitleMetadataFields(
                titleController:
                    draft.formFields.controller(AnimeCanonicalEditField.title),
                sortKeyController: draft.formFields
                    .controller(AnimeCanonicalEditField.sortTitle),
                originalTitleController: draft.formFields
                    .controller(AnimeCanonicalEditField.originalTitle),
                localizedTitleController: draft.formFields
                    .controller(AnimeCanonicalEditField.localizedTitle),
                searchAliasesController: draft.formFields
                    .controller(AnimeCanonicalEditField.searchAliases),
              ),
              const SizedBox(height: 10),
              LibraryEditDenseFields(
                wideColumns: 2,
                ultraWideColumns: 2,
                wideBreakpoint: 600,
                ultraWideBreakpoint: 600,
                children: [
                  LibraryEditTextField(
                    controller: draft.formFields
                        .controller(AnimeCanonicalEditField.displayTitle),
                    label: 'Custom display title',
                  ),
                  LibraryEditTextField(
                    controller: draft.formFields
                        .controller(AnimeCanonicalEditField.publisher),
                    label: 'Studios',
                  ),
                ],
              ),
              const SizedBox(height: 10),
              LibraryEditDenseFields(
                wideColumns: 2,
                ultraWideColumns: 2,
                wideBreakpoint: 600,
                ultraWideBreakpoint: 600,
                children: [
                  LibraryEditTextField(
                    controller: draft.formFields
                        .controller(AnimeCanonicalEditField.episodeRuntime),
                    label: 'Runtime (min)',
                    validator: optionalIntValidator,
                  ),
                  LibraryVocabularyField(
                    controller: draft.formFields
                        .controller(AnimeCanonicalEditField.genres),
                    options: const [],
                    label: 'Genres',
                    multiSelect: true,
                  ),
                ],
              ),
            ],
          ),
        ),
        EditSection(
          title: 'Classification',
          accent: accent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LibraryEditDenseFields(
                wideColumns: 2,
                ultraWideColumns: 2,
                wideBreakpoint: 600,
                ultraWideBreakpoint: 600,
                children: [
                  LibraryEditTextField(
                    label: 'Age rating',
                    controller: draft.formFields
                        .controller(AnimeCanonicalEditField.ageRating),
                  ),
                  LibraryEditTextField(
                    label: 'Audience rating',
                    controller: draft.formFields.controller(
                      AnimeCanonicalEditField.audienceRating,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              LibraryEditDenseFields(
                wideColumns: 2,
                ultraWideColumns: 2,
                wideBreakpoint: 600,
                ultraWideBreakpoint: 600,
                children: [
                  LibraryEditTextField(
                    label: 'Country',
                    controller: draft.formFields
                        .controller(AnimeCanonicalEditField.country),
                  ),
                  LibraryEditTextField(
                    label: 'Language',
                    controller: draft.formFields
                        .controller(AnimeCanonicalEditField.language),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
