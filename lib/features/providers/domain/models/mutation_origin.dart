import 'package:collectarr_app/features/providers/domain/models/provider_id.dart';
import 'package:flutter/foundation.dart';

enum MutationSourceType {
  user,
  collectarrSync,
  externalProvider,
  fileImport,
}

@immutable
final class MutationOrigin {
  const MutationOrigin({
    required this.source,
    this.provider,
    this.accountId,
    this.syncRunId,
    this.timestamp,
  });

  final MutationSourceType source;
  final ProviderId? provider;
  final String? accountId;
  final String? syncRunId;
  final DateTime? timestamp;

  static const user = MutationOrigin(source: MutationSourceType.user);
  static const collectarrSync =
      MutationOrigin(source: MutationSourceType.collectarrSync);

  bool get shouldEchoToExternalProvider =>
      source == MutationSourceType.user ||
      source == MutationSourceType.collectarrSync;
}
