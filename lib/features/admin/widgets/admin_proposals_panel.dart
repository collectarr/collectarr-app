import 'package:collectarr_app/core/api/dto/admin_metadata.dart';
import 'package:collectarr_app/ui/compact_search_dropdown_form_field.dart';
import 'package:flutter/material.dart';

final class AdminProposalsPanel extends StatelessWidget {
  const AdminProposalsPanel({
    required this.summary,
    required this.statusFilter,
    required this.providerFilter,
    required this.providers,
    required this.isLoading,
    required this.activeProposalTitle,
    required this.statusMessage,
    required this.errorMessage,
    required this.onStatusChanged,
    required this.onProviderChanged,
    required this.onClearReview,
    required this.content,
    super.key,
  });

  final AdminMetadataProposalSummary? summary;
  final String statusFilter;
  final String? providerFilter;
  final List<AdminProviderStatus> providers;
  final bool isLoading;
  final String? activeProposalTitle;
  final String? statusMessage;
  final String? errorMessage;
  final ValueChanged<String?> onStatusChanged;
  final ValueChanged<String?> onProviderChanged;
  final VoidCallback onClearReview;
  final Widget content;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final providerOptions = [
      const DropdownMenuItem<String>(value: '', child: Text('All providers')),
      for (final provider in providers)
        DropdownMenuItem<String>(
          value: provider.name,
          child: Text(provider.displayName),
        ),
    ];
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
            final provider = CompactSearchDropdownFormField<String>(
              initialValue: providerFilter ?? '',
              decoration: const InputDecoration(
                labelText: 'Provider',
                border: OutlineInputBorder(),
              ),
              items: providerOptions,
              onChanged: onProviderChanged,
            );
            if (constraints.maxWidth < 760) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  status,
                  const SizedBox(height: 12),
                  provider,
                ],
              );
            }
            return Row(
              children: [
                Expanded(child: status),
                const SizedBox(width: 12),
                Expanded(child: provider),
              ],
            );
          },
        ),
        if (activeProposalTitle != null) ...[
          const SizedBox(height: 12),
          DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Icon(Icons.travel_explore_outlined),
                  Text('Reviewing proposal: $activeProposalTitle'),
                  OutlinedButton.icon(
                    onPressed: onClearReview,
                    icon: const Icon(Icons.close_outlined),
                    label: const Text('Clear review'),
                  ),
                ],
              ),
            ),
          ),
        ],
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
