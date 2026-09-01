import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/add/library_add_manual_intro_card.dart';
import 'package:collectarr_app/features/library/add/library_add_result_badge.dart';
import 'package:collectarr_app/features/library/add/library_add_shared.dart';
import 'package:collectarr_app/features/library/add/panes/library_add_manual_action_bar.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/features/library/kinds/game/add/game_add_manual_draft.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_visual_primitives.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class GameAddManualPane extends StatelessWidget {
  const GameAddManualPane({super.key, required this.request});

  final LibraryAddManualPaneRequest request;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final draft = request.manualDraftAs<GameAddManualDraft>();
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
              title: 'Manual video game setup',
              subtitle:
                  'Set game title, edition, and publisher details before saving.',
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
                    title: 'Game Details',
                    accent: request.accent,
                    child: Column(
                      children: [
                        TextField(
                          controller: request.titleController,
                          decoration: const InputDecoration(
                            labelText: 'Game Title',
                            prefixIcon: Icon(Icons.sports_esports_outlined),
                          ),
                        ),
                        const SizedBox(height: 10),
                        LibraryResponsiveFormRow(
                          children: [
                            LibraryResponsiveFormItem(
                              child: TextField(
                                controller: draft.editionTitleController,
                                decoration: const InputDecoration(
                                  labelText: 'Edition / Variant',
                                  prefixIcon:
                                      Icon(Icons.auto_awesome_motion_outlined),
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
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  LibraryFormSection(
                    title: 'Publishing & Identifiers',
                    accent: request.accent,
                    child: Column(
                      children: [
                        LibraryResponsiveFormRow(
                          children: [
                            LibraryResponsiveFormItem(
                              child: TextField(
                                controller: draft.publisherController,
                                decoration: const InputDecoration(
                                  labelText: 'Publisher',
                                  prefixIcon: Icon(Icons.apartment_outlined),
                                ),
                              ),
                            ),
                            LibraryResponsiveFormItem(
                              child: TextField(
                                controller: draft.barcodeController,
                                decoration: const InputDecoration(
                                  labelText: 'Barcode',
                                  prefixIcon: Icon(Icons.qr_code_2),
                                ),
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

Widget buildGameAddManualPane(
  BuildContext context,
  LibraryAddManualPaneRequest request,
) {
  return GameAddManualPane(request: request);
}
