import 'package:flutter/foundation.dart';

@immutable
final class AnimeMediaId {
  const AnimeMediaId(this.value);

  final String value;

  @override
  bool operator ==(Object other) =>
      other is AnimeMediaId && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

typedef AnimeSeriesId = AnimeMediaId;

@immutable
final class AnimeEpisodeId {
  const AnimeEpisodeId(this.value);

  final String value;

  @override
  bool operator ==(Object other) =>
      other is AnimeEpisodeId && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

@immutable
final class AnimeReleaseId {
  const AnimeReleaseId(this.value);

  final String value;

  @override
  bool operator ==(Object other) =>
      other is AnimeReleaseId && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}
