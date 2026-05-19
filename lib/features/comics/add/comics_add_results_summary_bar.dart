import 'package:collectarr_app/features/library/add/library_add_result_badge.dart';
import 'package:flutter/material.dart';

class ComicsAddResultsSummaryBar extends StatelessWidget {
  const ComicsAddResultsSummaryBar({
    super.key,
    required this.visibleCount,
    required this.addableCount,
    required this.selectedCount,
    required this.seriesCount,
    required this.onSelectAll,
    required this.onClear,
    this.allCollapsed = false,
    this.onToggleCollapseAll,
  });

  final int visibleCount;
  final int addableCount;
  final int selectedCount;
  final int seriesCount;
  final VoidCallback? onSelectAll;
  final VoidCallback? onClear;
  final bool allCollapsed;
  final VoidCallback? onToggleCollapseAll;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
      decoration: const BoxDecoration(
        color: Color(0xFF252525),
        border: Border(bottom: BorderSide(color: Color(0xFF444444))),
      ),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  LibraryAddResultBadge(
                    '$visibleCount result${visibleCount == 1 ? '' : 's'}',
                  ),
                  const SizedBox(width: 6),
                  LibraryAddResultBadge('$seriesCount series'),
                  const SizedBox(width: 6),
                  LibraryAddResultBadge('$selectedCount selected'),
                  if (addableCount != visibleCount) ...[
                    const SizedBox(width: 6),
                    LibraryAddResultBadge('$addableCount addable'),
                  ],
                ],
              ),
            ),
          ),
          Wrap(
            spacing: 4,
            children: [
              if (onToggleCollapseAll != null)
                IconButton(
                  icon: Icon(
                    allCollapsed
                        ? Icons.unfold_more
                        : Icons.unfold_less,
                    size: 18,
                  ),
                  tooltip:
                      allCollapsed ? 'Expand all' : 'Collapse all',
                  onPressed: onToggleCollapseAll,
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              TextButton(
                onPressed: onSelectAll,
                child: const Text('Select all'),
              ),
              TextButton(
                onPressed: onClear,
                child: const Text('Clear'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
