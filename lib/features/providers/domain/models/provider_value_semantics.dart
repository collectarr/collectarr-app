/// Immutable snapshot of a provider payload value.
Object? immutableProviderValue(Object? value) {
  if (value is Map) {
    return Map<Object?, Object?>.unmodifiable({
      for (final entry in value.entries)
        immutableProviderValue(entry.key): immutableProviderValue(entry.value),
    });
  }
  if (value is List) {
    return List<Object?>.unmodifiable(value.map(immutableProviderValue));
  }
  if (value is Set) {
    return Set<Object?>.unmodifiable(value.map(immutableProviderValue));
  }
  return value;
}

/// Creates a detached, mutable copy suitable for serialization boundaries.
Object? mutableProviderValueCopy(Object? value) {
  if (value is Map) {
    return <Object?, Object?>{
      for (final entry in value.entries)
        mutableProviderValueCopy(entry.key):
            mutableProviderValueCopy(entry.value),
    };
  }
  if (value is List) {
    return value.map(mutableProviderValueCopy).toList();
  }
  if (value is Set) {
    return value.map(mutableProviderValueCopy).toSet();
  }
  return value;
}

bool providerValueEquals(Object? left, Object? right) {
  if (identical(left, right)) return true;
  if (left is Map && right is Map) {
    if (left.length != right.length) return false;
    for (final entry in left.entries) {
      if (!right.containsKey(entry.key) ||
          !providerValueEquals(entry.value, right[entry.key])) {
        return false;
      }
    }
    return true;
  }
  if (left is List && right is List) {
    if (left.length != right.length) return false;
    for (var index = 0; index < left.length; index++) {
      if (!providerValueEquals(left[index], right[index])) return false;
    }
    return true;
  }
  if (left is Set && right is Set) {
    if (left.length != right.length) return false;
    final unmatched = right.toList();
    for (final item in left) {
      final match = unmatched.indexWhere(
        (candidate) => providerValueEquals(item, candidate),
      );
      if (match < 0) return false;
      unmatched.removeAt(match);
    }
    return true;
  }
  return left == right;
}

int providerValueHashCode(Object? value) {
  if (value is Map) {
    return Object.hash(
      'map',
      value.length,
      Object.hashAllUnordered([
        for (final entry in value.entries)
          Object.hash(entry.key, providerValueHashCode(entry.value)),
      ]),
    );
  }
  if (value is List) {
    return Object.hash(
      'list',
      Object.hashAll(value.map(providerValueHashCode)),
    );
  }
  if (value is Set) {
    return Object.hash(
      'set',
      value.length,
      Object.hashAllUnordered(value.map(providerValueHashCode)),
    );
  }
  return value.hashCode;
}

Map<String, Object?> immutableProviderPayload(Map<String, Object?> values) {
  return Map<String, Object?>.unmodifiable({
    for (final entry in values.entries)
      entry.key: immutableProviderValue(entry.value),
  });
}

Map<String, Object?> mutableProviderPayloadCopy(Map<String, Object?> values) {
  return <String, Object?>{
    for (final entry in values.entries)
      entry.key: mutableProviderValueCopy(entry.value),
  };
}
