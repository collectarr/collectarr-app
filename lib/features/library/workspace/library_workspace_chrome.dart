import 'package:collectarr_app/features/settings/ui_preferences.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'library_pane_widths.dart';
import 'library_resizable_pane.dart';
import 'library_workspace_config.dart';

class LibraryToolbarFrame extends StatelessWidget {
  const LibraryToolbarFrame({
    super.key,
    required this.child,
    required this.backgroundColor,
    required this.dividerColor,
  });

  final Widget child;
  final Color backgroundColor;
  final Color dividerColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(bottom: BorderSide(color: dividerColor)),
      ),
      child: child,
    );
  }
}

class LibraryWorkspaceIconButton extends StatelessWidget {
  const LibraryWorkspaceIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.dimension = 30,
    this.iconSize = 17,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final double dimension;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: dimension,
      child: IconButton.filledTonal(
        visualDensity: VisualDensity.compact,
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        icon: Icon(icon, size: iconSize),
      ),
    );
  }
}

class LibraryWorkspaceSeparator extends StatelessWidget {
  const LibraryWorkspaceSeparator({
    super.key,
    required this.color,
    this.horizontalPadding = 7,
    this.height = 24,
  });

  final Color color;
  final double horizontalPadding;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: SizedBox(
        height: height,
        child: VerticalDivider(width: 1, thickness: 1, color: color),
      ),
    );
  }
}

class LibraryWorkspaceControlStrip extends StatelessWidget {
  const LibraryWorkspaceControlStrip({
    super.key,
    required this.children,
    this.spacing = 6,
  });

  final List<Widget> children;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Align(
        alignment: Alignment.centerRight,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: _spacedChildren(),
          ),
        ),
      ),
    );
  }

  List<Widget> _spacedChildren() {
    final spaced = <Widget>[];
    for (var index = 0; index < children.length; index += 1) {
      if (index > 0) {
        spaced.add(SizedBox(width: spacing));
      }
      spaced.add(children[index]);
    }
    return spaced;
  }
}

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
    final useFab = ref.watch(uiPreferencesProvider.select((p) => p.fabAddButton));
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
    this.selectedFilterLabel,
    this.onClearFilter,
    this.onChanged,
    this.maxWidth = 320,
  });

  final TextEditingController controller;
  final String hintText;
  final String? selectedFilterLabel;
  final ValueChanged<String> onSearch;
  final VoidCallback? onClearFilter;
  final ValueChanged<String>? onChanged;
  final Color selectionColor;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final inputBackground = Color.alphaBlend(
      Colors.black.withValues(alpha: 0.42),
      palette.surface,
    );
    final borderColor = Color.alphaBlend(
      palette.textMuted.withValues(alpha: 0.22),
      palette.divider,
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: inputBackground,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: borderColor),
            ),
            child: SizedBox(
              height: 36,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 8),
                    child: Icon(
                      Icons.search,
                      size: 18,
                      color: palette.textMuted,
                    ),
                  ),
                  Expanded(
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
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  Container(
                    width: 36,
                    decoration: BoxDecoration(
                      border: Border(left: BorderSide(color: borderColor)),
                    ),
                    child: Tooltip(
                      message: 'Search',
                      child: IconButton(
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        onPressed: () => onSearch(controller.text),
                        icon: Icon(
                          Icons.search,
                          size: 18,
                          color: palette.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (selectedFilterLabel != null) ...[
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
