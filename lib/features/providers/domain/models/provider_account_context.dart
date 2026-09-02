import 'package:collectarr_app/features/providers/domain/models/provider_id.dart';
import 'package:collectarr_app/features/providers/domain/models/sync_policy.dart';
import 'package:flutter/foundation.dart';

@immutable
final class ProviderAccountId {
  const ProviderAccountId(this.value);

  final String value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProviderAccountId &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

@immutable
final class ProviderAccountContext {
  const ProviderAccountContext({
    required this.accountId,
    required this.provider,
    this.remoteAccountId,
    this.remoteHandle,
    this.accessToken,
    this.credentials = const {},
    this.syncPolicy = const ProviderSyncPolicy(),
  });

  /// Internal identifier for the account (e.g. local UUID)
  final String accountId;

  /// External service provider
  final ProviderId provider;

  /// External provider account/user ID (e.g. AniList numeric userId '12345')
  final String? remoteAccountId;

  /// External username/handle (e.g. 'saitama')
  final String? remoteHandle;

  /// Auth token for API calls
  final String? accessToken;

  /// Extra credential key-value pairs
  final Map<String, String> credentials;

  /// Sync policy for this account
  final ProviderSyncPolicy syncPolicy;
}
