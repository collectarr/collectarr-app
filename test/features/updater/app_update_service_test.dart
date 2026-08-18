import 'package:collectarr_app/features/updater/app_update_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Semver comparison', () {
    test('compares stable versions correctly', () {
      expect(isNewerVersion('0.1.0', '0.2.0'), isTrue);
      expect(isNewerVersion('0.2.0', '0.2.1'), isTrue);
      expect(isNewerVersion('0.2.1', '0.2.0'), isFalse);
      expect(isNewerVersion('0.2.0', '0.2.0'), isFalse);
    });

    test('compares beta vs stable correctly', () {
      expect(isNewerVersion('0.2.0-beta.1', '0.2.0'), isTrue);
      expect(isNewerVersion('0.2.0', '0.2.0-beta.1'), isFalse);
      expect(isNewerVersion('0.2.0-beta.1', '0.2.1-beta.1'), isTrue);
    });

    test('compares beta sequence numbers correctly', () {
      expect(isNewerVersion('0.2.0-beta.1', '0.2.0-beta.2'), isTrue);
      expect(isNewerVersion('0.2.0-beta.2', '0.2.0-beta.10'), isTrue);
      expect(isNewerVersion('0.2.0-beta.10', '0.2.0-beta.2'), isFalse);
    });

    test('ignores build metadata in version precedence', () {
      expect(isNewerVersion('0.2.0+1', '0.2.0+2'), isFalse);
      expect(isNewerVersion('0.2.0-beta.1+1', '0.2.0-beta.2+1'), isTrue);
    });
  });

  group('Update channel filtering', () {
    final stableRelease = GitHubRelease(
      version: '0.2.1',
      tagName: 'v0.2.1',
      name: 'v0.2.1',
      body: 'Stable release',
      publishedAt: DateTime.now(),
      msixDownloadUrl: 'https://example.com/app.msix',
      msixSize: 100,
      isPrerelease: false,
    );

    final betaRelease = GitHubRelease(
      version: '0.2.1-beta.1',
      tagName: 'v0.2.1-beta.1',
      name: 'v0.2.1-beta.1',
      body: 'Beta release',
      publishedAt: DateTime.now(),
      msixDownloadUrl: 'https://example.com/app.msix',
      msixSize: 100,
      isPrerelease: true,
    );

    final nightlyRelease = GitHubRelease(
      version: '0.2.1-nightly.20260726',
      tagName: 'v0.2.1-nightly.20260726',
      name: 'v0.2.1-nightly.20260726',
      body: 'Nightly release',
      publishedAt: DateTime.now(),
      msixDownloadUrl: 'https://example.com/app.msix',
      msixSize: 100,
      isPrerelease: true,
    );

    test('Stable channel excludes prereleases', () {
      expect(isReleaseAllowedForChannel(stableRelease, UpdateChannel.stable),
          isTrue);
      expect(isReleaseAllowedForChannel(betaRelease, UpdateChannel.stable),
          isFalse);
      expect(isReleaseAllowedForChannel(nightlyRelease, UpdateChannel.stable),
          isFalse);
    });

    test('Beta channel allows stable and beta but excludes nightly', () {
      expect(isReleaseAllowedForChannel(stableRelease, UpdateChannel.beta),
          isTrue);
      expect(
          isReleaseAllowedForChannel(betaRelease, UpdateChannel.beta), isTrue);
      expect(isReleaseAllowedForChannel(nightlyRelease, UpdateChannel.beta),
          isFalse);
    });

    test('Nightly channel allows all releases', () {
      expect(isReleaseAllowedForChannel(stableRelease, UpdateChannel.nightly),
          isTrue);
      expect(isReleaseAllowedForChannel(betaRelease, UpdateChannel.nightly),
          isTrue);
      expect(isReleaseAllowedForChannel(nightlyRelease, UpdateChannel.nightly),
          isTrue);
    });
  });

  group('GitHubRelease.fromJson platform asset resolution', () {
    test('resolves primaryAsset based on targetPlatform', () {
      final json = {
        'tag_name': 'v0.3.0',
        'name': 'Release v0.3.0',
        'body': 'Notes',
        'published_at': '2026-08-18T12:00:00Z',
        'prerelease': false,
        'assets': [
          {
            'name': 'collectarr-0.3.0-windows-x64.msix',
            'browser_download_url': 'https://example.test/app.msix',
            'size': 5000,
          },
          {
            'name': 'collectarr-0.3.0-macos.dmg',
            'browser_download_url': 'https://example.test/app.dmg',
            'size': 6000,
          },
        ],
      };

      final winRelease = GitHubRelease.fromJson(
        json,
        targetPlatform: AppUpdatePlatform.windows,
      );
      expect(winRelease.version, '0.3.0');
      expect(winRelease.primaryAsset, isNotNull);
      expect(winRelease.primaryAsset!.assetType, ReleaseAssetType.msix);
      expect(winRelease.downloadUrl, 'https://example.test/app.msix');
      expect(winRelease.msixDownloadUrl, 'https://example.test/app.msix');
      expect(winRelease.msixSize, 5000);

      final macRelease = GitHubRelease.fromJson(
        json,
        targetPlatform: AppUpdatePlatform.macOS,
      );
      expect(macRelease.primaryAsset, isNotNull);
      expect(macRelease.primaryAsset!.assetType, ReleaseAssetType.dmg);
      expect(macRelease.downloadUrl, 'https://example.test/app.dmg');
    });
  });
}
