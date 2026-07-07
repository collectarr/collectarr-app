part of 'video_edit_tabs.dart';

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
              _responsiveFields([
                _field(
                  controller: draft.displayTitleController,
                  label: 'Custom display title',
                ),
                _field(controller: draft.publisherController, label: 'Studios'),
              ]),
              const SizedBox(height: 10),
              _responsiveFields([
                _field(
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
              ]),
            ],
          ),
        ),
        EditSection(
          title: 'Classification',
          accent: accent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _responsiveFields([
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
              ]),
              const SizedBox(height: 10),
              _responsiveFields([
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
              ]),
            ],
          ),
        ),
      ],
    );
  }
}
