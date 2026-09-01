import 'package:flutter/widgets.dart';

@immutable
final class LibraryAddFilterId {
  const LibraryAddFilterId(this.value);

  final String value;

  @override
  bool operator ==(Object other) =>
      other is LibraryAddFilterId && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

typedef LibraryAddAdvancedFilterChanged = void Function(
  LibraryAddFilterId id,
  Object? value,
);

/// Descriptor for a single field in the kind-owned advanced search filter row.
class LibraryAddAdvancedFilterField<T> {
  const LibraryAddAdvancedFilterField({
    required this.id,
    required this.key,
    required this.label,
    required this.value,
    required this.parse,
    this.hintText,
    this.width,
    this.flex = 1,
    this.keyboardType,
    this.format,
  });

  final LibraryAddFilterId id;
  final Key key;
  final String label;
  final T value;
  final T Function(String text) parse;
  final String? hintText;
  final double? width;
  final int flex;
  final TextInputType? keyboardType;
  final String Function(T value)? format;

  String get textValue => format?.call(value) ?? value.toString();
}
