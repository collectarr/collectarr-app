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
  });

  final AdminMetadataItem item;
  final List<AdminAuditLogEntry> auditLogs;
  final List<BundleReleaseSummary> bundleReleases;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dialogWidth =
        (MediaQuery.sizeOf(context).width - 96).clamp(280.0, 820.0).toDouble();
    return AlertDialog(
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
              ),
              if (auditLogs.isEmpty) ...[
                const SizedBox(height: 12),
                const _MessageRow(
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
    this.created,
    this.auditLogs = const [],
    this.bundleReleases = const [],
  });

  final AdminMetadataItem item;
  final bool? created;
  final List<AdminAuditLogEntry> auditLogs;
  final List<BundleReleaseSummary> bundleReleases;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final variant = item.primaryVariant;
    final edition = item.primaryEdition;
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
                    Icon(
                      created == true
                          ? Icons.add_circle_outline
                          : Icons.fact_check_outlined,
                      color: colorScheme.primary,
                    ),
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
                    if (item.series?.seriesTitle != null)
                      _MiniChip(label: item.series!.seriesTitle!),
                    if (edition?.physicalFormatLabel != null)
                      _MiniChip(label: edition!.physicalFormatLabel!),
                    if (item.publisher != null)
                      _MiniChip(label: item.publisher!),
                    if (item.barcode != null) _MiniChip(label: item.barcode!),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _Fact(
                      label: 'Editions',
                      value: item.editions.length.toString(),
                    ),
                    _Fact(
                      label: 'Variants',
                      value: item.editions
                          .fold<int>(
                            0,
                            (count, edition) => count + edition.variants.length,
                          )
                          .toString(),
                    ),
                    if (item.publishing?.pageCount != null)
                      _Fact(
                        label: 'Pages',
                        value: item.publishing!.pageCount.toString(),
                      ),
                    if (item.coverDate != null)
                      _Fact(label: 'Cover', value: _formatDate(item.coverDate!)),
                    if (item.storeDate != null)
                      _Fact(label: 'Store', value: _formatDate(item.storeDate!)),
                    if (variant?.coverPriceCents != null)
                      _Fact(
                        label: 'Cover price',
                        value: _formatMoney(
                          variant!.coverPriceCents!,
                          variant.currency ?? item.publishing?.currency,
                        ),
                      ),
                  ],
                ),
                if (item.providerLinks.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _ProviderLinksList(links: item.providerLinks),
                ],
                if (item.editions.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _AdminItemVariantSummary(item: item),
                ],
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
              children: [cover, const SizedBox(width: 12), Expanded(child: details)],
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
                                label: '${bundle.contentSummary.totalItems} members',
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

class _ProviderLinksList extends StatelessWidget {
  const _ProviderLinksList({required this.links});

  final List<AdminProviderLink> links;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Provider links', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 6),
        for (final link in links.take(6))
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _MiniChip(label: link.provider),
                _MiniChip(label: link.entityType),
                _MiniChip(label: 'Linked record'),
                if (link.siteUrl != null) const _MiniChip(label: 'site URL'),
                if (link.apiUrl != null) const _MiniChip(label: 'api URL'),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: SelectableText(link.providerItemId, maxLines: 1),
                ),
                if (link.siteUrl != null)
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: SelectableText(link.siteUrl!, maxLines: 1),
                  ),
              ],
            ),
          ),
      ],
    );
  }
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
      text: item.primaryVariant?.coverImageUrl ?? '',
    );
    _thumbnailController = TextEditingController(
      text: item.primaryVariant?.thumbnailImageUrl ?? '',
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
    final variants = [
      for (final edition in item.editions) ...edition.variants,
    ];
    return AlertDialog(
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
                            'Used by the client when the provider has no usable cover URL.',
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
                _MessageRow(
                  message: _checkMessage!,
                  isError: !_checkMessage!.startsWith('URL is reachable'),
                ),
              ],
              const SizedBox(height: 12),
              if (variants.isEmpty)
                const Text('No variants attached to this item.')
              else
                for (final variant in variants)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          variant.name,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        SelectableText(
                          [
                            if (variant.physicalFormatLabel != null)
                              'format: ${variant.physicalFormatLabel}',
                            if (variant.coverImageUrl != null)
                              'cover: ${variant.coverImageUrl}',
                            if (variant.thumbnailImageUrl != null)
                              'thumb: ${variant.thumbnailImageUrl}',
                            if (variant.coverImageUrl == null &&
                                variant.thumbnailImageUrl == null)
                              'no cover URLs',
                            'status: ${variant.coverStatus}',
                            if (variant.coverStorage != null)
                              'storage: ${variant.coverStorage}',
                            if (variant.coverPolicy != null)
                              'policy: ${variant.coverPolicy}',
                          ].join('\n'),
                        ),
                      ],
                    ),
                  ),
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
                      thumbnailImageUrl: _emptyToNull(_thumbnailController.text),
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
      await precacheImage(NetworkImage(url), context);
      if (mounted) {
        setState(() => _checkMessage = 'URL is reachable in this client.');
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

class _AdminItemVariantSummary extends StatelessWidget {
  const _AdminItemVariantSummary({required this.item});

  final AdminMetadataItem item;

  @override
  Widget build(BuildContext context) {
    final variants = [
      for (final edition in item.editions)
        for (final variant in edition.variants)
          _EditionVariantPair(edition: edition, variant: variant),
    ];
    if (variants.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Variants and cover status',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final pair in variants.take(6))
              _VariantStatusCard(edition: pair.edition, variant: pair.variant),
          ],
        ),
      ],
    );
  }
}

class _EditionVariantPair {
  const _EditionVariantPair({required this.edition, required this.variant});

  final AdminEdition edition;
  final AdminVariant variant;
}

class _VariantStatusCard extends StatelessWidget {
  const _VariantStatusCard({
    required this.edition,
    required this.variant,
  });

  final AdminEdition edition;
  final AdminVariant variant;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasCover = variant.coverImageUrl != null ||
        variant.thumbnailImageUrl != null ||
        variant.coverStatus != 'missing';
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360, minWidth: 240),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surface.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(
                    hasCover ? Icons.image_outlined : Icons.hide_image_outlined,
                    size: 18,
                    color: hasCover ? colorScheme.primary : colorScheme.error,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      variant.name.isEmpty ? edition.title : variant.name,
                      style: Theme.of(context).textTheme.labelLarge,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _MiniChip(label: variant.coverStatus),
                  if (variant.coverStorage != null)
                    _MiniChip(label: variant.coverStorage!),
                  if (variant.coverPolicy != null)
                    _MiniChip(label: variant.coverPolicy!),
                  if (variant.physicalFormatLabel != null)
                    _MiniChip(label: variant.physicalFormatLabel!),
                  if (variant.barcode != null)
                    _MiniChip(label: variant.barcode!),
                ],
              ),
              if (variant.coverSourceUrl != null) ...[
                const SizedBox(height: 6),
                Text(
                  variant.coverSourceUrl!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
      ),
    );
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
        Text('Item audit history', style: Theme.of(context).textTheme.labelLarge),
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