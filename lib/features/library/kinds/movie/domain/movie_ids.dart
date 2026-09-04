import 'package:flutter/foundation.dart';

@immutable
final class MovieMediaId {
  const MovieMediaId(this.value);

  final String value;

  @override
  bool operator ==(Object other) =>
      other is MovieMediaId && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

@immutable
final class MovieReleaseId {
  const MovieReleaseId(this.value);

  final String value;

  @override
  bool operator ==(Object other) =>
      other is MovieReleaseId && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

@immutable
final class MovieReleaseMediaId {
  const MovieReleaseMediaId(this.value);

  final String value;

  @override
  bool operator ==(Object other) =>
      other is MovieReleaseMediaId && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}
