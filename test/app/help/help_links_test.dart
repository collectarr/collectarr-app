import 'dart:convert';

import 'package:collectarr_app/app/help/help_links.dart';
import 'package:collectarr_app/app/shell/app_navigation_model.dart';
import 'package:collectarr_app/core/config/project_links.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Help keeps the reference order and external links preserve navigation',
      () {
    final links = appDrawerDestinations
        .where((destination) => destination.section == AppDrawerSection.help)
        .toList();
    expect(links.map((link) => link.label), [
      'Manual',
      'Community',
      'Contact Support',
      "What's New?",
      'Keyboard Shortcuts'
    ]);
    for (final link in links.take(4)) {
      expect(link.behavior, DrawerActionBehavior.externalLink);
      expect(link.routesAway, isFalse);
      expect(link.resetsToLibrary, isFalse);
    }
    expect(collectarrCommunityUrl,
        'https://github.com/collectarr/collectarr-app/discussions');
  });

  test('release notes open the installed release, excluding the build number',
      () async {
    final adapter =
        _ReleaseAdapter(200, {'tag_name': 'v1.0.0', 'draft': false});
    final client = Dio()..httpClientAdapter = adapter;
    addTearDown(client.close);
    expect((await releaseNotesUri(version: '1.0.0+42', client: client)).path,
        '/collectarr/collectarr-app/releases/tag/v1.0.0');
    expect(adapter.request!.uri.path,
        '/repos/collectarr/collectarr-app/releases/tags/v1.0.0');
  });

  test(
      'installed prerelease opens its own notes rather than a different stable release',
      () async {
    final client = Dio()
      ..httpClientAdapter = _ReleaseAdapter(200, {'tag_name': 'v0.2.0-beta.1'});
    addTearDown(client.close);
    expect(
        (await releaseNotesUri(version: '0.2.0-beta.1', client: client)).path,
        '/collectarr/collectarr-app/releases/tag/v0.2.0-beta.1');
  });

  for (final status in [404, 403, 500]) {
    test('release lookup $status falls back to latest', () async {
      final client = Dio()..httpClientAdapter = _ReleaseAdapter(status, {});
      addTearDown(client.close);
      expect((await releaseNotesUri(version: '9.8.7', client: client)).path,
          '/collectarr/collectarr-app/releases/latest');
    });
  }

  for (final body in [
    <String, dynamic>{},
    {'tag_name': 'v2.0.0'},
    {'tag_name': 'v1.0.0', 'draft': true}
  ]) {
    test('unverified release response $body falls back to latest', () async {
      final client = Dio()..httpClientAdapter = _ReleaseAdapter(200, body);
      addTearDown(client.close);
      expect((await releaseNotesUri(version: '1.0.0', client: client)).path,
          '/collectarr/collectarr-app/releases/latest');
    });
  }

  test('offline release lookup falls back without throwing', () async {
    final client = Dio()..httpClientAdapter = _ReleaseAdapter(null, {});
    addTearDown(client.close);
    expect((await releaseNotesUri(version: '1.0.0', client: client)).path,
        '/collectarr/collectarr-app/releases/latest');
  });

  test('unversioned builds do not send a GitHub lookup', () async {
    final adapter = _ReleaseAdapter(200, {});
    final client = Dio()..httpClientAdapter = adapter;
    addTearDown(client.close);
    expect((await releaseNotesUri(version: 'development', client: client)).path,
        '/collectarr/collectarr-app/releases/latest');
    expect(adapter.request, isNull);
  });
}

class _ReleaseAdapter implements HttpClientAdapter {
  _ReleaseAdapter(this.status, this.body);
  final int? status;
  final Map<String, dynamic> body;
  RequestOptions? request;

  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<List<int>>? requestStream, Future<void>? cancelFuture) async {
    request = options;
    if (status == null) {
      throw DioException.connectionError(
          requestOptions: options, reason: 'Offline');
    }
    return ResponseBody.fromString(jsonEncode(body), status!, headers: {
      Headers.contentTypeHeader: ['application/json'],
    });
  }

  @override
  void close({bool force = false}) {}
}
