import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:flutter/material.dart';

@immutable
final class LibraryNamedDetailControllers {
  const LibraryNamedDetailControllers({
    required this.identity,
    required this.name,
    required this.detail,
  });

  final Object identity;
  final TextEditingController name;
  final TextEditingController detail;
}

/// Shared ordered name/detail editor for credits and kind-specific people lists.
///
/// The kind owns its credit models and mutations. This widget only renders
/// their controller pairs and reports edits/additions to the owning draft.
final class LibraryNamedDetailList extends StatelessWidget {
  const LibraryNamedDetailList({
    super.key,
    required this.title,
    required this.emptyMessage,
    required this.addLabel,
    required this.accent,
    required this.rows,
    this.nameLabel = 'Name',
    this.detailLabel = 'Role',
    required this.onAdd,
    required this.onRemove,
    required this.onReorder,
    required this.onChanged,
  });

  final String title;
  final String emptyMessage;
  final String addLabel;
  final Color accent;
  final List<LibraryNamedDetailControllers> Function() rows;
  final String nameLabel;
  final String detailLabel;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;
  final void Function(int oldIndex, int newIndex) onReorder;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) => StatefulBuilder(
        builder: (context, setState) {
          final credits = rows();
          return EditSection(
            title: title,
            accent: accent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (credits.isEmpty)
                  EditSectionStateMessage(
                    message: emptyMessage,
                    icon: Icons.person_outline,
                  )
                else
                  ReorderableListView.builder(
                    shrinkWrap: true,
                    primary: false,
                    physics: const NeverScrollableScrollPhysics(),
                    buildDefaultDragHandles: false,
                    itemCount: credits.length,
                    onReorderItem: (oldIndex, newIndex) {
                      onReorder(oldIndex, newIndex);
                      setState(() {});
                      onChanged();
                    },
                    itemBuilder: (context, index) {
                      final credit = credits[index];
                      return Padding(
                        key: ObjectKey(credit.identity),
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            ReorderableDragStartListener(
                              index: index,
                              child: const Icon(Icons.drag_indicator, size: 18),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: LibraryEditTextField(
                                controller: credit.name,
                                label: nameLabel,
                                maxLines: 1,
                                onChanged: (_) => onChanged(),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: LibraryEditTextField(
                                controller: credit.detail,
                                label: detailLabel,
                                maxLines: 1,
                                onChanged: (_) => onChanged(),
                              ),
                            ),
                            IconButton(
                              tooltip: 'Remove ${title.toLowerCase()} credit',
                              visualDensity: VisualDensity.compact,
                              onPressed: () {
                                onRemove(index);
                                setState(() {});
                                onChanged();
                              },
                              icon: const Icon(Icons.close, size: 18),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () {
                    onAdd();
                    setState(() {});
                    onChanged();
                  },
                  icon: const Icon(Icons.add),
                  label: Text(addLabel),
                ),
              ],
            ),
          );
        },
      );
}
