import 'dart:math' as math;

import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/edit/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/metadata/metadata_diff_panel.dart';
import 'package:collectarr_app/features/library/models/library_kind_metadata_values.dart';
import 'package:collectarr_app/features/library/ui/library_dialog_scaffold.dart';
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
      final dto = await api.getTypedMetadataItem(
        kind: widget.localItem.kind,
        id: widget.localItem.id,
      );
      final item = CatalogItem.fromJson({
        ...dto.raw,
        'id': dto.id,
        'title': dto.title,
        'kind': dto.kind,
      });
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
    final payload = item.toSyncPayload();
    final details =
        (payload['character_details'] as List?)?.cast<Map<String, dynamic>>();
    if (details != null && details.isNotEmpty) {
      return details;
    }
    final chars =
        (payload['characters'] as List?)?.map((e) => e.toString()).toList();
    return [
      for (final name in chars ?? const <String>[])
        <String, dynamic>{
          'name': name,
        },
    ];
  }

  List<MetadataDiffEntry> _baseEntries(CatalogItem local, CatalogItem server) {
    final localP = local.toSyncPayload();
    final serverP = server.toSyncPayload();
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
        localValue: _text(localP['publisher']?.toString()),
        serverValue: _text(serverP['publisher']?.toString()),
      ),
      MetadataDiffEntry(
        label: 'Release date',
        localValue: _date(libraryKindReleaseDate(local)),
        serverValue: _date(libraryKindReleaseDate(server)),
      ),
      MetadataDiffEntry(
        label: 'Variant',
        localValue: _text(localP['variant']?.toString()),
        serverValue: _text(serverP['variant']?.toString()),
      ),
      MetadataDiffEntry(
        label: 'Edition title',
        localValue: _text(localP['edition_title']?.toString()),
        serverValue: _text(serverP['edition_title']?.toString()),
      ),
      MetadataDiffEntry(
        label: 'Barcode',
        localValue: _text(localP['barcode']?.toString()),
        serverValue: _text(serverP['barcode']?.toString()),
      ),
      MetadataDiffEntry(
        label: 'Country',
        localValue: _text(localP['country']?.toString()),
        serverValue: _text(serverP['country']?.toString()),
      ),
      MetadataDiffEntry(
        label: 'Language',
        localValue: _text(localP['language']?.toString()),
        serverValue: _text(serverP['language']?.toString()),
      ),
      MetadataDiffEntry(
        label: 'Genres',
        localValue: _list(
            (localP['genres'] as List?)?.map((e) => e.toString()).toList()),
        serverValue: _list(
            (serverP['genres'] as List?)?.map((e) => e.toString()).toList()),
      ),
      MetadataDiffEntry(
        label: 'Story arcs',
        localValue: _list(
            (localP['story_arcs'] as List?)?.map((e) => e.toString()).toList()),
        serverValue: _list((serverP['story_arcs'] as List?)
            ?.map((e) => e.toString())
            .toList()),
      ),
    ];
  }

  List<MetadataDiffEntry> _comicEntries(CatalogItem local, CatalogItem server) {
    final localP = local.toSyncPayload();
    final serverP = server.toSyncPayload();
    final localSeries = (localP['series'] as Map?) ?? localP;
    final serverSeries = (serverP['series'] as Map?) ?? serverP;
    final localPub = (localP['publishing'] as Map?) ?? localP;
    final serverPub = (serverP['publishing'] as Map?) ?? serverP;
    return [
      ..._baseEntries(local, server),
      MetadataDiffEntry(
        label: 'Series',
        localValue: _text(
            (localSeries['series_title'] ?? localSeries['seriesTitle'])
                ?.toString()),
        serverValue: _text(
            (serverSeries['series_title'] ?? serverSeries['seriesTitle'])
                ?.toString()),
      ),
      MetadataDiffEntry(
        label: 'Issue number',
        localValue:
            _text((localP['item_number'] ?? localP['itemNumber'])?.toString()),
        serverValue: _text(
            (serverP['item_number'] ?? serverP['itemNumber'])?.toString()),
      ),
      MetadataDiffEntry(
        label: 'Cover date',
        localValue: _date(localP['cover_date'] != null
            ? DateTime.tryParse(localP['cover_date'].toString())
            : null),
        serverValue: _date(serverP['cover_date'] != null
            ? DateTime.tryParse(serverP['cover_date'].toString())
            : null),
      ),
      MetadataDiffEntry(
        label: 'Imprint',
        localValue: _text(localPub['imprint']?.toString()),
        serverValue: _text(serverPub['imprint']?.toString()),
      ),
      MetadataDiffEntry(
        label: 'Page count',
        localValue: _text(localPub['page_count']?.toString()),
        serverValue: _text(serverPub['page_count']?.toString()),
      ),
      MetadataDiffEntry(
        label: 'Plot summary',
        localValue: _text(localP['plot_summary']?.toString()),
        serverValue: _text(serverP['plot_summary']?.toString()),
      ),
    ];
  }

  List<MetadataDiffEntry> _musicEntries(CatalogItem local, CatalogItem server) {
    final localP = local.toSyncPayload();
    final serverP = server.toSyncPayload();
    final localSeries = (localP['series'] as Map?) ?? localP;
    final serverSeries = (serverP['series'] as Map?) ?? serverP;
    final localPub = (localP['publishing'] as Map?) ?? localP;
    final serverPub = (serverP['publishing'] as Map?) ?? serverP;
    final localMusic = (localP['music'] as Map?) ?? localP;
    final serverMusic = (serverP['music'] as Map?) ?? serverP;
    return [
      ..._baseEntries(local, server),
      MetadataDiffEntry(
        label: 'Artist',
        localValue: _text(
            (localSeries['series_title'] ?? localSeries['seriesTitle'])
                ?.toString()),
        serverValue: _text(
            (serverSeries['series_title'] ?? serverSeries['seriesTitle'])
                ?.toString()),
      ),
      MetadataDiffEntry(
        label: 'Subtitle',
        localValue: _text(localPub['subtitle']?.toString()),
        serverValue: _text(serverPub['subtitle']?.toString()),
      ),
      MetadataDiffEntry(
        label: 'Catalog number',
        localValue: _text(localMusic['catalog_number']?.toString()),
        serverValue: _text(serverMusic['catalog_number']?.toString()),
      ),
      MetadataDiffEntry(
        label: 'Release status',
        localValue: _text(localMusic['release_status']?.toString()),
        serverValue: _text(serverMusic['release_status']?.toString()),
      ),
      MetadataDiffEntry(
        label: 'Original release date',
        localValue: _date(localMusic['original_release_date'] != null
            ? DateTime.tryParse(localMusic['original_release_date'].toString())
            : null),
        serverValue: _date(serverMusic['original_release_date'] != null
            ? DateTime.tryParse(serverMusic['original_release_date'].toString())
            : null),
      ),
      MetadataDiffEntry(
        label: 'Recording date',
        localValue: _date(localMusic['recording_date'] != null
            ? DateTime.tryParse(localMusic['recording_date'].toString())
            : null),
        serverValue: _date(serverMusic['recording_date'] != null
            ? DateTime.tryParse(serverMusic['recording_date'].toString())
            : null),
      ),
      MetadataDiffEntry(
        label: 'RPM',
        localValue: _text(localMusic['rpm']?.toString()),
        serverValue: _text(serverMusic['rpm']?.toString()),
      ),
      MetadataDiffEntry(
        label: 'SPARS',
        localValue: _text(localMusic['spars']?.toString()),
        serverValue: _text(serverMusic['spars']?.toString()),
      ),
      MetadataDiffEntry(
        label: 'Sound',
        localValue: _text(localMusic['sound_type']?.toString()),
        serverValue: _text(serverMusic['sound_type']?.toString()),
      ),
      MetadataDiffEntry(
        label: 'Vinyl color',
        localValue: _text(localMusic['vinyl_color']?.toString()),
        serverValue: _text(serverMusic['vinyl_color']?.toString()),
      ),
      MetadataDiffEntry(
        label: 'Vinyl weight',
        localValue: _text(localMusic['vinyl_weight']?.toString()),
        serverValue: _text(serverMusic['vinyl_weight']?.toString()),
      ),
      MetadataDiffEntry(
        label: 'Media condition',
        localValue: _text(localMusic['media_condition']?.toString()),
        serverValue: _text(serverMusic['media_condition']?.toString()),
      ),
      MetadataDiffEntry(
        label: 'Composition',
        localValue: _text(localMusic['composition']?.toString()),
        serverValue: _text(serverMusic['composition']?.toString()),
      ),
      MetadataDiffEntry(
        label: 'Instrument',
        localValue: _text(localMusic['instrument']?.toString()),
        serverValue: _text(serverMusic['instrument']?.toString()),
      ),
      MetadataDiffEntry(
        label: 'Live recording',
        localValue: (localMusic['is_live'] == true) ? 'Yes' : 'No',
        serverValue: (serverMusic['is_live'] == true) ? 'Yes' : 'No',
      ),
    ];
  }

  List<MetadataDiffEntry> _creatorsEntries(
      CatalogItem local, CatalogItem server) {
    final localP = local.toSyncPayload();
    final serverP = server.toSyncPayload();
    final localCreators =
        (localP['creators'] as List?)?.cast<Map<String, dynamic>>() ??
            const <Map<String, dynamic>>[];
    final serverCreators =
        (serverP['creators'] as List?)?.cast<Map<String, dynamic>>() ??
            const <Map<String, dynamic>>[];
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
    final localP = local.toSyncPayload();
    final serverP = server.toSyncPayload();
    final localMusic = (localP['music'] as Map?) ?? localP;
    final serverMusic = (serverP['music'] as Map?) ?? serverP;
    final localRawDiscs = (localMusic['discs'] as List?) ?? const [];
    final serverRawDiscs = (serverMusic['discs'] as List?) ?? const [];
    final localDiscs = {
      for (final raw in localRawDiscs)
        if (raw is CatalogDisc)
          raw.discNumber: raw
        else if (raw is Map)
          (raw['disc_number'] as int? ?? 0):
              CatalogDisc.fromJson(Map<String, dynamic>.from(raw))
    };
    final serverDiscs = {
      for (final raw in serverRawDiscs)
        if (raw is CatalogDisc)
          raw.discNumber: raw
        else if (raw is Map)
          (raw['disc_number'] as int? ?? 0):
              CatalogDisc.fromJson(Map<String, dynamic>.from(raw))
    };
    final all = <int>{
      ...localDiscs.keys.whereType<int>(),
      ...serverDiscs.keys.whereType<int>(),
    }.toList()
      ..sort();
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
    return LibraryDialogScaffold(
      title: Row(
        children: [
          const Icon(Icons.compare_arrows, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Metadata Compare — ${local.title}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      onClose: () => Navigator.of(context).pop(),
      maxWidth: 1200,
      maxHeight: 820,
      padding: EdgeInsets.zero,
      body: _isLoading
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
                              title: 'Metadata fields (Local vs Server)',
                              entries: local.kind == 'music'
                                  ? _musicEntries(local, server)
                                  : _comicEntries(local, server),
                              showOnlyDifferences: false,
                              emptyText: 'No metadata fields available.',
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
                                entries: _charactersEntries(local, server),
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
    );
  }
}
