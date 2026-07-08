import 'package:collectarr_app/features/library/edit/draft/library_edit_draft.dart';
import 'package:collectarr_app/features/library/edit/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/edit/fields/library_edit_field_groups.dart';
import 'package:collectarr_app/features/library/kinds/video/edit/video_edit_controller.dart';
import 'package:flutter/material.dart';

class VideoEditMediaTab extends StatelessWidget {
  const VideoEditMediaTab({
    super.key,
    required this.draft,
    required this.videoEdit,
    required this.accent,
    required this.countryOptions,
    required this.languageOptions,
    required this.ageRatingOptions,
    required this.audienceRatingOptions,
    required this.genreOptions,
  });

  final LibraryEditDraft draft;
  final VideoEditController videoEdit;
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
                titleController: draft.titleController,
                sortKeyController: draft.sortKeyController,
                originalTitleController: draft.originalTitleController,
                localizedTitleController: draft.localizedTitleController,
                searchAliasesController: draft.searchAliasesController,
              ),
              const SizedBox(height: 10),
              LibraryEditDenseFields(
                wideColumns: 2,
                ultraWideColumns: 2,
                wideBreakpoint: 600,
                ultraWideBreakpoint: 600,
                children: [
                  LibraryEditTextField(
                  controller: draft.displayTitleController,
                  label: 'Custom display title',
                ),
                  LibraryEditTextField(
                    controller: draft.publisherController,
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
                  controller: videoEdit.runtimeController,
                  label: 'Runtime (min)',
                  validator: optionalIntValidator,
                ),
                LibraryVocabularyField(
                  controller: draft.genresEditController,
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
                  controller: draft.ageRatingController,
                  options: ageRatingOptions,
                ),
                LibraryVocabularyField(
                  label: 'Audience rating',
                  controller: draft.audienceRatingController,
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
                  controller: draft.countryController,
                  options: countryOptions,
                ),
                LibraryVocabularyField(
                  label: 'Language',
                  controller: draft.languageController,
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
