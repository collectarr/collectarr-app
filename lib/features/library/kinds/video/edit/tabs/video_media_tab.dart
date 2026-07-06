part of 'video_edit_tabs.dart';

class VideoEditMediaTab extends StatelessWidget {
  const VideoEditMediaTab({
    super.key,
    required this.type,
    required this.draft,
    required this.videoEdit,
    required this.accent,
    required this.genreOptions,
  });

  final LibraryTypeConfig type;
  final LibraryEditDraft draft;
  final VideoEditController videoEdit;
  final Color accent;
  final List<String> genreOptions;

  @override
  Widget build(BuildContext context) {
    final releaseFields = type.releaseFields;
    return EditTabShell(
      children: [
        EditSection(
          title: 'Main',
          accent: accent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _responsiveFields([
                _field(
                  controller: draft.titleController,
                  label: 'Title',
                  validator: (value) =>
                      emptyToNull(value ?? '') == null ? 'Enter a title' : null,
                ),
              ]),
              const SizedBox(height: 10),
              _responsiveFields([
                _field(controller: draft.originalTitleController, label: 'Original title'),
                _field(controller: draft.editionTitleController, label: releaseFields.editionTitleLabel),
              ]),
              const SizedBox(height: 10),
              _responsiveFields([
                _field(controller: draft.variantController, label: releaseFields.variantLabel),
                _field(controller: draft.displayTitleController, label: 'Custom display title'),
              ]),
            ],
          ),
        ),
        EditSection(
          title: 'Advanced',
          accent: accent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _responsiveFields([
                _field(controller: draft.sortKeyController, label: 'Sort title'),
                _field(controller: draft.searchAliasesController, label: 'Search aliases'),
              ]),
              const SizedBox(height: 10),
              _responsiveFields([
                _field(controller: draft.localizedTitleController, label: 'Localized title'),
              ]),
              const SizedBox(height: 10),
              Text(
                'Sort title is optional. Custom display title stays local to your library.',
                style: TextStyle(color: appPalette(context).textMuted),
              ),
            ],
          ),
        ),
        EditSection(
          title: 'Release details',
          accent: accent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _responsiveFields([
                _field(controller: draft.releaseDateController, label: type.mediaFields.releaseDateLabel),
                _field(controller: draft.publisherController, label: 'Studios'),
              ]),
              const SizedBox(height: 10),
              _responsiveFields([
                _field(
                  controller: videoEdit.runtimeController,
                  label: 'Runtime (min)',
                  validator: optionalIntValidator,
                ),
                _field(controller: draft.ageRatingController, label: 'Age rating'),
              ]),
              const SizedBox(height: 10),
              _responsiveFields([
                _field(controller: draft.audienceRatingController, label: 'Audience rating'),
                _field(controller: draft.countryController, label: 'Country'),
              ]),
              const SizedBox(height: 10),
              _responsiveFields([
                _field(controller: draft.languageController, label: 'Language'),
                TagPickListField(
                  controller: draft.genresEditController,
                  options: genreOptions,
                  label: 'Genres',
                ),
              ]),
            ],
          ),
        ),
      ],
    );
  }
}
