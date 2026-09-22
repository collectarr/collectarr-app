import 'package:flutter/foundation.dart';

sealed class ProviderPatch<T> {
  const ProviderPatch();

  const factory ProviderPatch.unchanged() = ProviderUnchanged<T>;
  const factory ProviderPatch.set(T value) = ProviderSetValue<T>;
  const factory ProviderPatch.clear() = ProviderClearValue<T>;
}

/// A changed typed value at the final provider HTTP boundary.
///
/// The field name is supplied by the owning kind. This utility deliberately
/// does not define a semantic field catalog for any kind.
final class ProviderPatchWireField {
  const ProviderPatchWireField._({
    required this.field,
    required this.isChanged,
    required Object? Function() wireValueBuilder,
  }) : _wireValueBuilder = wireValueBuilder;

  final String field;
  final bool isChanged;
  final Object? Function() _wireValueBuilder;

  Object? get wireValue => _wireValueBuilder();
}

ProviderPatchWireField providerPatchWireField<T>(
  String field,
  ProviderPatch<T> patch, {
  Object? Function(T value)? encode,
}) {
  final encodeValue = encode ?? (value) => value;
  return switch (patch) {
    ProviderUnchanged<T>() => ProviderPatchWireField._(
        field: field,
        isChanged: false,
        wireValueBuilder: () => null,
      ),
    ProviderSetValue<T>(value: final value) => ProviderPatchWireField._(
        field: field,
        isChanged: true,
        wireValueBuilder: () => encodeValue(value),
      ),
    ProviderClearValue<T>() => ProviderPatchWireField._(
        field: field,
        isChanged: true,
        wireValueBuilder: () => null,
      ),
  };
}

Map<String, Object?> encodeChangedProviderPatchFields(
  Iterable<ProviderPatchWireField> fields,
) {
  return {
    for (final field in fields)
      if (field.isChanged) field.field: field.wireValue,
  };
}

final class ProviderUnchanged<T> extends ProviderPatch<T> {
  const ProviderUnchanged();
}

final class ProviderSetValue<T> extends ProviderPatch<T> {
  const ProviderSetValue(this.value);

  final T value;
}

final class ProviderClearValue<T> extends ProviderPatch<T> {
  const ProviderClearValue();
}

@immutable
final class ProviderFieldComparison<T> {
  const ProviderFieldComparison({this.current, this.provider});

  final T? current;
  final T? provider;
}
