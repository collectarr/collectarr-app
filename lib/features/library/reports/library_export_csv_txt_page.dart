import 'dart:convert';
import 'dart:io';

import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/config/library_kind_style.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_track.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_data.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_dto.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/ui/library_accent_scope.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum ExportSubset { all, currentList, checkboxed }

enum ExportMode { albumList, trackList }

enum ExportFileType { csv, txt }

enum FieldDelimiter {
  semicolon('Semicolon', ';'),
  comma('Comma', ','),
  tab('Tab', '\t'),
  space('Space', ' ');

  const FieldDelimiter(this.label, this.char);
  final String label;
  final String char;
}

enum FieldEnclosure {
  doubleQuote('Double Quote', '"'),
  singleQuote('Single Quote', "'"),
  none('None', '');

  const FieldEnclosure(this.label, this.char);
  final String label;
  final String char;
}

class ExportColumnDefinition {
  const ExportColumnDefinition({
    required this.id,
    required this.label,
    required this.getValue,
    this.defaultVisible = true,
  });

  final String id;
  final String label;
  final String Function(LibraryProjectionView item) getValue;
  final bool defaultVisible;
}

class ExportTrackColumnDefinition {
  const ExportTrackColumnDefinition({
    required this.id,
    required this.label,
    required this.getValue,
    this.defaultVisible = true,
  });

  final String id;
  final String label;
  final String Function(MusicTrack track, MusicAlbum album) getValue;
  final bool defaultVisible;
}

/// Full-page Export to CSV / TXT view matching the CLZ Web layout 1:1.
class LibraryExportCsvTxtPage extends StatefulWidget {
  const LibraryExportCsvTxtPage({
    super.key,
    required this.type,
    required this.items,
    this.allItems,
    this.selectedItemIds,
    this.allShelfEntries,
    this.initialTitle,
  });

  final LibraryKindRegistration type;
  final List<LibraryProjectionView> items;
  final List<LibraryProjectionView>? allItems;
  final Set<String>? selectedItemIds;
  final List<LibraryWorkspaceContext>? allShelfEntries;
  final String? initialTitle;

  @override
  State<LibraryExportCsvTxtPage> createState() =>
      _LibraryExportCsvTxtPageState();
}

class _LibraryExportCsvTxtPageState extends State<LibraryExportCsvTxtPage> {
  ExportSubset _subset = ExportSubset.all;
  ExportMode _exportMode = ExportMode.albumList;
  ExportFileType _fileType = ExportFileType.csv;
  FieldDelimiter _delimiter = FieldDelimiter.comma;
  FieldEnclosure _enclosure = FieldEnclosure.doubleQuote;
  bool _includeHeaderRow = true;

  late final TextEditingController _filenameController;

  late List<ExportColumnDefinition> _availableAlbumColumns;
  late List<String> _selectedAlbumColumnIds;

  late List<ExportTrackColumnDefinition> _availableTrackColumns;
  late List<String> _selectedTrackColumnIds;

  String _sortColumnId = 'artist';
  bool _sortAscending = true;

  bool _isGenerating = false;
  String? _generatedContent;
  String? _generatedFileSize;

  bool get _isMusic => widget.type.kind == CatalogMediaKind.music;

  @override
  void initState() {
    super.initState();
    if (widget.selectedItemIds != null &&
        widget.selectedItemIds!.isNotEmpty) {
      _subset = ExportSubset.checkboxed;
    }
    _filenameController = TextEditingController(
      text: _isMusic ? 'export_albums' : 'export_${widget.type.identity.pluralLabel.toLowerCase()}',
    );
    _initColumns();
  }

  @override
  void dispose() {
    _filenameController.dispose();
    super.dispose();
  }

  void _initColumns() {
    if (_isMusic) {
      _availableAlbumColumns = [
        ExportColumnDefinition(
          id: 'artist',
          label: 'Artist',
          getValue: (item) =>
              _musicAlbum(item)?.artist ?? item.dto.secondaryLabel ?? '',
        ),
        ExportColumnDefinition(
          id: 'artist_sort',
          label: 'Artist Sort',
          getValue: (item) =>
              _musicAlbum(item)?.artist ?? item.dto.secondaryLabel ?? '',
        ),
        ExportColumnDefinition(
          id: 'title',
          label: 'Title',
          getValue: (item) => item.dto.primaryLabel,
        ),
        ExportColumnDefinition(
          id: 'format',
          label: 'Format',
          getValue: (item) => _musicAlbum(item)?.formatSummary ?? '',
        ),
        ExportColumnDefinition(
          id: 'barcode',
          label: 'Barcode',
          getValue: (item) => _musicAlbum(item)?.barcode ?? '',
          defaultVisible: false,
        ),
        ExportColumnDefinition(
          id: 'cat_no',
          label: 'Cat No',
          getValue: (item) => _musicAlbum(item)?.catalogNumber ?? '',
          defaultVisible: false,
        ),
        ExportColumnDefinition(
          id: 'release_date',
          label: 'Release Date',
          getValue: (item) {
            final d = _musicAlbum(item)?.releaseDate;
            if (d == null) return '';
            return d.year.toString();
          },
        ),
        ExportColumnDefinition(
          id: 'orig_year',
          label: 'Original Year',
          getValue: (item) =>
              _musicAlbum(item)?.originalReleaseDate?.year.toString() ?? '',
          defaultVisible: false,
        ),
        ExportColumnDefinition(
          id: 'discs',
          label: 'Discs',
          getValue: (item) =>
              _musicAlbum(item)?.discs.length.toString() ?? '1',
        ),
        ExportColumnDefinition(
          id: 'tracks',
          label: 'Tracks',
          getValue: (item) =>
              _musicAlbum(item)?.trackCount.toString() ?? '',
        ),
        ExportColumnDefinition(
          id: 'length',
          label: 'Length',
          getValue: (item) {
            final tracks = _musicAlbum(item)?.tracks;
            if (tracks == null || tracks.isEmpty) return '';
            final ms = tracks.fold<int>(0, (sum, t) => sum + (t.durationMs ?? 0));
            if (ms <= 0) return '';
            final sec = (ms / 1000).round();
            final h = sec ~/ 3600;
            final m = (sec % 3600) ~/ 60;
            final s = sec % 60;
            if (h > 0) {
              return '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
            }
            return '$m:${s.toString().padLeft(2, '0')}';
          },
        ),
        ExportColumnDefinition(
          id: 'genre',
          label: 'Genre',
          getValue: (item) => _musicAlbum(item)?.genres.join(' | ') ?? '',
        ),
        ExportColumnDefinition(
          id: 'label',
          label: 'Label',
          getValue: (item) => _musicAlbum(item)?.publisher ?? '',
        ),
        ExportColumnDefinition(
          id: 'added_date',
          label: 'Added Date',
          getValue: (item) {
            final d = item.source.addedAt;
            if (d == null) return '';
            return '${_monthAbbr(d.month)} ${d.day.toString().padLeft(2, '0')}, ${d.year}';
          },
        ),
        ExportColumnDefinition(
          id: 'condition',
          label: 'Condition',
          getValue: (item) {
            if (item.dto case MusicWorkspaceProjection musicDto) {
              return musicDto.personal.condition ?? '';
            }
            return '';
          },
          defaultVisible: false,
        ),
        ExportColumnDefinition(
          id: 'rating',
          label: 'Rating',
          getValue: (item) => item.source.trackingRating?.toString() ?? '',
          defaultVisible: false,
        ),
        ExportColumnDefinition(
          id: 'location',
          label: 'Location',
          getValue: (item) => item.source.locationPath ?? '',
          defaultVisible: false,
        ),
        ExportColumnDefinition(
          id: 'price_paid',
          label: 'Price Paid',
          getValue: (item) => item.source.pricePaidCents != null
              ? formatMoney(item.source.pricePaidCents, item.source.currency)
              : '',
          defaultVisible: false,
        ),
        ExportColumnDefinition(
          id: 'value',
          label: 'Value',
          getValue: (item) => item.source.marketValueCents != null
              ? formatMoney(item.source.marketValueCents, item.source.currency)
              : '',
          defaultVisible: false,
        ),
      ];

      _selectedAlbumColumnIds = _availableAlbumColumns
          .where((col) => col.defaultVisible)
          .map((col) => col.id)
          .toList();

      _availableTrackColumns = [
        ExportTrackColumnDefinition(
          id: 'pos',
          label: '#',
          getValue: (track, _) => track.position,
        ),
        ExportTrackColumnDefinition(
          id: 'track_title',
          label: 'Track Title',
          getValue: (track, _) => track.title,
        ),
        ExportTrackColumnDefinition(
          id: 'track_artist',
          label: 'Artist',
          getValue: (track, album) => track.artist ?? album.artist ?? '',
        ),
        ExportTrackColumnDefinition(
          id: 'track_album',
          label: 'Album',
          getValue: (_, album) => album.title,
        ),
        ExportTrackColumnDefinition(
          id: 'duration',
          label: 'Duration',
          getValue: (track, _) {
            final ms = track.durationMs;
            if (ms == null || ms <= 0) return '';
            final sec = (ms / 1000).round();
            final m = sec ~/ 60;
            final s = sec % 60;
            return '$m:${s.toString().padLeft(2, '0')}';
          },
        ),
        ExportTrackColumnDefinition(
          id: 'format',
          label: 'Format',
          getValue: (_, album) => album.formatSummary ?? '',
        ),
        ExportTrackColumnDefinition(
          id: 'genre',
          label: 'Genre',
          getValue: (_, album) => album.genres.join(' | '),
        ),
      ];

      _selectedTrackColumnIds = _availableTrackColumns
          .where((col) => col.defaultVisible)
          .map((col) => col.id)
          .toList();
    } else {
      _availableAlbumColumns = [
        ExportColumnDefinition(
          id: 'title',
          label: 'Title',
          getValue: (item) => item.dto.primaryLabel,
        ),
        ExportColumnDefinition(
          id: 'secondary',
          label: 'Creator / Series',
          getValue: (item) => item.dto.secondaryLabel ?? '',
        ),
        ExportColumnDefinition(
          id: 'format',
          label: 'Format',
          getValue: (item) => item.source.catalogSummary?.subtitle ?? '',
        ),
        ExportColumnDefinition(
          id: 'status',
          label: 'Status',
          getValue: (item) => item.source.trackingStatusLabel,
        ),
        ExportColumnDefinition(
          id: 'added_date',
          label: 'Added Date',
          getValue: (item) {
            final d = item.source.addedAt;
            if (d == null) return '';
            return '${_monthAbbr(d.month)} ${d.day.toString().padLeft(2, '0')}, ${d.year}';
          },
        ),
        ExportColumnDefinition(
          id: 'location',
          label: 'Location',
          getValue: (item) => item.source.locationPath ?? '',
          defaultVisible: false,
        ),
        ExportColumnDefinition(
          id: 'price_paid',
          label: 'Price Paid',
          getValue: (item) => item.source.pricePaidCents != null
              ? formatMoney(item.source.pricePaidCents, item.source.currency)
              : '',
          defaultVisible: false,
        ),
        ExportColumnDefinition(
          id: 'value',
          label: 'Value',
          getValue: (item) => item.source.marketValueCents != null
              ? formatMoney(item.source.marketValueCents, item.source.currency)
              : '',
          defaultVisible: false,
        ),
      ];

      _selectedAlbumColumnIds = _availableAlbumColumns
          .where((col) => col.defaultVisible)
          .map((col) => col.id)
          .toList();

      _availableTrackColumns = const [];
      _selectedTrackColumnIds = const [];
      _sortColumnId = 'title';
    }
  }

  static String _monthAbbr(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    if (month >= 1 && month <= 12) return months[month - 1];
    return '';
  }

  static MusicAlbum? _musicAlbum(LibraryProjectionView item) {
    final data = item.source.kindPresentationData;
    return data is MusicWorkspaceData ? data.music : null;
  }

  List<LibraryProjectionView> get _allList => widget.allItems ?? widget.items;

  List<LibraryProjectionView> get _checkboxedList {
    final ids = widget.selectedItemIds;
    if (ids == null || ids.isEmpty) return const [];
    return _allList.where((item) => ids.contains(item.target.id)).toList();
  }

  List<LibraryProjectionView> get _activeItems {
    final list = switch (_subset) {
      ExportSubset.all => _allList,
      ExportSubset.currentList => widget.items,
      ExportSubset.checkboxed => _checkboxedList,
    };

    final sorted = List<LibraryProjectionView>.from(list);
    sorted.sort((a, b) {
      final col = _availableAlbumColumns.firstWhere(
        (c) => c.id == _sortColumnId,
        orElse: () => _availableAlbumColumns.first,
      );
      final valA = col.getValue(a).toLowerCase();
      final valB = col.getValue(b).toLowerCase();
      final cmp = valA.compareTo(valB);
      return _sortAscending ? cmp : -cmp;
    });
    return sorted;
  }

  List<({MusicTrack track, MusicAlbum album})> get _activeTracks {
    final rows = <({MusicTrack track, MusicAlbum album})>[];
    for (final item in _activeItems) {
      final album = _musicAlbum(item);
      if (album == null) continue;
      for (final disc in album.discs) {
        for (final track in disc.tracks) {
          if (!track.isHeader) {
            rows.add((track: track, album: album));
          }
        }
      }
    }
    return rows;
  }

  void _onFileTypeChanged(ExportFileType type) {
    setState(() {
      _fileType = type;
      if (type == ExportFileType.csv) {
        _delimiter = FieldDelimiter.comma;
        _enclosure = FieldEnclosure.doubleQuote;
      } else {
        _delimiter = FieldDelimiter.tab;
        _enclosure = FieldEnclosure.none;
      }
      _invalidateGenerated();
    });
  }

  void _invalidateGenerated() {
    _generatedContent = null;
    _generatedFileSize = null;
  }

  String _formatCell(String value) {
    final delim = _delimiter.char;
    final enc = _enclosure.char;

    if (enc.isEmpty) {
      return value.replaceAll(delim, ' ').replaceAll('\n', ' ');
    }

    final needsQuote = value.contains(delim) ||
        value.contains(enc) ||
        value.contains('\n') ||
        value.contains('\r') ||
        _enclosure == FieldEnclosure.doubleQuote;

    if (needsQuote) {
      final escaped = value.replaceAll(enc, '$enc$enc');
      return '$enc$escaped$enc';
    }

    return value;
  }

  String _generateRowString(List<String> cells) {
    return cells.map(_formatCell).join(_delimiter.char);
  }

  List<String> _buildPreviewLines({int limit = 30}) {
    final lines = <String>[];
    final isTrack = _isMusic && _exportMode == ExportMode.trackList;

    if (isTrack) {
      final activeColumns = _availableTrackColumns
          .where((col) => _selectedTrackColumnIds.contains(col.id))
          .toList();

      if (_includeHeaderRow) {
        lines.add(_generateRowString(activeColumns.map((c) => c.label).toList()));
      }

      final tracks = _activeTracks;
      final previewCount = tracks.length > limit ? limit : tracks.length;
      for (var i = 0; i < previewCount; i++) {
        final pair = tracks[i];
        final cells = activeColumns
            .map((col) => col.getValue(pair.track, pair.album))
            .toList();
        lines.add(_generateRowString(cells));
      }
    } else {
      final activeColumns = _availableAlbumColumns
          .where((col) => _selectedAlbumColumnIds.contains(col.id))
          .toList();

      if (_includeHeaderRow) {
        lines.add(_generateRowString(activeColumns.map((c) => c.label).toList()));
      }

      final items = _activeItems;
      final previewCount = items.length > limit ? limit : items.length;
      for (var i = 0; i < previewCount; i++) {
        final item = items[i];
        final cells = activeColumns.map((col) => col.getValue(item)).toList();
        lines.add(_generateRowString(cells));
      }
    }

    return lines;
  }

  String _generateFullExportContent() {
    final buffer = StringBuffer();
    final isTrack = _isMusic && _exportMode == ExportMode.trackList;

    if (isTrack) {
      final activeColumns = _availableTrackColumns
          .where((col) => _selectedTrackColumnIds.contains(col.id))
          .toList();

      if (_includeHeaderRow) {
        buffer.writeln(_generateRowString(activeColumns.map((c) => c.label).toList()));
      }

      for (final pair in _activeTracks) {
        final cells = activeColumns
            .map((col) => col.getValue(pair.track, pair.album))
            .toList();
        buffer.writeln(_generateRowString(cells));
      }
    } else {
      final activeColumns = _availableAlbumColumns
          .where((col) => _selectedAlbumColumnIds.contains(col.id))
          .toList();

      if (_includeHeaderRow) {
        buffer.writeln(_generateRowString(activeColumns.map((c) => c.label).toList()));
      }

      for (final item in _activeItems) {
        final cells = activeColumns.map((col) => col.getValue(item)).toList();
        buffer.writeln(_generateRowString(cells));
      }
    }

    return buffer.toString();
  }

  Future<void> _handleGenerate() async {
    setState(() => _isGenerating = true);
    await Future<void>.delayed(const Duration(milliseconds: 150));
    final content = _generateFullExportContent();
    final bytes = utf8.encode(content);
    final kb = bytes.length / 1024;
    final sizeStr = kb >= 1024
        ? '${(kb / 1024).toStringAsFixed(1)} MB'
        : '${kb.toStringAsFixed(1)} KB';

    setState(() {
      _generatedContent = content;
      _generatedFileSize = sizeStr;
      _isGenerating = false;
    });
  }

  Future<void> _handleDownload() async {
    if (_generatedContent == null) return;
    final ext = _fileType == ExportFileType.csv ? 'csv' : 'txt';
    final rawBase = _filenameController.text.trim();
    final base = rawBase.isEmpty ? 'export' : rawBase;
    final suggestedName = '$base.$ext';

    try {
      final location = await getSaveLocation(
        suggestedName: suggestedName,
        acceptedTypeGroups: [
          XTypeGroup(
            label: _fileType == ExportFileType.csv ? 'CSV (*.csv)' : 'Text (*.txt)',
            extensions: [ext],
          ),
        ],
      );
      if (location == null) return;
      final file = File(location.path);
      await file.writeAsString(_generatedContent!, encoding: utf8);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Saved file to ${file.path}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving file: $e')),
        );
      }
    }
  }

  void _handleCopyToClipboard() {
    final content = _generatedContent ?? _generateFullExportContent();
    Clipboard.setData(ClipboardData(text: content));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export content copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = libraryAccentForKind(widget.type.kind);
    final palette = appPalette(context);

    final itemLabel = _isMusic
        ? (_exportMode == ExportMode.albumList ? 'Albums' : 'Tracks')
        : widget.type.identity.pluralLabel;

    return Scaffold(
      backgroundColor: palette.surface,
      appBar: AppBar(
        leading: IconButton(
          key: const Key('export_csv_txt.back'),
          tooltip: 'Back',
          style: IconButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.transparent,
          ),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'assets/sidebar_icons/file-export.svg',
              width: 18,
              height: 18,
              colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
            ),
            const SizedBox(width: 8),
            const Text(
              'Export to CSV / TXT',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: libraryAccentChromeFallbackColor(accent),
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        flexibleSpace: LibraryAccentChrome(
          accent: accent,
          animationDuration: Duration.zero,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Page Title
                Text(
                  'Export ${widget.type.identity.pluralLabel.toLowerCase()} to CSV / TXT: $itemLabel',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w400,
                    color: palette.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),

                // Top Options Pane
                _buildTopOptionsPane(palette, accent),
                const SizedBox(height: 20),

                // Filetype Tabs
                _buildFiletypeTabs(palette, accent),

                // 1. Settings Pane
                _buildSettingsPane(palette, accent),
                const SizedBox(height: 24),

                // 4. Preview Pane
                _buildPreviewPane(palette, accent),
                const SizedBox(height: 20),

                // Bottom Action Button
                _buildBottomActions(palette, accent),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // SECTION: TOP OPTIONS PANE
  // ==========================================
  Widget _buildTopOptionsPane(AppThemePalette palette, Color accent) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.panel,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: palette.cardBorder),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 850;
          if (isWide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildSubsetSection(palette, accent)),
                      if (_isMusic) ...[
                        const SizedBox(width: 16),
                        Expanded(child: _buildMusicModeSection(palette, accent)),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildVisibleColumnsSection(palette, accent),
                      const SizedBox(height: 16),
                      _buildSortOrderSection(palette, accent),
                    ],
                  ),
                ),
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSubsetSection(palette, accent),
              if (_isMusic) ...[
                const SizedBox(height: 16),
                _buildMusicModeSection(palette, accent),
              ],
              const SizedBox(height: 16),
              _buildVisibleColumnsSection(palette, accent),
              const SizedBox(height: 16),
              _buildSortOrderSection(palette, accent),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSubsetSection(AppThemePalette palette, Color accent) {
    final allCount = _allList.length;
    final currentCount = widget.items.length;
    final checkboxedCount = _checkboxedList.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Which ${_isMusic ? 'Albums' : widget.type.identity.pluralLabel}',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: palette.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: palette.panelRaised,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: palette.cardBorder),
          ),
          child: Column(
            children: [
              _buildRadioOption(
                palette: palette,
                accent: accent,
                title: 'All ${_isMusic ? 'Albums' : widget.type.identity.pluralLabel}',
                count: allCount,
                selected: _subset == ExportSubset.all,
                enabled: true,
                onTap: () {
                  setState(() {
                    _subset = ExportSubset.all;
                    _invalidateGenerated();
                  });
                },
              ),
              Divider(height: 1, color: palette.cardBorder),
              _buildRadioOption(
                palette: palette,
                accent: accent,
                title: 'Current List',
                count: currentCount,
                selected: _subset == ExportSubset.currentList,
                enabled: currentCount > 0,
                onTap: () {
                  setState(() {
                    _subset = ExportSubset.currentList;
                    _invalidateGenerated();
                  });
                },
              ),
              Divider(height: 1, color: palette.cardBorder),
              _buildRadioOption(
                palette: palette,
                accent: accent,
                title: 'Checkboxed',
                count: checkboxedCount,
                selected: _subset == ExportSubset.checkboxed,
                enabled: checkboxedCount > 0,
                onTap: () {
                  setState(() {
                    _subset = ExportSubset.checkboxed;
                    _invalidateGenerated();
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMusicModeSection(AppThemePalette palette, Color accent) {
    final albumCount = _activeItems.length;
    final trackCount = _activeTracks.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Export mode',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: palette.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: palette.panelRaised,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: palette.cardBorder),
          ),
          child: Column(
            children: [
              _buildRadioOption(
                palette: palette,
                accent: accent,
                title: 'Album list',
                count: albumCount,
                selected: _exportMode == ExportMode.albumList,
                enabled: true,
                onTap: () {
                  setState(() {
                    _exportMode = ExportMode.albumList;
                    _filenameController.text = 'export_albums';
                    _invalidateGenerated();
                  });
                },
              ),
              Divider(height: 1, color: palette.cardBorder),
              _buildRadioOption(
                palette: palette,
                accent: accent,
                title: 'Track list',
                count: trackCount,
                selected: _exportMode == ExportMode.trackList,
                enabled: true,
                onTap: () {
                  setState(() {
                    _exportMode = ExportMode.trackList;
                    _filenameController.text = 'export_tracks';
                    _invalidateGenerated();
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRadioOption({
    required AppThemePalette palette,
    required Color accent,
    required String title,
    required int count,
    required bool selected,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    final textColor = enabled
        ? (selected ? Colors.white : palette.textPrimary)
        : palette.textMuted;

    return InkWell(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? accent.withValues(alpha: 0.18)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 16,
              color: enabled ? (selected ? accent : palette.textMuted) : palette.textMuted.withValues(alpha: 0.5),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  color: textColor,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: selected
                    ? accent
                    : palette.cardBorder,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: selected ? Colors.white : palette.textMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisibleColumnsSection(AppThemePalette palette, Color accent) {
    final isTrack = _isMusic && _exportMode == ExportMode.trackList;
    final columnNames = isTrack
        ? _availableTrackColumns
            .where((col) => _selectedTrackColumnIds.contains(col.id))
            .map((c) => c.label)
            .join(', ')
        : _availableAlbumColumns
            .where((col) => _selectedAlbumColumnIds.contains(col.id))
            .map((c) => c.label)
            .join(', ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Visible Columns',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: palette.textPrimary,
              ),
            ),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                visualDensity: VisualDensity.compact,
                foregroundColor: palette.textPrimary,
                side: BorderSide(color: palette.cardBorder),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              ),
              onPressed: () => _showManageColumnsDialog(context),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Manage', style: TextStyle(fontSize: 12)),
                  SizedBox(width: 4),
                  Icon(Icons.more_vert, size: 14),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: palette.panelRaised,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: palette.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My List View columns',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: palette.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                columnNames.isEmpty ? 'No columns selected' : columnNames,
                style: TextStyle(
                  fontSize: 12,
                  color: palette.textMuted,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSortOrderSection(AppThemePalette palette, Color accent) {
    final col = _availableAlbumColumns.firstWhere(
      (c) => c.id == _sortColumnId,
      orElse: () => _availableAlbumColumns.first,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Sort Order',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: palette.textPrimary,
              ),
            ),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                visualDensity: VisualDensity.compact,
                foregroundColor: palette.textPrimary,
                side: BorderSide(color: palette.cardBorder),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              ),
              onPressed: () => _showManageSortDialog(context),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Manage', style: TextStyle(fontSize: 12)),
                  SizedBox(width: 4),
                  Icon(Icons.more_vert, size: 14),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: palette.panelRaised,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: palette.cardBorder),
          ),
          child: Row(
            children: [
              Text(
                col.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: palette.textPrimary,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: palette.cardBorder,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  _sortAscending ? 'ASC' : 'DESC',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: palette.textMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================
  // SECTION: FILETYPE TABS (CSV / TXT)
  // ==========================================
  Widget _buildFiletypeTabs(AppThemePalette palette, Color accent) {
    return Row(
      children: [
        _buildFiletypeTab(
          label: 'CSV',
          selected: _fileType == ExportFileType.csv,
          palette: palette,
          accent: accent,
          onTap: () => _onFileTypeChanged(ExportFileType.csv),
        ),
        const SizedBox(width: 4),
        _buildFiletypeTab(
          label: 'TXT',
          selected: _fileType == ExportFileType.txt,
          palette: palette,
          accent: accent,
          onTap: () => _onFileTypeChanged(ExportFileType.txt),
        ),
      ],
    );
  }

  Widget _buildFiletypeTab({
    required String label,
    required bool selected,
    required AppThemePalette palette,
    required Color accent,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: selected ? palette.panel : palette.panelRaised,
          border: Border.all(
            color: palette.cardBorder,
            width: 1,
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                  color: selected ? Colors.white : palette.textMuted,
                ),
              ),
            ),
            if (selected)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 3,
                child: ColoredBox(color: accent),
              ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // SECTION: 1. SETTINGS PANE
  // ==========================================
  Widget _buildSettingsPane(AppThemePalette palette, Color accent) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.panel,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(4),
          bottomLeft: Radius.circular(4),
          bottomRight: Radius.circular(4),
        ),
        border: Border.all(color: palette.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '1. Settings',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: palette.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 850;
              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: _buildDelimiterCard(palette, accent),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 3,
                      child: _buildEnclosureCard(palette, accent),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 5,
                      child: _buildOptionsCard(palette, accent),
                    ),
                  ],
                );
              }

              return Column(
                children: [
                  _buildDelimiterCard(palette, accent),
                  const SizedBox(height: 16),
                  _buildEnclosureCard(palette, accent),
                  const SizedBox(height: 16),
                  _buildOptionsCard(palette, accent),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDelimiterCard(AppThemePalette palette, Color accent) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: palette.panelRaised,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: palette.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Field Delimiter',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: palette.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          for (final d in FieldDelimiter.values)
            _buildRadioRow(
              palette: palette,
              accent: accent,
              label: d.label,
              tag: d == FieldDelimiter.semicolon
                  ? ';'
                  : (d == FieldDelimiter.comma ? ',' : null),
              selected: _delimiter == d,
              onTap: () {
                setState(() {
                  _delimiter = d;
                  _invalidateGenerated();
                });
              },
            ),
        ],
      ),
    );
  }

  Widget _buildEnclosureCard(AppThemePalette palette, Color accent) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: palette.panelRaised,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: palette.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Field Enclosure',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: palette.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          for (final e in FieldEnclosure.values)
            _buildRadioRow(
              palette: palette,
              accent: accent,
              label: e.label,
              tag: e == FieldEnclosure.doubleQuote
                  ? '"'
                  : (e == FieldEnclosure.singleQuote ? "'" : null),
              selected: _enclosure == e,
              onTap: () {
                setState(() {
                  _enclosure = e;
                  _invalidateGenerated();
                });
              },
            ),
        ],
      ),
    );
  }

  Widget _buildRadioRow({
    required AppThemePalette palette,
    required Color accent,
    required String label,
    String? tag,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 16,
              color: selected ? accent : palette.textMuted,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: palette.textPrimary,
              ),
            ),
            if (tag != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: palette.cardBorder,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                    color: palette.textPrimary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOptionsCard(AppThemePalette palette, Color accent) {
    final ext = _fileType == ExportFileType.csv ? '.csv' : '.txt';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: palette.panelRaised,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: palette.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Options',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: palette.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: () {
              setState(() {
                _includeHeaderRow = !_includeHeaderRow;
                _invalidateGenerated();
              });
            },
            child: Row(
              children: [
                Checkbox(
                  value: _includeHeaderRow,
                  onChanged: (val) {
                    setState(() {
                      _includeHeaderRow = val ?? true;
                      _invalidateGenerated();
                    });
                  },
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Include Field Names as First Row',
                    style: TextStyle(
                      fontSize: 13,
                      color: palette.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 16, color: palette.cardBorder),
          Text(
            'Filename',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: palette.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 34,
                  child: TextField(
                    controller: _filenameController,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      filled: true,
                      fillColor: palette.panel,
                      border: OutlineInputBorder(
                        borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(4),
                        ),
                        borderSide: BorderSide(color: palette.cardBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(4),
                        ),
                        borderSide: BorderSide(color: palette.cardBorder),
                      ),
                    ),
                    onChanged: (_) => _invalidateGenerated(),
                  ),
                ),
              ),
              Container(
                height: 34,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: palette.cardBorder,
                  borderRadius: const BorderRadius.horizontal(
                    right: Radius.circular(4),
                  ),
                ),
                child: Text(
                  ext,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: palette.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // SECTION: 4. PREVIEW PANE
  // ==========================================
  Widget _buildPreviewPane(AppThemePalette palette, Color accent) {
    final previewLines = _buildPreviewLines();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '4. Preview',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: palette.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          height: 320,
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: palette.cardBorder),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 800),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (int index = 0; index < previewLines.length; index++) ...[
                      if (index > 0)
                        const Divider(
                          height: 1,
                          color: Color(0xFF2D2D2D),
                        ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 44,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            alignment: Alignment.topRight,
                            color: const Color(0xFF252525),
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12,
                                color: Color(0xFF888888),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 3,
                              horizontal: 4,
                            ),
                            child: SelectableText(
                              previewLines[index],
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12,
                                fontWeight: (index == 0 && _includeHeaderRow)
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: (index == 0 && _includeHeaderRow)
                                    ? const Color(0xFFB0C4DE)
                                    : const Color(0xFFE0E0E0),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // SECTION: BOTTOM ACTION BUTTONS
  // ==========================================
  Widget _buildBottomActions(AppThemePalette palette, Color accent) {
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 450),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_generatedContent == null) ...[
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                onPressed: _isGenerating ? null : _handleGenerate,
                child: _isGenerating
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Generating file...',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                    : const Text(
                        'Generate file',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ] else ...[
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAE4C),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                onPressed: _handleDownload,
                icon: const Icon(Icons.download, size: 18),
                label: Text(
                  'Download file (${_generatedFileSize ?? '0 KB'})',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: palette.textPrimary,
                  side: BorderSide(color: palette.cardBorder),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                onPressed: _handleCopyToClipboard,
                icon: const Icon(Icons.copy, size: 16),
                label: const Text(
                  'Copy to clipboard',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ==========================================
  // MANAGE COLUMNS MODAL
  // ==========================================
  void _showManageColumnsDialog(BuildContext context) {
    final palette = appPalette(context);
    final accent = libraryAccentForKind(widget.type.kind);
    final isTrack = _isMusic && _exportMode == ExportMode.trackList;

    final tempSelectedIds = isTrack
        ? List<String>.from(_selectedTrackColumnIds)
        : List<String>.from(_selectedAlbumColumnIds);

    showDialog<void>(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setModalState) {
          final allColumns = isTrack
              ? _availableTrackColumns.map((c) => (id: c.id, label: c.label)).toList()
              : _availableAlbumColumns.map((c) => (id: c.id, label: c.label)).toList();

          return AlertDialog(
            backgroundColor: palette.panel,
            title: Text(
              'Manage Visible Columns',
              style: TextStyle(color: palette.textPrimary),
            ),
            content: SizedBox(
              width: 400,
              height: 420,
              child: Column(
                children: [
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            tempSelectedIds.clear();
                            tempSelectedIds.addAll(allColumns.map((c) => c.id));
                          });
                        },
                        child: const Text('Select All'),
                      ),
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            tempSelectedIds.clear();
                          });
                        },
                        child: const Text('Deselect All'),
                      ),
                    ],
                  ),
                  const Divider(),
                  Expanded(
                    child: ListView.builder(
                      itemCount: allColumns.length,
                      itemBuilder: (context, index) {
                        final col = allColumns[index];
                        final isChecked = tempSelectedIds.contains(col.id);
                        return CheckboxListTile(
                          dense: true,
                          title: Text(col.label),
                          value: isChecked,
                          onChanged: (val) {
                            setModalState(() {
                              if (val == true) {
                                tempSelectedIds.add(col.id);
                              } else {
                                tempSelectedIds.remove(col.id);
                              }
                            });
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    if (isTrack) {
                      _selectedTrackColumnIds = tempSelectedIds;
                    } else {
                      _selectedAlbumColumnIds = tempSelectedIds;
                    }
                    _invalidateGenerated();
                  });
                  Navigator.pop(dialogCtx);
                },
                child: const Text('Apply'),
              ),
            ],
          );
        },
      ),
    );
  }

  // ==========================================
  // MANAGE SORT MODAL
  // ==========================================
  void _showManageSortDialog(BuildContext context) {
    final palette = appPalette(context);
    final accent = libraryAccentForKind(widget.type.kind);

    var tempSortId = _sortColumnId;
    var tempAscending = _sortAscending;

    showDialog<void>(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setModalState) {
          return AlertDialog(
            backgroundColor: palette.panel,
            title: Text(
              'Manage Sort Order',
              style: TextStyle(color: palette.textPrimary),
            ),
            content: SizedBox(
              width: 360,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: tempSortId,
                    decoration: const InputDecoration(labelText: 'Sort by'),
                    items: [
                      for (final col in _availableAlbumColumns)
                        DropdownMenuItem(
                          value: col.id,
                          child: Text(col.label),
                        ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() => tempSortId = val);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  RadioGroup<bool>(
                    groupValue: tempAscending,
                    onChanged: (val) =>
                        setModalState(() => tempAscending = val ?? true),
                    child: const Row(
                      children: [
                        Expanded(
                          child: RadioListTile<bool>(
                            dense: true,
                            title: Text('Ascending'),
                            value: true,
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<bool>(
                            dense: true,
                            title: Text('Descending'),
                            value: false,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    _sortColumnId = tempSortId;
                    _sortAscending = tempAscending;
                    _invalidateGenerated();
                  });
                  Navigator.pop(dialogCtx);
                },
                child: const Text('Apply'),
              ),
            ],
          );
        },
      ),
    );
  }
}
