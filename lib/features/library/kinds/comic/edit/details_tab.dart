import 'package:collectarr_app/features/library/edit/fields/edit_layout_widgets.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_value_fields.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_selection_fields.dart';
import 'package:collectarr_app/features/library/kinds/comic/edit/host.dart';
import 'package:flutter/material.dart';

extension ComicDetailsTab on ComicEditHost {
  Widget buildComicEntryDetailsTab() {
    return EditTabShell(
      children: [
        EditSection(
          title: 'Details',
          accent: comicAccent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LibraryEditResponsiveRow(children: [
                LibraryEditTextField(
                  controller: comicTitleController,
                  label: 'Title',
                ),
                LibraryEditTextField(
                  controller: comicOriginalTitleController,
                  label: 'Original Title',
                ),
              ]),
              const SizedBox(height: 10),
              LibraryEditResponsiveRow(children: [
                LibraryEditTextField(
                  controller: comicEditionTitleController,
                  label: 'Edition title',
                ),
                LibraryEditTextField(
                  controller: comicVariantController,
                  label: 'Variant / format',
                ),
              ]),
              const SizedBox(height: 10),
              LibraryEditResponsiveRow(children: [
                buildComicCrossoverPickField(),
                buildComicStoryArcPickField(),
              ]),
              const SizedBox(height: 10),
              LibraryEditResponsiveRow(children: [
                buildComicCountryPickField(),
                LibraryEditTextField(
                    controller: comicLanguageController, label: 'Language'),
              ]),
              const SizedBox(height: 10),
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 620) {
                    return Column(
                      children: [
                        LibraryEditTextField(
                          controller: comicAgeRatingController,
                          label: 'Age',
                        ),
                        const SizedBox(height: 10),
                        LibraryEditTextField(
                          controller: comicPageCountController,
                          label: 'No. of Pages',
                          validator: optionalIntValidator,
                        ),
                        const SizedBox(height: 10),
                        LibraryVocabularyField(
                          controller: comicGenresEditController,
                          options: comicGenreOptions,
                          label: 'Genres',
                          multiSelect: true,
                        ),
                      ],
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: LibraryEditTextField(
                                controller: comicAgeRatingController,
                                label: 'Age',
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: LibraryEditTextField(
                                controller: comicPageCountController,
                                label: 'No. of Pages',
                                validator: optionalIntValidator,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: LibraryVocabularyField(
                          controller: comicGenresEditController,
                          options: comicGenreOptions,
                          label: 'Genres',
                          multiSelect: true,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
        EditSection(
          title: 'Advanced',
          accent: comicAccent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LibraryEditResponsiveRow(children: [
                LibraryEditTextField(
                    controller: comicSortKeyController, label: 'Sort Title'),
                LibraryEditTextField(
                  controller: comicSearchAliasesController,
                  maxLines: 3,
                  label: 'Search Aliases',
                  hint: 'Comma-separated aliases',
                ),
              ]),
              const SizedBox(height: 10),
              LibraryEditResponsiveRow(children: [
                LibraryEditTextField(
                  controller: comicLocalizedTitleController,
                  label: 'Localized title',
                ),
              ]),
            ],
          ),
        ),
      ],
    );
  }
}
