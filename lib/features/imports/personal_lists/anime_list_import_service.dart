import 'dart:convert';
import 'dart:typed_data';

import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_id.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_personal_entry.dart';
import 'package:xml/xml.dart';

class AnimeListImportService {
  const AnimeListImportService();

  List<ProviderPersonalEntry> parseFileBytes(
    Uint8List bytes, {
    required String fileName,
    required ProviderId provider,
  }) {
    final text = utf8.decode(bytes, allowMalformed: true);
    return parsePayload(text, provider: provider);
  }

  List<ProviderPersonalEntry> parsePayload(
    String text, {
    required ProviderId provider,
  }) {
    final normalized = text.trim();
    if (normalized.isEmpty) {
      throw const FormatException('Anime list import payload cannot be empty.');
    }
    final document = XmlDocument.parse(normalized);
    final entries = _entryElements(document);
    if (entries.isEmpty) {
      throw const FormatException(
          'Anime list export does not contain entries.');
    }

    final rows = <ProviderPersonalEntry>[];
    for (final entry in entries) {
      final kindStr = _mediaKindForEntry(entry);
      final kind =
          kindStr == 'manga' ? CatalogMediaKind.manga : CatalogMediaKind.anime;
      final title = _text(
            entry,
            const [
              'series_title',
              'title',
              'series_english',
              'series_romaji',
              'name',
            ],
          ) ??
          'Untitled';
      final id = _providerEntryId(entry, kindStr, title);
      final status = _statusForEntry(entry);
      final score = _int(_text(entry, const ['my_score', 'score']));
      final progress = _progressForEntry(entry, kindStr);
      final startedAt = _date(
        _text(entry, const ['my_start_date', 'start_date', 'started_at']),
      );
      final finishedAt = _date(
        _text(entry, const ['my_finish_date', 'finish_date', 'completed_at']),
      );
      rows.add(
        ProviderPersonalEntry(
          provider: provider,
          remoteItemId: id,
          kind: kind,
          title: title,
          status: status,
          rating: score == null ? null : (score * 10).clamp(0, 100).toDouble(),
          startedAt: startedAt,
          completedAt: finishedAt,
          progress: progress,
          externalIds: {
            provider.storageValue: id,
          },
          rawPayload: _rawPayload(entry),
        ),
      );
    }
    return rows;
  }

  List<XmlElement> _entryElements(XmlDocument document) {
    final root = document.rootElement;
    final entries = <XmlElement>[];
    for (final child in root.children.whereType<XmlElement>()) {
      final childName = child.name.local.toLowerCase();
      if (childName == 'entry') {
        entries.add(child);
        continue;
      }
      if (childName == 'anime' || childName == 'manga') {
        final nested = child.children
            .whereType<XmlElement>()
            .where((element) => element.name.local.toLowerCase() == 'entry')
            .toList(growable: false);
        if (nested.isNotEmpty) {
          entries.addAll(nested);
        } else {
          entries.add(child);
        }
      }
    }
    if (entries.isNotEmpty) {
      return entries;
    }
    return root.descendants
        .whereType<XmlElement>()
        .where((element) => element.name.local.toLowerCase() == 'entry')
        .toList(growable: false);
  }

  String _mediaKindForEntry(XmlElement entry) {
    final direct = entry.name.local.toLowerCase();
    if (direct == 'anime' || direct == 'manga') {
      return direct;
    }
    final parent = entry.parent;
    if (parent is XmlElement) {
      final parentName = parent.name.local.toLowerCase();
      if (parentName == 'anime' || parentName == 'manga') {
        return parentName;
      }
    }
    return 'anime';
  }

  String _providerEntryId(XmlElement entry, String kind, String title) {
    final candidates = kind == 'manga'
        ? const ['series_mangadb_id', 'series_animedb_id', 'id']
        : const ['series_animedb_id', 'series_mangadb_id', 'id'];
    for (final key in candidates) {
      final value = _text(entry, [key]);
      if (value != null && value.isNotEmpty) {
        return value;
      }
    }
    return title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-');
  }

  ProviderEntryStatus? _statusForEntry(XmlElement entry) {
    final raw = _text(entry, const ['my_status', 'status']);
    final normalized = raw?.trim().toLowerCase();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }
    return switch (normalized) {
      '1' ||
      'watching' ||
      'reading' ||
      'in progress' =>
        ProviderEntryStatus.current,
      '2' ||
      'completed' ||
      'finish' ||
      'finished' =>
        ProviderEntryStatus.completed,
      '3' || 'on hold' || 'paused' => ProviderEntryStatus.paused,
      '4' || 'dropped' => ProviderEntryStatus.dropped,
      '6' ||
      'plan to watch' ||
      'plan to read' ||
      'plan to listen' ||
      'wishlist' ||
      'want to watch' ||
      'want to read' =>
        ProviderEntryStatus.planning,
      'repeating' ||
      'rewatching' ||
      'rereading' =>
        ProviderEntryStatus.repeating,
      _ => null,
    };
  }

  int? _progressForEntry(XmlElement entry, String kind) {
    final keys = kind == 'manga'
        ? const ['my_read_chapters', 'my_read_volumes', 'chapters', 'volumes']
        : const ['my_watched_episodes', 'episodes'];
    for (final key in keys) {
      final value = _int(_text(entry, [key]));
      if (value != null) {
        return value;
      }
    }
    return null;
  }

  String? _text(XmlElement entry, List<String> names) {
    for (final name in names) {
      final element = entry.getElement(name);
      if (element == null) {
        continue;
      }
      final text = element.innerText.trim();
      if (text.isNotEmpty) {
        return text;
      }
    }
    return null;
  }

  int? _int(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    return int.tryParse(value.trim());
  }

  DateTime? _date(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    final parsed = DateTime.tryParse(value.trim());
    if (parsed != null) {
      return parsed;
    }
    final parts = value.trim().split(RegExp(r'[-/.]'));
    if (parts.length != 3) {
      return null;
    }
    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final day = int.tryParse(parts[2]);
    if (year == null || month == null || day == null) {
      return null;
    }
    try {
      return DateTime(year, month, day);
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> _rawPayload(XmlElement entry) {
    return {
      for (final child in entry.children.whereType<XmlElement>())
        child.name.local: child.innerText.trim(),
    };
  }
}
