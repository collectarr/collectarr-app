part of 'settings_page.dart';

// ---------------------------------------------------------------------------
// Data tab widgets: import sources, TMDB import, import jobs, proposals
// ---------------------------------------------------------------------------

class _MetadataProposalHistory extends StatelessWidget {
  const _MetadataProposalHistory({
    required this.records,
    required this.isLoading,
    required this.onClear,
  });

  final List<MetadataProposalRecord> records;
  final bool isLoading;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const LinearProgressIndicator();
    }
    if (records.isEmpty) {
      return const Text('No local proposal submissions yet.');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _StatusChip(
              icon: Icons.outbox_outlined,
              label: '${records.length} submitted locally',
            ),
            _StatusChip(
              icon: Icons.pending_actions,
              label:
                  "${records.where((row) => row.status == 'pending').length} pending",
            ),
          ],
        ),
        const SizedBox(height: 8),
        for (final record in records.take(5))
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.fact_check_outlined),
            title: Text(record.title ?? record.query),
            subtitle: Text(
              [
                record.source,
                record.provider,
                record.status,
                _formatProposalTime(record.createdAt),
              ].join(' | '),
            ),
          ),
        if (records.length > 5)
          Text('+${records.length - 5} older proposal submissions'),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: onClear,
            icon: const Icon(Icons.clear_all),
            label: const Text('Clear local history'),
          ),
        ),
      ],
    );
  }
}

String _formatProposalTime(DateTime value) {
  final local = value.toLocal();
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')} $hour:$minute';
}

class _ImportSourcesGrid extends ConsumerWidget {
  const _ImportSourcesGrid({required this.tmdbSettings});

  final TmdbImportSettings tmdbSettings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final availableDescriptors = providerImportDescriptors
        .where(
          (d) => d.availability == ProviderImportAvailability.available,
        )
        .where(
          (d) => d.id != ProviderId.myAnimeList && d.id != ProviderId.aniList,
        )
        .toList(growable: false);
    final comingSoonDescriptors = providerImportDescriptors
        .where(
          (d) => d.availability == ProviderImportAvailability.comingSoon,
        )
        .where(
          (d) =>
              d.id != ProviderId.trakt &&
              d.id != ProviderId.simkl &&
              d.id != ProviderId.kitsu &&
              d.id != ProviderId.imdb &&
              d.id != ProviderId.goodReads &&
              d.id != ProviderId.howLongToBeat,
        )
        .toList(growable: false);
    return LayoutBuilder(
      builder: (context, constraints) {
        final useWide = constraints.maxWidth >= 560;
        final cardWidth =
            useWide ? (constraints.maxWidth - 12) / 2 : constraints.maxWidth;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: cardWidth,
              child: TmdbImportInlineCard(tmdbSettings: tmdbSettings),
            ),
            SizedBox(
              width: cardWidth,
              child: const _AnimeListImportCard(),
            ),
            SizedBox(
              width: cardWidth,
              child: const _ProviderCsvImportCard(),
            ),
            for (final descriptor in availableDescriptors)
              SizedBox(
                width: cardWidth,
                child: _AvailableImportCard(descriptor: descriptor),
              ),
            for (final descriptor in comingSoonDescriptors)
              SizedBox(
                width: cardWidth,
                child: _ComingSoonImportCard(descriptor: descriptor),
              ),
          ],
        );
      },
    );
  }
}

class _AnimeListImportCard extends ConsumerStatefulWidget {
  const _AnimeListImportCard();

  @override
  ConsumerState<_AnimeListImportCard> createState() =>
      _AnimeListImportCardState();
}

class _AnimeListImportCardState extends ConsumerState<_AnimeListImportCard> {
  ProviderId _provider = ProviderId.myAnimeList;
  String? _accountId;
  bool _keepUnmatchedLocally = true;
  bool _isWorking = false;

  Future<void> _pickAndImportFile() async {
    final file = await openFile(
      acceptedTypeGroups: const [
        XTypeGroup(
          label: 'Anime list export',
          extensions: ['xml'],
        ),
      ],
    );
    if (file == null) return;
    setState(() => _isWorking = true);
    try {
      final bytes = await file.readAsBytes();
      unawaited(
        ref.read(importJobsProvider.notifier).startAnimeListFileImport(
              bytes: bytes,
              fileName: file.name,
              provider: _provider,
              keepUnmatchedLocally: _keepUnmatchedLocally,
              accountId: _accountId,
            ),
      );
    } finally {
      if (mounted) {
        setState(() => _isWorking = false);
      }
    }
    if (!mounted) return;
    showAppToast(
      context,
      'Importing ${file.name} as ${_provider.label}.',
      tone: AppToastTone.info,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.4),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  providerImportIcon(_provider),
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Anime list XML',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Available',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Import anime and manga list exports from MyAnimeList or AniList XML files.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.hintColor,
                fontSize: 11,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<ProviderId>(
              initialValue: _provider,
              isExpanded: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Provider',
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
              style: theme.textTheme.bodySmall,
              items: const [
                ProviderId.myAnimeList,
                ProviderId.aniList,
              ].map((provider) {
                return DropdownMenuItem(
                  value: provider,
                  child: Text(provider.label),
                );
              }).toList(growable: false),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _provider = value;
                    _accountId = null;
                  });
                }
              },
            ),
            const SizedBox(height: 8),
            ProviderAccountSelector(
              provider: _provider,
              selectedAccountId: _accountId,
              onChanged: (value) => setState(() => _accountId = value),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox.adaptive(
                    value: _keepUnmatchedLocally,
                    visualDensity: VisualDensity.compact,
                    onChanged: (value) =>
                        setState(() => _keepUnmatchedLocally = value ?? false),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Keep unmatched locally',
                    style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: _isWorking ? null : _pickAndImportFile,
              icon: const Icon(Icons.folder_open_outlined, size: 14),
              label: const Text('Select XML File'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 6),
                textStyle: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProviderCsvImportCard extends ConsumerStatefulWidget {
  const _ProviderCsvImportCard();

  @override
  ConsumerState<_ProviderCsvImportCard> createState() =>
      _ProviderCsvImportCardState();
}

class _ProviderCsvImportCardState
    extends ConsumerState<_ProviderCsvImportCard> {
  ProviderId _provider = ProviderId.trakt;
  String? _accountId;
  bool _keepUnmatchedLocally = true;
  bool _isWorking = false;

  static const _csvProviders = <ProviderId>[
    ProviderId.trakt,
    ProviderId.simkl,
    ProviderId.kitsu,
    ProviderId.imdb,
    ProviderId.goodReads,
    ProviderId.howLongToBeat,
  ];

  Future<void> _pickAndImportFile() async {
    final file = await openFile(
      acceptedTypeGroups: const [
        XTypeGroup(
          label: 'Provider CSV export',
          extensions: ['csv'],
        ),
      ],
    );
    if (file == null) return;
    setState(() => _isWorking = true);
    try {
      final bytes = await file.readAsBytes();
      unawaited(
        ref.read(importJobsProvider.notifier).startProviderCsvFileImport(
              bytes: bytes,
              fileName: file.name,
              provider: _provider,
              keepUnmatchedLocally: _keepUnmatchedLocally,
              accountId: _accountId,
            ),
      );
    } finally {
      if (mounted) {
        setState(() => _isWorking = false);
      }
    }
    if (!mounted) return;
    showAppToast(
      context,
      'Importing ${file.name} as ${_provider.label}.',
      tone: AppToastTone.info,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.4),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  providerImportIcon(_provider),
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Provider CSV export',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Available',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Import CSV exports from Trakt, Simkl, Kitsu, IMDb, Goodreads, or HowLongToBeat.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.hintColor,
                fontSize: 11,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<ProviderId>(
              initialValue: _provider,
              isExpanded: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Provider',
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
              style: theme.textTheme.bodySmall,
              items: _csvProviders.map((provider) {
                return DropdownMenuItem(
                  value: provider,
                  child: Text(provider.label),
                );
              }).toList(growable: false),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _provider = value;
                    _accountId = null;
                  });
                }
              },
            ),
            const SizedBox(height: 8),
            ProviderAccountSelector(
              provider: _provider,
              selectedAccountId: _accountId,
              onChanged: (value) => setState(() => _accountId = value),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox.adaptive(
                    value: _keepUnmatchedLocally,
                    visualDensity: VisualDensity.compact,
                    onChanged: (value) =>
                        setState(() => _keepUnmatchedLocally = value ?? false),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Keep unmatched locally',
                    style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: _isWorking ? null : _pickAndImportFile,
              icon: const Icon(Icons.folder_open_outlined, size: 14),
              label: const Text('Select CSV File'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 6),
                textStyle: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AvailableImportCard extends StatelessWidget {
  const _AvailableImportCard({required this.descriptor});

  final ProviderImportDescriptor descriptor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(providerImportIcon(descriptor.id), size: 20),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    descriptor.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Available',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              descriptor.summary,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.hintColor,
                fontSize: 11,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () => showLibraryAddDialog(
                    context: context,
                    type: libraryKindModuleForKind(CatalogMediaKind.anime),
                  ),
                  icon: const Icon(Icons.auto_awesome_outlined, size: 14),
                  label: const Text('Open Anime add flow'),
                ),
                OutlinedButton.icon(
                  onPressed: () => showLibraryAddDialog(
                    context: context,
                    type: libraryKindModuleForKind(CatalogMediaKind.manga),
                  ),
                  icon: const Icon(Icons.import_contacts_outlined, size: 14),
                  label: const Text('Open Manga add flow'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ComingSoonImportCard extends StatelessWidget {
  const _ComingSoonImportCard({required this.descriptor});

  final ProviderImportDescriptor descriptor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  providerImportIcon(descriptor.id),
                  size: 20,
                  color: theme.hintColor,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    descriptor.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Coming soon',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.hintColor,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              descriptor.summary,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.hintColor,
                fontSize: 11,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
