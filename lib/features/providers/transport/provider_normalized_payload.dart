import 'package:flutter/foundation.dart';

import '../domain/models/provider_value_semantics.dart';

/// Schema-v1 normalized provider payload at the wire boundary.
///
/// This value is intentionally only a serialization container. Kind-owned
/// mappers must decode it immediately into their concrete catalog model.
@immutable
final class ProviderNormalizedPayload {
  ProviderNormalizedPayload(Map<String, dynamic> values)
      : values = Map<String, dynamic>.unmodifiable({
          for (final entry in values.entries)
            entry.key: immutableProviderValue(entry.value),
        });

  factory ProviderNormalizedPayload.fromJson(Object? raw) {
    if (raw is! Map) {
      return ProviderNormalizedPayload(<String, dynamic>{});
    }
    return ProviderNormalizedPayload({
      for (final entry in raw.entries)
        if (entry.key != null) entry.key.toString(): entry.value,
    });
  }

  final Map<String, dynamic> values;

  Object? operator [](String key) => values[key];

  bool containsKey(String key) => values.containsKey(key);

  bool get isEmpty => values.isEmpty;

  bool get isNotEmpty => values.isNotEmpty;

  Map<String, dynamic> toJson() => {
        for (final entry in values.entries)
          entry.key: mutableProviderValueCopy(entry.value),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProviderNormalizedPayload &&
          providerValueEquals(values, other.values);

  @override
  int get hashCode => providerValueHashCode(values);
}
