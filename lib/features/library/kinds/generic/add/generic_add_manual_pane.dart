import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/add/library_add_manual_intro_card.dart';
import 'package:collectarr_app/features/library/add/library_add_result_badge.dart';
import 'package:collectarr_app/features/library/add/panes/library_add_manual_action_bar.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_visual_primitives.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class GenericAddManualPane extends StatelessWidget {
  const GenericAddManualPane({super.key, required this.request});

  final LibraryAddManualPaneRequest request;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
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
              title: 'Manual entry',
              subtitle: 'Enter item details for this collection item.',
              badges: const [LibraryAddResultBadge('main')],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: [
                  LibraryFormSection(
                    title: 'Item Title',
                    accent: request.accent,
                    child: TextField(
                      controller: request.titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        prefixIcon: Icon(Icons.title_outlined),
                      ),
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

Widget buildGenericAddManualPane(
  BuildContext context,
  LibraryAddManualPaneRequest request,
) {
  return GenericAddManualPane(request: request);
}
