import 'package:flutter/foundation.dart';

@immutable
final class MusicReleaseGroupId {
  const MusicReleaseGroupId(this.value);

  final String value;

  @override
  bool operator ==(Object other) =>
      other is MusicReleaseGroupId && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

@immutable
final class MusicReleaseId {
  const MusicReleaseId(this.value);

  final String value;

  @override
  bool operator ==(Object other) =>
      other is MusicReleaseId && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

/// A physical disc, tape, vinyl record, or digital medium belonging to a
/// concrete [MusicRelease].
@immutable
final class MusicMediumId {
  const MusicMediumId(this.value);

  final String value;

  @override
  bool operator ==(Object other) =>
      other is MusicMediumId && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

@immutable
final class MusicTrackId {
  const MusicTrackId(this.value);

  final String value;

  @override
  bool operator ==(Object other) =>
      other is MusicTrackId && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

@immutable
final class MusicReleaseContributionId {
  const MusicReleaseContributionId(this.value);

  final String value;

  @override
  bool operator ==(Object other) =>
      other is MusicReleaseContributionId && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

@immutable
final class MusicReleaseIdentifierId {
  const MusicReleaseIdentifierId(this.value);

  final String value;

  @override
  bool operator ==(Object other) =>
      other is MusicReleaseIdentifierId && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

@immutable
final class MusicOwnedItemId {
  const MusicOwnedItemId(this.value);

  final String value;

  @override
  bool operator ==(Object other) =>
      other is MusicOwnedItemId && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}
