part of 'admin_page.dart';

class _DuplicateMergeSelection {
  const _DuplicateMergeSelection({
    required this.targetItemId,
    required this.sourceItemIds,
  });

  final String targetItemId;
  final List<String> sourceItemIds;
}

class _DuplicateMergeReviewDialog extends StatefulWidget {
  const _DuplicateMergeReviewDialog({required this.candidate});

  final AdminDuplicateCandidate candidate;

  @override
  State<_DuplicateMergeReviewDialog> createState() =>
      _DuplicateMergeReviewDialogState();
}

class _DuplicateMergeReviewDialogState
    extends State<_DuplicateMergeReviewDialog> {
  late String _targetItemId;
  late Set<String> _sourceItemIds;
  late final TextEditingController _confirmController;
  bool _typedConfirmationMatches = false;

  @override
  void initState() {
    super.initState();
    _targetItemId =
        widget.candidate.preferredTargetItemId ?? widget.candidate.itemIds.first;
    _sourceItemIds = widget.candidate.itemIds
        .where((itemId) => itemId != _targetItemId)
        .toSet();
    _confirmController = TextEditingController()
      ..addListener(() {
        final matches = _confirmController.text.trim() == 'MERGE';
        if (matches != _typedConfirmationMatches) {
          setState(() {
            _typedConfirmationMatches = matches;
          });
        }
      });
  }

  @override
  void dispose() {
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final candidate = widget.candidate;
    return AlertDialog(
      title: Text('Merge review: ${candidate.displayTitle}'),
      content: SizedBox(
        width: 560,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _MiniChip(label: candidate.reason),
                  _MiniChip(label: '${candidate.duplicateScore}% match'),
                  if (candidate.hasProviderConflicts)
                    const _MiniChip(label: 'provider conflict'),
                  if (candidate.hasCoverConflicts)
                    const _MiniChip(label: 'cover conflict'),
                  if (candidate.preferredTargetItemId != null)
                    _MiniChip(
                      label:
                          'target ${_shortId(candidate.preferredTargetItemId!)}',
                    ),
                ],
              ),
              const SizedBox(height: 12),
              const _DestructiveWarning(
                icon: Icons.warning_amber_outlined,
                message:
                    'This moves provider links, editions, variants, relationships, and admin history onto the selected target. Source catalog records are removed after merge.',
              ),
              const SizedBox(height: 12),
              for (final itemId in candidate.itemIds)
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _sourceItemIds.contains(itemId),
                  enabled: itemId != _targetItemId,
                  title: Text('Source ${_shortId(itemId)}'),
                  subtitle: itemId == _targetItemId
                      ? Text(
                          itemId == candidate.preferredTargetItemId
                              ? 'Recommended merge target'
                              : 'Merge target',
                        )
                      : itemId == candidate.preferredTargetItemId
                          ? const Text('Recommended target')
                          : null,
                  secondary: IconButton(
                    tooltip: 'Set merge target',
                    onPressed: () {
                      setState(() {
                        _targetItemId = itemId;
                        _sourceItemIds = candidate.itemIds
                            .where((id) => id != itemId)
                            .toSet();
                      });
                    },
                    icon: Icon(
                      itemId == _targetItemId
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                    ),
                  ),
                  onChanged: itemId == _targetItemId
                      ? null
                      : (value) {
                          setState(() {
                            if (value == true) {
                              _sourceItemIds.add(itemId);
                            } else {
                              _sourceItemIds.remove(itemId);
                            }
                          });
                        },
                ),
              const SizedBox(height: 8),
              TextField(
                controller: _confirmController,
                decoration: const InputDecoration(
                  labelText: 'Type MERGE to confirm',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: _sourceItemIds.isEmpty || !_typedConfirmationMatches
              ? null
              : () => Navigator.of(context).pop(
                    _DuplicateMergeSelection(
                      targetItemId: _targetItemId,
                      sourceItemIds: _sourceItemIds.toList(growable: false),
                    ),
                  ),
          icon: const Icon(Icons.merge_type_outlined),
          label: const Text('Merge selected'),
        ),
      ],
    );
  }
}