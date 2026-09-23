import 'package:collectarr_app/ui/theme/theme_palette.dart';
import 'package:flutter/material.dart';

/// The kind-owned row data shown by [LibraryExternalLinksTable].
///
/// The owning kind keeps the controllers and domain model. This row only gives
/// the shared editor a stable identity and the two editable values it displays.
final class LibraryExternalLinkEditRow<TIdentity extends Object> {
  const LibraryExternalLinkEditRow({
    required this.identity,
    required this.urlController,
    required this.descriptionController,
    this.urlFieldKey,
    this.descriptionFieldKey,
  });

  final TIdentity identity;
  final TextEditingController urlController;
  final TextEditingController descriptionController;
  final Key? urlFieldKey;
  final Key? descriptionFieldKey;

  Key get key => ObjectKey(identity);
}

/// Shared editable links table used by all kind-specific Links tabs.
final class LibraryExternalLinksTable<TIdentity extends Object>
    extends StatefulWidget {
  const LibraryExternalLinksTable({
    super.key,
    required this.rows,
    required this.accent,
    required this.addLabel,
    required this.onAdd,
    required this.onReorder,
    required this.onRemoveSelected,
    this.onChanged,
    this.emptyMessage = 'No links added yet.',
  });

  final List<LibraryExternalLinkEditRow<TIdentity>> rows;
  final Color accent;
  final String addLabel;
  final VoidCallback onAdd;
  final void Function(int oldIndex, int newIndex) onReorder;
  final ValueChanged<List<LibraryExternalLinkEditRow<TIdentity>>>
      onRemoveSelected;
  final VoidCallback? onChanged;
  final String emptyMessage;

  @override
  State<LibraryExternalLinksTable<TIdentity>> createState() =>
      _LibraryExternalLinksTableState<TIdentity>();
}

final class _LibraryExternalLinksTableState<TIdentity extends Object>
    extends State<LibraryExternalLinksTable<TIdentity>> {
  final Set<Key> _selectedKeys = {};
  TIdentity? _draggingIdentity;

  @override
  void didUpdateWidget(
    covariant LibraryExternalLinksTable<TIdentity> oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);
    final rowKeys = widget.rows.map((row) => row.key).toSet();
    _selectedKeys.removeWhere((key) => !rowKeys.contains(key));
  }

  void _toggleSelected(
    LibraryExternalLinkEditRow<TIdentity> row,
    bool selected,
  ) {
    setState(() {
      if (selected) {
        _selectedKeys.add(row.key);
      } else {
        _selectedKeys.remove(row.key);
      }
    });
  }

  void _toggleAllSelected() {
    setState(() {
      if (_selectedKeys.length == widget.rows.length) {
        _selectedKeys.clear();
      } else {
        _selectedKeys
          ..clear()
          ..addAll(widget.rows.map((row) => row.key));
      }
    });
  }

  void _removeSelected() {
    final selectedRows = [
      for (final row in widget.rows)
        if (_selectedKeys.contains(row.key)) row,
    ];
    if (selectedRows.isEmpty) return;
    widget.onRemoveSelected(selectedRows);
    setState(_selectedKeys.clear);
  }

  void _add() {
    widget.onAdd();
    setState(_selectedKeys.clear);
  }

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final selecting = _selectedKeys.isNotEmpty;
    final allSelected =
        widget.rows.isNotEmpty && _selectedKeys.length == widget.rows.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: palette.divider),
            borderRadius: BorderRadius.circular(4),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              if (selecting)
                _buildSelectionHeader(palette, allSelected)
              else
                _buildColumnHeader(palette),
              if (widget.rows.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      widget.emptyMessage,
                      style: TextStyle(color: palette.textMuted),
                    ),
                  ),
                )
              else
                for (var index = 0; index < widget.rows.length; index++)
                  _buildRow(context, index),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: OutlinedButton.icon(
            onPressed: _add,
            icon: const Icon(Icons.add),
            label: Text(widget.addLabel),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectionHeader(AppThemePalette palette, bool allSelected) {
    return Container(
      height: 40,
      color: widget.accent,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          TextButton.icon(
            onPressed: () => setState(_selectedKeys.clear),
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Text(
                '${_selectedKeys.length} of ${widget.rows.length}',
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
    );
  }

  Widget _buildColumnHeader(AppThemePalette palette) {
    return Container(
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
    );
  }

  Widget _buildRow(BuildContext context, int index) {
    final row = widget.rows[index];
    final palette = appPalette(context);
    final isSelected = _selectedKeys.contains(row.key);
    return LayoutBuilder(
      builder: (context, constraints) => DragTarget<int>(
        key: row.key,
        onWillAcceptWithDetails: (details) => details.data != index,
        onAcceptWithDetails: (details) {
          widget.onReorder(details.data, index);
          setState(() => _draggingIdentity = null);
        },
        builder: (context, candidates, rejected) {
          final isDropTarget = candidates.isNotEmpty;
          return AnimatedOpacity(
            duration: const Duration(milliseconds: 100),
            opacity: identical(_draggingIdentity, row.identity) ? 0.35 : 1,
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
                        onDragStarted: () =>
                            setState(() => _draggingIdentity = row.identity),
                        onDragEnd: (_) {
                          if (mounted) {
                            setState(() => _draggingIdentity = null);
                          }
                        },
                        feedback: _buildDragFeedback(
                          row,
                          constraints.maxWidth,
                          palette,
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
                      key: row.urlFieldKey ?? ValueKey((row.key, 'url')),
                      controller: row.urlController,
                      decoration: const InputDecoration(
                        hintText: 'https://example.com',
                        isDense: true,
                      ),
                      keyboardType: TextInputType.url,
                      onChanged: (_) => widget.onChanged?.call(),
                    ),
                  ),
                  const SizedBox(width: _columnGap),
                  Expanded(
                    flex: 5,
                    child: TextFormField(
                      key: row.descriptionFieldKey ??
                          ValueKey((row.key, 'description')),
                      controller: row.descriptionController,
                      decoration: const InputDecoration(isDense: true),
                      onChanged: (_) => widget.onChanged?.call(),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDragFeedback(
    LibraryExternalLinkEditRow<TIdentity> row,
    double availableWidth,
    AppThemePalette palette,
  ) {
    final width =
        availableWidth.isFinite && availableWidth > 0 ? availableWidth : 520.0;
    return Material(
      color: Colors.transparent,
      elevation: 8,
      child: Container(
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
                row.urlController.text.isEmpty
                    ? 'https://example.com'
                    : row.urlController.text,
                palette,
              ),
            ),
            const SizedBox(width: _columnGap),
            Expanded(
              flex: 5,
              child: _dragFeedbackCell(row.descriptionController.text, palette),
            ),
          ],
        ),
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
