class TvEpisodeImportRow {
  const TvEpisodeImportRow({
    required this.kind,
    required this.title,
    this.seasonNumber,
    this.episodeNumber,
    this.status,
    this.score,
    this.progress,
    this.repeats,
    this.startDate,
    this.endDate,
    this.watchedDate,
    this.notes,
  });

  final String kind;
  final String title;
  final int? seasonNumber;
  final int? episodeNumber;
  final String? status;
  final int? score;
  final double? progress;
  final int? repeats;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? watchedDate;
  final String? notes;
}

class TvEpisodeImportMapping {
  const TvEpisodeImportMapping({
    required this.targetKind,
    required this.targetScope,
    required this.summary,
  });

  final String targetKind;
  final String targetScope;
  final String summary;
}

class TvEpisodeImportMapper {
  const TvEpisodeImportMapper();

  TvEpisodeImportMapping mapRow(TvEpisodeImportRow row) {
    final scope = switch ((row.seasonNumber, row.episodeNumber)) {
      (int _, int _) => 'episode',
      (int _, null) => 'season',
      _ => 'series',
    };
    return TvEpisodeImportMapping(
      targetKind: row.kind.trim().toLowerCase(),
      targetScope: scope,
      summary: _summaryFor(row),
    );
  }

  String _summaryFor(TvEpisodeImportRow row) {
    final parts = <String>[
      if (row.status != null && row.status!.trim().isNotEmpty) row.status!.trim(),
      if (row.score != null) 'Score ${row.score}',
      if (row.progress != null) '${(row.progress! * 100).round()}%',
      if (row.repeats != null && row.repeats! > 0) 'x${row.repeats}',
      if (row.watchedDate != null) row.watchedDate!.toIso8601String(),
    ];
    return parts.isEmpty ? row.title : '${row.title} · ${parts.join(' · ')}';
  }
}
