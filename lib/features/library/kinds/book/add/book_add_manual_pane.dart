import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/add/library_add_manual_intro_card.dart';
import 'package:collectarr_app/features/library/add/library_add_result_badge.dart';
import 'package:collectarr_app/features/library/add/library_add_shared.dart';
import 'package:collectarr_app/features/library/add/panes/library_add_manual_action_bar.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/features/library/kinds/book/add/book_add_manual_draft.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_visual_primitives.dart';
import 'package:collectarr_app/ui/single_value_pick_field.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class BookAddManualPane extends StatelessWidget {
  const BookAddManualPane({super.key, required this.request});

  final LibraryAddManualPaneRequest request;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final draft = request.manualDraftAs<BookAddManualDraft>();
    final copyTypeLabel = ownedCopyTypeLabel(
      digitalPhysicalMediaFormatFlag(
        request.physicalFormatId,
        formats: request.physicalFormats,
      ),
    );
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
              icon: request.type.workspace.icon,
              accent: request.accent,
              title: 'Manual book',
              subtitle:
                  'Set identity and publication details before saving to your library.',
              badges: [
                const LibraryAddResultBadge('main'),
                libraryAddManualIntroBadge(
                  copyTypeLabel ?? 'owned defaults',
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
                    title: 'Identity',
                    accent: request.accent,
                    child: Column(
                      children: [
                        TextField(
                          controller: request.titleController,
                          decoration: const InputDecoration(
                            labelText: 'Book Title',
                            prefixIcon: Icon(Icons.book_outlined),
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
                                  labelText: 'Authors',
                                  prefixIcon: Icon(Icons.person_outline),
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
                        const SizedBox(height: 10),
                        TextField(
                          controller: draft.synopsisController,
                          minLines: 2,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            labelText: 'Synopsis / Description',
                            alignLabelWithHint: true,
                            prefixIcon: Icon(Icons.description_outlined),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  LibraryFormSection(
                    title: 'Edition & Publishing',
                    accent: request.accent,
                    child: Column(
                      children: [
                        LibraryResponsiveFormRow(
                          children: [
                            LibraryResponsiveFormItem(
                              child: SingleValuePickField(
                                controller: draft.publisherController,
                                options: request.publisherOptions,
                                label: 'Publisher',
                                onManage: request.onManagePublishers,
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
                            LibraryResponsiveFormItem(
                              child: TextField(
                                controller: draft.editionTitleController,
                                decoration: const InputDecoration(
                                  labelText: 'Edition Title',
                                  prefixIcon: Icon(Icons.auto_stories_outlined),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        LibraryResponsiveFormRow(
                          children: [
                            LibraryResponsiveFormItem(
                              flex: 2,
                              child: TextField(
                                controller: draft.barcodeController,
                                decoration: const InputDecoration(
                                  labelText: 'ISBN / Barcode',
                                  prefixIcon: Icon(Icons.qr_code_2),
                                ),
                              ),
                            ),
                            if (request.physicalFormats.isNotEmpty ||
                                request.physicalFormatOptions.isNotEmpty)
                              LibraryResponsiveFormItem(
                                flex: 2,
                                child: SingleValuePickField(
                                  controller:
                                      request.physicalFormatLabelController,
                                  options: request.physicalFormatOptions,
                                  label: 'Format',
                                  onChanged:
                                      request.onPhysicalFormatLabelChanged,
                                  onManage: request.onManagePhysicalFormats,
                                ),
                              ),
                          ],
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

Widget buildBookAddManualPane(
  BuildContext context,
  LibraryAddManualPaneRequest request,
) {
  return BookAddManualPane(request: request);
}
