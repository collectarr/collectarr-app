import 'package:collectarr_app/features/library/selection/commands.dart';
import 'package:collectarr_app/features/library/selection/action.dart';
import 'package:collectarr_app/features/library/config/kind_style.dart';
import 'package:collectarr_app/features/library/selection/controls.dart';
import 'package:collectarr_app/features/library/workspace/chrome/chrome.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/ui/app_icons.dart';

class LibrarySelectionToolbarBand extends StatelessWidget {
  const LibrarySelectionToolbarBand({
    super.key,
    required this.selectedCount,
    required this.totalSelectableCount,
    required this.callbacks,
    required this.actions,
    this.accent,
    this.showBottomBorder = true,
  });

  final int selectedCount;
  final int totalSelectableCount;
  final LibrarySelectionStateCallbacks callbacks;
  final Color? accent;
  final List<ResolvedLibrarySelectionAction> actions;
  final bool showBottomBorder;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    // Selection is a shared-blue state, not a kind identity (see the item
    // selection fill), so the band ignores the kind accent.
    final effectiveAccent = palette.utilityAction;

    final borderBottom = Color.lerp(effectiveAccent, Colors.black, 0.14)!;
    final badgeBg = palette.isDark
        ? const Color(0xFF4CA3D8)
        : Color.lerp(effectiveAccent, Colors.black, 0.18)!;
    final dividerLeft = Color.lerp(effectiveAccent, Colors.black, 0.09)!;
    final dividerRight = Color.lerp(effectiveAccent, Colors.white, 0.11)!;

    final actionButtonStyle = TextButton.styleFrom(
      visualDensity: VisualDensity.compact,
      foregroundColor: Colors.white,
      backgroundColor: Colors.transparent,
      overlayColor: Colors.white.withValues(alpha: 0.15),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
      minimumSize: Size.zero,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      textStyle: TextStyle(
          fontFamily: appFontFamily,
          fontFamilyFallback: kAppFontFamilyFallback,
          fontSize: 14,
          fontWeight: FontWeight.w400),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
    );

    final isAllSelected =
        selectedCount == totalSelectableCount && totalSelectableCount > 0;

    return AnimatedLibraryChrome(
      accent: effectiveAccent,
      borderBuilder: (animatedAccent, _) => Border(
        bottom: showBottomBorder
            ? BorderSide(color: borderBottom)
            : BorderSide.none,
      ),
      child: SizedBox(
        width: double.infinity,
        height: kLibraryToolbarBandHeight,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final leftOptions = Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Tooltip(
                    message: 'Cancel',
                    child: TextButton.icon(
                      onPressed: callbacks.onClearSelection,
                      style: actionButtonStyle,
                      icon: const Icon(
                        AppIcons.close,
                        size: 13,
                        color: Colors.white,
                      ),
                      label: const Text('Cancel'),
                    ),
                  ),
                  LibrarySelectionToolbarDivider(
                    dividerLeft: dividerLeft,
                    dividerRight: dividerRight,
                  ),
                  Tooltip(
                    message: 'Select all visible items',
                    child: TextButton.icon(
                      onPressed: callbacks.onSelectAll,
                      style: actionButtonStyle,
                      icon: Icon(
                        isAllSelected
                            ? AppIcons.selectAll
                            : AppIcons.selectNone,
                        size: 14,
                        color: Colors.white,
                      ),
                      label: const Text('All'),
                    ),
                  ),
                ],
              );

              final centerActions = LibrarySelectionControls(
                actions: actions,
                onAccent: true,
                accent: effectiveAccent,
              );

              final rightCountPill = DecoratedBox(
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 3,
                  ),
                  child: Text(
                    '$selectedCount of $totalSelectableCount selected',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: Colors.white,
                        ),
                  ),
                ),
              );

              const minWidthForSpacedLayout = 880.0;
              final useSpacedLayout = constraints.hasBoundedWidth &&
                  constraints.maxWidth >= minWidthForSpacedLayout;

              if (useSpacedLayout) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    leftOptions,
                    const Spacer(),
                    centerActions,
                    const Spacer(),
                    Center(child: rightCountPill),
                  ],
                );
              }

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  height: kLibraryToolbarBandHeight - 6,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      leftOptions,
                      const SizedBox(width: 12),
                      centerActions,
                      const SizedBox(width: 16),
                      Center(child: rightCountPill),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
