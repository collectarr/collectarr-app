import 'package:collectarr_app/features/settings/ui_preferences.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'library_workspace_controls.dart';
import 'library_pane_widths.dart';
import 'library_resizable_pane.dart';
import 'library_workspace_config.dart';

export 'library_workspace_controls.dart';
export 'library_workspace_menus.dart';
export 'library_workspace_tokens.dart';

class LibraryToolbarPrimaryActions extends ConsumerWidget {
  const LibraryToolbarPrimaryActions({
    super.key,
    required this.addLabel,
    required this.onAdd,
    required this.onScanBarcode,
    required this.onRefreshMetadata,
    this.onRandomPick,
    this.onScanCover,
    required this.addBackgroundColor,
    required this.addForegroundColor,
  });

  final String addLabel;
  final VoidCallback onAdd;
  final VoidCallback onScanBarcode;
  final VoidCallback onRefreshMetadata;
  final VoidCallback? onRandomPick;
  final VoidCallback? onScanCover;
  final Color addBackgroundColor;
  final Color addForegroundColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final useFab =
        ref.watch(uiPreferencesProvider.select((p) => p.fabAddButton));
    final showTrailingActions = onRandomPick != null;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!useFab) ...[
          SizedBox(
            height: 30,
            child: FilledButton.icon(
              onPressed: onAdd,
              style: FilledButton.styleFrom(
                backgroundColor: addBackgroundColor,
                foregroundColor: addForegroundColor,
                padding: const EdgeInsets.symmetric(horizontal: 9),
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
              icon: const Icon(Icons.add, size: 17),
              label: Text(addLabel),
            ),
          ),
          if (showTrailingActions) const SizedBox(width: 6),
        ],
        if (onRandomPick != null)
          Tooltip(
            message: 'Random pick',
            child: LibraryWorkspaceIconButton(
              icon: Icons.casino_outlined,
              onPressed: onRandomPick!,
            ),
          ),
      ],
    );
  }
}

class LibraryToolbarSearch extends StatelessWidget {
  const LibraryToolbarSearch({
    super.key,
    required this.controller,
    required this.hintText,
    required this.onSearch,
    required this.selectionColor,
    this.onScanBarcode,
    this.onScanCover,
    this.selectedFilterLabel,
    this.onClearFilter,
    this.onChanged,
    this.maxWidth = 300,
  });

  final TextEditingController controller;
  final String hintText;
  final String? selectedFilterLabel;
  final ValueChanged<String> onSearch;
  final VoidCallback? onScanBarcode;
  final VoidCallback? onScanCover;
  final VoidCallback? onClearFilter;
  final ValueChanged<String>? onChanged;
  final Color selectionColor;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final colorScheme = Theme.of(context).colorScheme;
    final inlineActionCount =
        1 + (onScanBarcode != null ? 1 : 0) + (onScanCover != null ? 1 : 0);
    final inlineActionsWidth = inlineActionCount * 30.0 + 8;
    final inputBackground = colorScheme.brightness == Brightness.dark
        ? const Color(0xFF34383D)
        : const Color(0xFFF4F6F8);
    final borderColor = colorScheme.brightness == Brightness.dark
        ? const Color(0xFF575D65)
        : const Color(0xFFD6DCE3);
    return LayoutBuilder(
      builder: (context, constraints) {
        final showFilterChip =
            selectedFilterLabel != null && constraints.maxWidth >= 340;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: inputBackground,
                    border: Border.all(color: borderColor),
                  ),
                  child: SizedBox(
                    height: 38,
                    child: TextField(
                      controller: controller,
                      onChanged: onChanged,
                      onSubmitted: onSearch,
                      style: Theme.of(context).textTheme.bodyMedium,
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: hintText,
                        hintStyle: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: palette.textMuted),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        suffixIconConstraints: BoxConstraints(
                          minWidth: inlineActionsWidth,
                          maxWidth: inlineActionsWidth,
                          minHeight: 38,
                          maxHeight: 38,
                        ),
                        suffixIcon: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _ToolbarSearchInlineAction(
                                tooltip: 'Search',
                                icon: Icons.search,
                                onPressed: () => onSearch(controller.text),
                              ),
                              if (onScanBarcode != null)
                                _ToolbarSearchInlineAction(
                                  tooltip: 'Scan barcode',
                                  icon: Icons.qr_code_2,
                                  onPressed: onScanBarcode!,
                                ),
                              if (onScanCover != null)
                                _ToolbarSearchInlineAction(
                                  tooltip: 'Search by cover',
                                  icon: Icons.image_search,
                                  onPressed: onScanCover!,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (showFilterChip) ...[
              const SizedBox(width: 6),
              InputChip(
                visualDensity: VisualDensity.compact,
                backgroundColor: selectionColor,
                label: Text(selectedFilterLabel!),
                onDeleted: onClearFilter,
              ),
            ],
          ],
        );
      },
    );
  }
}

class _ToolbarSearchInlineAction extends StatelessWidget {
  const _ToolbarSearchInlineAction({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return SizedBox(
      width: 30,
      child: Tooltip(
        message: tooltip,
        child: IconButton(
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          style: IconButton.styleFrom(
            backgroundColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            hoverColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          constraints: const BoxConstraints.tightFor(width: 30, height: 30),
          onPressed: onPressed,
          icon: Icon(icon, size: 19, color: palette.textPrimary),
        ),
      ),
    );
  }
}

class LibraryDetailsAwareLayout extends StatelessWidget {
  const LibraryDetailsAwareLayout({
    super.key,
    required this.content,
    required this.detailsLayout,
    required this.inspector,
    this.rightWidth = 340,
    this.bottomHeight = 310,
    this.onRightWidthChanged,
    this.maxRightWidth = kLibraryDetailsMaxWidth,
  });

  final Widget content;
  final LibraryDetailsLayout detailsLayout;
  final Widget inspector;
  final double rightWidth;
  final double bottomHeight;
  final ValueChanged<double>? onRightWidthChanged;
  final double maxRightWidth;

  @override
  Widget build(BuildContext context) {
    final effectiveRightWidth = clampLibraryPaneWidth(
      rightWidth,
      minWidth: kLibraryDetailsMinWidth,
      maxWidth: maxRightWidth,
    );
    return switch (detailsLayout) {
      LibraryDetailsLayout.right => Row(
          children: [
            Expanded(child: content),
            if (onRightWidthChanged == null)
              const VerticalDivider(width: 1)
            else
              LibraryResizableDivider(
                onDragDelta: (delta) => onRightWidthChanged!(
                  clampLibraryPaneWidth(
                    effectiveRightWidth - delta,
                    minWidth: kLibraryDetailsMinWidth,
                    maxWidth: maxRightWidth,
                  ),
                ),
              ),
            SizedBox(width: effectiveRightWidth, child: inspector),
          ],
        ),
      LibraryDetailsLayout.bottom => Column(
          children: [
            Expanded(child: content),
            const Divider(height: 1),
            SizedBox(height: bottomHeight, child: inspector),
          ],
        ),
      LibraryDetailsLayout.hidden => content,
    };
  }
}
