import 'package:collectarr_app/features/providers/domain/models/provider_id.dart';
import 'package:flutter/foundation.dart';

enum ProviderAuthType {
  oauth2,
  accessToken,
  apiKey,
  userToken,
  cookie,
}

@immutable
final class ProviderAccount {
  const ProviderAccount({
    required this.id,
    required this.provider,
    required this.displayName,
    required this.authType,
    this.remoteAccountId,
    this.remoteHandle,
    String? username,
    this.avatarUrl,
    this.connectedAt,
    this.lastSyncAt,
    this.enabledCapabilities = const {},
  }) : _username = username;

  /// Internal unique ID for the account
  final String id;
  final ProviderId provider;
  final String displayName;
  final ProviderAuthType authType;

  /// External provider account/user ID
  final String? remoteAccountId;

  /// External username/handle
  final String? remoteHandle;
  final String? _username;

  String? get username => remoteHandle ?? _username;
  final String? avatarUrl;
  final DateTime? connectedAt;
  final DateTime? lastSyncAt;
  final Set<String> enabledCapabilities;

  Map<String, dynamic> toJson() => {
        'id': id,
        'provider': provider.value,
        'displayName': displayName,
        'authType': authType.name,
        if (remoteAccountId != null) 'remoteAccountId': remoteAccountId,
        if (remoteHandle != null) 'remoteHandle': remoteHandle,
        if (username != null) 'username': username,
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
        if (connectedAt != null) 'connectedAt': connectedAt!.toIso8601String(),
        if (lastSyncAt != null) 'lastSyncAt': lastSyncAt!.toIso8601String(),
        'enabledCapabilities': enabledCapabilities.toList(),
      };

  factory ProviderAccount.fromJson(Map<String, dynamic> json) {
    return ProviderAccount(
      id: json['id']?.toString() ?? '',
      provider: ProviderId.fromValue(json['provider']?.toString()) ??
          ProviderId.aniList,
      displayName: json['displayName']?.toString() ?? '',
      authType: ProviderAuthType.values.asNameMap()[json['authType']] ??
          ProviderAuthType.accessToken,
      remoteAccountId: json['remoteAccountId']?.toString(),
      remoteHandle:
          json['remoteHandle']?.toString() ?? json['username']?.toString(),
      username: json['username']?.toString(),
      avatarUrl: json['avatarUrl']?.toString(),
      connectedAt: json['connectedAt'] != null
          ? DateTime.tryParse(json['connectedAt'].toString())
          : null,
      lastSyncAt: json['lastSyncAt'] != null
          ? DateTime.tryParse(json['lastSyncAt'].toString())
          : null,
      enabledCapabilities: Set<String>.from(
        (json['enabledCapabilities'] as List?) ?? const [],
      ),
    );
  }
}
