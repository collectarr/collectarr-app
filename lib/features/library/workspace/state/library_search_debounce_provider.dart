import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Controls how long the search input waits before triggering a query.
///
/// Override with [Duration.zero] in tests to make search synchronous without
/// importing [dart:io] or checking [Platform.environment].
///
/// ```dart
/// // In a test:
/// container = ProviderContainer(
///   overrides: [
///     librarySearchDebounceDurationProvider.overrideWithValue(Duration.zero),
///   ],
/// );
/// ```
final librarySearchDebounceDurationProvider = Provider<Duration>(
  (_) => const Duration(milliseconds: 350),
);
