part of 'admin_page.dart';

// Metadata proposals, add dialog, shared widgets, utility functions

class _MetadataProposalPanel extends StatelessWidget {
  const _MetadataProposalPanel({
    required this.summary,
    required this.proposals,
    required this.statusFilter,
    required this.providerFilter,
    required this.providers,
    required this.isLoading,
    required this.actingProposalId,
    required this.activeProposalTitle,
    required this.statusMessage,
    required this.errorMessage,
    required this.onStatusChanged,
    required this.onProviderChanged,
    required this.onReview,
    required this.onApprove,
    required this.onApproveLinked,
    required this.onReject,
    required this.onClearReview,
    required this.canApproveLinkedItem,
  });

  final AdminMetadataProposalSummary? summary;
  final List<AdminMetadataProposal> proposals;
  final String statusFilter;
  final String? providerFilter;
  final List<AdminProviderStatus> providers;
  final bool isLoading;
  final String? actingProposalId;
  final String? activeProposalTitle;
  final String? statusMessage;
  final String? errorMessage;
  final ValueChanged<String?> onStatusChanged;
  final ValueChanged<String?> onProviderChanged;
  final ValueChanged<AdminMetadataProposal> onReview;
  final ValueChanged<AdminMetadataProposal> onApprove;
  final ValueChanged<AdminMetadataProposal> onApproveLinked;
  final ValueChanged<AdminMetadataProposal> onReject;
  final VoidCallback onClearReview;
  final bool Function(String provider) canApproveLinkedItem;

  @override
  Widget build(BuildContext context) {
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
            _StatusChip(
              icon: Icons.pending_actions_outlined,
              label: '${summary?.pending ?? 0} pending',
            ),
            _StatusChip(
              icon: Icons.task_alt_outlined,
              label: '${summary?.approved ?? 0} approved',
            ),
            _StatusChip(
              icon: Icons.block_outlined,
              label: '${summary?.rejected ?? 0} rejected',
            ),
          ],
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 760;
            final statusField = DropdownButtonFormField<String>(
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
            final providerField = DropdownButtonFormField<String>(
              initialValue: providerFilter ?? '',
              decoration: const InputDecoration(
                labelText: 'Provider',
                border: OutlineInputBorder(),
              ),
              items: providerOptions,
              onChanged: onProviderChanged,
            );
            if (isNarrow) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  statusField,
                  const SizedBox(height: 12),
                  providerField,
                ],
              );
            }
            return Row(
              children: [
                Expanded(child: statusField),
                const SizedBox(width: 12),
                Expanded(child: providerField),
              ],
            );
          },
        ),
        if (activeProposalTitle != null) ...[
          const SizedBox(height: 12),
          DecoratedBox(
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest
                  .withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
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
          _MessageRow(
            message: errorMessage ?? statusMessage!,
            isError: errorMessage != null,
          ),
        ],
        const SizedBox(height: 12),
        if (isLoading)
          const Center(child: CircularProgressIndicator())
        else if (proposals.isEmpty)
          _MessageRow(
            message: 'No ${statusFilter.toLowerCase()} proposals found.',
            isError: false,
          )
        else
          Column(
            children: [
              for (final proposal in proposals)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _MetadataProposalTile(
                    proposal: proposal,
                    isActing: actingProposalId == proposal.id,
                    canApproveLinkedItem: canApproveLinkedItem(proposal.provider),
                    onReview: () => onReview(proposal),
                    onApprove: () => onApprove(proposal),
                    onApproveLinked: () => onApproveLinked(proposal),
                    onReject: () => onReject(proposal),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

class _MetadataProposalTile extends StatelessWidget {
  const _MetadataProposalTile({
    required this.proposal,
    required this.isActing,
    required this.canApproveLinkedItem,
    required this.onReview,
    required this.onApprove,
    required this.onApproveLinked,
    required this.onReject,
  });

  final AdminMetadataProposal proposal;
  final bool isActing;
  final bool canApproveLinkedItem;
  final VoidCallback onReview;
  final VoidCallback onApprove;
  final VoidCallback onApproveLinked;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
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
                Text(
                  proposal.displayTitle,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                _MiniChip(label: proposal.provider),
                _MiniChip(label: proposal.status),
                if (proposal.providerItemId != null &&
                    proposal.providerItemId!.isNotEmpty)
                  _MiniChip(label: 'ID ${proposal.providerItemId}'),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              proposal.query,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            if (proposal.summary != null && proposal.summary!.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                proposal.summary!,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
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
                  if ((proposal.providerItemId?.isNotEmpty ?? false) &&
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

enum _ProviderAddMode { search, direct }

class _ProviderAddRequest {
  const _ProviderAddRequest({
    required this.mode,
    required this.kind,
    required this.provider,
    this.query,
    this.providerItemId,
  });

  final _ProviderAddMode mode;
  final String? kind;
  final String provider;
  final String? query;
  final String? providerItemId;
}

class _ProviderAddDialog extends StatefulWidget {
  const _ProviderAddDialog({
    required this.providers,
    required this.kinds,
    required this.kindLabels,
    this.initialKind,
    this.initialProvider,
    this.initialQuery,
    this.initialProviderItemId,
  });

  final List<AdminProviderStatus> providers;
  final List<String> kinds;
  final Map<String, String> kindLabels;
  final String? initialKind;
  final String? initialProvider;
  final String? initialQuery;
  final String? initialProviderItemId;

  @override
  State<_ProviderAddDialog> createState() => _ProviderAddDialogState();
}

class _ProviderAddDialogState extends State<_ProviderAddDialog> {
  late _ProviderAddMode _mode;
  late String? _selectedKind;
  late String _selectedProvider;
  late final TextEditingController _queryController;
  late final TextEditingController _providerItemIdController;
  String? _error;

  @override
  void initState() {
    super.initState();
    _mode = _ProviderAddMode.search;
    _selectedKind = widget.initialKind;
    _selectedProvider = widget.initialProvider ?? '';
    _queryController = TextEditingController(text: widget.initialQuery ?? '');
    _providerItemIdController = TextEditingController(
      text: widget.initialProviderItemId ?? '',
    );
    _syncSelectedProvider();
  }

  @override
  void dispose() {
    _queryController.dispose();
    _providerItemIdController.dispose();
    super.dispose();
  }

  List<AdminProviderStatus> get _availableProviders {
    return [
      for (final provider in widget.providers)
        if ((_mode == _ProviderAddMode.search
                ? provider.supportsSearch
                : provider.supportsIngest) &&
            (_selectedKind == null || provider.effectiveKinds.contains(_selectedKind)))
          provider,
    ];
  }

  void _syncSelectedProvider() {
    final providers = _availableProviders;
    if (providers.any((provider) => provider.name == _selectedProvider)) {
      return;
    }
    _selectedProvider = providers.isEmpty ? '' : providers.first.name;
  }

  @override
  Widget build(BuildContext context) {
    final actionLabel = _mode == _ProviderAddMode.search
        ? 'Search provider'
        : 'Add to catalog';
    return AlertDialog(
      shape: _kAdminDialogShape,
      title: const Text('Add metadata from provider'),
      content: SizedBox(
        width: 680,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_error != null) ...[
                _MessageRow(message: _error!, isError: true),
                const SizedBox(height: 12),
              ],
              SegmentedButton<_ProviderAddMode>(
                segments: const [
                  ButtonSegment<_ProviderAddMode>(
                    value: _ProviderAddMode.search,
                    icon: Icon(Icons.manage_search_outlined),
                    label: Text('Search first'),
                  ),
                  ButtonSegment<_ProviderAddMode>(
                    value: _ProviderAddMode.direct,
                    icon: Icon(Icons.download_for_offline_outlined),
                    label: Text('Known ID'),
                  ),
                ],
                selected: {_mode},
                onSelectionChanged: (selection) {
                  setState(() {
                    _mode = selection.first;
                    _error = null;
                    _syncSelectedProvider();
                  });
                },
              ),
              const SizedBox(height: 16),
              _ProviderKindSelector(
                value: _selectedKind,
                kinds: widget.kinds,
                kindLabels: widget.kindLabels,
                isLoading: false,
                onChanged: (value) {
                  setState(() {
                    _selectedKind = value == null || value.isEmpty ? null : value;
                    _error = null;
                    _syncSelectedProvider();
                  });
                },
              ),
              const SizedBox(height: 12),
              _ProviderSelector(
                value: _selectedProvider,
                providers: _availableProviders,
                isLoading: false,
                onChanged: (value) {
                  setState(() {
                    _selectedProvider = value?.trim() ?? '';
                    _error = null;
                  });
                },
              ),
              const SizedBox(height: 12),
              Text(
                _mode == _ProviderAddMode.search
                    ? 'Search for candidates inside the selected category before creating anything in the canonical catalog.'
                    : 'Use a known provider item ID when you already know the exact external record you want to ingest.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              if (_mode == _ProviderAddMode.search)
                TextField(
                  controller: _queryController,
                  decoration: const InputDecoration(
                    labelText: 'Provider query',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _submit(),
                )
              else
                TextField(
                  controller: _providerItemIdController,
                  decoration: const InputDecoration(
                    labelText: 'Provider item ID',
                    prefixIcon: Icon(Icons.tag_outlined),
                    border: OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
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
          onPressed: _submit,
          icon: Icon(
            _mode == _ProviderAddMode.search
                ? Icons.manage_search_outlined
                : Icons.download_for_offline_outlined,
          ),
          label: Text(actionLabel),
        ),
      ],
    );
  }

  void _submit() {
    final kind = _selectedKind?.trim();
    if (kind == null || kind.isEmpty) {
      setState(() {
        _error = 'Choose a media category first.';
      });
      return;
    }
    if (_selectedProvider.trim().isEmpty) {
      setState(() {
        _error = 'Choose a provider.';
      });
      return;
    }
    if (_mode == _ProviderAddMode.search) {
      final query = _queryController.text.trim();
      if (query.isEmpty) {
        setState(() {
          _error = 'Enter a provider query.';
        });
        return;
      }
      Navigator.of(context).pop(
        _ProviderAddRequest(
          mode: _mode,
          kind: kind,
          provider: _selectedProvider,
          query: query,
        ),
      );
      return;
    }
    final providerItemId = _providerItemIdController.text.trim();
    if (providerItemId.isEmpty) {
      setState(() {
        _error = 'Enter a provider item ID.';
      });
      return;
    }
    Navigator.of(context).pop(
      _ProviderAddRequest(
        mode: _mode,
        kind: kind,
        provider: _selectedProvider,
        providerItemId: providerItemId,
      ),
    );
  }
}

class _CatalogCorrection {
  const _CatalogCorrection({
    this.title,
    this.itemNumber,
    this.synopsis,
    this.editionTitle,
    this.pageCount,
    this.runtimeMinutes,
    this.publisher,
    this.releaseDate,
    this.imprint,
    this.subtitle,
    this.seriesGroup,
    this.country,
    this.language,
    this.ageRating,
    this.catalogNumber,
    this.releaseStatus,
    this.physicalFormat,
    this.variantName,
    this.barcode,
    this.coverImageUrl,
    this.thumbnailImageUrl,
    this.seriesTags,
  });

  final String? title;
  final String? itemNumber;
  final String? synopsis;
  final String? editionTitle;
  final int? pageCount;
  final int? runtimeMinutes;
  final String? publisher;
  final DateTime? releaseDate;
  final String? imprint;
  final String? subtitle;
  final String? seriesGroup;
  final String? country;
  final String? language;
  final String? ageRating;
  final String? catalogNumber;
  final String? releaseStatus;
  final String? physicalFormat;
  final String? variantName;
  final String? barcode;
  final String? coverImageUrl;
  final String? thumbnailImageUrl;
  final List<String>? seriesTags;
}

class _CorrectionPreviewEntry {
  const _CorrectionPreviewEntry({
    required this.label,
    required this.before,
    required this.after,
  });

  final String label;
  final String before;
  final String after;
}


class _Fact extends StatelessWidget {
  const _Fact({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall,
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageRow extends StatelessWidget {
  const _MessageRow({required this.message, required this.isError});

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(
          isError ? Icons.error_outline : Icons.info_outline,
          color: isError ? colorScheme.error : colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(message)),
      ],
    );
  }
}

class _DestructiveWarning extends StatelessWidget {
  const _DestructiveWarning({
    required this.icon,
    required this.message,
  });

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withValues(alpha: 0.34),
        border: Border.all(color: colorScheme.error.withValues(alpha: 0.42)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: colorScheme.error, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }
}

class _CorrectionPreviewRow extends StatelessWidget {
  const _CorrectionPreviewRow({required this.change});

  final _CorrectionPreviewEntry change;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                change.label,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 6),
              Text('Before: ${change.before}'),
              Text('After: ${change.after}'),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _MiniChip extends StatelessWidget {
  const _MiniChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

String _adminErrorMessage(Object error) {
  if (error is DioException) {
    final statusCode = error.response?.statusCode;
    if (statusCode == 401 || statusCode == 403) {
      return 'Admin access was rejected.';
    }
    if (statusCode == 422) {
      return 'Provider request was invalid.';
    }
    if (statusCode != null && statusCode >= 500) {
      return 'Metadata server could not complete the admin request.';
    }
    final message = error.message?.trim();
    if (message != null && message.isNotEmpty) {
      return message;
    }
  }
  return error.toString();
}

String _proposalAuditActionLabel(String action) {
  return switch (action) {
    'metadata_proposal.approve' => 'Approved proposal',
    'metadata_proposal.approve_provider' => 'Approved via provider',
    'metadata_proposal.reject' => 'Rejected proposal',
    _ => action,
  };
}

String _shortId(String id) {
  if (id.length <= 8) {
    return id;
  }
  return id.substring(0, 8);
}

String _providerKindLabel(String kind, Map<String, String> labels) {
  final label = labels[kind];
  if (label != null && label.isNotEmpty) {
    return label;
  }
  return switch (kind) {
    'boardgame' => 'Board game',
    'tv' => 'TV',
    _ => kind.isEmpty ? kind : '${kind[0].toUpperCase()}${kind.substring(1)}',
  };
}

String _mediaTypeDisplayLabel(CatalogMediaType type) {
  if (type.kind == 'tv') {
    return 'TV';
  }
  return type.pluralLabel.isNotEmpty ? type.pluralLabel : type.kind;
}

int _compareMediaKinds(String left, String right, Map<String, String> labels) {
  return _providerKindLabel(left, labels).compareTo(
    _providerKindLabel(right, labels),
  );
}

String _preferredProvider(
  List<AdminProviderStatus> providers, {
  required String current,
}) {
  if (current.isNotEmpty &&
      providers.any((provider) => provider.name == current)) {
    return current;
  }
  AdminProviderStatus? best;
  for (final provider in providers) {
    if (provider.isConfigured &&
        provider.supportsSearch &&
        provider.supportsIngest) {
      best = provider;
      break;
    }
  }
  best ??= _firstWhereOrNull(providers, (provider) => provider.isConfigured);
  best ??= _firstWhereOrNull(providers, (provider) => provider.supportsIngest);
  best ??= _firstWhereOrNull(providers, (provider) => provider.supportsSearch);
  best ??= providers.isEmpty ? null : providers.first;
  return best?.name ?? '';
}

T? _firstWhereOrNull<T>(Iterable<T> items, bool Function(T) test) {
  for (final item in items) {
    if (test(item)) {
      return item;
    }
  }
  return null;
}

String _formatDate(DateTime value) {
  return '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}

String _formatDateTime(DateTime value) {
  final local = value.toLocal();
  return '${_formatDate(local)} '
      '${local.hour.toString().padLeft(2, '0')}:'
      '${local.minute.toString().padLeft(2, '0')}';
}

int _ingestJobAttemptsRemaining(AdminProviderIngestJob job) {
  final remaining = job.maxAttempts - job.attempts;
  return remaining < 0 ? 0 : remaining;
}

String _ingestJobStateDescription(AdminProviderIngestJob job) {
  return job.status.replaceAll('_', ' ');
}

String _formatMoney(int cents, String? currency) {
  final amount = (cents / 100).toStringAsFixed(2);
  return currency == null || currency.isEmpty ? amount : '$amount $currency';
}

String? _emptyToNull(String value) {
  final text = value.trim();
  return text.isEmpty ? null : text;
}
