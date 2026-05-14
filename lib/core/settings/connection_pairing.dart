import 'dart:convert';

import 'package:collectarr_app/core/settings/connection_settings.dart';

class ConnectionPairing {
  static const prefix = 'collectarr-pair:v1:';

  const ConnectionPairing();

  String encode(ConnectionSettings settings) {
    final payload = jsonEncode({
      'version': 1,
      'metadata_base_url': _normalizeUrl(settings.metadataBaseUrl),
      'sync_base_url': _normalizeUrl(settings.syncBaseUrl),
      'sync_key': settings.syncKey.trim(),
    });
    return '$prefix${base64UrlEncode(utf8.encode(payload))}';
  }

  ConnectionSettings decode(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      throw const FormatException('Pairing code is empty');
    }
    final decoded = trimmed.startsWith(prefix)
        ? utf8.decode(base64Url.decode(trimmed.substring(prefix.length)))
        : trimmed;
    final json = jsonDecode(decoded);
    if (json is! Map<String, dynamic>) {
      throw const FormatException('Pairing code must contain an object');
    }
    final version = json['version'];
    if (version != null && version != 1) {
      throw FormatException('Unsupported pairing code version: $version');
    }
    final metadataBaseUrl = json['metadata_base_url'];
    final syncBaseUrl = json['sync_base_url'];
    final syncKey = json['sync_key'];
    if (metadataBaseUrl is! String ||
        syncBaseUrl is! String ||
        syncKey is! String) {
      throw const FormatException('Pairing code is missing connection fields');
    }
    return ConnectionSettings(
      metadataBaseUrl: _normalizeUrl(metadataBaseUrl),
      syncBaseUrl: _normalizeUrl(syncBaseUrl),
      syncKey: syncKey.trim(),
      isLoaded: true,
    );
  }

  String _normalizeUrl(String value) {
    return value.trim().replaceFirst(RegExp(r'/+$'), '');
  }
}
