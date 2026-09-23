part of 'admin_page.dart';

// Metadata proposals, add dialog, shared widgets, utility functions

class _ProposalPayloadPreview extends StatelessWidget {
  const _ProposalPayloadPreview({
    required this.kind,
    required this.payload,
  });

  final CatalogMediaKind kind;
  final Map<String, Object?> payload;

  @override
  Widget build(BuildContext context) {
    final fields = libraryAdminContributorForKind(kind)?.proposalFields ??
        const <LibraryAdminProposalField>[];
    final values = LibraryMetadataCorrectionValues.fromSerialized(payload);
    final badges = <String>[
      for (final field in fields)
        if (field.read(values).trim().isNotEmpty)
          '${field.label}: ${field.read(values).trim()}',
    ];
    if (badges.isEmpty) {
      return const SizedBox.shrink();
    }
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final badge in badges) _MiniChip(label: badge),
      ],
    );
  }
}

class _ReleaseMappingRuleFormResult {
  const _ReleaseMappingRuleFormResult({
    required this.provider,
    required this.releaseType,
    required this.targetKind,
    required this.priority,
    required this.isActive,
    this.notes,
  });

  final String? provider;
  final String releaseType;
  final String targetKind;
  final int priority;
  final bool isActive;
  final String? notes;
}

class _ReleaseMappingRuleDialog extends StatefulWidget {
  const _ReleaseMappingRuleDialog({
    required this.providers,
    required this.kinds,
    required this.kindLabels,
    this.initialProvider,
    this.initialReleaseType,
    this.initialTargetKind,
    this.initialPriority = 100,
    this.initialIsActive = true,
    this.initialNotes,
  });

  final List<String> providers;
  final List<String> kinds;
  final Map<String, String> kindLabels;
  final String? initialProvider;
  final String? initialReleaseType;
  final String? initialTargetKind;
  final int initialPriority;
  final bool initialIsActive;
  final String? initialNotes;

  @override
  State<_ReleaseMappingRuleDialog> createState() =>
      _ReleaseMappingRuleDialogState();
}

class _ReleaseMappingRuleDialogState extends State<_ReleaseMappingRuleDialog> {
  late final TextEditingController _releaseTypeController;
  late final TextEditingController _priorityController;
  late final TextEditingController _notesController;
  String? _provider;
  String? _targetKind;
  late bool _isActive;
  String? _error;

  @override
  void initState() {
    super.initState();
    _releaseTypeController = TextEditingController(
      text: widget.initialReleaseType ?? '',
    );
    _priorityController = TextEditingController(
      text: widget.initialPriority.toString(),
    );
    _notesController = TextEditingController(
      text: widget.initialNotes ?? '',
    );
    _provider = widget.initialProvider;
    _targetKind = widget.initialTargetKind ??
        (widget.kinds.contains('comic')
            ? 'comic'
            : (widget.kinds.isNotEmpty ? widget.kinds.first : null));
    _isActive = widget.initialIsActive;
  }

  @override
  void dispose() {
    _releaseTypeController.dispose();
    _priorityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AccentAlertDialog(
      shape: adminDialogShape,
      title: const Text('Release mapping rule'),
      content: SizedBox(
        width: 480,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CompactSearchDropdownFormField<String?>(
              initialValue: _provider,
              decoration: const InputDecoration(
                labelText: 'Provider scope',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('All providers'),
                ),
                for (final provider in widget.providers)
                  DropdownMenuItem<String?>(
                    value: provider,
                    child: Text(provider),
                  ),
              ],
              onChanged: (value) {
                setState(() {
                  _provider = value;
                });
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _releaseTypeController,
              decoration: const InputDecoration(
                labelText: 'Release type',
                hintText: 'issue, variant, season, episode...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            CompactSearchDropdownFormField<String>(
              initialValue: _targetKind,
              decoration: const InputDecoration(
                labelText: 'Target media kind',
                border: OutlineInputBorder(),
              ),
              items: [
                for (final kind in widget.kinds)
                  DropdownMenuItem<String>(
                    value: kind,
                    child: Text(widget.kindLabels[kind] ?? kind),
                  ),
              ],
              onChanged: (value) {
                setState(() {
                  _targetKind = value;
                });
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _priorityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Priority (lower wins)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              minLines: 2,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _isActive,
              onChanged: (value) {
                setState(() {
                  _isActive = value ?? true;
                });
              },
              title: const Text('Rule is active'),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: AdminMessageRow(message: _error!, isError: true),
              ),
          ],
        ),
      ),
      actions: [
        DialogActionButtons.cancel(
          onPressed: () => Navigator.of(context).pop(),
        ),
        DialogActionButtons.save(
          onPressed: _submit,
        ),
      ],
    );
  }

  void _submit() {
    final releaseType = _releaseTypeController.text.trim().toLowerCase();
    if (releaseType.isEmpty) {
      setState(() {
        _error = 'Release type is required.';
      });
      return;
    }
    final targetKind = _targetKind?.trim();
    if (targetKind == null || targetKind.isEmpty) {
      setState(() {
        _error = 'Select a target media kind.';
      });
      return;
    }
    final parsedPriority = int.tryParse(_priorityController.text.trim());
    if (parsedPriority == null || parsedPriority < 0) {
      setState(() {
        _error = 'Priority must be a positive number.';
      });
      return;
    }
    Navigator.of(context).pop(
      _ReleaseMappingRuleFormResult(
        provider:
            _provider?.trim().isNotEmpty == true ? _provider!.trim() : null,
        releaseType: releaseType,
        targetKind: targetKind,
        priority: parsedPriority,
        isActive: _isActive,
        notes: _notesController.text.trim(),
      ),
    );
  }
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

String _proposalKindLabel(String kind) {
  final mediaKind = catalogMediaKindFromApiValue(kind);
  return adminKindLabelForType(mediaKind, plural: false) ??
      adminFallbackKindLabel(kind);
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

String? _emptyToNull(String value) {
  final text = value.trim();
  return text.isEmpty ? null : text;
}
