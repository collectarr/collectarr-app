import 'package:flutter/foundation.dart';

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

@immutable
final class MusicMediaId {
  const MusicMediaId(this.value);

  final String value;

  @override
  bool operator ==(Object other) =>
      other is MusicMediaId && other.value == value;

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
