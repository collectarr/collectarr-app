import 'package:collectarr_app/core/api/dto/admin_metadata.dart';
import 'package:flutter/material.dart';

final class AdminProposalTile extends StatelessWidget {
  const AdminProposalTile({
    required this.proposal,
    required this.isActing,
    required this.canApproveLinkedItem,
    required this.kindLabel,
    required this.onReview,
    required this.onEdit,
    required this.onApprove,
    required this.onApproveLinked,
    required this.onReject,
    this.payloadPreview,
    super.key,
  });

  final AdminMetadataProposal proposal;
  final bool isActing;
  final bool canApproveLinkedItem;
  final String kindLabel;
  final Widget? payloadPreview;
  final VoidCallback onReview;
  final VoidCallback onEdit;
  final VoidCallback onApprove;
  final VoidCallback onApproveLinked;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
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
                _MiniChip(label: proposal.provider),
                _MiniChip(label: proposal.status),
                _MiniChip(label: kindLabel),
                if (proposal.providerItemId?.isNotEmpty == true)
                  _MiniChip(label: 'ID ${proposal.providerItemId}'),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              proposal.query,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: colors.onSurfaceVariant),
            ),
            if (proposal.summary?.trim().isNotEmpty == true) ...[
              const SizedBox(height: 8),
              Text(proposal.summary!,
                  maxLines: 3, overflow: TextOverflow.ellipsis),
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
                    onPressed: isActing ? null : onReview,
                    icon: const Icon(Icons.travel_explore_outlined),
                    label: const Text('Review in search'),
                  ),
                  OutlinedButton.icon(
                    onPressed: isActing ? null : onEdit,
                    icon: const Icon(Icons.edit_note_outlined),
                    label: const Text('Edit metadata'),
                  ),
                  if (proposal.providerItemId?.isNotEmpty == true &&
                      canApproveLinkedItem)
                    FilledButton.tonalIcon(
                      onPressed: isActing ? null : onApproveLinked,
                      icon: isActing
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.link_outlined),
                      label: const Text('Approve linked ID'),
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
