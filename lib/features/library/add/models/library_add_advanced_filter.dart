import 'package:flutter/widgets.dart';
import 'package:collectarr_app/features/library/config/library_chrome_config.dart';

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
  LibraryAddFilterValue? value,
);

@immutable
sealed class LibraryAddFilterValue {
  const LibraryAddFilterValue();

  String get displayValue;
  bool get hasValue;
}

@immutable
final class LibraryAddTextFilterValue extends LibraryAddFilterValue {
  const LibraryAddTextFilterValue(this.value);

  final String value;

  @override
  String get displayValue => value;

  @override
  bool get hasValue => value.trim().isNotEmpty;
}

@immutable
final class LibraryAddOptionFilterValue extends LibraryAddFilterValue {
  const LibraryAddOptionFilterValue(this.value);

  final String value;

  @override
  String get displayValue => value;

  @override
  bool get hasValue => value.trim().isNotEmpty;
}

@immutable
final class LibraryAddSearchScopesFilterValue extends LibraryAddFilterValue {
  LibraryAddSearchScopesFilterValue(Set<LibraryAddSearchScope> scopes)
      : scopes = Set.unmodifiable(scopes);

  final Set<LibraryAddSearchScope> scopes;

  @override
  String get displayValue =>
      scopes.map((scope) => scope.providerValue).join(' ');

  @override
  bool get hasValue => scopes.isNotEmpty;
}

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
