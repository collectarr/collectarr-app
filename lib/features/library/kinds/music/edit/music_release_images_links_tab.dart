import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_external_link.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_release_edit_draft.dart';
import 'package:collectarr_app/ui/theme/theme_palette.dart';
import 'package:flutter/material.dart';

final class MusicReleaseLinksTab extends StatefulWidget {
  const MusicReleaseLinksTab({
    super.key,
    required this.draft,
    required this.accent,
  });

  final MusicReleaseEditDraft draft;
  final Color accent;

  @override
  State<MusicReleaseLinksTab> createState() => _MusicReleaseLinksTabState();
}

final class _MusicReleaseLinksTabState extends State<MusicReleaseLinksTab> {
  late final List<_ReleaseLinkRow> _rows;
  final Set<_ReleaseLinkRow> _selectedRows = {};
  _ReleaseLinkRow? _draggingRow;

  @override
  void initState() {
    super.initState();
    _rows = [
      for (final link in widget.draft.externalLinks)
        _ReleaseLinkRow.fromLink(link),
    ];
  }

  @override
  void dispose() {
    for (final row in _rows) {
      row.dispose();
    }
    super.dispose();
  }

  void _syncDraft() {
    widget.draft.externalLinks = [
      for (final row in _rows)
        MusicExternalLink(
          url: row.url.text.trim(),
          title: row.original?.title,
          description: _nullable(row.description.text),
          source: row.original?.source ?? 'manual',
          isAutomatic: row.original?.isAutomatic ?? false,
        ),
    ];
  }

  void _reorder(int sourceIndex, int targetIndex) {
    if (sourceIndex == targetIndex) return;
    final row = _rows.removeAt(sourceIndex);
    _rows.insert(targetIndex, row);
    setState(() {});
    _syncDraft();
  }

  void _toggleSelected(_ReleaseLinkRow row, bool selected) {
    setState(() {
      if (selected) {
        _selectedRows.add(row);
      } else {
        _selectedRows.remove(row);
      }
    });
  }

  void _toggleAllSelected() {
    setState(() {
      if (_selectedRows.length == _rows.length) {
        _selectedRows.clear();
      } else {
        _selectedRows
          ..clear()
          ..addAll(_rows);
      }
    });
  }

  void _removeSelected() {
    final removed = _rows.where(_selectedRows.contains).toList();
    if (removed.isEmpty) return;
    _rows.removeWhere(_selectedRows.contains);
    for (final row in removed) {
      row.dispose();
    }
    setState(_selectedRows.clear);
    _syncDraft();
  }

  @override
  Widget build(BuildContext context) => EditTabShell(
        children: [
          EditSection(
            title: 'Release links',
            accent: widget.accent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLinksTable(context),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _selectedRows.clear();
                        _rows.add(_ReleaseLinkRow.empty());
                      });
                      _syncDraft();
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('New Link'),
                  ),
                ),
              ],
            ),
          ),
        ],
      );

  Widget _buildLinksTable(BuildContext context) {
    final palette = appPalette(context);
    final selecting = _selectedRows.isNotEmpty;
    final allSelected = _selectedRows.length == _rows.length;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: palette.divider),
        borderRadius: BorderRadius.circular(4),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          if (selecting)
            Container(
              height: 40,
              color: widget.accent,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  TextButton.icon(
                    onPressed: () => setState(_selectedRows.clear),
                    style: TextButton.styleFrom(
                      foregroundColor: palette.textPrimary,
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      minimumSize: const Size(0, 32),
                    ),
                    icon: const Icon(Icons.close, size: 16),
                    label: const Text('Cancel'),
                  ),
                  Checkbox(
                    value: allSelected,
                    onChanged: (_) => _toggleAllSelected(),
                    visualDensity: VisualDensity.compact,
                    side: BorderSide(color: palette.textPrimary),
                    checkColor: palette.panel,
                    fillColor: WidgetStateProperty.resolveWith(
                      (states) => states.contains(WidgetState.selected)
                          ? palette.textPrimary
                          : Colors.transparent,
                    ),
                  ),
                  Text('All', style: TextStyle(color: palette.textPrimary)),
                  const Spacer(),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      child: Text(
                        '${_selectedRows.length} of ${_rows.length}',
                        style: TextStyle(
                          color: palette.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: _removeSelected,
                    style: TextButton.styleFrom(
                      foregroundColor: palette.textPrimary,
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      minimumSize: const Size(0, 32),
                    ),
                    icon: const Icon(Icons.delete_outline, size: 16),
                    label: const Text('Remove'),
                  ),
                ],
              ),
            )
          else
            Container(
              height: 36,
              color: palette.panelRaised,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Row(
                children: [
                  const SizedBox(width: _handleColumnWidth),
                  const SizedBox(width: _selectionColumnWidth),
                  Expanded(
                    flex: 7,
                    child: Text(
                      'URL',
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: _columnGap),
                  Expanded(
                    flex: 5,
                    child: Text(
                      'Description',
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          for (var index = 0; index < _rows.length; index++)
            _buildLinkRow(context, index),
        ],
      ),
    );
  }

  Widget _buildLinkRow(BuildContext context, int index) {
    final row = _rows[index];
    final palette = appPalette(context);
    return DragTarget<int>(
      key: row.key,
      onWillAcceptWithDetails: (details) => details.data != index,
      onAcceptWithDetails: (details) => _reorder(details.data, index),
      builder: (context, candidates, rejected) {
        final isDropTarget = candidates.isNotEmpty;
        final isSelected = _selectedRows.contains(row);
        return LayoutBuilder(
          builder: (context, constraints) => AnimatedOpacity(
            duration: const Duration(milliseconds: 100),
            opacity: identical(_draggingRow, row) ? 0.35 : 1,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
              decoration: BoxDecoration(
                color: isDropTarget
                    ? widget.accent.withValues(alpha: 0.12)
                    : isSelected
                        ? palette.selection.withValues(alpha: 0.35)
                        : index.isEven
                            ? palette.tableEvenRow
                            : palette.tableOddRow,
                border: Border(
                  bottom: BorderSide(color: palette.tableBottomBorder),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: _handleColumnWidth,
                    height: 36,
                    child: Center(
                      child: Draggable<int>(
                        data: index,
                        onDragStarted: () => setState(() => _draggingRow = row),
                        onDragEnd: (_) {
                          if (mounted) setState(() => _draggingRow = null);
                        },
                        feedback: Material(
                          color: Colors.transparent,
                          elevation: 8,
                          child: _buildDragFeedback(
                            row,
                            constraints.maxWidth,
                            palette,
                          ),
                        ),
                        childWhenDragging: Icon(
                          Icons.drag_indicator,
                          color: palette.textMuted,
                        ),
                        child: const MouseRegion(
                          cursor: SystemMouseCursors.grab,
                          child: Tooltip(
                            message: 'Drag to reorder',
                            child: Icon(Icons.drag_indicator, size: 20),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: _selectionColumnWidth,
                    child: Checkbox(
                      value: isSelected,
                      onChanged: (value) =>
                          _toggleSelected(row, value ?? false),
                      visualDensity: VisualDensity.compact,
                      activeColor: widget.accent,
                      side: BorderSide(color: palette.textMuted),
                    ),
                  ),
                  Expanded(
                    flex: 7,
                    child: TextFormField(
                      key: ValueKey('musicReleaseLinkUrl_${row.key}'),
                      controller: row.url,
                      decoration: const InputDecoration(
                        hintText: 'https://example.com',
                        isDense: true,
                      ),
                      keyboardType: TextInputType.url,
                      onChanged: (_) => _syncDraft(),
                    ),
                  ),
                  const SizedBox(width: _columnGap),
                  Expanded(
                    flex: 5,
                    child: TextFormField(
                      key: ValueKey('musicReleaseLinkDescription_${row.key}'),
                      controller: row.description,
                      decoration: const InputDecoration(isDense: true),
                      onChanged: (_) => _syncDraft(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDragFeedback(
    _ReleaseLinkRow row,
    double availableWidth,
    AppThemePalette palette,
  ) {
    final width =
        availableWidth.isFinite && availableWidth > 0 ? availableWidth : 520.0;
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      decoration: BoxDecoration(
        color: palette.panelRaised,
        border: Border.all(color: widget.accent, width: 1.5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          SizedBox(
            width: _handleColumnWidth,
            child: Icon(Icons.drag_indicator, color: widget.accent),
          ),
          const SizedBox(width: _selectionColumnWidth),
          Expanded(
            flex: 7,
            child: _dragFeedbackCell(
              row.url.text.isEmpty ? 'https://example.com' : row.url.text,
              palette,
            ),
          ),
          const SizedBox(width: _columnGap),
          Expanded(
            flex: 5,
            child: _dragFeedbackCell(row.description.text, palette),
          ),
        ],
      ),
    );
  }

  Widget _dragFeedbackCell(String value, AppThemePalette palette) => Container(
        height: 38,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: palette.field,
          border: Border.all(color: palette.divider),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: palette.textPrimary),
        ),
      );
}

const double _handleColumnWidth = 28;
const double _selectionColumnWidth = 34;
const double _columnGap = 10;

final class _ReleaseLinkRow {
  _ReleaseLinkRow({
    required this.url,
    required this.description,
    this.original,
  }) : key = UniqueKey();

  factory _ReleaseLinkRow.empty() => _ReleaseLinkRow(
        url: TextEditingController(),
        description: TextEditingController(),
      );

  factory _ReleaseLinkRow.fromLink(MusicExternalLink link) => _ReleaseLinkRow(
        url: TextEditingController(text: link.url),
        description: TextEditingController(
          text: link.description ?? link.title ?? '',
        ),
        original: link,
      );

  final Key key;
  final TextEditingController url;
  final TextEditingController description;
  final MusicExternalLink? original;

  void dispose() {
    url.dispose();
    description.dispose();
  }
}

String? _nullable(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
