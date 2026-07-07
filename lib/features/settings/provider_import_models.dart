import 'dart:convert';

import 'package:flutter/material.dart';

enum ProviderImportId {
  tmdb,
  trakt,
  simkl,
  myAnimeList,
  aniList,
  kitsu,
  imdb,
  goodReads,
  howLongToBeat,
  steam,
}

extension ProviderImportIdX on ProviderImportId {
  String get storageValue {
    return switch (this) {
      ProviderImportId.tmdb => 'tmdb',
      ProviderImportId.trakt => 'trakt',
      ProviderImportId.simkl => 'simkl',
      ProviderImportId.myAnimeList => 'myanimelist',
      ProviderImportId.aniList => 'anilist',
      ProviderImportId.kitsu => 'kitsu',
      ProviderImportId.imdb => 'imdb',
      ProviderImportId.goodReads => 'goodreads',
      ProviderImportId.howLongToBeat => 'howlongtobeat',
      ProviderImportId.steam => 'steam',
    };
  }

  String get label {
    return switch (this) {
      ProviderImportId.tmdb => 'TMDB',
      ProviderImportId.trakt => 'Trakt',
      ProviderImportId.simkl => 'SIMKL',
      ProviderImportId.myAnimeList => 'MyAnimeList',
      ProviderImportId.aniList => 'AniList',
      ProviderImportId.kitsu => 'Kitsu',
      ProviderImportId.imdb => 'IMDB',
      ProviderImportId.goodReads => 'GoodReads',
      ProviderImportId.howLongToBeat => 'HowLongToBeat',
      ProviderImportId.steam => 'Steam',
    };
  }

  static ProviderImportId? fromStorageValue(String? value) {
    return switch (value?.trim().toLowerCase()) {
      'tmdb' => ProviderImportId.tmdb,
      'trakt' => ProviderImportId.trakt,
      'simkl' => ProviderImportId.simkl,
      'myanimelist' => ProviderImportId.myAnimeList,
      'anilist' => ProviderImportId.aniList,
      'kitsu' => ProviderImportId.kitsu,
      'imdb' => ProviderImportId.imdb,
      'goodreads' => ProviderImportId.goodReads,
      'howlongtobeat' => ProviderImportId.howLongToBeat,
      'steam' => ProviderImportId.steam,
      _ => null,
    };
  }
}

enum ProviderImportAvailability {
  available,
  comingSoon,
}

class ProviderImportDescriptor {
  const ProviderImportDescriptor({
    required this.id,
    required this.title,
    required this.summary,
    required this.supportsAccountSync,
    required this.supportsFileImport,
    this.availability = ProviderImportAvailability.available,
  });

  final ProviderImportId id;
  final String title;
  final String summary;
  final bool supportsAccountSync;
  final bool supportsFileImport;
  final ProviderImportAvailability availability;
}

/// Icon data for each provider (Material Icons fallback for missing logos).
IconData providerImportIcon(ProviderImportId id) {
  return switch (id) {
    ProviderImportId.tmdb => Icons.movie_outlined,
    ProviderImportId.trakt => Icons.live_tv_outlined,
    ProviderImportId.simkl => Icons.connected_tv_outlined,
    ProviderImportId.myAnimeList => Icons.auto_awesome_outlined,
    ProviderImportId.aniList => Icons.auto_awesome_outlined,
    ProviderImportId.kitsu => Icons.auto_awesome_outlined,
    ProviderImportId.imdb => Icons.theaters_outlined,
    ProviderImportId.goodReads => Icons.menu_book_outlined,
    ProviderImportId.howLongToBeat => Icons.sports_esports_outlined,
    ProviderImportId.steam => Icons.sports_esports_outlined,
  };
}

const providerImportDescriptors = <ProviderImportDescriptor>[
  ProviderImportDescriptor(
    id: ProviderImportId.tmdb,
    title: 'TMDB',
    summary: 'Import rated and watchlist movies from TMDB account sync or TMDB export files.',
    supportsAccountSync: true,
    supportsFileImport: true,
  ),
  ProviderImportDescriptor(
    id: ProviderImportId.trakt,
    title: 'Trakt',
    summary: 'Import TV shows and movies.',
    supportsAccountSync: true,
    supportsFileImport: false,
    availability: ProviderImportAvailability.comingSoon,
  ),
  ProviderImportDescriptor(
    id: ProviderImportId.simkl,
    title: 'SIMKL',
    summary: 'Import TV shows, movies and anime.',
    supportsAccountSync: true,
    supportsFileImport: false,
    availability: ProviderImportAvailability.comingSoon,
  ),
  ProviderImportDescriptor(
    id: ProviderImportId.myAnimeList,
    title: 'MyAnimeList',
    summary: 'Import anime and manga XML exports.',
    supportsAccountSync: false,
    supportsFileImport: true,
    availability: ProviderImportAvailability.available,
  ),
  ProviderImportDescriptor(
    id: ProviderImportId.aniList,
    title: 'AniList',
    summary: 'Import anime and manga XML exports.',
    supportsAccountSync: false,
    supportsFileImport: true,
    availability: ProviderImportAvailability.available,
  ),
  ProviderImportDescriptor(
    id: ProviderImportId.kitsu,
    title: 'Kitsu',
    summary: 'Import anime and manga.',
    supportsAccountSync: true,
    supportsFileImport: false,
    availability: ProviderImportAvailability.comingSoon,
  ),
  ProviderImportDescriptor(
    id: ProviderImportId.imdb,
    title: 'IMDB',
    summary: 'Import movies and TV shows from your ratings.',
    supportsAccountSync: false,
    supportsFileImport: true,
    availability: ProviderImportAvailability.comingSoon,
  ),
  ProviderImportDescriptor(
    id: ProviderImportId.goodReads,
    title: 'GoodReads',
    summary: 'Import from GoodReads backup.',
    supportsAccountSync: false,
    supportsFileImport: true,
    availability: ProviderImportAvailability.comingSoon,
  ),
  ProviderImportDescriptor(
    id: ProviderImportId.howLongToBeat,
    title: 'HowLongToBeat',
    summary: 'Import games.',
    supportsAccountSync: false,
    supportsFileImport: true,
    availability: ProviderImportAvailability.comingSoon,
  ),
  ProviderImportDescriptor(
    id: ProviderImportId.steam,
    title: 'Steam',
    summary: 'Import games from your Steam library.',
    supportsAccountSync: true,
    supportsFileImport: false,
    availability: ProviderImportAvailability.comingSoon,
  ),
];

enum ProviderImportHistoryStatus {
  success,
  failed,
}

extension ProviderImportHistoryStatusX on ProviderImportHistoryStatus {
  String get storageValue {
    return switch (this) {
      ProviderImportHistoryStatus.success => 'success',
      ProviderImportHistoryStatus.failed => 'failed',
    };
  }

  static ProviderImportHistoryStatus fromStorageValue(String? value) {
    return switch (value?.trim().toLowerCase()) {
      'failed' => ProviderImportHistoryStatus.failed,
      _ => ProviderImportHistoryStatus.success,
    };
  }
}

class ProviderImportHistoryEntry {
  const ProviderImportHistoryEntry({
    required this.id,
    required this.provider,
    required this.status,
    required this.collectionLabel,
    required this.sourceLabel,
    required this.message,
    required this.createdAt,
    this.rows = 0,
    this.matched = 0,
    this.unmatched = 0,
    this.imported = 0,
    this.proposed = 0,
    this.keptLocal = 0,
  });

  final String id;
  final ProviderImportId provider;
  final ProviderImportHistoryStatus status;
  final String collectionLabel;
  final String sourceLabel;
  final String message;
  final DateTime createdAt;
  final int rows;
  final int matched;
  final int unmatched;
  final int imported;
  final int proposed;
  final int keptLocal;

  factory ProviderImportHistoryEntry.fromJson(Map<String, dynamic> json) {
    return ProviderImportHistoryEntry(
      id: json['id'] as String? ?? '',
      provider: ProviderImportIdX.fromStorageValue(json['provider'] as String?) ??
          ProviderImportId.tmdb,
      status: ProviderImportHistoryStatusX.fromStorageValue(
        json['status'] as String?,
      ),
      collectionLabel: json['collection_label'] as String? ?? '',
      sourceLabel: json['source_label'] as String? ?? '',
      message: json['message'] as String? ?? '',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      rows: (json['rows'] as num?)?.toInt() ?? 0,
      matched: (json['matched'] as num?)?.toInt() ?? 0,
      unmatched: (json['unmatched'] as num?)?.toInt() ?? 0,
      imported: (json['imported'] as num?)?.toInt() ?? 0,
      proposed: (json['proposed'] as num?)?.toInt() ?? 0,
      keptLocal: (json['kept_local'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'provider': provider.storageValue,
      'status': status.storageValue,
      'collection_label': collectionLabel,
      'source_label': sourceLabel,
      'message': message,
      'created_at': createdAt.toUtc().toIso8601String(),
      'rows': rows,
      'matched': matched,
      'unmatched': unmatched,
      'imported': imported,
      'proposed': proposed,
      'kept_local': keptLocal,
    };
  }

  static List<ProviderImportHistoryEntry> decodeList(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      return const [];
    }
    return [
      for (final value in decoded)
        if (value is Map<String, dynamic>)
          ProviderImportHistoryEntry.fromJson(value)
        else if (value is Map)
          ProviderImportHistoryEntry.fromJson(Map<String, dynamic>.from(value)),
    ];
  }
}