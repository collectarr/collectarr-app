import 'package:collectarr_app/features/library/edit/draft/library_edit_shell_state.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/edit/fields/library_edit_field_groups.dart';
import 'package:collectarr_app/features/library/kinds/tv/edit/tv_edit_controller.dart';
import 'package:collectarr_app/features/library/kinds/tv/edit/tv_edit_draft.dart';
import 'package:flutter/material.dart';

class TvEditMediaTab extends StatelessWidget {
  const TvEditMediaTab({
    super.key,
    required this.draft,
    required this.tvEdit,
    required this.accent,
  });

  final LibraryEditShellState draft;
  final TvEditController tvEdit;
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
                    draft.formFields.controller(TvCanonicalEditField.title),
                sortKeyController:
                    draft.formFields.controller(TvCanonicalEditField.sortTitle),
                originalTitleController: draft.formFields
                    .controller(TvCanonicalEditField.originalTitle),
                localizedTitleController: draft.formFields
                    .controller(TvCanonicalEditField.localizedTitle),
                searchAliasesController: draft.formFields
                    .controller(TvCanonicalEditField.searchAliases),
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
                        .controller(TvCanonicalEditField.displayTitle),
                    label: 'Custom display title',
                  ),
                  LibraryEditTextField(
                    controller: tvEdit.publisherController,
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
                    controller: tvEdit.runtimeController,
                    label: 'Runtime (min)',
                    validator: optionalIntValidator,
                  ),
                  LibraryEditTextField(
                    controller: tvEdit.genresEditController,
                    label: 'Genres',
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
                    controller: tvEdit.ageRatingController,
                  ),
                  LibraryEditTextField(
                    label: 'Audience rating',
                    controller: tvEdit.audienceRatingController,
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
                    controller: tvEdit.countryController,
                  ),
                  LibraryEditTextField(
                    label: 'Language',
                    controller: tvEdit.languageController,
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
