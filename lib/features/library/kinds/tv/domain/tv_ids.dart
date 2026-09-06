import 'package:flutter/foundation.dart';

@immutable
final class TvSeriesId {
  const TvSeriesId(this.value);
  final String value;

  @override
  bool operator ==(Object other) => other is TvSeriesId && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

@immutable
final class TvSeasonId {
  const TvSeasonId(this.value);
  final String value;

  @override
  bool operator ==(Object other) => other is TvSeasonId && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

@immutable
final class TvEpisodeId {
  const TvEpisodeId(this.value);
  final String value;

  @override
  bool operator ==(Object other) =>
      other is TvEpisodeId && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

@immutable
final class TvReleaseId {
  const TvReleaseId(this.value);
  final String value;

  @override
  bool operator ==(Object other) =>
      other is TvReleaseId && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

@immutable
final class TvReleaseMediaId {
  const TvReleaseMediaId(this.value);
  final String value;

  @override
  bool operator ==(Object other) =>
      other is TvReleaseMediaId && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

@immutable
final class TvOwnedItemId {
  const TvOwnedItemId(this.value);

  final String value;

  @override
  bool operator ==(Object other) =>
      other is TvOwnedItemId && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

@immutable
final class TvReleaseEpisodeMapId {
  const TvReleaseEpisodeMapId(this.value);
  final String value;

  @override
  bool operator ==(Object other) =>
      other is TvReleaseEpisodeMapId && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}
