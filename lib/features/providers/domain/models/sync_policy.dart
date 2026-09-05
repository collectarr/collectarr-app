import 'package:flutter/foundation.dart';

enum SyncDirection {
  disabled,
  pullOnly,
  pushOnly,
  bidirectional,
}

enum SyncField {
  status,
  rating,
  progress,
  history,
}

@immutable
final class ProviderSyncPolicy {
  const ProviderSyncPolicy({
    this.status = SyncDirection.bidirectional,
    this.rating = SyncDirection.bidirectional,
    this.progress = SyncDirection.bidirectional,
    this.history = SyncDirection.pullOnly,
  });

  final SyncDirection status;
  final SyncDirection rating;
  final SyncDirection progress;
  final SyncDirection history;

  SyncDirection directionFor(SyncField field) {
    return switch (field) {
      SyncField.status => status,
      SyncField.rating => rating,
      SyncField.progress => progress,
      SyncField.history => history,
    };
  }

  bool allowsPull(SyncField field) {
    final direction = directionFor(field);
    return direction == SyncDirection.pullOnly ||
        direction == SyncDirection.bidirectional;
  }

  bool allowsPush(SyncField field) {
    final direction = directionFor(field);
    return direction == SyncDirection.pushOnly ||
        direction == SyncDirection.bidirectional;
  }

  Map<String, dynamic> toJson() => {
        'status': status.name,
        'rating': rating.name,
        'progress': progress.name,
        'history': history.name,
      };

  factory ProviderSyncPolicy.fromJson(Map<String, dynamic> json) {
    return ProviderSyncPolicy(
      status: SyncDirection.values.asNameMap()[json['status']] ??
          SyncDirection.bidirectional,
      rating: SyncDirection.values.asNameMap()[json['rating']] ??
          SyncDirection.bidirectional,
      progress: SyncDirection.values.asNameMap()[json['progress']] ??
          SyncDirection.bidirectional,
      history: SyncDirection.values.asNameMap()[json['history']] ??
          SyncDirection.pullOnly,
    );
  }
}
