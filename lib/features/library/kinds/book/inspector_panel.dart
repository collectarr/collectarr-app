import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/detail/library_detail_hero.dart';
import 'package:collectarr_app/features/library/inspector/library_inspector_chrome.dart';
import 'package:collectarr_app/features/library/kinds/book/presentation_builder.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

Widget buildBookInspectorPanel(
  BuildContext context,
  LibraryInspectorPanelRequest request,
) {
  return BookInspectorPanel(request: request);
}

class BookInspectorPanel extends StatelessWidget {
  const BookInspectorPanel({super.key, required this.request});

  final LibraryInspectorPanelRequest request;

  @override
  Widget build(BuildContext context) {
    final entry = request.inspector.entry;
    final ownedItem = request.inspector.ownedItem;
    final palette = appPalette(context);
    final accent = request.inspector.accent;
    final sections = const BookLibraryMediaPresentationBuilder(
      showSummary: true,
    ).buildInspectorSections(
      context: context,
      entry: entry,
      accent: accent,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.panel,
        border: Border(
          left: BorderSide(
            color: accent.withValues(alpha: palette.isDark ? 0.3 : 0.22),
          ),
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: InspectorBackdrop(entry: entry, ownedItem: ownedItem),
          ),
          ListView(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
            children: [
              InspectorUnifiedToolbar(
                entry: entry,
                onEdit: request.onEdit,
                onShare: request.onShare,
                onDuplicate: request.onDuplicate,
                onToggleOwned: request.onToggleOwned,
                onLoan: request.onLoan,
                onRefreshMetadata: request.onRefreshMetadata,
                onUnlinkFromCore: request.onUnlinkFromCore,
                onDetailsLayoutChanged: request.onDetailsLayoutChanged,
              ),
              const SizedBox(height: 8),
              LibraryDetailHero(
                type: request.inspector.type,
                entry: entry,
                ownedItem: ownedItem,
                accent: accent,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: request.onOpenDetails,
                    icon: const Icon(Icons.open_in_new, size: 16),
                    label: const Text('Details'),
                  ),
                  if (request.onCorrectMetadata != null)
                    OutlinedButton.icon(
                      onPressed: request.onCorrectMetadata,
                      icon: const Icon(Icons.fact_check_outlined, size: 16),
                      label: const Text('Correct'),
                    ),
                  ...request.extraActions,
                ],
              ),
              if (request.ownedCopiesSection != null) ...[
                const SizedBox(height: 8),
                request.ownedCopiesSection!,
              ],
              if (request.bundleSection != null) ...[
                const SizedBox(height: 8),
                request.bundleSection!,
              ],
              if (request.conditionGradeSection != null) ...[
                const SizedBox(height: 8),
                request.conditionGradeSection!,
              ],
              if (sections.isNotEmpty) ...[
                const SizedBox(height: 8),
                ...sections,
              ],
              if (request.trailingSections.isNotEmpty) ...[
                ...request.trailingSections,
              ],
            ],
          ),
        ],
      ),
    );
  }
}
