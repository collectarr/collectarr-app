import 'dart:async';

import 'package:collectarr_app/core/utils/app_toast.dart';
import 'package:collectarr_app/features/imports/framework/import_review_panel.dart';
import 'package:collectarr_app/features/providers/adapters/tmdb/tmdb_import_job_provider.dart';
import 'package:collectarr_app/features/providers/adapters/tmdb/tmdb_import_service.dart';
import 'package:collectarr_app/features/providers/adapters/tmdb/tmdb_import_settings.dart';
import 'package:collectarr_app/features/providers/adapters/tmdb/tmdb_pending_import_store.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_id.dart';
import 'package:collectarr_app/features/providers/ui/external_services_page.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

final _tmdbPendingImportsProvider =
    FutureProvider.autoDispose<List<TmdbPendingImportRecord>>((ref) async {
  return const TmdbPendingImportStore().read(limit: 10);
});

// TMDB inline import card (Yamtrack-style, no modal)
// ---------------------------------------------------------------------------

enum _TmdbSourceMode { accountSync, csvFile }

class TmdbImportInlineCard extends ConsumerStatefulWidget {
  const TmdbImportInlineCard({super.key, required this.tmdbSettings});

  final TmdbImportSettings tmdbSettings;

  @override
  ConsumerState<TmdbImportInlineCard> createState() =>
      TmdbImportInlineCardState();
}

class TmdbImportInlineCardState extends ConsumerState<TmdbImportInlineCard> {
  late final TextEditingController _apiKeyCtrl;
  late final TextEditingController _accountIdCtrl;
  late final TextEditingController _sessionIdCtrl;
  _TmdbSourceMode _sourceMode = _TmdbSourceMode.csvFile;
  TmdbImportCollection _collection = TmdbImportCollection.ratedMovies;
  String? _accountId;
  bool _keepUnmatchedLocally = true;

  @override
  void initState() {
    super.initState();
    _apiKeyCtrl = TextEditingController(text: widget.tmdbSettings.apiKey);
    _accountIdCtrl = TextEditingController(text: widget.tmdbSettings.accountId);
    _sessionIdCtrl = TextEditingController(text: widget.tmdbSettings.sessionId);
  }

  @override
  void dispose() {
    _apiKeyCtrl.dispose();
    _accountIdCtrl.dispose();
    _sessionIdCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveCredentials() async {
    await ref.read(tmdbImportSettingsProvider.notifier).save(
          apiKey: _apiKeyCtrl.text,
          accountId: _accountIdCtrl.text,
          sessionId: _sessionIdCtrl.text,
        );
    if (!mounted) return;
    showAppToast(context, 'Credentials saved.', tone: AppToastTone.success);
  }

  Future<void> _startAccountImport() async {
    final apiKey = _apiKeyCtrl.text.trim();
    final accountId = _accountIdCtrl.text.trim();
    final sessionId = _sessionIdCtrl.text.trim();
    if (apiKey.isEmpty || accountId.isEmpty || sessionId.isEmpty) {
      showAppToast(
        context,
        'Fill in API key, account ID, and session ID.',
        tone: AppToastTone.error,
      );
      return;
    }
    await _saveCredentials();
    unawaited(ref.read(importJobsProvider.notifier).startTmdbAccountImport(
          credentials: TmdbImportCredentials(
            apiKey: apiKey,
            accountId: accountId,
            sessionId: sessionId,
          ),
          collection: _collection,
          keepUnmatchedLocally: _keepUnmatchedLocally,
        ));
    if (!mounted) return;
    showAppToast(
      context,
      'TMDB import started in background.',
      tone: AppToastTone.info,
    );
  }

  Future<void> _pickAndImportFile() async {
    final file = await openFile(
      acceptedTypeGroups: const [
        XTypeGroup(
          label: 'TMDB exports',
          extensions: ['csv', 'zip', 'json'],
        ),
      ],
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    unawaited(ref.read(importJobsProvider.notifier).startTmdbFileImport(
          bytes: bytes,
          fileName: file.name,
          collection: _collection,
          keepUnmatchedLocally: _keepUnmatchedLocally,
          apiKey: _apiKeyCtrl.text.trim().isNotEmpty
              ? _apiKeyCtrl.text.trim()
              : null,
          accountId: _accountId,
        ));
    if (!mounted) return;
    showAppToast(
      context,
      'Importing ${file.name} in background.',
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
            // Header row
            Row(
              children: [
                SvgPicture.asset(
                  'assets/logos/tmdb_logo.svg',
                  width: 24,
                  height: 24,
                  colorFilter: const ColorFilter.mode(
                    Color(0xFF01B4E4),
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'TMDB',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              'Import movies and TV shows.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.hintColor,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 8),

            // Collection dropdown
            DropdownButtonFormField<TmdbImportCollection>(
              initialValue: _collection,
              isExpanded: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Collection',
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
              style: theme.textTheme.bodySmall,
              items: TmdbImportCollection.values
                  .map(
                    (c) => DropdownMenuItem(value: c, child: Text(c.label)),
                  )
                  .toList(growable: false),
              onChanged: (value) {
                if (value != null) setState(() => _collection = value);
              },
            ),
            const SizedBox(height: 8),

            // Source mode as compact row of chips
            Row(
              children: [
                Expanded(
                  child: _SourceChip(
                    icon: Icons.cloud_sync_outlined,
                    label: 'Account',
                    selected: _sourceMode == _TmdbSourceMode.accountSync,
                    onTap: () => setState(
                        () => _sourceMode = _TmdbSourceMode.accountSync),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _SourceChip(
                    icon: Icons.upload_file_outlined,
                    label: 'CSV / JSON',
                    selected: _sourceMode == _TmdbSourceMode.csvFile,
                    onTap: () =>
                        setState(() => _sourceMode = _TmdbSourceMode.csvFile),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Source-specific fields
            if (_sourceMode == _TmdbSourceMode.accountSync) ...[
              TextField(
                controller: _apiKeyCtrl,
                obscureText: true,
                style: theme.textTheme.bodySmall,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'API key',
                  isDense: true,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _accountIdCtrl,
                style: theme.textTheme.bodySmall,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Account ID',
                  isDense: true,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _sessionIdCtrl,
                obscureText: true,
                style: theme.textTheme.bodySmall,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Session ID',
                  isDense: true,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                ),
              ),
              const SizedBox(height: 6),
            ],
            if (_sourceMode == _TmdbSourceMode.csvFile) ...[
              ProviderAccountSelector(
                provider: ProviderId.tmdb,
                selectedAccountId: _accountId,
                onChanged: (value) => setState(() => _accountId = value),
              ),
              const SizedBox(height: 6),
            ],

            // Options
            Row(
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox.adaptive(
                    value: _keepUnmatchedLocally,
                    visualDensity: VisualDensity.compact,
                    onChanged: (v) =>
                        setState(() => _keepUnmatchedLocally = v ?? false),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'Keep unmatched locally',
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Action buttons
            if (_sourceMode == _TmdbSourceMode.accountSync)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _saveCredentials,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                      child: const Text('Save'),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _startAccountImport,
                      icon: const Icon(Icons.download_outlined, size: 14),
                      label: const Text('Import'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ],
              )
            else
              FilledButton.icon(
                onPressed: _pickAndImportFile,
                icon: const Icon(Icons.folder_open_outlined, size: 14),
                label: const Text('Select CSV / JSON File'),
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

// ---------------------------------------------------------------------------
// Compact source mode chip
// ---------------------------------------------------------------------------

class ProviderAccountSelector extends ConsumerWidget {
  const ProviderAccountSelector({
    super.key,
    required this.provider,
    required this.selectedAccountId,
    required this.onChanged,
  });

  final ProviderId provider;
  final String? selectedAccountId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final accountsAsync = ref.watch(externalAccountsProvider);
    return accountsAsync.when(
      loading: () => const LinearProgressIndicator(minHeight: 2),
      error: (error, stackTrace) => Text(
        'Could not load linked accounts: $error',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.error,
          fontSize: 11,
        ),
      ),
      data: (accounts) {
        final providerAccounts = accounts
            .where((account) => account.provider == provider)
            .toList(growable: false);
        final selected = providerAccounts.any(
          (account) => account.id == selectedAccountId,
        )
            ? selectedAccountId
            : '';
        return DropdownButtonFormField<String>(
          initialValue: selected,
          isExpanded: true,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Link imported items to',
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          ),
          style: theme.textTheme.bodySmall,
          items: [
            const DropdownMenuItem<String>(
              value: '',
              child: Text('No account linking'),
            ),
            for (final account in providerAccounts)
              DropdownMenuItem<String>(
                value: account.id,
                child: Text(
                  account.username?.trim().isNotEmpty == true
                      ? '${account.displayName} Â· ${account.username}'
                      : account.displayName,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
          onChanged: (value) => onChanged(
            value == null || value.isEmpty ? null : value,
          ),
        );
      },
    );
  }
}

class _SourceChip extends StatelessWidget {
  const _SourceChip({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fg = selected ? theme.colorScheme.onPrimary : theme.hintColor;
    final bg = selected
        ? theme.colorScheme.primary
        : theme.colorScheme.surfaceContainerHighest;
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: fg),
              const SizedBox(width: 4),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: fg,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class TmdbPendingImportsPanel extends ConsumerWidget {
  const TmdbPendingImportsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pending = ref.watch(_tmdbPendingImportsProvider);
    return pending.when(
      data: (records) {
        final store = const TmdbPendingImportStore();
        return ImportReviewPanel(
          title: 'Pending TMDB imports',
          emptyLabel: 'No queued local TMDB proposals.',
          items: [
            for (final record in records)
              ImportReviewItem(
                title: record.entry.title,
                description:
                    '${record.entry.mediaType.label} Â· ${record.entry.collection.label}',
                trailingLabel: record.proposalServerId == null
                    ? 'Local only'
                    : 'Proposal ${record.proposalServerId}',
                severity: ImportReviewSeverity.info,
                actions: [
                  ImportReviewAction(
                    label: 'Remove',
                    onPressed: () async {
                      await store.remove(record.localItemId);
                      ref.invalidate(_tmdbPendingImportsProvider);
                    },
                  ),
                ],
              ),
          ],
          onClearAll: records.isEmpty
              ? null
              : () async {
                  await store.clear();
                  ref.invalidate(_tmdbPendingImportsProvider);
                },
        );
      },
      loading: () => const LinearProgressIndicator(),
      error: (error, _) => Text('Failed to load pending imports: $error'),
    );
  }
}

// Import jobs status panel (real-time progress like CLZ)
// ---------------------------------------------------------------------------

class TmdbImportJobsPanel extends ConsumerWidget {
  const TmdbImportJobsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobs = ref.watch(importJobsProvider);
    if (jobs.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
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
                  Icon(Icons.sync_outlined, size: 18, color: theme.hintColor),
                  const SizedBox(width: 6),
                  Text(
                    'Import jobs',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              for (final job in jobs) ...[
                _ImportJobTile(job: job),
                if (job != jobs.last) const SizedBox(height: 6),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ImportJobTile extends ConsumerWidget {
  const _ImportJobTile({required this.job});

  final ImportJobState job;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDone = job.phase == ImportJobPhase.done;
    final isFailed = job.phase == ImportJobPhase.failed;
    final isActive = job.isActive;

    final statusColor = isFailed
        ? theme.colorScheme.error
        : isDone
            ? Colors.green
            : theme.colorScheme.primary;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  isFailed
                      ? Icons.error_outline
                      : isDone
                          ? Icons.check_circle_outline
                          : Icons.sync,
                  size: 16,
                  color: statusColor,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    job.label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  job.phaseLabel,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (!isActive) ...[
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: () => ref
                        .read(importJobsProvider.notifier)
                        .dismissJob(job.id),
                    borderRadius: BorderRadius.circular(12),
                    child: Icon(
                      Icons.close,
                      size: 14,
                      color: theme.hintColor,
                    ),
                  ),
                ],
              ],
            ),
            if (isActive && job.total > 0) ...[
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: job.progress,
                  minHeight: 3,
                  backgroundColor: theme.dividerColor,
                  valueColor: AlwaysStoppedAnimation(statusColor),
                ),
              ),
            ] else if (isActive && job.total == 0) ...[
              const SizedBox(height: 6),
              const ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(2)),
                child: LinearProgressIndicator(minHeight: 3),
              ),
            ],
            const SizedBox(height: 4),
            Text(
              job.summary,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.hintColor,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (isDone) ...[
              const SizedBox(height: 2),
              Text(
                '${job.matched} matched Â· ${job.unmatched} unmatched',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.hintColor,
                  fontSize: 11,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
