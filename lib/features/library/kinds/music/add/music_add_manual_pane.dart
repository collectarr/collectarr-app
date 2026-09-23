import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/add/library_add_manual_intro_card.dart';
import 'package:collectarr_app/features/library/add/library_add_result_badge.dart';
import 'package:collectarr_app/features/library/add/panes/library_add_manual_action_bar.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/vocabulary/music_vocabularies.dart';
import 'package:collectarr_app/features/library/schema/library_field_spec.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_multi_value_pick_field.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_visual_primitives.dart';
import 'package:collectarr_app/features/pick_lists/widgets/multi_pick_list_select_dialog.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MusicAddManualPane extends StatelessWidget {
  const MusicAddManualPane({super.key, required this.request});

  final LibraryAddManualPaneRequest request;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final draft = request.manualDraftAs<MusicAddManualDraft>();
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.panel,
        border: Border(left: BorderSide(color: palette.divider)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LibraryAddManualIntroCard(
              icon: request.type.identity.icon,
              accent: request.accent,
              title: 'Manual music album setup',
              subtitle:
                  'Capture the release identity before saving it to your library.',
              badges: [
                const LibraryAddResultBadge('main'),
                libraryAddManualIntroBadge(
                  'owned defaults',
                  accent: request.accent,
                ),
                if (request.defaultLocationLabel != null)
                  libraryAddManualIntroBadge(
                    request.defaultLocationLabel!,
                    accent: request.accent,
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: [
                  LibraryFormSection(
                    title: 'Album & Artist',
                    accent: request.accent,
                    child: Column(
                      children: [
                        TextField(
                          controller: request.titleController,
                          decoration: const InputDecoration(
                            labelText: 'Album Title',
                            prefixIcon: Icon(Icons.album_outlined),
                          ),
                        ),
                        const SizedBox(height: 10),
                        LibraryResponsiveFormRow(
                          children: [
                            LibraryResponsiveFormItem(
                              flex: 2,
                              child: TextField(
                                controller: draft.creatorsController,
                                decoration: const InputDecoration(
                                  labelText: 'Artist(s)',
                                  prefixIcon: Icon(Icons.person_outline),
                                ),
                              ),
                            ),
                            LibraryResponsiveFormItem(
                              child: TextField(
                                controller: draft.yearController,
                                textAlign: TextAlign.center,
                                decoration: const InputDecoration(
                                  labelText: 'Year',
                                  prefixIcon:
                                      Icon(Icons.calendar_today_outlined),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        LibraryMultiValuePickField<String>(
                          label: 'Genres',
                          value: draft.genres,
                          options: [
                            for (final genre
                                in MusicVocabularies.genre.builtIns)
                              LibraryFieldOption(value: genre, label: genre),
                          ],
                          onChanged: (genres) => draft.genres = {...genres},
                          onOpenPicker: ({
                            required label,
                            required selectedValues,
                            required options,
                          }) {
                            final db = ProviderScope.containerOf(
                              context,
                              listen: false,
                            ).read(localDatabaseProvider);
                            return showMultiPickListSelectDialog(
                              context: context,
                              label: label,
                              pluralLabel: 'Genres',
                              options: [
                                for (final option in options) option.value,
                              ],
                              selectedValues: selectedValues,
                              listName: MusicVocabularyIds.genre.value,
                              mediaKind: 'music',
                              allowUserValues: true,
                              db: db,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  LibraryFormSection(
                    title: 'Release & Label',
                    accent: request.accent,
                    child: Column(
                      children: [
                        LibraryResponsiveFormRow(
                          children: [
                            LibraryResponsiveFormItem(
                              child: TextField(
                                controller: draft.editionTitleController,
                                decoration: const InputDecoration(
                                  labelText: 'Release / Edition title',
                                  prefixIcon: Icon(Icons.album_outlined),
                                ),
                              ),
                            ),
                            LibraryResponsiveFormItem(
                              child: TextField(
                                controller: draft.numberController,
                                decoration: const InputDecoration(
                                  labelText: 'Catalog number',
                                  prefixIcon: Icon(Icons.tag_outlined),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        LibraryResponsiveFormRow(
                          children: [
                            LibraryResponsiveFormItem(
                              child: TextField(
                                controller: draft.publisherController,
                                decoration: const InputDecoration(
                                  labelText: 'Record Label',
                                  prefixIcon: Icon(Icons.apartment_outlined),
                                ),
                              ),
                            ),
                            LibraryResponsiveFormItem(
                              child: TextField(
                                controller: draft.physicalFormatLabelController,
                                decoration: const InputDecoration(
                                  labelText: 'Format',
                                  prefixIcon: Icon(Icons.album_outlined),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        LibraryResponsiveFormRow(
                          children: [
                            LibraryResponsiveFormItem(
                              child: TextField(
                                controller: draft.barcodeController,
                                decoration: const InputDecoration(
                                  labelText: 'Barcode',
                                  prefixIcon: Icon(Icons.qr_code_2),
                                ),
                              ),
                            ),
                            LibraryResponsiveFormItem(
                              child: TextField(
                                controller: draft.countryController,
                                decoration: const InputDecoration(
                                  labelText: 'Country',
                                  prefixIcon: Icon(Icons.public_outlined),
                                ),
                              ),
                            ),
                            LibraryResponsiveFormItem(
                              child: TextField(
                                controller: draft.packagingController,
                                decoration: const InputDecoration(
                                  labelText: 'Packaging',
                                  prefixIcon: Icon(Icons.inventory_2_outlined),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        LibraryResponsiveFormRow(
                          children: [
                            LibraryResponsiveFormItem(
                              child: LibraryDateFieldButton(
                                label: 'Release date',
                                value: DateTime.tryParse(
                                  draft.releaseDateController.text.trim(),
                                ),
                                onChanged: (value) {
                                  draft.releaseDateController.text =
                                      value == null ? '' : formatDate(value);
                                },
                              ),
                            ),
                            LibraryResponsiveFormItem(
                              child: TextField(
                                controller: draft.languageController,
                                decoration: const InputDecoration(
                                  labelText: 'Language',
                                  prefixIcon: Icon(Icons.language_outlined),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  LibraryFormSection(
                    title: 'Artwork',
                    accent: request.accent,
                    child: Column(
                      children: [
                        TextField(
                          controller: draft.coverController,
                          decoration: const InputDecoration(
                            labelText: 'Cover image URL',
                            prefixIcon: Icon(Icons.image_outlined),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            LibraryAddManualActionBar(request: request),
          ],
        ),
      ),
    );
  }
}

Widget buildMusicAddManualPane(
  BuildContext context,
  LibraryAddManualPaneRequest request,
) {
  return MusicAddManualPane(request: request);
}
