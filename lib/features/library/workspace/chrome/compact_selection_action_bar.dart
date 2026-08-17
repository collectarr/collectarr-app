import 'package:collectarr_app/ui/library_accent_scope.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// A touch-friendly floating / sticky bottom action bar that appears when items are selected in touch selection mode.
class CompactSelectionActionBar extends StatelessWidget {
  const CompactSelectionActionBar({
    super.key,
    required this.selectedCount,
    required this.totalCount,
    required this.onExitSelection,
    this.onToggleSelectAll,
    this.isAllSelected = false,
    this.onBulkEdit,
    this.onBulkDelete,
    this.onBulkChangeStatus,
    this.extraActions,
    this.height = 56.0,
  });

  final int selectedCount;
  final int totalCount;
  final VoidCallback onExitSelection;
  final VoidCallback? onToggleSelectAll;
  final bool isAllSelected;
  final VoidCallback? onBulkEdit;
  final VoidCallback? onBulkDelete;
  final VoidCallback? onBulkChangeStatus;
  final List<Widget>? extraActions;
  final double height;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final accentData = LibraryAccentScope.of(context);

    return Material(
      elevation: 8,
      color: palette.surface,
      shape: Border(
        top: BorderSide(
          color: accentData.accent.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: SafeArea(
        top: false,
        child: Container(
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              IconButton(
                key: const ValueKey('selection_bar_close'),
                icon: const Icon(Icons.close, size: 20),
                tooltip: 'Exit selection',
                onPressed: onExitSelection,
                visualDensity: VisualDensity.compact,
                color: palette.textPrimary,
              ),
              const SizedBox(width: 4),
              Text(
                '$selectedCount selected',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: palette.textPrimary,
                ),
              ),
              if (onToggleSelectAll != null) ...[
                const SizedBox(width: 8),
                TextButton(
                  key: const ValueKey('selection_bar_toggle_all'),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  onPressed: onToggleSelectAll,
                  child: Text(
                    isAllSelected ? 'Deselect all' : 'Select all',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: accentData.accent,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              if (onBulkEdit != null)
                IconButton(
                  key: const ValueKey('selection_bar_edit'),
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  tooltip: 'Bulk edit',
                  onPressed: selectedCount > 0 ? onBulkEdit : null,
                  visualDensity: VisualDensity.compact,
                  color: palette.textPrimary,
                ),
              if (onBulkChangeStatus != null)
                IconButton(
                  key: const ValueKey('selection_bar_status'),
                  icon: const Icon(Icons.checklist, size: 20),
                  tooltip: 'Change status',
                  onPressed: selectedCount > 0 ? onBulkChangeStatus : null,
                  visualDensity: VisualDensity.compact,
                  color: palette.textPrimary,
                ),
              if (onBulkDelete != null)
                IconButton(
                  key: const ValueKey('selection_bar_delete'),
                  icon: const Icon(Icons.delete_outline, size: 20),
                  tooltip: 'Delete selected',
                  onPressed: selectedCount > 0 ? onBulkDelete : null,
                  visualDensity: VisualDensity.compact,
                  color: Theme.of(context).colorScheme.error,
                ),
              if (extraActions != null) ...extraActions!,
            ],
          ),
        ),
      ),
    );
  }
}
