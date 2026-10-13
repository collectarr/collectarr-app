import 'package:collectarr_app/core/api/dto/admin_metadata.dart';
import 'package:collectarr_app/ui/compact_search_dropdown_form_field.dart';
import 'package:flutter/material.dart';

final class AdminProposalsPanel extends StatelessWidget {
  const AdminProposalsPanel({
    required this.summary,
    required this.statusFilter,
    required this.isLoading,
    required this.statusMessage,
    required this.errorMessage,
    required this.onStatusChanged,
    required this.content,
    super.key,
  });

  final AdminMetadataProposalSummary? summary;
  final String statusFilter;
  final bool isLoading;
  final String? statusMessage;
  final String? errorMessage;
  final ValueChanged<String?> onStatusChanged;
  final Widget content;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _SummaryChip(label: '${summary?.pending ?? 0} pending'),
            _SummaryChip(label: '${summary?.approved ?? 0} approved'),
            _SummaryChip(label: '${summary?.rejected ?? 0} rejected'),
            _SummaryChip(label: '${summary?.total ?? 0} total'),
          ],
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final status = CompactSearchDropdownFormField<String>(
              initialValue: statusFilter,
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'pending', child: Text('Pending')),
                DropdownMenuItem(value: 'approved', child: Text('Approved')),
                DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
              ],
              onChanged: onStatusChanged,
            );
            return SizedBox(width: constraints.maxWidth, child: status);
          },
        ),
        if (statusMessage != null || errorMessage != null) ...[
          const SizedBox(height: 12),
          Text(
            errorMessage ?? statusMessage!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: errorMessage == null
                  ? theme.colorScheme.onSurfaceVariant
                  : theme.colorScheme.error,
            ),
          ),
        ],
        const SizedBox(height: 12),
        if (isLoading)
          const Center(child: CircularProgressIndicator())
        else
          content,
      ],
    );
  }
}

final class _SummaryChip extends StatelessWidget {
  const _SummaryChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(label, style: Theme.of(context).textTheme.labelMedium),
      ),
    );
  }
}
