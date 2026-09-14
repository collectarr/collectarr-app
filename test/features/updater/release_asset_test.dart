import 'package:collectarr_app/features/updater/release_asset.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ReleaseAsset parsing', () {
    test('parses Windows MSIX asset correctly', () {
      final json = {
        'name': 'collectarr-0.2.0-windows-x64.msix',
        'browser_download_url': 'https://example.test/collectarr.msix',
        'size': 50000000,
        'content_type': 'application/octet-stream',
      };
      final asset = ReleaseAsset.fromJson(json);
      expect(asset.name, 'collectarr-0.2.0-windows-x64.msix');
      expect(asset.downloadUrl, 'https://example.test/collectarr.msix');
      expect(asset.size, 50000000);
      expect(asset.assetType, ReleaseAssetType.msix);
      expect(asset.runtimePlatform, AppUpdatePlatform.windows);
      expect(asset.architecture, 'x64');
      expect(asset.isNotEmpty, isTrue);
    });

    test('parses macOS DMG asset correctly', () {
      final json = {
        'name': 'collectarr-0.2.0-macos-arm64.dmg',
        'browser_download_url': 'https://example.test/collectarr.dmg',
        'size': 60000000,
      };
      final asset = ReleaseAsset.fromJson(json);
      expect(asset.assetType, ReleaseAssetType.dmg);
      expect(asset.runtimePlatform, AppUpdatePlatform.macOS);
      expect(asset.architecture, 'arm64');
    });

    test('parses Linux AppImage asset correctly', () {
      final json = {
        'name': 'collectarr-0.2.0-linux-x86_64.AppImage',
        'browser_download_url': 'https://example.test/collectarr.AppImage',
        'size': 70000000,
      };
      final asset = ReleaseAsset.fromJson(json);
      expect(asset.assetType, ReleaseAssetType.appImage);
      expect(asset.runtimePlatform, AppUpdatePlatform.linux);
      expect(asset.architecture, 'x64');
    });

    test('parses Android APK asset correctly', () {
      final json = {
        'name': 'collectarr-0.2.0-android-arm64.apk',
        'browser_download_url': 'https://example.test/collectarr.apk',
        'size': 30000000,
      };
      final asset = ReleaseAsset.fromJson(json);
      expect(asset.assetType, ReleaseAssetType.apk);
      expect(asset.runtimePlatform, AppUpdatePlatform.android);
      expect(asset.architecture, 'arm64');
    });
  });

  group('ReleaseAssetResolver', () {
    const resolver = ReleaseAssetResolver();

    final assets = [
      const ReleaseAsset(
        name: 'collectarr-windows-x64.zip',
        downloadUrl: 'https://example.test/win.zip',
        size: 1000,
        assetType: ReleaseAssetType.zip,
        runtimePlatform: AppUpdatePlatform.windows,
        architecture: 'x64',
      ),
      const ReleaseAsset(
        name: 'collectarr-windows-x64.exe',
        downloadUrl: 'https://example.test/win.exe',
        size: 2000,
        assetType: ReleaseAssetType.exe,
        runtimePlatform: AppUpdatePlatform.windows,
        architecture: 'x64',
      ),
      const ReleaseAsset(
        name: 'collectarr-windows-x64.msix',
        downloadUrl: 'https://example.test/win.msix',
        size: 3000,
        assetType: ReleaseAssetType.msix,
        runtimePlatform: AppUpdatePlatform.windows,
        architecture: 'x64',
      ),
      const ReleaseAsset(
        name: 'collectarr-macos.dmg',
        downloadUrl: 'https://example.test/mac.dmg',
        size: 4000,
        assetType: ReleaseAssetType.dmg,
        runtimePlatform: AppUpdatePlatform.macOS,
      ),
      const ReleaseAsset(
        name: 'collectarr-linux.deb',
        downloadUrl: 'https://example.test/linux.deb',
        size: 5000,
        assetType: ReleaseAssetType.deb,
        runtimePlatform: AppUpdatePlatform.linux,
      ),
      const ReleaseAsset(
        name: 'collectarr-linux.AppImage',
        downloadUrl: 'https://example.test/linux.AppImage',
        size: 6000,
        assetType: ReleaseAssetType.appImage,
        runtimePlatform: AppUpdatePlatform.linux,
      ),
      const ReleaseAsset(
        name: 'collectarr-android.apk',
        downloadUrl: 'https://example.test/android.apk',
        size: 7000,
        assetType: ReleaseAssetType.apk,
        runtimePlatform: AppUpdatePlatform.android,
      ),
    ];

    test('resolves Windows MSIX over EXE and ZIP', () {
      final resolved = resolver.resolve(
        assets: assets,
        targetPlatform: AppUpdatePlatform.windows,
      );
      expect(resolved, isNotNull);
      expect(resolved!.assetType, ReleaseAssetType.msix);
      expect(resolved.downloadUrl, 'https://example.test/win.msix');
    });

    test('resolves macOS DMG asset', () {
      final resolved = resolver.resolve(
        assets: assets,
        targetPlatform: AppUpdatePlatform.macOS,
      );
      expect(resolved, isNotNull);
      expect(resolved!.assetType, ReleaseAssetType.dmg);
      expect(resolved.downloadUrl, 'https://example.test/mac.dmg');
    });

    test('resolves Linux AppImage over DEB', () {
      final resolved = resolver.resolve(
        assets: assets,
        targetPlatform: AppUpdatePlatform.linux,
      );
      expect(resolved, isNotNull);
      expect(resolved!.assetType, ReleaseAssetType.appImage);
      expect(resolved.downloadUrl, 'https://example.test/linux.AppImage');
    });

    test('resolves Android APK asset', () {
      final resolved = resolver.resolve(
        assets: assets,
        targetPlatform: AppUpdatePlatform.android,
      );
      expect(resolved, isNotNull);
      expect(resolved!.assetType, ReleaseAssetType.apk);
      expect(resolved.downloadUrl, 'https://example.test/android.apk');
    });

    test('returns null when no matching platform assets are found', () {
      final resolved = resolver.resolve(
        assets: const [],
        targetPlatform: AppUpdatePlatform.windows,
      );
      expect(resolved, isNull);
    });
  });
}
