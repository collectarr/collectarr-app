import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/add/library_add_manual_intro_card.dart';
import 'package:collectarr_app/features/library/add/library_add_result_badge.dart';
import 'package:collectarr_app/features/library/add/panes/library_add_manual_action_bar.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_manual_draft.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_visual_primitives.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

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
                        TextField(
                          controller: draft.genresEditController,
                          decoration: const InputDecoration(
                            labelText: 'Genres',
                            prefixIcon: Icon(Icons.local_offer_outlined),
                            hintText: 'Separate multiple genres with commas',
                          ),
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
                              child: TextField(
                                controller: draft.releaseDateController,
                                decoration: const InputDecoration(
                                  labelText: 'Release date (YYYY-MM-DD)',
                                  prefixIcon: Icon(Icons.event_outlined),
                                ),
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
                    title: 'Artwork & Notes',
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
                        TextField(
                          controller: draft.synopsisController,
                          minLines: 2,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            labelText: 'Notes / synopsis',
                            prefixIcon: Icon(Icons.notes_outlined),
                          ),
                        ),
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
