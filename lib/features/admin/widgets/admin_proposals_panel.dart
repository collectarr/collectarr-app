import 'package:collectarr_app/ui/compact_search_dropdown_form_field.dart';
import 'package:flutter/material.dart';

final class AdminProposalsPanel extends StatelessWidget {
  const AdminProposalsPanel({
    required this.statusFilter,
    required this.isLoading,
    required this.statusMessage,
    required this.errorMessage,
    required this.onStatusChanged,
    required this.content,
    super.key,
  });

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
