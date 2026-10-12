import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

const collectarrManualUrl = String.fromEnvironment(
  'COLLECTARR_MANUAL_URL',
  defaultValue: 'https://collectarr.github.io/collectarr-site/manual/',
);

/// One external manual, with contextual chapters for the active kind.
Uri userManualUri(
    {CatalogMediaKind? kind, String baseUrl = collectarrManualUrl}) {
  final base = Uri.parse(baseUrl);
  if (!base.hasAuthority ||
      !{'http', 'https'}.contains(base.scheme) ||
      base.userInfo.isNotEmpty ||
      base.hasQuery ||
      base.hasFragment) {
    throw ArgumentError.value(
        baseUrl, 'baseUrl', 'Expected an HTTP(S) manual root');
  }
  final path = base.path.endsWith('/') ? base.path : '${base.path}/';
  return base.replace(
      path: kind == null || kind.isUnknown
          ? path
          : '${path}kinds/${kind.apiValue}/');
}

Future<void> openUserManual(BuildContext context,
    {CatalogMediaKind? kind}) async {
  try {
    final opened = await launchUrl(userManualUri(kind: kind),
        mode: LaunchMode.externalApplication);
    if (opened) return;
  } catch (_) {
    // Surface browser launch failures without disrupting the current library.
  }
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Could not open the user manual in your browser.')));
}
