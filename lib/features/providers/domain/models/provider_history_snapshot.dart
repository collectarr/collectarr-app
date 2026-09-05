import 'package:flutter/foundation.dart';

/// The history fields that participate in provider sync as one diff domain.
@immutable
final class ProviderHistorySnapshot {
  const ProviderHistorySnapshot({
    this.startedAt,
    this.completedAt,
    this.repeatCount = 0,
    this.notes,
  });

  final DateTime? startedAt;
  final DateTime? completedAt;
  final int repeatCount;
  final String? notes;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProviderHistorySnapshot &&
          runtimeType == other.runtimeType &&
          startedAt == other.startedAt &&
          completedAt == other.completedAt &&
          repeatCount == other.repeatCount &&
          notes == other.notes;

  @override
  int get hashCode => Object.hash(
        startedAt,
        completedAt,
        repeatCount,
        notes,
      );
}
