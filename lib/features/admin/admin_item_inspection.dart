part of 'admin_page.dart';

enum _CanonicalInspectAction { edit, covers }

class _CanonicalInspectResult {
  const _CanonicalInspectResult._({this.action, this.bundleReleaseId});

  const _CanonicalInspectResult.action(_CanonicalInspectAction action)
      : this._(action: action);

  const _CanonicalInspectResult.bundle(String bundleReleaseId)
      : this._(bundleReleaseId: bundleReleaseId);

  final _CanonicalInspectAction? action;
  final String? bundleReleaseId;
}

class _CanonicalItemInspectionDialog extends StatelessWidget {
  const _CanonicalItemInspectionDialog({
    required this.item,
    required this.auditLogs,
    required this.bundleReleases,
    required this.metadataFields,
  });

  final AdminMetadataItem item;
  final List<AdminAuditLogEntry> auditLogs;
  final List<BundleReleaseSummary> bundleReleases;
  final List<LibraryAdminCorrectionField> metadataFields;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dialogWidth =
        (MediaQuery.sizeOf(context).width - 96).clamp(280.0, 820.0).toDouble();
    return AccentAlertDialog(
      title: Row(
        children: [
          Icon(Icons.fact_check_outlined, color: colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Inspect: ${item.displayTitle}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: dialogWidth,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              _CanonicalItemSummary(
                item: item,
                auditLogs: auditLogs,
                bundleReleases: bundleReleases,
                metadataFields: metadataFields,
              ),
              if (auditLogs.isEmpty) ...[
                const SizedBox(height: 12),
                const AdminMessageRow(
                  message: 'No item audit history yet.',
                  isError: false,
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        OutlinedButton.icon(
          onPressed: () => Navigator.of(context).pop(
            const _CanonicalInspectResult.action(
              _CanonicalInspectAction.covers,
            ),
          ),
          icon: const Icon(Icons.image_search_outlined),
          label: const Text('Covers'),
        ),
        FilledButton.icon(
          onPressed: () => Navigator.of(context).pop(
            const _CanonicalInspectResult.action(
              _CanonicalInspectAction.edit,
            ),
          ),
          icon: const Icon(Icons.edit_outlined),
          label: const Text('Edit metadata'),
        ),
      ],
    );
  }
}

class _CanonicalItemSummary extends StatelessWidget {
  const _CanonicalItemSummary({
    required this.item,
    this.auditLogs = const [],
    this.bundleReleases = const [],
    this.metadataFields = const [],
  });

  final AdminMetadataItem item;
  final List<AdminAuditLogEntry> auditLogs;
  final List<BundleReleaseSummary> bundleReleases;
  final List<LibraryAdminCorrectionField> metadataFields;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 620;
            final cover = SizedBox(
              width: 84,
              height: 118,
              child: LibraryCoverImage(
                title: item.title,
                itemNumber: item.itemNumber,
                imageUrl: item.displayCoverUrl,
              ),
            );
            final details = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.fact_check_outlined, color: colorScheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.displayTitle,
                        style: Theme.of(context).textTheme.titleSmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _MiniChip(label: item.kind),
                    if (item.displayPhysicalFormat case final format?)
                      _MiniChip(label: format),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final field in metadataFields.take(10))
                      if (field
                          .displayValue(field.read(item))
                          .trim()
                          .isNotEmpty)
                        _Fact(
                          label: field.presentation.label,
                          value: field.displayValue(field.read(item)),
                        ),
                  ],
                ),
                if (bundleReleases.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _BundleReleaseSummaryList(bundleReleases: bundleReleases),
                ],
                if (auditLogs.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _ItemAuditTimeline(logs: auditLogs),
                ],
              ],
            );
            if (isNarrow) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [cover, const SizedBox(height: 12), details],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                cover,
                const SizedBox(width: 12),
                Expanded(child: details)
              ],
            );
          },
        ),
      ),
    );
  }
}

class _BundleReleaseSummaryList extends StatelessWidget {
  const _BundleReleaseSummaryList({required this.bundleReleases});

  final List<BundleReleaseSummary> bundleReleases;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Bundle releases', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        for (final bundle in bundleReleases)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bundle.title,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              _MiniChip(
                                label:
                                    '${bundle.contentSummary.totalItems} members',
                              ),
                              if (bundle.bundleType != null)
                                _MiniChip(label: bundle.bundleType!),
                              if (bundle.publisher != null)
                                _MiniChip(label: bundle.publisher!),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).pop(
                        _CanonicalInspectResult.bundle(bundle.id),
                      ),
                      icon: const Icon(Icons.inventory_2_outlined),
                      label: const Text('Edit bundle'),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _CoverUpdate {
  const _CoverUpdate({
    required this.coverImageUrl,
    this.thumbnailImageUrl,
  });

  final String coverImageUrl;
  final String? thumbnailImageUrl;
}

class _CoverInspectionDialog extends StatefulWidget {
  const _CoverInspectionDialog({required this.item});

  final AdminMetadataItem item;

  @override
  State<_CoverInspectionDialog> createState() => _CoverInspectionDialogState();
}

class _CoverInspectionDialogState extends State<_CoverInspectionDialog> {
  late final TextEditingController _coverController;
  late final TextEditingController _thumbnailController;
  String? _checkMessage;
  bool _isChecking = false;

  AdminMetadataItem get item => widget.item;

  @override
  void initState() {
    super.initState();
    _coverController = TextEditingController(
      text: item.coverImageUrl ?? '',
    );
    _thumbnailController = TextEditingController(
      text: item.thumbnailImageUrl ?? '',
    );
    _coverController.addListener(_urlFieldsChanged);
    _thumbnailController.addListener(_urlFieldsChanged);
  }

  @override
  void dispose() {
    _coverController.removeListener(_urlFieldsChanged);
    _thumbnailController.removeListener(_urlFieldsChanged);
    _coverController.dispose();
    _thumbnailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AccentAlertDialog(
      title: Text('Covers: ${item.displayTitle}'),
      content: SizedBox(
        width: 640,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 180,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AspectRatio(
                      aspectRatio: 2 / 3,
                      child: LibraryCoverImage(
                        title: item.title,
                        itemNumber: item.itemNumber,
                        imageUrl: item.displayCoverUrl,
                      ),
                    ),
                    const SizedBox(width: 12),
                    AspectRatio(
                      aspectRatio: 2 / 3,
                      child: LibraryCoverImage(
                        title: item.title,
                        itemNumber: item.itemNumber,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Generated fallback preview',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Used by the client when the catalog item has no cover URL.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _coverController,
                decoration: const InputDecoration(
                  labelText: 'Replacement cover URL',
                  prefixIcon: Icon(Icons.link_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _thumbnailController,
                decoration: const InputDecoration(
                  labelText: 'Replacement thumbnail URL',
                  prefixIcon: Icon(Icons.image_search_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
              if (_checkMessage != null) ...[
                const SizedBox(height: 10),
                AdminMessageRow(
                  message: _checkMessage!,
                  isError: !_checkMessage!.startsWith('URL is reachable'),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton.icon(
          onPressed: _isChecking ? null : _checkCoverUrl,
          icon: _isChecking
              ? const SizedBox.square(
                  dimension: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.fact_check_outlined),
          label: const Text('Check URL'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        FilledButton.icon(
          onPressed: _coverController.text.trim().isEmpty
              ? null
              : () => Navigator.of(context).pop(
                    _CoverUpdate(
                      coverImageUrl: _coverController.text.trim(),
                      thumbnailImageUrl:
                          _emptyToNull(_thumbnailController.text),
                    ),
                  ),
          icon: const Icon(Icons.save_outlined),
          label: const Text('Replace URL'),
        ),
      ],
    );
  }

  Future<void> _checkCoverUrl() async {
    final url = _coverController.text.trim();
    if (url.isEmpty) {
      setState(() => _checkMessage = 'Enter a cover URL first.');
      return;
    }
    setState(() {
      _isChecking = true;
      _checkMessage = null;
    });
    try {
      if (await isLikelyImageUrl(url)) {
        if (mounted) {
          setState(() => _checkMessage = 'URL is reachable in this client.');
        }
      } else if (mounted) {
        setState(
            () => _checkMessage = 'URL check failed: not a valid image URL.');
      }
    } catch (error) {
      if (mounted) {
        setState(() => _checkMessage = 'URL check failed: $error');
      }
    } finally {
      if (mounted) {
        setState(() => _isChecking = false);
      }
    }
  }

  void _urlFieldsChanged() {
    if (mounted) {
      setState(() {});
    }
  }
}

class _ItemAuditTimeline extends StatelessWidget {
  const _ItemAuditTimeline({required this.logs});

  final List<AdminAuditLogEntry> logs;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Item audit history',
            style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 6),
        for (final log in logs.take(5))
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.manage_history_outlined, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${_formatDateTime(log.createdAt)} - ${log.action} by ${log.displayActor} (${log.detailsSummary})',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
