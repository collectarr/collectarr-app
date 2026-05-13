import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/catalog/catalog_cache_repository.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/comics/comics_library_config.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_query.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void showComicsMissingIssuesDialog(
  BuildContext context, {
  required String? selectedSeries,
  required List<int> missingIssues,
}) {
  showDialog<void>(
    context: context,
    builder: (context) => _MissingIssuesDialog(
      selectedSeries: selectedSeries,
      missingIssues: missingIssues,
    ),
  );
}

class _MissingIssuesDialog extends ConsumerStatefulWidget {
  const _MissingIssuesDialog({
    required this.selectedSeries,
    required this.missingIssues,
  });

  final String? selectedSeries;
  final List<int> missingIssues;

  @override
  ConsumerState<_MissingIssuesDialog> createState() =>
      _MissingIssuesDialogState();
}

class _MissingIssuesDialogState extends ConsumerState<_MissingIssuesDialog> {
  final _matches = <int, CatalogItem>{};
  final _searched = <int>{};
  final _working = <int>{};
  String? _error;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.selectedSeries == null
            ? 'Missing issues'
            : 'Missing issues: ${widget.selectedSeries}',
      ),
      content: SizedBox(
        width: 680,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_error != null) ...[
              Text(_error!, style: TextStyle(color: Colors.red.shade300)),
              const SizedBox(height: 8),
            ],
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: widget.missingIssues.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final issue = widget.missingIssues[index];
                  final match = _matches[issue];
                  final busy = _working.contains(issue);
                  return ListTile(
                    dense: true,
                    title: Text('#$issue'),
                    subtitle: Text(
                      match == null
                          ? _searched.contains(issue)
                              ? 'No Collectarr Core match yet'
                              : 'Search Core or propose metadata'
                          : _catalogItemTitle(match),
                    ),
                    trailing: Wrap(
                      spacing: 6,
                      children: [
                        OutlinedButton.icon(
                          onPressed: busy ? null : () => _searchIssue(issue),
                          icon: busy
                              ? const SizedBox.square(
                                  dimension: 16,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.manage_search, size: 18),
                          label: const Text('Search Core'),
                        ),
                        FilledButton.tonalIcon(
                          onPressed: match == null || busy
                              ? null
                              : () => _addMatchToWishlist(issue, match),
                          icon:
                              const Icon(Icons.bookmark_add_outlined, size: 18),
                          label: const Text('Wishlist'),
                        ),
                        OutlinedButton.icon(
                          onPressed:
                              busy ? null : () => _proposeMissingIssue(issue),
                          icon: const Icon(Icons.outbox, size: 18),
                          label: const Text('Propose'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Done'),
        ),
      ],
    );
  }

  Future<void> _searchIssue(int issue) async {
    final series = widget.selectedSeries;
    if (series == null) {
      return;
    }
    setState(() {
      _working.add(issue);
      _error = null;
    });
    try {
      final rows = await ref.read(apiClientProvider).searchMetadata(
            libraryMetadataSearchQuery(
              comicsLibraryConfig,
              query: series,
              issueNumber: issue.toString(),
              limit: 10,
            ),
          );
      final items = rows.map(CatalogItem.fromJson).toList(growable: false);
      if (items.isNotEmpty) {
        await CatalogCacheRepository(ref.read(localDatabaseProvider))
            .upsertAll(items);
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _searched.add(issue);
        if (items.isNotEmpty) {
          _matches[issue] = items.first;
        }
      });
    } catch (error) {
      if (mounted) {
        setState(() => _error = 'Missing issue search failed: $error');
      }
    } finally {
      if (mounted) {
        setState(() => _working.remove(issue));
      }
    }
  }

  Future<void> _addMatchToWishlist(int issue, CatalogItem item) async {
    setState(() {
      _working.add(issue);
      _error = null;
    });
    try {
      await ref.read(collectionMutationsProvider).addToWishlist(item.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added ${_catalogItemTitle(item)} to wishlist'),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        setState(() => _error = 'Wishlist add failed: $error');
      }
    } finally {
      if (mounted) {
        setState(() => _working.remove(issue));
      }
    }
  }

  Future<void> _proposeMissingIssue(int issue) async {
    final series = widget.selectedSeries;
    if (series == null) {
      return;
    }
    setState(() {
      _working.add(issue);
      _error = null;
    });
    try {
      await ref.read(apiClientProvider).createMetadataProposal(
            provider: comicsLibraryConfig.defaultMetadataProvider,
            query: '$series #$issue',
            title: series,
            summary: [
              'Metadata proposal from missing issues workflow',
              '',
              'series: $series',
              'issue: $issue',
            ].join('\n'),
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Proposal sent for $series #$issue')),
        );
      }
    } catch (error) {
      if (mounted) {
        setState(() => _error = 'Metadata proposal failed: $error');
      }
    } finally {
      if (mounted) {
        setState(() => _working.remove(issue));
      }
    }
  }
}

String _catalogItemTitle(CatalogItem item) {
  final issue = item.itemNumber;
  if (issue == null || issue.isEmpty) {
    return item.title;
  }
  return '${item.title} #$issue';
}
