import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/add/library_add_manual_intro_card.dart';
import 'package:collectarr_app/features/library/add/library_add_result_badge.dart';
import 'package:collectarr_app/features/library/add/library_add_shared.dart';
import 'package:collectarr_app/features/library/add/panes/library_add_manual_action_bar.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/features/library/kinds/comic/add/comic_add_manual_draft.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_visual_primitives.dart';
import 'package:collectarr_app/ui/single_value_pick_field.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ComicAddManualPane extends StatelessWidget {
  const ComicAddManualPane({super.key, required this.request});

  final LibraryAddManualPaneRequest request;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final comicDraft = request.manualDraftAs<ComicAddManualDraft>();
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
              title: 'Manual comic issue',
              subtitle:
                  'Set issue basics here, then review collector fields before saving.',
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
                    title: 'Main',
                    accent: request.accent,
                    child: Column(
                      children: [
                        LibraryResponsiveFormRow(
                          children: [
                            LibraryResponsiveFormItem(
                              flex: 3,
                              child: SingleValuePickField(
                                controller: request.titleController,
                                options: [
                                  for (final entry in request.seriesEntries)
                                    entry.title,
                                ],
                                label: 'Series',
                                onChanged: request.onSeriesChanged,
                                onManage: request.onManageSeries,
                                manageTooltip: 'Select or manage series',
                              ),
                            ),
                            LibraryResponsiveFormItem(
                              child: TextField(
                                controller: comicDraft.numberController,
                                textAlign: TextAlign.center,
                                decoration: const InputDecoration(
                                  labelText: 'Issue No.',
                                  prefixIcon:
                                      Icon(Icons.confirmation_number_outlined),
                                ),
                              ),
                            ),
                            LibraryResponsiveFormItem(
                              child: TextField(
                                controller: comicDraft.variantController,
                                decoration: const InputDecoration(
                                  labelText: 'Variant',
                                  prefixIcon:
                                      Icon(Icons.auto_awesome_motion_outlined),
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
                                controller: comicDraft.barcodeController,
                                decoration: const InputDecoration(
                                  labelText: 'Barcode',
                                  prefixIcon: Icon(Icons.qr_code_2),
                                ),
                              ),
                            ),
                            if (request.physicalFormats.isNotEmpty ||
                                request.physicalFormatOptions.isNotEmpty ||
                                request.physicalFormatLabelController.text
                                    .trim()
                                    .isNotEmpty)
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
                            LibraryResponsiveFormItem(
                              child: TextField(
                                controller: comicDraft.yearController,
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                decoration: const InputDecoration(
                                  labelText: 'Cover Date (YYYY)',
                                  prefixIcon:
                                      Icon(Icons.calendar_today_outlined),
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
                              child: SingleValuePickField(
                                controller: comicDraft.publisherController,
                                options: request.publisherOptions,
                                label: 'Publisher',
                                onManage: request.onManagePublishers,
                              ),
                            ),
                            LibraryResponsiveFormItem(
                              flex: 2,
                              child: TextField(
                                controller: comicDraft.coverController,
                                decoration: const InputDecoration(
                                  labelText: 'Cover image URL',
                                  prefixIcon: Icon(Icons.image_outlined),
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
                    title: 'Collector',
                    accent: request.accent,
                    child: Column(
                      children: [
                        LibraryResponsiveFormRow(
                          children: [
                            LibraryResponsiveFormItem(
                              child: TextField(
                                controller: comicDraft.rawOrSlabbedController,
                                decoration: const InputDecoration(
                                  labelText: 'Raw / Slabbed',
                                  prefixIcon: Icon(Icons.layers_outlined),
                                ),
                              ),
                            ),
                            LibraryResponsiveFormItem(
                              child: TextField(
                                controller: comicDraft.gradingCompanyController,
                                decoration: const InputDecoration(
                                  labelText: 'Grading Co.',
                                  prefixIcon: Icon(Icons.verified_outlined),
                                ),
                              ),
                            ),
                            LibraryResponsiveFormItem(
                              child: TextField(
                                controller:
                                    comicDraft.certificationNumberController,
                                decoration: const InputDecoration(
                                  labelText: 'Certification No.',
                                  prefixIcon: Icon(Icons.pin_outlined),
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
                                controller: comicDraft.labelTypeController,
                                decoration: const InputDecoration(
                                  labelText: 'Label Type',
                                  prefixIcon: Icon(Icons.label_outline),
                                ),
                              ),
                            ),
                            LibraryResponsiveFormItem(
                              child: TextField(
                                controller: comicDraft.pageQualityController,
                                decoration: const InputDecoration(
                                  labelText: 'Page Quality',
                                  prefixIcon:
                                      Icon(Icons.auto_stories_outlined),
                                ),
                              ),
                            ),
                            LibraryResponsiveFormItem(
                              child: TextField(
                                controller: comicDraft.signedByController,
                                decoration: const InputDecoration(
                                  labelText: 'Signed by',
                                  prefixIcon: Icon(Icons.draw_outlined),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: comicDraft.graderNotesController,
                          minLines: 2,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            labelText: 'Grader Notes',
                            alignLabelWithHint: true,
                            prefixIcon: Icon(Icons.sticky_note_2_outlined),
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
