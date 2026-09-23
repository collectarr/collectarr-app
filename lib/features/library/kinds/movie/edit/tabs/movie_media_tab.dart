import 'package:collectarr_app/features/library/edit/draft/library_edit_shell_state.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/edit/fields/library_edit_field_groups.dart';
import 'package:collectarr_app/features/library/kinds/movie/edit/movie_edit_controller.dart';
import 'package:collectarr_app/features/library/kinds/movie/edit/movie_edit_draft.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_selection_fields.dart';
import 'package:flutter/material.dart';

class MovieEditMediaTab extends StatelessWidget {
  const MovieEditMediaTab({
    super.key,
    required this.draft,
    required this.movieEdit,
    required this.accent,
    required this.countryOptions,
    required this.languageOptions,
    required this.ageRatingOptions,
    required this.audienceRatingOptions,
    required this.genreOptions,
  });

  final LibraryEditShellState draft;
  final MovieEditController movieEdit;
  final Color accent;
  final List<String> countryOptions;
  final List<String> languageOptions;
  final List<String> ageRatingOptions;
  final List<String> audienceRatingOptions;
  final List<String> genreOptions;

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
                    draft.formFields.controller(MovieCanonicalEditField.title),
                sortKeyController: draft.formFields
                    .controller(MovieCanonicalEditField.sortTitle),
                originalTitleController: draft.formFields
                    .controller(MovieCanonicalEditField.originalTitle),
                localizedTitleController: draft.formFields
                    .controller(MovieCanonicalEditField.localizedTitle),
                searchAliasesController: draft.formFields
                    .controller(MovieCanonicalEditField.searchAliases),
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
                        .controller(MovieCanonicalEditField.displayTitle),
                    label: 'Custom display title',
                  ),
                  LibraryEditTextField(
                    controller: movieEdit.publisherController,
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
                    controller: movieEdit.runtimeController,
                    label: 'Runtime (min)',
                    validator: optionalIntValidator,
                  ),
                  LibraryVocabularyField(
                    controller: movieEdit.genresEditController,
                    options: genreOptions,
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
                  LibraryVocabularyField(
                    label: 'Age rating',
                    controller: movieEdit.ageRatingController,
                    options: ageRatingOptions,
                  ),
                  LibraryVocabularyField(
                    label: 'Audience rating',
                    controller: movieEdit.audienceRatingController,
                    options: audienceRatingOptions,
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
                  LibraryVocabularyField(
                    label: 'Country',
                    controller: movieEdit.countryController,
                    options: countryOptions,
                  ),
                  LibraryVocabularyField(
                    label: 'Language',
                    controller: movieEdit.languageController,
                    options: languageOptions,
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
