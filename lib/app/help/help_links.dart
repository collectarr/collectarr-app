import 'package:collectarr_app/core/config/project_links.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// Build numbers do not belong to release tags. Unpublished builds and
/// unavailable GitHub responses lead to the latest public release.
Future<Uri> releaseNotesUri(
    {required String version, required Dio client}) async {
  final latest = Uri.parse('$collectarrRepositoryUrl/releases/latest');
  final normalized = version.trim().split('+').first;
  if (!RegExp(r'^\d+\.\d+\.\d+(?:-[0-9A-Za-z.-]+)?$').hasMatch(normalized)) {
    return latest;
  }
  final tag = 'v$normalized';
  try {
    final response = await client.get<Map<String, dynamic>>(
      'https://api.github.com/repos/$kGitHubOwner/$kGitHubRepo/releases/tags/$tag',
      options: Options(
        headers: {'Accept': 'application/vnd.github+json'},
        receiveTimeout: const Duration(seconds: 4),
      ),
    );
    if (response.statusCode == 200 &&
        response.data?['tag_name'] == tag &&
        response.data?['draft'] != true) {
      return Uri.parse('$collectarrRepositoryUrl/releases/tag/$tag');
    }
  } catch (_) {
    // Missing, offline and rate-limited responses must not strand Help.
  }
  return latest;
}

Future<void> openCommunity(BuildContext context) =>
    _openHelp(context, () async => Uri.parse(collectarrCommunityUrl));

Future<void> openContactSupport(BuildContext context) =>
    _openHelp(context, () async => Uri.parse(collectarrSupportUrl));

Future<void> openWhatsNew(BuildContext context) => _openHelp(context, () async {
      final client =
          Dio(BaseOptions(connectTimeout: const Duration(seconds: 4)));
      try {
        final info = await PackageInfo.fromPlatform();
        return await releaseNotesUri(version: info.version, client: client);
      } catch (_) {
        return Uri.parse('$collectarrRepositoryUrl/releases/latest');
      } finally {
        client.close();
      }
    });

Future<void> _openHelp(
    BuildContext context, Future<Uri> Function() destination) async {
  try {
    final uri = await destination();
    if (await launchUrl(uri, mode: LaunchMode.externalApplication)) return;
  } catch (_) {
    // Keep the library usable if the OS cannot launch a browser.
  }
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
    content: Text('Could not open this help page in your browser.'),
  ));
}
