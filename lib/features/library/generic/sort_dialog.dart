import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';
import 'package:flutter/material.dart';

Future<List<LibrarySortRule>?> showLibrarySortDialog({
  required BuildContext context,
  required List<LibrarySortRule> currentRules,
}) {
  return showDialog<List<LibrarySortRule>>(
    context: context,
    builder: (context) => _LibrarySortDialog(currentRules: currentRules),
  );
}

class _LibrarySortDialog extends StatefulWidget {
  const _LibrarySortDialog({required this.currentRules});

  final List<LibrarySortRule> currentRules;

  @override
  State<_LibrarySortDialog> createState() => _LibrarySortDialogState();
}

class _LibrarySortDialogState extends State<_LibrarySortDialog> {
  late List<LibrarySortRule> _rules;

  @override
  void initState() {
    super.initState();
    _rules = widget.currentRules.isEmpty
        ? const [
            LibrarySortRule(
              column: LibrarySortColumn.title,
              ascending: true,
            ),
          ]
        : List<LibrarySortRule>.from(widget.currentRules);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Sort rules'),
      content: SizedBox(
        width: 560,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('The first rule is primary. Later rules break ties.'),
            const SizedBox(height: 12),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    for (var index = 0; index < _rules.length; index++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _SortRuleRow(
                          index: index,
                          rule: _rules[index],
                          canMoveUp: index > 0,
                          canMoveDown: index < _rules.length - 1,
                          canRemove: _rules.length > 1,
                          onColumnChanged: (column) {
                            setState(() {
                              _rules[index] =
                                  _rules[index].copyWith(column: column);
                              _rules = _dedupeRules(_rules);
                            });
                          },
                          onAscendingChanged: (ascending) {
                            setState(() {
                              _rules[index] = _rules[index].copyWith(
                                ascending: ascending,
                              );
                            });
                          },
                          onMoveUp: () => _moveRule(index, index - 1),
                          onMoveDown: () => _moveRule(index, index + 1),
                          onRemove: () {
                            setState(() {
                              _rules.removeAt(index);
                            });
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: _rules.length >= LibrarySortColumn.values.length
                    ? null
                    : _addRule,
                icon: const Icon(Icons.add),
                label: const Text('Add rule'),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_dedupeRules(_rules)),
          child: const Text('Apply'),
        ),
      ],
    );
  }

  void _addRule() {
    final usedColumns = _rules.map((rule) => rule.column).toSet();
    final nextColumn = LibrarySortColumn.values.firstWhere(
      (column) => !usedColumns.contains(column),
      orElse: () => LibrarySortColumn.title,
    );
    setState(() {
      _rules = [
        ..._rules,
        LibrarySortRule(column: nextColumn, ascending: true),
      ];
    });
  }

  void _moveRule(int fromIndex, int toIndex) {
    setState(() {
      final rule = _rules.removeAt(fromIndex);
      _rules.insert(toIndex, rule);
    });
  }
}

class _SortRuleRow extends StatelessWidget {
  const _SortRuleRow({
    required this.index,
    required this.rule,
    required this.canMoveUp,
    required this.canMoveDown,
    required this.canRemove,
    required this.onColumnChanged,
    required this.onAscendingChanged,
    required this.onMoveUp,
    required this.onMoveDown,
    required this.onRemove,
  });

  final int index;
  final LibrarySortRule rule;
  final bool canMoveUp;
  final bool canMoveDown;
  final bool canRemove;
  final ValueChanged<LibrarySortColumn> onColumnChanged;
  final ValueChanged<bool> onAscendingChanged;
  final VoidCallback onMoveUp;
  final VoidCallback onMoveDown;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 28,
              child: Padding(
                padding: const EdgeInsets.only(top: 14),
                child: Text('${index + 1}.'),
              ),
            ),
            Expanded(
              child: DropdownButtonFormField<LibrarySortColumn>(
                initialValue: rule.column,
                decoration: const InputDecoration(
                  labelText: 'Column',
                  border: OutlineInputBorder(),
                ),
                items: [
                  for (final column in LibrarySortColumn.values)
                    DropdownMenuItem<LibrarySortColumn>(
                      value: column,
                      child: Text(_sortColumnLabel(column)),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    onColumnChanged(value);
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment<bool>(value: true, label: Text('Asc')),
                ButtonSegment<bool>(value: false, label: Text('Desc')),
              ],
              selected: {rule.ascending},
              onSelectionChanged: (value) => onAscendingChanged(value.first),
            ),
            IconButton(
              tooltip: 'Move up',
              onPressed: canMoveUp ? onMoveUp : null,
              icon: const Icon(Icons.arrow_upward),
            ),
            IconButton(
              tooltip: 'Move down',
              onPressed: canMoveDown ? onMoveDown : null,
              icon: const Icon(Icons.arrow_downward),
            ),
            IconButton(
              tooltip: 'Remove rule',
              onPressed: canRemove ? onRemove : null,
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
      ],
    );
  }
}

List<LibrarySortRule> _dedupeRules(List<LibrarySortRule> rules) {
  final seen = <LibrarySortColumn>{};
  final deduped = <LibrarySortRule>[];
  for (final rule in rules) {
    if (seen.add(rule.column)) {
      deduped.add(rule);
    }
  }
  return deduped;
}

String _sortColumnLabel(LibrarySortColumn column) {
  return switch (column) {
    LibrarySortColumn.status => 'Status',
    LibrarySortColumn.title => 'Title',
    LibrarySortColumn.issue => 'Issue / number',
    LibrarySortColumn.variant => 'Variant',
    LibrarySortColumn.publisher => 'Publisher',
    LibrarySortColumn.releaseDate => 'Release date',
    LibrarySortColumn.barcode => 'Barcode',
    LibrarySortColumn.grade => 'Grade',
    LibrarySortColumn.condition => 'Condition',
    LibrarySortColumn.price => 'Price',
    LibrarySortColumn.storageBox => 'Storage box',
    LibrarySortColumn.wishlist => 'Wishlist',
    LibrarySortColumn.updated => 'Updated',
    LibrarySortColumn.country => 'Country',
    LibrarySortColumn.language => 'Language',
    LibrarySortColumn.pageCount => 'Page count',
    LibrarySortColumn.ageRating => 'Age rating',
    LibrarySortColumn.imprint => 'Imprint',
  };
}