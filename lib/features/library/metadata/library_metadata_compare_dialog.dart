import 'dart:math' as math;

import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/api/mappers/catalog_typed_mapper.dart';
import 'package:collectarr_app/features/library/edit/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/metadata/metadata_diff_panel.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> showLibraryMetadataCompareDialog({
  required BuildContext context,
  required CatalogItem localItem,
  required Color accent,
}) async {
  await showDialog<void>(
    context: context,
    builder: (_) => _LibraryMetadataCompareDialog(
      localItem: localItem,
      accent: accent,
    ),
  );
}

class _LibraryMetadataCompareDialog extends ConsumerStatefulWidget {
  const _LibraryMetadataCompareDialog({
    required this.localItem,
    required this.accent,
  });

  final CatalogItem localItem;
  final Color accent;

  @override
  ConsumerState<_LibraryMetadataCompareDialog> createState() =>
      _LibraryMetadataCompareDialogState();
}

class _LibraryMetadataCompareDialogState
    extends ConsumerState<_LibraryMetadataCompareDialog> {
  bool _isLoading = false;
  String? _error;
  CatalogItem? _serverItem;

  @override
  void initState() {
    super.initState();
    _loadServerItem();
  }

  Future<void> _loadServerItem() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final api = ref.read(apiClientProvider);
      final item = await api
          .getTypedMetadataItemDto(
            kind: widget.localItem.kind,
            id: widget.localItem.id,
          )
          .then(catalogItemFromTypedDto);
      if (!mounted) {
        return;
      }
      setState(() {
        _serverItem = item;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = _errorText(error);
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _errorText(Object error) {
    if (error is DioException) {
      final statusCode = error.response?.statusCode;
      if (statusCode == 404) {
        return 'This item no longer exists on server metadata.';
      }
      if (statusCode == 422) {
        return 'Server rejected this compare request (422). '
            'This item likely has an unsupported metadata id format.';
      }
      final body = error.response?.data;
      if (body is Map<String, dynamic>) {
        final detail = body['detail']?.toString().trim();
        if (detail != null && detail.isNotEmpty) {
          return 'Could not load server metadata: $detail';
        }
      }
      if (statusCode != null) {
        return 'Could not load server metadata (HTTP $statusCode).';
      }
    }
    return 'Could not load server metadata snapshot.';
  }

  String _text(String? value) {
    final normalized = value?.trim() ?? '';
    return normalized.isEmpty ? '—' : normalized;
  }

  String _date(DateTime? value) => value == null ? '—' : formatDate(value);

  String _list(Iterable<String>? values) {
    if (values == null) {
      return '—';
    }
    final normalized = values
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList(growable: false);
    return normalized.isEmpty ? '—' : normalized.join(', ');
  }

  String _creatorText(Map<String, dynamic>? value) {
    if (value == null) {
      return '—';
    }
    final role = value['role']?.toString().trim();
    final name = value['name']?.toString().trim();
    if (name == null || name.isEmpty) {
      return _text(role);
    }
    if (role == null || role.isEmpty) {
      return name;
    }
    return '$role - $name';
  }

  String _characterText(Map<String, dynamic>? value) {
    if (value == null) {
      return '—';
    }
    final name = value['name']?.toString().trim();
    final realName = value['real_name']?.toString().trim();
    if (name == null || name.isEmpty) {
      return _text(realName);
    }
    if (realName == null || realName.isEmpty) {
      return name;
    }
    return '$name ($realName)';
  }

  String _discText(CatalogDisc? value) {
    if (value == null) {
      return '—';
    }
    final lines = <String>[
      if ((value.discName ?? '').trim().isNotEmpty) 'Title: ${value.discName}',
      if ((value.storageDevice ?? '').trim().isNotEmpty)
        'Storage: ${value.storageDevice}',
      if ((value.slot ?? '').trim().isNotEmpty) 'Slot: ${value.slot}',
      if ((value.matrixSideA ?? '').trim().isNotEmpty)
        'Matrix A: ${value.matrixSideA}',
      if ((value.matrixSideB ?? '').trim().isNotEmpty)
        'Matrix B: ${value.matrixSideB}',
    ];
    return lines.isEmpty ? 'Disc #${value.discNumber}' : lines.join('\n');
  }

  List<Map<String, dynamic>> _characterList(CatalogItem item) {
    final details = item.characterDetails;
    if (details != null && details.isNotEmpty) {
      return details;
    }
    return [
      for (final name in item.characters ?? const <String>[])
        <String, dynamic>{
          'name': name,
        },
    ];
  }

  List<MetadataDiffEntry> _baseEntries(CatalogItem local, CatalogItem server) {
    return [
      MetadataDiffEntry(
        label: 'Title',
        localValue: _text(local.title),
        serverValue: _text(server.title),
      ),
      MetadataDiffEntry(
        label: 'Sort key',
        localValue: _text(local.sortKey),
        serverValue: _text(server.sortKey),
      ),
      MetadataDiffEntry(
        label: 'Publisher',
        localValue: _text(local.publisher),
        serverValue: _text(server.publisher),
      ),
      MetadataDiffEntry(
        label: 'Release date',
        localValue: _date(local.releaseDate),
        serverValue: _date(server.releaseDate),
      ),
      MetadataDiffEntry(
        label: 'Variant',
        localValue: _text(local.variant),
        serverValue: _text(server.variant),
      ),
      MetadataDiffEntry(
        label: 'Edition title',
        localValue: _text(local.editionTitle),
        serverValue: _text(server.editionTitle),
      ),
      MetadataDiffEntry(
        label: 'Barcode',
        localValue: _text(local.barcode),
        serverValue: _text(server.barcode),
      ),
      MetadataDiffEntry(
        label: 'Country',
        localValue: _text(local.country),
        serverValue: _text(server.country),
      ),
      MetadataDiffEntry(
        label: 'Language',
        localValue: _text(local.language),
        serverValue: _text(server.language),
      ),
      MetadataDiffEntry(
        label: 'Genres',
        localValue: _list(local.genres),
        serverValue: _list(server.genres),
      ),
      MetadataDiffEntry(
        label: 'Story arcs',
        localValue: _list(local.storyArcs),
        serverValue: _list(server.storyArcs),
      ),
    ];
  }

  List<MetadataDiffEntry> _comicEntries(CatalogItem local, CatalogItem server) {
    return [
      ..._baseEntries(local, server),
      MetadataDiffEntry(
        label: 'Series',
        localValue: _text(local.series?.seriesTitle),
        serverValue: _text(server.series?.seriesTitle),
      ),
      MetadataDiffEntry(
        label: 'Issue number',
        localValue: _text(local.itemNumber),
        serverValue: _text(server.itemNumber),
      ),
      MetadataDiffEntry(
        label: 'Cover date',
        localValue: _date(local.coverDate),
        serverValue: _date(server.coverDate),
      ),
      MetadataDiffEntry(
        label: 'Imprint',
        localValue: _text(local.publishing?.imprint),
        serverValue: _text(server.publishing?.imprint),
      ),
      MetadataDiffEntry(
        label: 'Page count',
        localValue: _text(local.publishing?.pageCount?.toString()),
        serverValue: _text(server.publishing?.pageCount?.toString()),
      ),
      MetadataDiffEntry(
        label: 'Plot summary',
        localValue: _text(local.plotSummary),
        serverValue: _text(server.plotSummary),
      ),
    ];
  }

  List<MetadataDiffEntry> _musicEntries(CatalogItem local, CatalogItem server) {
    return [
      ..._baseEntries(local, server),
      MetadataDiffEntry(
        label: 'Artist',
        localValue: _text(local.series?.seriesTitle),
        serverValue: _text(server.series?.seriesTitle),
      ),
      MetadataDiffEntry(
        label: 'Subtitle',
        localValue: _text(local.publishing?.subtitle),
        serverValue: _text(server.publishing?.subtitle),
      ),
      MetadataDiffEntry(
        label: 'Catalog number',
        localValue: _text(local.music?.catalogNumber),
        serverValue: _text(server.music?.catalogNumber),
      ),
      MetadataDiffEntry(
        label: 'Release status',
        localValue: _text(local.music?.releaseStatus),
        serverValue: _text(server.music?.releaseStatus),
      ),
      MetadataDiffEntry(
        label: 'Original release date',
        localValue: _date(local.music?.originalReleaseDate),
        serverValue: _date(server.music?.originalReleaseDate),
      ),
      MetadataDiffEntry(
        label: 'Recording date',
        localValue: _date(local.music?.recordingDate),
        serverValue: _date(server.music?.recordingDate),
      ),
      MetadataDiffEntry(
        label: 'RPM',
        localValue: _text(local.music?.rpm),
        serverValue: _text(server.music?.rpm),
      ),
      MetadataDiffEntry(
        label: 'SPARS',
        localValue: _text(local.music?.spars),
        serverValue: _text(server.music?.spars),
      ),
      MetadataDiffEntry(
        label: 'Sound',
        localValue: _text(local.music?.soundType),
        serverValue: _text(server.music?.soundType),
      ),
      MetadataDiffEntry(
        label: 'Vinyl color',
        localValue: _text(local.music?.vinylColor),
        serverValue: _text(server.music?.vinylColor),
      ),
      MetadataDiffEntry(
        label: 'Vinyl weight',
        localValue: _text(local.music?.vinylWeight),
        serverValue: _text(server.music?.vinylWeight),
      ),
      MetadataDiffEntry(
        label: 'Media condition',
        localValue: _text(local.music?.mediaCondition),
        serverValue: _text(server.music?.mediaCondition),
      ),
      MetadataDiffEntry(
        label: 'Composition',
        localValue: _text(local.music?.composition),
        serverValue: _text(server.music?.composition),
      ),
      MetadataDiffEntry(
        label: 'Instrument',
        localValue: _text(local.music?.instrument),
        serverValue: _text(server.music?.instrument),
      ),
      MetadataDiffEntry(
        label: 'Live recording',
        localValue: (local.music?.isLive ?? false) ? 'Yes' : 'No',
        serverValue: (server.music?.isLive ?? false) ? 'Yes' : 'No',
      ),
    ];
  }

  List<MetadataDiffEntry> _creatorsEntries(
      CatalogItem local, CatalogItem server) {
    final localCreators = local.creators ?? const <Map<String, dynamic>>[];
    final serverCreators = server.creators ?? const <Map<String, dynamic>>[];
    final count = math.max(localCreators.length, serverCreators.length);
    return [
      for (var i = 0; i < count; i++)
        MetadataDiffEntry(
          label: 'Creator #${i + 1}',
          localValue:
              _creatorText(i < localCreators.length ? localCreators[i] : null),
          serverValue: _creatorText(
              i < serverCreators.length ? serverCreators[i] : null),
        ),
    ];
  }

  List<MetadataDiffEntry> _charactersEntries(
    CatalogItem local,
    CatalogItem server,
  ) {
    final localCharacters = _characterList(local);
    final serverCharacters = _characterList(server);
    final count = math.max(localCharacters.length, serverCharacters.length);
    return [
      for (var i = 0; i < count; i++)
        MetadataDiffEntry(
          label: 'Character #${i + 1}',
          localValue: _characterText(
            i < localCharacters.length ? localCharacters[i] : null,
          ),
          serverValue: _characterText(
            i < serverCharacters.length ? serverCharacters[i] : null,
          ),
        ),
    ];
  }

  List<MetadataDiffEntry> _discEntries(CatalogItem local, CatalogItem server) {
    final localDiscs = {
      for (final disc in local.music?.discs ?? const <CatalogDisc>[])
        disc.discNumber: disc
    };
    final serverDiscs = {
      for (final disc in server.music?.discs ?? const <CatalogDisc>[])
        disc.discNumber: disc
    };
    final all = <int>{...localDiscs.keys, ...serverDiscs.keys}.toList()..sort();
    return [
      for (final discNumber in all)
        MetadataDiffEntry(
          label: 'Disc #$discNumber',
          localValue: _discText(localDiscs[discNumber]),
          serverValue: _discText(serverDiscs[discNumber]),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final local = widget.localItem;
    final server = _serverItem;
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200, maxHeight: 820),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
              decoration: BoxDecoration(
                color: kEditPanelRaised,
                border: Border(
                    bottom: BorderSide(
                        color: widget.accent.withValues(alpha: 0.25))),
              ),
              child: Row(
                children: [
                  Icon(Icons.compare_arrows, color: widget.accent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Metadata Compare — ${local.title}',
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              _error!,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: Colors.redAccent),
                            ),
                          ),
                        )
                      : server == null
                          ? const SizedBox.shrink()
                          : Scrollbar(
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  children: [
                                    MetadataDiffPanel(
                                      title:
                                          'Metadata fields (Local vs Server)',
                                      entries: local.kind == 'music'
                                          ? _musicEntries(local, server)
                                          : _comicEntries(local, server),
                                      showOnlyDifferences: false,
                                      emptyText:
                                          'No metadata fields available.',
                                    ),
                                    MetadataDiffPanel(
                                      title: 'Creators (Local vs Server)',
                                      entries: _creatorsEntries(local, server),
                                      showOnlyDifferences: false,
                                      emptyText: 'No creators available.',
                                    ),
                                    if (local.kind == 'comic')
                                      MetadataDiffPanel(
                                        title: 'Characters (Local vs Server)',
                                        entries:
                                            _charactersEntries(local, server),
                                        showOnlyDifferences: false,
                                        emptyText: 'No characters available.',
                                      ),
                                    if (local.kind == 'music')
                                      MetadataDiffPanel(
                                        title: 'Discs (Local vs Server)',
                                        entries: _discEntries(local, server),
                                        showOnlyDifferences: false,
                                        emptyText: 'No discs available.',
                                      ),
                                  ],
                                ),
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }
}
