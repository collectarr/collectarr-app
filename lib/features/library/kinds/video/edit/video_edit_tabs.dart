import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/edit/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/edit/library_edit_draft.dart';
import 'package:collectarr_app/features/library/edit/library_edit_scaffold.dart';
import 'package:collectarr_app/features/library/kinds/video/edit/video_edit_controller.dart';
import 'package:collectarr_app/features/library/kinds/video/edit/video_edit_models.dart';
import 'package:collectarr_app/features/library/kinds/video/video_external_links_section.dart';
import 'package:collectarr_app/ui/tag_pick_list_field.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

class VideoEditEditionTab extends StatelessWidget {
  const VideoEditEditionTab({
    super.key,
    required this.type,
    required this.draft,
    required this.accent,
    required this.physicalFormats,
  });

  final LibraryTypeConfig type;
  final LibraryEditDraft draft;
  final Color accent;
  final List<dynamic> physicalFormats;

  @override
  Widget build(BuildContext context) {
    final releaseFields = type.releaseFields;
    return EditTabShell(
      children: [
        EditSection(
          title: 'Edition',
          accent: accent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _responsiveFields([
                _field(controller: draft.editionTitleController, label: releaseFields.editionTitleLabel),
                _field(controller: draft.variantController, label: releaseFields.variantLabel),
                _field(controller: draft.barcodeController, label: releaseFields.barcodeLabel),
              ]),
            ],
          ),
        ),
      ],
    );
  }
}

class VideoEditSpecsTab extends StatelessWidget {
  const VideoEditSpecsTab({
    super.key,
    required this.draft,
    required this.videoEdit,
    required this.accent,
  });

  final LibraryEditDraft draft;
  final VideoEditController videoEdit;
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
              _responsiveFields([
                _field(controller: videoEdit.audioTracksController, label: 'Audio tracks'),
                _field(controller: videoEdit.subtitlesController, label: 'Subtitles'),
              ]),
              const SizedBox(height: 10),
              _responsiveFields([
                _field(controller: videoEdit.layersController, label: 'Layers'),
                _field(controller: videoEdit.colorController, label: 'Color'),
                _field(controller: videoEdit.nrDiscsController, label: 'Discs', validator: optionalIntValidator),
              ]),
            ],
          ),
        ),
      ],
    );
  }
}

class VideoEditCastTab extends StatelessWidget {
  const VideoEditCastTab({
    super.key,
    required this.accent,
    required this.videoEdit,
  });

  final Color accent;
  final VideoEditController videoEdit;

  @override
  Widget build(BuildContext context) {
    return _creditsTab(
      context: context,
      title: 'Cast',
      emptyMessage: 'No cast data yet.',
      addLabel: 'Add Cast',
      accent: accent,
      credits: videoEdit.castCredits,
      defaultRole: 'Actor',
      onAdd: () => videoEdit.castCredits.add(EditableVideoCredit.custom(role: 'Actor')),
    );
  }
}

class VideoEditCrewTab extends StatelessWidget {
  const VideoEditCrewTab({
    super.key,
    required this.accent,
    required this.videoEdit,
  });

  final Color accent;
  final VideoEditController videoEdit;

  @override
  Widget build(BuildContext context) {
    return _creditsTab(
      context: context,
      title: 'Crew',
      emptyMessage: 'No crew data yet.',
      addLabel: 'Add Crew',
      accent: accent,
      credits: videoEdit.crewCredits,
      defaultRole: 'Director',
      onAdd: () => videoEdit.crewCredits.add(EditableVideoCredit.custom(role: 'Director')),
    );
  }
}

class VideoEditDiscsTab extends StatelessWidget {
  const VideoEditDiscsTab({
    super.key,
    required this.type,
    required this.item,
    required this.accent,
  });

  final LibraryTypeConfig type;
  final LibraryMetadataItem item;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final allDiscs = <(String, CatalogDisc)>[];
    for (final edition in item.editions) {
      for (final disc in edition.discs) {
        allDiscs.add((edition.title, disc));
      }
    }
    return EditTabShell(
      children: [
        EditSection(
          title: 'Provider disc metadata',
          accent: accent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const EditSectionStateMessage(
                message: 'Read-only: disc metadata is synced from provider/Core metadata.',
                icon: Icons.lock_outline,
              ),
              const SizedBox(height: 10),
              if (allDiscs.isEmpty)
                const EditSectionStateMessage(
                  message: 'No disc data available yet.',
                  icon: Icons.album_outlined,
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final (editionTitle, disc) in allDiscs)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            Icon(Icons.album, size: 16, color: appPalette(context).textMuted),
                            const SizedBox(width: 8),
                            Text(disc.discName ?? 'Disc ${disc.discNumber}', style: const TextStyle(fontWeight: FontWeight.w700)),
                            if (disc.discFormat != null) ...[
                              const SizedBox(width: 6),
                              Text('(${disc.discFormat})', style: TextStyle(color: appPalette(context).textMuted)),
                            ],
                            const Spacer(),
                            Text(editionTitle, style: TextStyle(color: appPalette(context).textMuted, fontSize: 12)),
                          ],
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
        EditSection(
          title: 'Local disc notes',
          accent: accent,
          child: const EditSectionStateMessage(
            message: 'Use the release details tab for package/disc notes and the episode map tab for disc assignments.',
            icon: Icons.edit_note,
          ),
        ),
      ],
    );
  }
}

class VideoEditLinksTab extends ConsumerWidget {
  const VideoEditLinksTab({
    super.key,
    required this.type,
    required this.item,
    required this.accent,
    required this.videoEdit,
  });

  final LibraryTypeConfig type;
  final LibraryMetadataItem item;
  final Color accent;
  final VideoEditController videoEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final providerLinks = item.trailerUrls;
    return EditTabShell(
      children: [
        if (providerLinks.isNotEmpty)
          EditSection(
            title: 'Provider links',
            accent: accent,
            child: VideoExternalLinksSection(
              title: 'Provider links',
              links: providerLinks,
              accent: accent,
            ),
          ),
        EditSection(
          title: 'User links',
          accent: accent,
          child: _EditableLinkList(
            accent: accent,
            title: 'User links',
            items: videoEdit.userLinkEdits,
            onAdd: () => videoEdit.userLinkEdits.add(
              EditableUserExternalLink.fromTrailerLink(
                TrailerLink(
                  url: '',
                  source: 'manual',
                  isAutomatic: false,
                  kind: 'external',
                ),
                kind: 'custom',
              ),
            ),
          ),
        ),
        EditSection(
          title: 'Trailers',
          accent: accent,
          child: _EditableLinkList(
            accent: accent,
            title: 'Trailers',
            items: videoEdit.userTrailerEdits,
            onAdd: () => videoEdit.userTrailerEdits.add(
              EditableUserExternalLink.fromTrailerLink(
                TrailerLink(
                  url: '',
                  source: 'manual',
                  isAutomatic: false,
                  kind: 'trailer',
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

Widget _creditsTab({
  required BuildContext context,
  required String title,
  required String emptyMessage,
  required String addLabel,
  required Color accent,
  required List<EditableVideoCredit> credits,
  required String defaultRole,
  required VoidCallback onAdd,
}) {
  return EditTabShell(
    children: [
      EditSection(
        title: title,
        accent: accent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (credits.isEmpty)
              EditSectionStateMessage(message: emptyMessage, icon: Icons.person_outline)
            else
              Column(
                children: [
                  for (final credit in credits)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: credit.nameController,
                              decoration: const InputDecoration(labelText: 'Name'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: credit.roleController,
                              decoration: const InputDecoration(labelText: 'Role'),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: Text(addLabel),
            ),
          ],
        ),
      ),
    ],
  );
}

class _EditableLinkList extends StatelessWidget {
  const _EditableLinkList({
    required this.accent,
    required this.title,
    required this.items,
    required this.onAdd,
  });

  final Color accent;
  final String title;
  final List<EditableUserExternalLink> items;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (items.isEmpty)
          const EditSectionStateMessage(message: 'No entries yet.', icon: Icons.link_outlined)
        else
          Column(
            children: [
              for (final item in items)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: item.labelController,
                          decoration: const InputDecoration(labelText: 'Label'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: item.urlController,
                          decoration: const InputDecoration(labelText: 'URL'),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add),
          label: Text('Add $title'),
        ),
      ],
    );
  }
}

Widget _responsiveFields(List<Widget> children) {
  return LayoutBuilder(
    builder: (context, constraints) {
      final width = constraints.maxWidth;
      final itemWidth = width < 600 ? width : (width - 10) / 2;
      return Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          for (final child in children)
            SizedBox(width: itemWidth, child: child),
        ],
      );
    },
  );
}

Widget _field({
  required TextEditingController controller,
  required String label,
  String? Function(String?)? validator,
}) {
  return TextFormField(
    controller: controller,
    decoration: InputDecoration(labelText: label),
    validator: validator,
  );
}
