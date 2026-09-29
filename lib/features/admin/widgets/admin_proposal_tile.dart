import 'package:collectarr_app/core/api/dto/admin_metadata.dart';
import 'package:flutter/material.dart';

final class AdminProposalTile extends StatelessWidget {
  const AdminProposalTile({
    required this.proposal,
    required this.isActing,
    required this.kindLabel,
    required this.onEdit,
    required this.onApprove,
    required this.onReject,
    this.payloadPreview,
    super.key,
  });

  final AdminMetadataProposal proposal;
  final bool isActing;
  final String kindLabel;
  final Widget? payloadPreview;
  final VoidCallback onEdit;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final description =
        proposal.catalogItem['description'] ?? proposal.catalogItem['synopsis'];
    final summary = description is String ? description.trim() : '';
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(proposal.displayTitle,
                    style: Theme.of(context).textTheme.titleSmall),
                const _MiniChip(label: 'User proposal'),
                _MiniChip(label: proposal.status),
                _MiniChip(label: kindLabel),
              ],
            ),
            if (summary.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(summary, maxLines: 3, overflow: TextOverflow.ellipsis),
            ],
            if (payloadPreview != null) ...[
              const SizedBox(height: 8),
              payloadPreview!,
            ],
            if (proposal.isPending) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: isActing ? null : onEdit,
                    icon: const Icon(Icons.edit_note_outlined),
                    label: const Text('Edit metadata'),
                  ),
                  FilledButton.icon(
                    onPressed: isActing ? null : onApprove,
                    icon: isActing
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.task_alt_outlined),
                    label: const Text('Approve'),
                  ),
                  OutlinedButton.icon(
                    onPressed: isActing ? null : onReject,
                    icon: const Icon(Icons.block_outlined),
                    label: const Text('Reject'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

final class _MiniChip extends StatelessWidget {
  const _MiniChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(label, style: Theme.of(context).textTheme.labelSmall),
      ),
    );
  }
}
