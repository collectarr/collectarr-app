import 'dart:async';

import 'package:collectarr_app/core/models/tracking_source.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/kinds/movie/config.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_proposal.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_query.dart';
import 'package:collectarr_app/features/library/providers/media_catalog_provider.dart';
import 'package:collectarr_app/features/settings/tmdb_import_service.dart';
import 'package:collectarr_app/features/settings/tmdb_import_settings.dart';
import 'package:collectarr_app/features/settings/tmdb_pending_import_store.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TmdbImportDialog extends ConsumerStatefulWidget {
  const TmdbImportDialog({
    super.key,
    required this.initialSettings,
  });

  final TmdbImportSettings initialSettings;

  @override
  ConsumerState<TmdbImportDialog> createState() => _TmdbImportDialogState();
}

class _TmdbImportDialogState extends ConsumerState<TmdbImportDialog> {
  late final TextEditingController _apiKeyController;
  late final TextEditingController _accountIdController;
  late final TextEditingController _sessionIdController;
  final TextEditingController _payloadController = TextEditingController();
  final TmdbImportService _service = TmdbImportService();
  final TmdbPendingImportStore _pendingStore = const TmdbPendingImportStore();
  TmdbImportCollection _collection = TmdbImportCollection.ratedMovies;
  TmdbImportPreview? _preview;
  String? _statusMessage;
  String? _error;
  bool _isWorking = false;
  bool _keepUnmatchedLocally = false;
  int _pendingLocalCount = 0;

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
    return AlertDialog(
      title: const Text('TMDB import'),
      content: SizedBox(
        width: 760,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'TMDB personal imports need more than a plain API key. For direct account sync, provide your TMDB API key together with account id and session id. You can also paste TMDB JSON or CSV data from rated/watchlist exports or endpoint responses.',
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<TmdbImportCollection>(
                value: _collection,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'TMDB collection',
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
                          _preview = null;
                          _statusMessage = null;
                          _error = null;
                        });
                      },
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(
                    width: 220,
                    child: TextField(
                      controller: _apiKeyController,
                      maxLines: 1,
                      obscureText: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'TMDB API key',
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 160,
                    child: TextField(
                      controller: _accountIdController,
                      maxLines: 1,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Account id',
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 220,
                    child: TextField(
                      controller: _sessionIdController,
                      maxLines: 1,
                      obscureText: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Session id',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _PreviewCountChip(
                    label: 'Pending local',
                    value: _pendingLocalCount,
                  ),
                  OutlinedButton.icon(
                    onPressed: _isWorking ? null : _saveCredentials,
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Save credentials'),
                  ),
                  FilledButton.tonalIcon(
                    onPressed: _isWorking ? null : _loadFromTmdb,
                    icon: const Icon(Icons.cloud_download_outlined),
                    label: const Text('Load from TMDB'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _isWorking || _pendingLocalCount == 0
                        ? null
                        : _reconcilePendingImports,
                    icon: const Icon(Icons.link_outlined),
                    label: const Text('Reconcile pending local imports'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              CheckboxListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: _keepUnmatchedLocally,
                onChanged: _isWorking
                    ? null
                    : (value) {
                        setState(() {
                          _keepUnmatchedLocally = value ?? false;
                        });
                      },
                title: const Text('Keep unmatched items locally until Core ingest'),
                subtitle: const Text(
                  'These rows stay on this device only until they can be reconciled to a real Core item id. They are not pushed to personal sync before reconciliation.',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _payloadController,
                minLines: 8,
                maxLines: 12,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Paste TMDB JSON or CSV',
                  helperText:
                      'CSV headers supported: tmdb_id or id, title, release_date, rating, overview, poster_path or poster_url.',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: FilledButton.tonalIcon(
                  onPressed: _isWorking ? null : _previewPayload,
                  icon: const Icon(Icons.preview_outlined),
                  label: const Text('Preview pasted data'),
                ),
              ),
              if (_statusMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  _statusMessage!,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              if (_preview != null) ...[
                const SizedBox(height: 16),
                _TmdbImportPreviewPanel(
                  preview: _preview!,
                  keepUnmatchedLocally: _keepUnmatchedLocally,
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isWorking ? null : () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        FilledButton.icon(
          onPressed: _isWorking || _preview == null ? null : _importPreview,
          icon: const Icon(Icons.download_done_outlined),
          label: Text(_importButtonLabel),
        ),
      ],
    );
  }

  String get _importButtonLabel {
    return switch (_collection) {
      TmdbImportCollection.ratedMovies => 'Import as completed',
      TmdbImportCollection.watchlistMovies => 'Import as wishlist',
    };
  }

  Future<void> _saveCredentials() async {
    await ref.read(tmdbImportSettingsProvider.notifier).save(
          apiKey: _apiKeyController.text,
          accountId: _accountIdController.text,
          sessionId: _sessionIdController.text,
        );
    if (!mounted) {
      return;
    }
    setState(() {
      _statusMessage = 'TMDB credentials saved locally on this device.';
      _error = null;
    });
  }

  Future<void> _loadFromTmdb() async {
    final credentials = TmdbImportCredentials(
      apiKey: _apiKeyController.text,
      accountId: _accountIdController.text,
      sessionId: _sessionIdController.text,
    );
    setState(() {
      _isWorking = true;
      _error = null;
      _statusMessage = null;
      _preview = null;
    });
    try {
      final entries = await _service.fetchCollection(credentials, _collection);
      await _saveCredentials();
      final preview = await _buildPreview(entries);
      if (!mounted) {
        return;
      }
      setState(() {
        _preview = preview;
        _statusMessage =
            'Loaded ${entries.length} ${_collection.label.toLowerCase()} from TMDB.';
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = 'TMDB fetch failed: $error';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isWorking = false;
        });
      }
    }
  }

  Future<void> _previewPayload() async {
    final rawText = _payloadController.text.trim();
    if (rawText.isEmpty) {
      setState(() {
        _error = 'Paste a TMDB JSON payload before previewing.';
        _statusMessage = null;
      });
      return;
    }
    setState(() {
      _isWorking = true;
      _error = null;
      _statusMessage = null;
      _preview = null;
    });
    try {
      final entries = _service.parseCollectionPayload(
        rawText,
        collection: _collection,
      );
      final preview = await _buildPreview(entries);
      if (!mounted) {
        return;
      }
      setState(() {
        _preview = preview;
        _statusMessage =
            'Previewed ${entries.length} ${_collection.label.toLowerCase()} from pasted JSON.';
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = 'TMDB payload preview failed: $error';
      });
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

  Future<void> _importPreview() async {
    final preview = _preview;
    if (preview == null) {
      return;
    }
    setState(() {
      _isWorking = true;
      _error = null;
      _statusMessage = null;
    });
    try {
      final type = _resolvedMovieType();
      final mutations = ref.read(collectionMutationsProvider);
      var importedCount = 0;
      var proposedCount = 0;
      var keptLocalCount = 0;
      for (final match in preview.matches) {
        final item = match.catalogItem;
        if (item != null) {
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

        final response = await createAndRecordLibraryMetadataProposal(
          api: ref.read(apiClientProvider),
          type: type,
          provider: 'tmdb',
          providerItemId: match.entry.tmdbId.toString(),
          query: match.entry.query,
          title: match.entry.title,
          summary: match.entry.overview,
          imageUrl: match.entry.posterUrl,
          metadataPayload: match.entry.rawPayload,
          source: 'TMDB import',
        );
        proposedCount += 1;

        if (_keepUnmatchedLocally) {
          final localItem = _service.localSyntheticCatalogItem(match.entry);
          switch (preview.collection) {
            case TmdbImportCollection.ratedMovies:
              await mutations.addLocalOnlyTrackingEntry(
                localItem,
                sourceType: TrackingSourceType.streaming,
                status: MediaTrackingStatus.completed,
                rating: _normalizedRating(match.entry.rating),
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
              entry: match.entry,
              createdAt: DateTime.now().toUtc(),
              proposalServerId: response['id']?.toString(),
            ),
          );
          keptLocalCount += 1;
        }
      }
      await _refreshPendingLocalCount();
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            keptLocalCount == 0
                ? 'Imported $importedCount items and sent $proposedCount metadata proposals.'
                : 'Imported $importedCount items, kept $keptLocalCount unmatched items locally, and sent $proposedCount metadata proposals.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = 'TMDB import failed: $error';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isWorking = false;
        });
      }
    }
  }

  Future<void> _reconcilePendingImports() async {
    setState(() {
      _isWorking = true;
      _error = null;
      _statusMessage = null;
    });
    try {
      final records = await _pendingStore.read();
      final mutations = ref.read(collectionMutationsProvider);
      final type = _resolvedMovieType();
      var reconciled = 0;
      for (final record in records) {
        final preview = await _service.previewImport(
          collection: record.entry.collection,
          entries: [record.entry],
          searchCatalog: (entry) => searchLibraryMetadata(
            ref.read(apiClientProvider),
            type,
            query: entry.title,
            year: entry.releaseYear,
            limit: 10,
          ),
        );
        final match = preview.matches.single;
        final item = match.catalogItem;
        if (item == null) {
          continue;
        }
        final promoted = await mutations.promoteLocalOnlyItemToCatalog(
          record.localItemId,
          item,
          notify: false,
        );
        if (promoted > 0) {
          await _pendingStore.remove(record.localItemId);
          reconciled += 1;
        }
      }
      await _refreshPendingLocalCount();
      if (!mounted) {
        return;
      }
      setState(() {
        _statusMessage = reconciled == 0
            ? 'No pending local TMDB imports could be reconciled yet.'
            : 'Reconciled $reconciled pending local TMDB imports to Core items.';
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = 'TMDB reconciliation failed: $error';
      });
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
}

class _TmdbImportPreviewPanel extends StatelessWidget {
  const _TmdbImportPreviewPanel({
    required this.preview,
    required this.keepUnmatchedLocally,
  });

  final TmdbImportPreview preview;
  final bool keepUnmatchedLocally;

  @override
  Widget build(BuildContext context) {
    final matched = preview.matched;
    final unmatched = preview.unmatched;
    final visibleRows = preview.matches.take(12).toList(growable: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _PreviewCountChip(label: 'Rows', value: preview.matches.length),
            _PreviewCountChip(label: 'Matched', value: matched.length),
            _PreviewCountChip(label: 'Unmatched', value: unmatched.length),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          preview.collection == TmdbImportCollection.ratedMovies
              ? keepUnmatchedLocally
                  ? 'Matched rows will be imported as streaming entries with status Completed. Unmatched rows will be kept locally on this device and also sent as TMDB metadata proposals until they can be reconciled to a Core item.'
                  : 'Matched rows will be imported as streaming entries with status Completed. Unmatched rows stay proposal-only for now until Core ingest exists; no local synthetic catalog items are created.'
              : keepUnmatchedLocally
                  ? 'Matched rows will be added to wishlist. Unmatched rows will be kept locally on this device and also sent as TMDB metadata proposals until they can be reconciled to a Core item.'
                  : 'Matched rows will be added to wishlist. Unmatched rows stay proposal-only for now until Core ingest exists; no local synthetic catalog items are created.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: SizedBox(
            height: 260,
            child: ListView.separated(
              itemCount: visibleRows.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final match = visibleRows[index];
                final item = match.catalogItem;
                final subtitle = item == null
                    ? keepUnmatchedLocally
                        ? 'No confident Core match. A metadata proposal will be sent and the item will stay local-only until reconciliation succeeds.'
                        : 'No confident Core match. A metadata proposal will be sent.'
                    : '${item.title}${item.releaseYear == null ? '' : ' (${item.releaseYear})'}';
                return ListTile(
                  dense: true,
                  leading: Icon(
                    item == null
                        ? Icons.outbox_outlined
                        : Icons.check_circle_outline,
                  ),
                  title: Text(match.entry.title),
                  subtitle: Text(subtitle),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _PreviewCountChip extends StatelessWidget {
  const _PreviewCountChip({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text('$label: $value'));
  }
}
