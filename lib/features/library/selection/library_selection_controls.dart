import 'package:collectarr_app/features/library/workspace/config/library_workspace_tokens.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum _BulkAction {
  exportCsvTxt,
  exportXml,
  exportCovrPrice,
  duplicate,
  mergeAlbums,
  loan,
  transferFieldData,
  moveToCollection,
  updateKeyInfo,
  updateFromCore,
}

typedef LibrarySelectionCallbacks = ({
  VoidCallback onClearSelection,
  VoidCallback onSelectAll,
  VoidCallback? onBulkEdit,
  VoidCallback? onPrintToPdf,
  VoidCallback? onExportCsvTxt,
  VoidCallback? onBulkDuplicate,
  VoidCallback? onBulkLoan,
  VoidCallback? onTransferFieldData,
  VoidCallback? onBulkUpdateValues,
  VoidCallback? onBulkUpdateKeyInfo,
  VoidCallback? onBulkMoveToEntry,
  VoidCallback? onBulkMoveToWishlist,
  VoidCallback? onBulkRemove,
  VoidCallback? onBulkRefreshMetadata,
});

class LibrarySelectionToolbarDivider extends StatelessWidget {
  const LibrarySelectionToolbarDivider({
    super.key,
    required this.dividerLeft,
    required this.dividerRight,
    this.margin = const EdgeInsets.symmetric(horizontal: 3, vertical: 3.5),
  });

  final Color dividerLeft;
  final Color dividerRight;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 2,
      margin: margin,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(width: 1, color: dividerLeft),
          Container(width: 1, color: dividerRight),
        ],
      ),
    );
  }
}

class LibrarySelectionMoreIcon extends StatelessWidget {
  const LibrarySelectionMoreIcon({
    super.key,
    this.color = Colors.white,
    this.dotSize = 3.5,
    this.spacing = 3.5,
  });

  final Color color;
  final double dotSize;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: dotSize,
          height: dotSize,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(height: spacing),
        Container(
          width: dotSize,
          height: dotSize,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(height: spacing),
        Container(
          width: dotSize,
          height: dotSize,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }
}

class LibrarySelectionControls extends StatelessWidget {
  const LibrarySelectionControls({
    super.key,
    required this.callbacks,
    this.onAccent = false,
    this.accent,
    this.mergeLabel,
  });

  final LibrarySelectionCallbacks callbacks;
  final bool onAccent;
  final Color? accent;
  final String? mergeLabel;

  void _dispatchAfterMenuClose(VoidCallback action) {
    WidgetsBinding.instance.addPostFrameCallback((_) => action());
  }

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final effectiveAccent = accent ?? palette.accent;
    final dividerLeft = Color.lerp(effectiveAccent, Colors.black, 0.09)!;
    final dividerRight = Color.lerp(effectiveAccent, Colors.white, 0.11)!;

    final baseStyle = TextButton.styleFrom(
      visualDensity: VisualDensity.compact,
      foregroundColor: onAccent ? Colors.white : palette.textPrimary,
      backgroundColor: onAccent
          ? Colors.transparent
          : librarySelectionToolbarSecondaryAction(context),
      overlayColor: onAccent ? Colors.white.withValues(alpha: 0.15) : null,
      padding: onAccent
          ? const EdgeInsets.symmetric(horizontal: 6, vertical: 0)
          : const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      minimumSize: onAccent ? Size.zero : null,
      tapTargetSize: onAccent ? MaterialTapTargetSize.shrinkWrap : null,
      textStyle: onAccent
          ? const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)
          : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(onAccent ? 4 : 6),
        side: onAccent
            ? BorderSide.none
            : BorderSide(
                color: librarySelectionToolbarBorder(context)
                    .withValues(alpha: 0.86),
              ),
      ),
    );

    TextButton actionButton({
      required VoidCallback? onPressed,
      IconData? icon,
      String? svgAsset,
      required String label,
      Color? foregroundColor,
      Color? backgroundColor,
      Color? borderColor,
    }) {
      final effectiveFg = onAccent
          ? (foregroundColor ?? Colors.white)
          : (foregroundColor ?? palette.textPrimary);
      final effectiveBg = onAccent
          ? (backgroundColor ?? Colors.transparent)
          : (backgroundColor ??
              librarySelectionToolbarSecondaryAction(context));
      final effectiveBorder = onAccent
          ? (borderColor != null
              ? BorderSide(color: borderColor)
              : BorderSide.none)
          : BorderSide(
              color: borderColor ??
                  librarySelectionToolbarBorder(context)
                      .withValues(alpha: 0.86),
            );

      final iconWidget = svgAsset != null
          ? SvgPicture.asset(
              svgAsset,
              width: 15,
              height: 15,
              colorFilter: ColorFilter.mode(effectiveFg, BlendMode.srcIn),
            )
          : Icon(icon, size: 15);

      return TextButton.icon(
        onPressed: onPressed,
        icon: iconWidget,
        label: Text(label),
        style: baseStyle.copyWith(
          foregroundColor: WidgetStatePropertyAll(effectiveFg),
          backgroundColor: WidgetStatePropertyAll(effectiveBg),
          side: WidgetStatePropertyAll(effectiveBorder),
        ),
      );
    }

    PopupMenuItem<_BulkAction> accentMenuItem({
      required _BulkAction value,
      IconData? icon,
      String? svgAsset,
      required String label,
      required bool enabled,
    }) {
      final contentColor =
          enabled ? Colors.white : Colors.white.withValues(alpha: 0.38);
      return PopupMenuItem<_BulkAction>(
        value: value,
        enabled: enabled,
        height: 28,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: Center(
                child: svgAsset != null
                    ? SvgPicture.asset(
                        svgAsset,
                        width: 15,
                        height: 15,
                        colorFilter:
                            ColorFilter.mode(contentColor, BlendMode.srcIn),
                      )
                    : Icon(icon, size: 15, color: contentColor),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: contentColor,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final moreMenuButton = Theme(
      data: Theme.of(context).copyWith(
        dividerColor: const Color(0xFF4F4F4F),
      ),
      child: PopupMenuButton<_BulkAction>(
        key: const ValueKey('library-selection-more-button'),
        tooltip: 'More selection actions',
        position: onAccent ? PopupMenuPosition.under : PopupMenuPosition.over,
        color: onAccent
            ? const Color(0xFF333333)
            : librarySelectionToolbarSecondaryAction(context),
        surfaceTintColor: Colors.transparent,
        elevation: onAccent ? 6 : 8,
        menuPadding: onAccent
            ? const EdgeInsets.symmetric(vertical: 4)
            : EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(onAccent ? 2 : 6),
          side: BorderSide(
            color: onAccent
                ? const Color(0xFF4F4F4F)
                : librarySelectionToolbarBorder(context)
                    .withValues(alpha: 0.86),
          ),
        ),
        style: ButtonStyle(
          visualDensity: VisualDensity.compact,
          foregroundColor: WidgetStatePropertyAll(
            onAccent ? Colors.white : palette.textPrimary,
          ),
          backgroundColor: WidgetStatePropertyAll(
            onAccent
                ? Colors.transparent
                : librarySelectionToolbarSecondaryAction(context),
          ),
          overlayColor: onAccent
              ? WidgetStatePropertyAll(Colors.white.withValues(alpha: 0.15))
              : null,
          padding: WidgetStatePropertyAll(
            onAccent
                ? const EdgeInsets.symmetric(horizontal: 6, vertical: 0)
                : const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          ),
          minimumSize:
              onAccent ? const WidgetStatePropertyAll(Size.zero) : null,
          tapTargetSize: onAccent ? MaterialTapTargetSize.shrinkWrap : null,
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(onAccent ? 4 : 6),
              side: onAccent
                  ? BorderSide.none
                  : BorderSide(
                      color: librarySelectionToolbarBorder(context)
                          .withValues(alpha: 0.86),
                    ),
            ),
          ),
        ),
        icon: onAccent
            ? const LibrarySelectionMoreIcon(color: Colors.white)
            : const Icon(Icons.more_horiz, size: 18),
        onSelected: (action) {
          final callback = switch (action) {
            _BulkAction.exportCsvTxt => callbacks.onExportCsvTxt,
            _BulkAction.exportXml => null,
            _BulkAction.exportCovrPrice => null,
            _BulkAction.duplicate => callbacks.onBulkDuplicate,
            _BulkAction.mergeAlbums => null,
            _BulkAction.loan => callbacks.onBulkLoan,
            _BulkAction.transferFieldData => callbacks.onTransferFieldData,
            _BulkAction.moveToCollection =>
              callbacks.onBulkMoveToWishlist ?? callbacks.onBulkMoveToEntry,
            _BulkAction.updateKeyInfo => callbacks.onBulkUpdateKeyInfo,
            _BulkAction.updateFromCore => callbacks.onBulkRefreshMetadata,
          };
          if (callback != null) {
            _dispatchAfterMenuClose(callback);
          }
        },
        itemBuilder: (context) => onAccent
            ? [
                accentMenuItem(
                  value: _BulkAction.exportCsvTxt,
                  svgAsset: 'assets/sidebar_icons/file-export.svg',
                  icon: Icons.table_view_outlined,
                  label: 'Export to CSV / TXT',
                  enabled: callbacks.onExportCsvTxt != null,
                ),
                accentMenuItem(
                  value: _BulkAction.exportXml,
                  svgAsset: 'assets/sidebar_icons/file-export.svg',
                  icon: Icons.data_object_outlined,
                  label: 'Export to XML',
                  enabled: false,
                ),
                const PopupMenuDivider(height: 7),
                accentMenuItem(
                  value: _BulkAction.duplicate,
                  svgAsset: 'assets/sidebar_icons/clone.svg',
                  icon: Icons.copy_all_outlined,
                  label: 'Duplicate',
                  enabled: callbacks.onBulkDuplicate != null,
                ),
                accentMenuItem(
                  value: _BulkAction.mergeAlbums,
                  svgAsset: 'assets/sidebar_icons/compress.svg',
                  icon: Icons.call_merge,
                  label: mergeLabel ?? 'Merge Albums',
                  enabled: false,
                ),
                accentMenuItem(
                  value: _BulkAction.loan,
                  svgAsset: 'assets/sidebar_icons/clock.svg',
                  icon: Icons.schedule_outlined,
                  label: 'Loan',
                  enabled: callbacks.onBulkLoan != null,
                ),
                accentMenuItem(
                  value: _BulkAction.transferFieldData,
                  svgAsset: 'assets/sidebar_icons/arrows-turn-right.svg',
                  icon: Icons.swap_horiz,
                  label: 'Transfer Field Data',
                  enabled: callbacks.onTransferFieldData != null,
                ),
                accentMenuItem(
                  value: _BulkAction.moveToCollection,
                  svgAsset: 'assets/sidebar_icons/database.svg',
                  icon: Icons.dns_outlined,
                  label: 'Move to other collection',
                  enabled: callbacks.onBulkMoveToWishlist != null ||
                      callbacks.onBulkMoveToEntry != null,
                ),
                const PopupMenuDivider(height: 7),
                accentMenuItem(
                  value: _BulkAction.updateFromCore,
                  svgAsset: 'assets/sidebar_icons/cloud-arrow-down.svg',
                  icon: Icons.cloud_download_outlined,
                  label: 'Update from Core',
                  enabled: callbacks.onBulkRefreshMetadata != null,
                ),
              ]
            : [
                PopupMenuItem(
                  value: _BulkAction.exportCsvTxt,
                  enabled: callbacks.onExportCsvTxt != null,
                  child: const Material(
                    type: MaterialType.transparency,
                    child: ListTile(
                      leading: Icon(Icons.table_view_outlined),
                      title: Text('Export to CSV / TXT'),
                      dense: true,
                    ),
                  ),
                ),
                const PopupMenuItem(
                  value: _BulkAction.exportXml,
                  enabled: false,
                  child: Material(
                    type: MaterialType.transparency,
                    child: ListTile(
                      leading: Icon(Icons.data_object_outlined),
                      title: Text('Export to XML'),
                      dense: true,
                    ),
                  ),
                ),
                const PopupMenuItem(
                  value: _BulkAction.exportCovrPrice,
                  enabled: false,
                  child: Material(
                    type: MaterialType.transparency,
                    child: ListTile(
                      leading: Icon(Icons.sell_outlined),
                      title: Text('Export for CovrPrice'),
                      dense: true,
                    ),
                  ),
                ),
                PopupMenuItem(
                  value: _BulkAction.transferFieldData,
                  enabled: callbacks.onTransferFieldData != null,
                  child: const Material(
                    type: MaterialType.transparency,
                    child: ListTile(
                      leading: Icon(Icons.swap_horiz),
                      title: Text('Transfer Field Data'),
                      dense: true,
                    ),
                  ),
                ),
                PopupMenuItem(
                  value: _BulkAction.updateKeyInfo,
                  enabled: callbacks.onBulkUpdateKeyInfo != null,
                  child: const Material(
                    type: MaterialType.transparency,
                    child: ListTile(
                      leading: Icon(Icons.key_outlined),
                      title: Text('Update Key Info'),
                      dense: true,
                    ),
                  ),
                ),
                PopupMenuItem(
                  value: _BulkAction.updateFromCore,
                  enabled: callbacks.onBulkRefreshMetadata != null,
                  child: const Material(
                    type: MaterialType.transparency,
                    child: ListTile(
                      leading: Icon(Icons.sync),
                      title: Text('Update from Core'),
                      dense: true,
                    ),
                  ),
                ),
              ],
      ),
    );

    if (onAccent) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          actionButton(
            onPressed: callbacks.onBulkEdit,
            svgAsset: 'assets/sidebar_icons/pen-to-square.svg',
            icon: Icons.edit_outlined,
            label: 'Edit',
          ),
          actionButton(
            onPressed: callbacks.onBulkRemove,
            svgAsset: 'assets/sidebar_icons/trash.svg',
            icon: Icons.delete_outline,
            label: 'Remove',
          ),
          LibrarySelectionToolbarDivider(
            dividerLeft: dividerLeft,
            dividerRight: dividerRight,
          ),
          actionButton(
            onPressed: callbacks.onPrintToPdf,
            svgAsset: 'assets/sidebar_icons/print.svg',
            icon: Icons.picture_as_pdf_outlined,
            label: 'Print to PDF',
          ),
          LibrarySelectionToolbarDivider(
            dividerLeft: dividerLeft,
            dividerRight: dividerRight,
          ),
          moreMenuButton,
        ],
      );
    }

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        actionButton(
          onPressed: callbacks.onBulkEdit,
          icon: Icons.edit_outlined,
          label: 'Edit',
        ),
        actionButton(
          onPressed: callbacks.onBulkRemove,
          icon: Icons.delete_outline,
          label: 'Remove',
          foregroundColor: Theme.of(context).colorScheme.error,
          backgroundColor: Theme.of(context)
              .colorScheme
              .errorContainer
              .withValues(alpha: 0.34),
          borderColor:
              Theme.of(context).colorScheme.error.withValues(alpha: 0.52),
        ),
        actionButton(
          onPressed: callbacks.onBulkDuplicate,
          icon: Icons.copy_all_outlined,
          label: 'Duplicate',
        ),
        actionButton(
          onPressed: callbacks.onBulkLoan,
          icon: Icons.handshake_outlined,
          label: 'Loan',
        ),
        actionButton(
          onPressed: callbacks.onBulkMoveToEntry,
          icon: Icons.inventory_2_outlined,
          label: 'Move to entry',
        ),
        actionButton(
          onPressed: callbacks.onBulkMoveToWishlist,
          icon: Icons.star_border,
          label: 'Move to wishlist',
        ),
        actionButton(
          onPressed: callbacks.onPrintToPdf,
          icon: Icons.picture_as_pdf_outlined,
          label: 'Print to PDF',
        ),
        actionButton(
          onPressed: callbacks.onBulkUpdateValues,
          icon: Icons.price_change_outlined,
          label: 'Update values',
        ),
        moreMenuButton,
      ],
    );
  }
}
