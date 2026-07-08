import 'dart:convert';
import 'dart:typed_data';

import 'package:collectarr_app/features/imports/framework/import_models.dart';
import 'package:collectarr_app/features/settings/provider_import_models.dart';

class ProviderCsvImportService {
  const ProviderCsvImportService();

  List<ImportRow> parseFileBytes(
    Uint8List bytes, {
    required String fileName,
    required ProviderImportId provider,
  }) {
    final text = utf8.decode(bytes, allowMalformed: true);
    return parsePayload(text, provider: provider);
  }

  List<ImportRow> parsePayload(
    String text, {
    required ProviderImportId provider,
  }) {
    final normalized = text.trim();
    if (normalized.isEmpty) {
      throw const FormatException('Import payload cannot be empty.');
    }
    final rows = _parseCsvRows(normalized);
    if (rows.isEmpty) {
      throw const FormatException('CSV export does not contain rows.');
    }
    final header = rows.first.map(_cellText).toList(growable: false);
    final index = {
      for (var i = 0; i < header.length; i++)
        if (header[i].isNotEmpty) _normalizeKey(header[i]): i,
    };

    final entries = <ImportRow>[];
    for (var i = 1; i < rows.length; i++) {
      final values = rows[i].map(_cellText).toList(growable: false);
      final title = _value(index, values, const [
            'title',
            'name',
            'series_title',
            'book_title',
            'game_title',
          ]) ??
          '';
      if (title.trim().isEmpty) {
        continue;
      }
      final sourceId = _sourceId(provider, index, values, title, i);
      final mediaKind = _mediaKind(provider, index, values);
      final status = _status(provider, index, values);
      final rating = _rating(provider, index, values);
      final progress = _progress(provider, index, values);
      entries.add(
        ImportRow(
          sourceId: sourceId,
          title: title,
          mediaKind: mediaKind,
          status: status,
          rating: rating,
          startedAt: _date(_value(index, values, const [
            'started_at',
            'start_date',
            'created',
            'date_started',
          ])),
          finishedAt: _date(_value(index, values, const [
            'finished_at',
            'finish_date',
            'date_read',
            'completed_at',
            'modified',
          ])),
          progress: progress,
          externalIds: _externalIds(provider, index, values, sourceId),
          raw: {
            for (final entry in index.entries)
              entry.key: entry.value < values.length ? values[entry.value] : '',
          },
        ),
      );
    }
    return entries;
  }

  String? _value(
    Map<String, int> index,
    List<String> values,
    List<String> keys,
  ) {
    for (final key in keys) {
      final ix = index[_normalizeKey(key)];
      if (ix == null || ix >= values.length) {
        continue;
      }
      final text = values[ix].trim();
      if (text.isNotEmpty) {
        return text;
      }
    }
    return null;
  }

  String _sourceId(
    ProviderImportId provider,
    Map<String, int> index,
    List<String> values,
    String title,
    int rowIndex,
  ) {
    final candidates = switch (provider) {
      ProviderImportId.imdb => const ['const', 'id'],
      ProviderImportId.goodReads => const ['book_id', 'book id', 'id', 'isbn13'],
      ProviderImportId.howLongToBeat => const ['id', 'game_id'],
      ProviderImportId.trakt => const ['trakt_id', 'id', 'slug'],
      ProviderImportId.simkl => const ['id', 'simkl_id'],
      ProviderImportId.kitsu => const ['id', 'kitsu_id'],
      _ => const ['id'],
    };
    final source = _value(index, values, candidates);
    if (source != null && source.isNotEmpty) {
      return source;
    }
    return '${provider.storageValue}:$rowIndex:${title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-')}';
  }

  String? _mediaKind(
    ProviderImportId provider,
    Map<String, int> index,
    List<String> values,
  ) {
    final direct = _value(index, values, const [
      'media_kind',
      'kind',
      'type',
      'title_type',
    ])?.toLowerCase();
    if (direct != null) {
      if (direct.contains('anime')) return 'anime';
      if (direct.contains('manga')) return 'manga';
      if (direct.contains('book')) return 'book';
      if (direct.contains('game')) return 'game';
      if (direct.contains('tv')) return 'tv';
      if (direct.contains('movie') || direct.contains('film')) return 'movie';
    }
    return switch (provider) {
      ProviderImportId.goodReads => 'book',
      ProviderImportId.howLongToBeat => 'game',
      ProviderImportId.myAnimeList ||
      ProviderImportId.aniList ||
      ProviderImportId.kitsu =>
        'anime',
      ProviderImportId.trakt ||
      ProviderImportId.simkl ||
      ProviderImportId.imdb =>
        'movie',
      _ => null,
    };
  }

  ImportItemStatus _status(
    ProviderImportId provider,
    Map<String, int> index,
    List<String> values,
  ) {
    final raw = _value(index, values, const [
      'exclusive_shelf',
      'bookshelves',
      'status',
      'watch_status',
      'completion_status',
      'my_status',
    ])?.toLowerCase();
    if (raw == null || raw.isEmpty) {
      return switch (provider) {
        ProviderImportId.goodReads => ImportItemStatus.completed,
        _ => ImportItemStatus.unknown,
      };
    }
    if (raw.contains('read') || raw.contains('watched') || raw.contains('completed')) {
      return ImportItemStatus.completed;
    }
    if (raw.contains('currently') ||
        raw.contains('watching') ||
        raw.contains('reading') ||
        raw.contains('playing') ||
        raw.contains('in progress')) {
      return ImportItemStatus.inProgress;
    }
    if (raw.contains('plan') || raw.contains('to read') || raw.contains('to watch') || raw.contains('backlog')) {
      return ImportItemStatus.planned;
    }
    if (raw.contains('hold') || raw.contains('paused')) {
      return ImportItemStatus.paused;
    }
    if (raw.contains('drop') || raw.contains('abandon')) {
      return ImportItemStatus.dropped;
    }
    if (raw.contains('wish') || raw.contains('favorite') || raw.contains('favourite')) {
      return ImportItemStatus.wishlist;
    }
    return ImportItemStatus.unknown;
  }

  int? _rating(
    ProviderImportId provider,
    Map<String, int> index,
    List<String> values,
  ) {
    final raw = _value(index, values, const [
      'my_rating',
      'you rated',
      'score',
      'rating',
    ]);
    final numeric = num.tryParse(raw ?? '');
    if (numeric == null || numeric <= 0) {
      return null;
    }
    return switch (provider) {
      ProviderImportId.goodReads => (numeric * 20).round().clamp(0, 100),
      ProviderImportId.imdb => (numeric * 10).round().clamp(0, 100),
      _ => (numeric * 10).round().clamp(0, 100),
    };
  }

  int? _progress(
    ProviderImportId provider,
    Map<String, int> index,
    List<String> values,
  ) {
    final raw = _value(index, values, const [
      'my_watched_episodes',
      'my_read_chapters',
      'my_read_volumes',
      'progress',
      'episodes',
      'chapters',
      'hours',
      'hours played',
      'time',
    ]);
    final numeric = num.tryParse(raw ?? '');
    if (numeric == null || numeric <= 0) {
      return null;
    }
    return numeric.round();
  }

  Map<String, String> _externalIds(
    ProviderImportId provider,
    Map<String, int> index,
    List<String> values,
    String sourceId,
  ) {
    final result = <String, String>{};
    if (sourceId.isNotEmpty) {
      result[provider.storageValue] = sourceId;
    }
    final imdbId = _value(index, values, const ['const', 'imdb_id']);
    if (imdbId != null && imdbId.isNotEmpty) {
      result['imdb'] = imdbId;
    }
    final isbn13 = _value(index, values, const ['isbn13', 'isbn_13']);
    if (isbn13 != null && isbn13.isNotEmpty) {
      result['isbn13'] = isbn13;
    }
    final isbn = _value(index, values, const ['isbn', 'isbn_10']);
    if (isbn != null && isbn.isNotEmpty) {
      result['isbn'] = isbn;
    }
    return result;
  }

  String _cellText(Object? cell) {
    return cell?.toString().trim() ?? '';
  }

  String _normalizeKey(String value) {
    return value.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
  }

  DateTime? _date(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    return DateTime.tryParse(value.trim());
  }

  List<List<String>> _parseCsvRows(String text) {
    final lines = const LineSplitter().convert(text);
    final rows = <List<String>>[];
    for (final line in lines) {
      if (line.trim().isEmpty) {
        continue;
      }
      rows.add(_parseCsvLine(line));
    }
    return rows;
  }

  List<String> _parseCsvLine(String line) {
    final values = <String>[];
    final buffer = StringBuffer();
    var inQuotes = false;
    for (var i = 0; i < line.length; i++) {
      final char = line[i];
      if (char == '"') {
        final nextIsQuote = i + 1 < line.length && line[i + 1] == '"';
        if (inQuotes && nextIsQuote) {
          buffer.write('"');
          i++;
          continue;
        }
        inQuotes = !inQuotes;
        continue;
      }
      if (char == ',' && !inQuotes) {
        values.add(buffer.toString().trim());
        buffer.clear();
        continue;
      }
      buffer.write(char);
    }
    values.add(buffer.toString().trim());
    return values;
  }
}
