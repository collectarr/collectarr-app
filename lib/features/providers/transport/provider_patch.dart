import 'package:flutter/foundation.dart';

sealed class ProviderPatch<T> {
  const ProviderPatch();

  const factory ProviderPatch.unchanged() = ProviderUnchanged<T>;
  const factory ProviderPatch.set(T value) = ProviderSetValue<T>;
  const factory ProviderPatch.clear() = ProviderClearValue<T>;
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
