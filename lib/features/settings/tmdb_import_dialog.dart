import 'dart:async';
import 'dart:math' as math;

import 'package:collectarr_app/core/logging/recoverable_error.dart';
import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/tracking_source.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';
import 'package:collectarr_app/core/utils/app_toast.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/kinds/movie/config.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_proposal.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_query.dart';
import 'package:collectarr_app/features/library/providers/media_catalog_provider.dart';
import 'package:collectarr_app/features/settings/provider_import_history_store.dart';
import 'package:collectarr_app/features/settings/provider_import_models.dart';
import 'package:collectarr_app/features/settings/tmdb_import_preview_dialog.dart';
import 'package:collectarr_app/features/settings/tmdb_import_service.dart';
import 'package:collectarr_app/features/settings/tmdb_import_settings.dart';
import 'package:collectarr_app/features/settings/tmdb_pending_import_store.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:dio/dio.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum _TmdbImportSourceMode {
  accountSync,
  exportFile,
}

class TmdbImportWorkspace extends ConsumerStatefulWidget {
  const TmdbImportWorkspace({
    super.key,
    required this.initialSettings,
    this.onImportRecorded,
    this.onStateChanged,
  });

  final TmdbImportSettings initialSettings;
  final VoidCallback? onImportRecorded;
  final VoidCallback? onStateChanged;

  @override
  ConsumerState<TmdbImportWorkspace> createState() =>
      _TmdbImportWorkspaceState();
}

class _TmdbImportWorkspaceState extends ConsumerState<TmdbImportWorkspace> {
  static const _unmatchedImportConcurrency = 4;
  late final TextEditingController _apiKeyController;
  late final TextEditingController _accountIdController;
  late final TextEditingController _sessionIdController;
  final TextEditingController _payloadController = TextEditingController();
  final TmdbImportService _service = TmdbImportService();
  final TmdbPendingImportStore _pendingStore = const TmdbPendingImportStore();
  final ProviderImportHistoryStore _historyStore =
      const ProviderImportHistoryStore();
  TmdbImportCollection _collection = TmdbImportCollection.ratedMovies;
  _TmdbImportSourceMode _sourceMode = _TmdbImportSourceMode.exportFile;
  bool _isWorking = false;
  bool _keepUnmatchedLocally = true;
  int _pendingLocalCount = 0;
  String _lastPreviewSourceLabel = 'Pasted payload';

  @override
  void initState() {
    super.initState();
    _apiKeyController =
        TextEditingController(text: widget.initialSettings.apiKey);
    _accountIdController =
        TextEditingController(text: widget.initialSettings.accountId);
    _sessionIdController =
        TextEditingController(text: widget.initialSettings.sessionId);
    unawaited(_refreshPendingLocalCount());
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _accountIdController.dispose();
    _sessionIdController.dispose();
    _payloadController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 760;
        final controlsPane = _buildControlsPane(context);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                SizedBox(
                  width: isWide ? 240 : double.infinity,
                  child: DropdownButtonFormField<TmdbImportCollection>(
                    initialValue: _collection,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'TMDB collection',
                      isDense: true,
                    ),
                    items: TmdbImportCollection.values
                        .map(
                          (value) => DropdownMenuItem<TmdbImportCollection>(
                            value: value,
                            child: Text(value.label),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: _isWorking
                        ? null
                        : (value) {
                            if (value == null) {
                              return;
                            }
                            setState(() {
                              _collection = value;
                            });
                          },
                  ),
                ),
                SegmentedButton<_TmdbImportSourceMode>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment<_TmdbImportSourceMode>(
                      value: _TmdbImportSourceMode.accountSync,
                      icon: Icon(Icons.cloud_sync_outlined, size: 18),
                      label: Text('Account sync'),
                    ),
                    ButtonSegment<_TmdbImportSourceMode>(
                      value: _TmdbImportSourceMode.exportFile,
                      icon: Icon(Icons.upload_file_outlined, size: 18),
                      label: Text('JSON / CSV'),
                    ),
                  ],
                  selected: {_sourceMode},
                  onSelectionChanged: _isWorking
                      ? null
                      : (selection) {
                          final nextMode = selection.firstOrNull;
                          if (nextMode == null || nextMode == _sourceMode) {
                            return;
                          }
                          setState(() {
                            _sourceMode = nextMode;
                          });
                        },
                ),
                if (_isWorking)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: isWide
                  ? Center(
                      child: SizedBox(
                        width: 720,
                        child: controlsPane,
                      ),
                    )
                  : controlsPane,
            ),
          ],
        );
      },
    );
  }

  Widget _buildControlsPane(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: switch (_sourceMode) {
            _TmdbImportSourceMode.accountSync => _buildAccountSyncPane(context),
            _TmdbImportSourceMode.exportFile => _buildExportPane(context),
          },
        ),
        const SizedBox(height: 10),
        _ImportSectionCard(
          title: 'Options',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Checkbox.adaptive(
                    value: _keepUnmatchedLocally,
                    visualDensity: VisualDensity.compact,
                    onChanged: _isWorking
                        ? null
                        : (value) {
                            setState(() {
                              _keepUnmatchedLocally = value ?? false;
                            });
                          },
                  ),
                  const SizedBox(width: 4),
                  const Expanded(
                    child: Text('Keep unmatched locally'),
                  ),
                ],
              ),
              Text(
                'Unmatched rows stay on this device until reconciliation succeeds.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: _isWorking || _pendingLocalCount == 0
                      ? null
                      : _reconcilePendingImports,
                  icon: const Icon(Icons.link_outlined),
                  label: const Text('Reconcile pending'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAccountSyncPane(BuildContext context) {
    return _ImportSectionCard(
      title: 'Account sync',
      expandChild: true,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          TextField(
            controller: _apiKeyController,
            maxLines: 1,
            obscureText: true,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'TMDB API key',
              isDense: true,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _accountIdController,
            maxLines: 1,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Account id',
              isDense: true,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _sessionIdController,
            maxLines: 1,
            obscureText: true,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Session id',
              isDense: true,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: _isWorking ? null : _saveCredentials,
                icon: const Icon(Icons.save_outlined),
                label: const Text('Save'),
              ),
              FilledButton.tonalIcon(
                onPressed: _isWorking ? null : _loadFromTmdb,
                icon: const Icon(Icons.cloud_download_outlined),
                label: const Text('Import from TMDB'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExportPane(BuildContext context) {
    return _ImportSectionCard(
      title: 'JSON / CSV import',
      expandChild: true,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final editorHeight = constraints.maxHeight > 240
              ? constraints.maxHeight - 52
              : 180.0;
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              SizedBox(
                height: editorHeight,
                child: TextField(
                  controller: _payloadController,
                  expands: true,
                  minLines: null,
                  maxLines: null,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Paste TMDB JSON or CSV export',
                    alignLabelWithHint: true,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.tonalIcon(
                    onPressed: _isWorking ? null : _previewPayload,
                    icon: const Icon(Icons.file_download_outlined),
                    label: const Text('Import JSON / CSV'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _isWorking ? null : _pickImportFile,
                    icon: const Icon(Icons.folder_open_outlined),
                    label: const Text('Import file'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'TMDB file exports often omit poster data. Save an API key in Account sync if you want covers enriched during JSON / CSV imports.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          );
        },
      ),
    );
  }

  String get _importButtonLabel {
    return switch (_collection) {
      TmdbImportCollection.ratedMovies => 'Import as completed',
      TmdbImportCollection.watchlistMovies => 'Import as wishlist',
    };
  }

  Future<void> _persistCredentials({bool showSuccessToast = false}) async {
    await ref.read(tmdbImportSettingsProvider.notifier).save(
          apiKey: _apiKeyController.text,
          accountId: _accountIdController.text,
          sessionId: _sessionIdController.text,
        );
    if (!showSuccessToast || !mounted) {
      return;
    }
    showAppToast(
      context,
      'TMDB credentials saved on this device.',
      tone: AppToastTone.success,
    );
  }

  Future<void> _saveCredentials() {
    return _persistCredentials(showSuccessToast: true);
  }

  Future<void> _loadFromTmdb() async {
    await _runPreviewFlow(
      sourceMode: _TmdbImportSourceMode.accountSync,
      mapError: _describeTmdbFetchError,
      preparePreview: () async {
        final credentials = TmdbImportCredentials(
          apiKey: _apiKeyController.text,
          accountId: _accountIdController.text,
          sessionId: _sessionIdController.text,
        );
        final entries = await _service.fetchCollection(credentials, _collection);
        await _persistCredentials();
        return _TmdbPreviewRequest(
          sourceLabel: 'TMDB account sync',
          entries: entries,
        );
      },
    );
  }

  Future<void> _previewPayload() async {
    final rawText = _payloadController.text.trim();
    if (rawText.isEmpty) {
      showAppToast(
        context,
        'Paste a TMDB JSON or CSV export first.',
        tone: AppToastTone.error,
      );
      return;
    }
    await _runPreviewFlow(
      sourceMode: _TmdbImportSourceMode.exportFile,
      mapError: _describeTmdbPayloadError,
      preparePreview: () async {
        final entries = _service.parseCollectionPayload(
          rawText,
          collection: _collection,
        );
        return _TmdbPreviewRequest(
          sourceLabel: 'Pasted payload',
          entries: entries,
        );
      },
    );
  }

  Future<void> _pickImportFile() async {
    await _runPreviewFlow(
      sourceMode: _TmdbImportSourceMode.exportFile,
      mapError: _describeTmdbFileError,
      preparePreview: () async {
        final file = await openFile(
          acceptedTypeGroups: const [
            XTypeGroup(
              label: 'TMDB exports',
              extensions: ['csv', 'zip', 'json'],
            ),
          ],
        );
        if (file == null) {
          return null;
        }
        final bytes = await file.readAsBytes();
        final entries = _service.parseCollectionFileBytes(
          bytes,
          fileName: file.name,
          collection: _collection,
        );
        return _TmdbPreviewRequest(
          sourceLabel: file.name,
          entries: entries,
        );
      },
    );
  }

  Future<void> _runPreviewFlow({
    required _TmdbImportSourceMode sourceMode,
    required Future<_TmdbPreviewRequest?> Function() preparePreview,
    required String Function(Object error) mapError,
  }) async {
    setState(() {
      _sourceMode = sourceMode;
      _isWorking = true;
    });
    try {
      final request = await preparePreview();
      if (request == null) {
        return;
      }
      _lastPreviewSourceLabel = request.sourceLabel;
      final preview = await _buildPreview(request.entries);
      if (!mounted) {
        return;
      }
      setState(() {
        _isWorking = false;
      });
      await _openPreviewDialog(preview);
    } catch (error) {
      if (!mounted) {
        return;
      }
      showAppToast(
        context,
        mapError(error),
        tone: AppToastTone.error,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isWorking = false;
        });
      }
    }
  }

  Future<TmdbImportPreview> _buildPreview(List<TmdbImportEntry> entries) async {
    final type = _resolvedMovieType();
    return _service.previewImport(
      collection: _collection,
      entries: entries,
      searchCatalog: (entry) => searchLibraryMetadata(
        ref.read(apiClientProvider),
        type,
        query: entry.title,
        year: entry.releaseYear,
        limit: 10,
      ),
    );
  }

  Future<String> _importPreview(
    TmdbImportPreview preview, {
    required bool skipUnmatchedRows,
  }) async {
    setState(() {
      _isWorking = true;
    });
    var importedCount = 0;
    var proposedCount = 0;
    var keptLocalCount = 0;
    var skippedCount = 0;
    try {
      final type = _resolvedMovieType();
      final mutations = ref.read(collectionMutationsProvider);
      final unmatchedMatches = <TmdbImportMatch>[];
      for (final match in preview.matches) {
        final item = match.catalogItem;
        if (item != null) {
          final enrichedEntry = await _enrichMatchedEntry(match.entry);
          final mergedItem = _service.mergeMatchedCatalogItem(
            item,
            enrichedEntry,
          );
          if (_shouldUpdateCatalogSnapshot(item, mergedItem)) {
            await mutations.updateCatalogSnapshot(mergedItem, notify: false);
          }
          switch (preview.collection) {
            case TmdbImportCollection.ratedMovies:
              await mutations.upsertTrackingEntry(
                item.id,
                sourceType: TrackingSourceType.streaming,
                status: MediaTrackingStatus.completed,
                rating: _normalizedRating(match.entry.rating),
                timesCompleted: 1,
              );
              break;
            case TmdbImportCollection.watchlistMovies:
              await mutations.addToWishlist(item.id);
              break;
          }
          importedCount += 1;
          continue;
        }

        if (skipUnmatchedRows) {
          skippedCount += 1;
          continue;
        }
        unmatchedMatches.add(match);
      }
      final unmatchedResults = await _processUnmatchedMatches(
        matches: unmatchedMatches,
        type: type,
      );
      for (final result in unmatchedResults) {
        if (!result.proposalCreated) {
          skippedCount += 1;
          continue;
        }
        proposedCount += 1;
        if (!_keepUnmatchedLocally) {
          continue;
        }
        final enrichedEntry = result.entry;
        final localItem = _service.localSyntheticCatalogItem(enrichedEntry);
        switch (preview.collection) {
          case TmdbImportCollection.ratedMovies:
            await mutations.addLocalOnlyTrackingEntry(
              localItem,
              sourceType: TrackingSourceType.streaming,
              status: MediaTrackingStatus.completed,
              rating: _normalizedRating(enrichedEntry.rating),
              timesCompleted: 1,
            );
            break;
          case TmdbImportCollection.watchlistMovies:
            await mutations.addLocalOnlyWishlistItem(localItem);
            break;
        }
        await _pendingStore.upsert(
          TmdbPendingImportRecord(
            localItemId: localItem.id,
            entry: enrichedEntry,
            createdAt: DateTime.now().toUtc(),
            proposalServerId: result.proposalServerId,
          ),
        );
        keptLocalCount += 1;
      }
      await _refreshPendingLocalCount();
      widget.onStateChanged?.call();
      final resultMessage = _buildImportResultMessage(
        importedCount: importedCount,
        proposedCount: proposedCount,
        keptLocalCount: keptLocalCount,
        skippedCount: skippedCount,
      );
      await _recordImportHistory(
        status: ProviderImportHistoryStatus.success,
        preview: preview,
        message: resultMessage,
        importedCount: importedCount,
        proposedCount: proposedCount,
        keptLocalCount: keptLocalCount,
      );
      return resultMessage;
    } catch (error) {
      await _recordImportHistory(
        status: ProviderImportHistoryStatus.failed,
        preview: preview,
        message: 'TMDB import failed: $error',
        importedCount: importedCount,
        proposedCount: proposedCount,
        keptLocalCount: keptLocalCount,
      );
      if (!mounted) {
        rethrow;
      }
      rethrow;
    } finally {
      if (mounted) {
        setState(() {
          _isWorking = false;
        });
      }
    }
  }

  Future<List<_UnmatchedTmdbImportResult>> _processUnmatchedMatches({
    required List<TmdbImportMatch> matches,
    required LibraryTypeConfig type,
  }) async {
    if (matches.isEmpty) {
      return const <_UnmatchedTmdbImportResult>[];
    }
    final queue = List<TmdbImportMatch>.from(matches);
    final results = <_UnmatchedTmdbImportResult>[];
    Future<void> worker() async {
      while (queue.isNotEmpty) {
        final match = queue.removeLast();
        results.add(await _processUnmatchedMatch(match, type: type));
      }
    }

    await Future.wait([
      for (
        var index = 0;
        index < math.min(_unmatchedImportConcurrency, queue.length);
        index += 1
      )
        worker(),
    ]);
    return results;
  }

  Future<_UnmatchedTmdbImportResult> _processUnmatchedMatch(
    TmdbImportMatch match, {
    required LibraryTypeConfig type,
  }) async {
    final enrichedEntry = await _enrichMatchedEntry(match.entry);
    try {
      final response = await createAndRecordLibraryMetadataProposal(
        api: ref.read(apiClientProvider),
        type: type,
        provider: 'tmdb',
        providerItemId: enrichedEntry.tmdbId.toString(),
        query: enrichedEntry.query,
        title: enrichedEntry.title,
        summary: enrichedEntry.overview,
        imageUrl: enrichedEntry.posterUrl,
        metadataPayload: enrichedEntry.rawPayload,
        source: 'TMDB import',
      );
      return _UnmatchedTmdbImportResult(
        entry: enrichedEntry,
        proposalCreated: true,
        proposalServerId: response['id']?.toString(),
      );
    } catch (error, stackTrace) {
      logRecoverableError(
        source: 'tmdb_import',
        message: 'Failed to create metadata proposal for ${enrichedEntry.title}.',
        error: error,
        stackTrace: stackTrace,
      );
      return _UnmatchedTmdbImportResult(
        entry: enrichedEntry,
        proposalCreated: false,
      );
    }
  }

  Future<void> _openPreviewDialog(TmdbImportPreview preview) async {
    if (!mounted) {
      return;
    }
    final resultMessage = await showTmdbImportPreviewDialog(
      context: context,
      preview: preview,
      sourceLabel: _lastPreviewSourceLabel,
      keepUnmatchedLocally: _keepUnmatchedLocally,
      hasApiKey: _apiKeyController.text.trim().isNotEmpty,
      importButtonLabel: _importButtonLabel,
      onImport: ({required skipUnmatchedRows}) =>
          _importPreview(preview, skipUnmatchedRows: skipUnmatchedRows),
      mapImportError: _describeTmdbImportError,
    );
    if (!mounted || resultMessage == null) {
      return;
    }
    Navigator.of(context).pop();
    showAppToast(
      context,
      resultMessage,
      tone: AppToastTone.success,
    );
  }

  Future<void> _reconcilePendingImports() async {
    setState(() {
      _isWorking = true;
    });
    try {
      final records = await _pendingStore.read();
      final mutations = ref.read(collectionMutationsProvider);
      final type = _resolvedMovieType();
      final api = ref.read(apiClientProvider);
      final resolved = await Future.wait<
          ({TmdbPendingImportRecord record, CatalogItem? item})>(
        records.map((record) async {
          try {
            final preview = await _service.previewImport(
              collection: record.entry.collection,
              entries: [record.entry],
              searchCatalog: (entry) => searchLibraryMetadata(
                api,
                type,
                query: entry.title,
                year: entry.releaseYear,
                limit: 10,
              ),
            );
            return (record: record, item: preview.matches.single.catalogItem);
          } catch (error, stackTrace) {
            logRecoverableError(
              source: 'tmdb_import',
              message:
                  'Failed to search catalog for pending import ${record.entry.title}.',
              error: error,
              stackTrace: stackTrace,
            );
            return (record: record, item: null);
          }
        }),
      );
      var reconciled = 0;
      for (final result in resolved) {
        final item = result.item;
        if (item == null) {
          continue;
        }
        final enrichedEntry = await _enrichMatchedEntry(result.record.entry);
        final mergedItem = _service.mergeMatchedCatalogItem(item, enrichedEntry);
        if (_shouldUpdateCatalogSnapshot(item, mergedItem)) {
          await mutations.updateCatalogSnapshot(mergedItem, notify: false);
        }
        final promoted = await mutations.promoteLocalOnlyItemToCatalog(
          result.record.localItemId,
          mergedItem,
          notify: false,
        );
        if (promoted > 0) {
          await _pendingStore.remove(result.record.localItemId);
          reconciled += 1;
        }
      }
      await _refreshPendingLocalCount();
      widget.onStateChanged?.call();
      if (!mounted) {
        return;
      }
      showAppToast(
        context,
        reconciled == 0
            ? 'No pending TMDB imports could be reconciled yet.'
            : 'Reconciled $reconciled pending TMDB imports.',
        tone: reconciled == 0 ? AppToastTone.info : AppToastTone.success,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      showAppToast(
        context,
        _describeTmdbReconcileError(error),
        tone: AppToastTone.error,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isWorking = false;
        });
      }
    }
  }

  Future<void> _refreshPendingLocalCount() async {
    final records = await _pendingStore.read();
    if (!mounted) {
      return;
    }
    setState(() {
      _pendingLocalCount = records.length;
    });
  }

  LibraryTypeConfig _resolvedMovieType() {
    return ref.read(resolvedLibraryTypeProvider(moviesLibraryConfig));
  }

  int? _normalizedRating(num? value) {
    if (value == null) {
      return null;
    }
    final rounded = value.round();
    if (rounded < 1) {
      return 1;
    }
    if (rounded > 10) {
      return 10;
    }
    return rounded;
  }

  Future<TmdbImportEntry> _enrichMatchedEntry(TmdbImportEntry entry) async {
    final apiKey = _apiKeyController.text.trim();
    if (apiKey.isEmpty) {
      return entry;
    }
    try {
      return await _service.enrichEntry(apiKey: apiKey, entry: entry);
    } catch (error, stackTrace) {
      logRecoverableError(
        source: 'tmdb_import',
        message:
            'Failed to enrich TMDB entry ${entry.tmdbId}. Using export data only.',
        error: error,
        stackTrace: stackTrace,
      );
      return entry;
    }
  }

  bool _shouldUpdateCatalogSnapshot(CatalogItem current, CatalogItem next) {
    return current.displayTitle != next.displayTitle ||
        current.localizedTitle != next.localizedTitle ||
        current.originalTitle != next.originalTitle ||
        current.synopsis != next.synopsis ||
        current.coverImageUrl != next.coverImageUrl ||
        current.thumbnailImageUrl != next.thumbnailImageUrl ||
        current.publisher != next.publisher ||
        current.releaseDate != next.releaseDate ||
        current.releaseYear != next.releaseYear ||
        current.country != next.country ||
        current.language != next.language ||
        current.video?.runtimeMinutes != next.video?.runtimeMinutes ||
        current.displayCoverUrl != next.displayCoverUrl ||
        !_sameStringLists(current.genres, next.genres) ||
        !_sameStringLists(current.searchAliases, next.searchAliases);
  }

  bool _sameStringLists(List<String>? left, List<String>? right) {
    if (left == null || left.isEmpty) {
      return right == null || right.isEmpty;
    }
    if (right == null || left.length != right.length) {
      return false;
    }
    for (var index = 0; index < left.length; index += 1) {
      if (left[index] != right[index]) {
        return false;
      }
    }
    return true;
  }

  String _describeTmdbFetchError(Object error) {
    if (error case DioException dioError) {
      final statusCode = dioError.response?.statusCode;
      if (statusCode == 401) {
        return 'TMDB credentials were rejected. Check the API key, account ID, and session ID.';
      }
      if (statusCode != null) {
        return 'TMDB request failed with status $statusCode.';
      }
      if (dioError.type == DioExceptionType.connectionTimeout ||
          dioError.type == DioExceptionType.receiveTimeout ||
          dioError.type == DioExceptionType.sendTimeout) {
        return 'TMDB took too long to respond. Try again.';
      }
      return 'Couldn\'t reach TMDB right now. Try again.';
    }
    return 'TMDB import could not be loaded. ${_describeGenericError(error)}';
  }

  String _describeTmdbPayloadError(Object error) {
    return 'Couldn\'t read the pasted TMDB data. Use a TMDB JSON or CSV export. ${_describeGenericError(error)}';
  }

  String _describeTmdbFileError(Object error) {
    return 'Couldn\'t read that TMDB export file. Use a JSON, CSV, or ZIP export. ${_describeGenericError(error)}';
  }

  String _describeTmdbImportError(Object error) {
    if (error case DioException dioError) {
      final statusCode = dioError.response?.statusCode;
      if (statusCode == 401) {
        return 'The server rejected this import with status 401.';
      }
      if (statusCode != null) {
        return 'Import failed with status $statusCode.';
      }
    }
    return 'TMDB import failed. ${_describeGenericError(error)}';
  }

  String _describeTmdbReconcileError(Object error) {
    return 'Couldn\'t reconcile pending TMDB imports. ${_describeGenericError(error)}';
  }

  String _describeGenericError(Object error) {
    final text = error.toString().trim();
    if (text.startsWith('StateError: ')) {
      return text.substring('StateError: '.length);
    }
    if (text.startsWith('Exception: ')) {
      return text.substring('Exception: '.length);
    }
    if (text.startsWith('Invalid argument')) {
      return text;
    }
    return text;
  }

  String _buildImportResultMessage({
    required int importedCount,
    required int proposedCount,
    required int keptLocalCount,
    required int skippedCount,
  }) {
    if (keptLocalCount == 0 && proposedCount == 0 && skippedCount == 0) {
      return 'Imported $importedCount items.';
    }
    final parts = <String>['Imported $importedCount items.'];
    if (proposedCount > 0) {
      parts.add('Sent $proposedCount metadata proposals.');
    }
    if (keptLocalCount > 0) {
      parts.add('Kept $keptLocalCount unmatched locally.');
    }
    if (skippedCount > 0) {
      parts.add('Skipped $skippedCount unmatched rows.');
    }
    return parts.join(' ');
  }

  Future<void> _recordImportHistory({
    required ProviderImportHistoryStatus status,
    required TmdbImportPreview preview,
    required String message,
    int importedCount = 0,
    int proposedCount = 0,
    int keptLocalCount = 0,
  }) async {
    await _historyStore.append(
      ProviderImportHistoryEntry(
        id: DateTime.now().toUtc().microsecondsSinceEpoch.toString(),
        provider: ProviderImportId.tmdb,
        status: status,
        collectionLabel: preview.collection.label,
        sourceLabel: _lastPreviewSourceLabel,
        message: message,
        createdAt: DateTime.now().toUtc(),
        rows: preview.matches.length,
        matched: preview.matched.length,
        unmatched: preview.unmatched.length,
        imported: importedCount,
        proposed: proposedCount,
        keptLocal: keptLocalCount,
      ),
    );
    if (widget.onImportRecorded != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          widget.onImportRecorded?.call();
        }
      });
    }
  }
}

class _UnmatchedTmdbImportResult {
  const _UnmatchedTmdbImportResult({
    required this.entry,
    required this.proposalCreated,
    this.proposalServerId,
  });

  final TmdbImportEntry entry;
  final bool proposalCreated;
  final String? proposalServerId;
}

class _TmdbPreviewRequest {
  const _TmdbPreviewRequest({
    required this.sourceLabel,
    required this.entries,
  });

  final String sourceLabel;
  final List<TmdbImportEntry> entries;
}

class _ImportSectionCard extends StatelessWidget {
  const _ImportSectionCard({
    required this.title,
    required this.child,
    this.expandChild = false,
  });

  final String title;
  final Widget child;
  final bool expandChild;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: theme.textTheme.titleSmall),
            const SizedBox(height: 10),
            if (expandChild) Expanded(child: child) else child,
          ],
        ),
      ),
    );
  }
}
