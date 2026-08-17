import 'package:flutter/foundation.dart';

@immutable
class IgdbCredentials {
  const IgdbCredentials({
    required this.clientId,
    required this.userAccessToken,
  });

  /// Twitch / IGDB Client ID.
  final String clientId;

  /// Twitch / IGDB User Access Token (never secret client secret).
  final String userAccessToken;

  bool get isValid =>
      clientId.trim().isNotEmpty && userAccessToken.trim().isNotEmpty;

  Map<String, dynamic> toJson() => {
        'client_id': clientId,
        'user_access_token': userAccessToken,
      };

  factory IgdbCredentials.fromJson(Map<String, dynamic> json) =>
      IgdbCredentials(
        clientId: json['client_id']?.toString() ?? '',
        userAccessToken: json['user_access_token']?.toString() ?? '',
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IgdbCredentials &&
          runtimeType == other.runtimeType &&
          clientId == other.clientId &&
          userAccessToken == other.userAccessToken;

  @override
  int get hashCode => Object.hash(clientId, userAccessToken);
}
