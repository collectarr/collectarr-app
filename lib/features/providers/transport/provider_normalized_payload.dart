import 'package:flutter/foundation.dart';

/// Schema-v1 normalized provider payload at the wire boundary.
///
/// This value is intentionally only a serialization container. Kind-owned
/// mappers must decode it immediately into their concrete catalog model.
@immutable
final class ProviderNormalizedPayload {
  const ProviderNormalizedPayload(this.values);

  factory ProviderNormalizedPayload.fromJson(Object? raw) {
    if (raw is! Map) {
      return const ProviderNormalizedPayload(<String, dynamic>{});
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

  Map<String, dynamic> toJson() => Map<String, dynamic>.from(values);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProviderNormalizedPayload && mapEquals(values, other.values);

  @override
  int get hashCode => Object.hashAll(values.entries);
}
