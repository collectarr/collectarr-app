import 'dart:io';

enum AppUpdatePlatform {
  windows,
  macOS,
  linux,
  android,
  iOS,
  unknown;

  static AppUpdatePlatform current() {
    if (Platform.isWindows) return AppUpdatePlatform.windows;
    if (Platform.isMacOS) return AppUpdatePlatform.macOS;
    if (Platform.isLinux) return AppUpdatePlatform.linux;
    if (Platform.isAndroid) return AppUpdatePlatform.android;
    if (Platform.isIOS) return AppUpdatePlatform.iOS;
    return AppUpdatePlatform.unknown;
  }
}

enum ReleaseAssetType {
  msix,
  exe,
  zip,
  dmg,
  pkg,
  appImage,
  deb,
  rpm,
  tarGz,
  apk,
  unknown;

  static ReleaseAssetType fromFilename(String filename) {
    final lower = filename.toLowerCase();
    if (lower.endsWith('.msix')) return ReleaseAssetType.msix;
    if (lower.endsWith('.exe')) return ReleaseAssetType.exe;
    if (lower.endsWith('.dmg')) return ReleaseAssetType.dmg;
    if (lower.endsWith('.pkg')) return ReleaseAssetType.pkg;
    if (lower.endsWith('.appimage')) return ReleaseAssetType.appImage;
    if (lower.endsWith('.deb')) return ReleaseAssetType.deb;
    if (lower.endsWith('.rpm')) return ReleaseAssetType.rpm;
    if (lower.endsWith('.tar.gz') || lower.endsWith('.tgz')) {
      return ReleaseAssetType.tarGz;
    }
    if (lower.endsWith('.zip')) return ReleaseAssetType.zip;
    if (lower.endsWith('.apk')) return ReleaseAssetType.apk;
    return ReleaseAssetType.unknown;
  }
}

class ReleaseAsset {
  const ReleaseAsset({
    required this.name,
    required this.downloadUrl,
    required this.size,
    required this.assetType,
    this.platform,
    this.architecture,
    this.contentType,
  });

  const ReleaseAsset.empty()
      : name = '',
        downloadUrl = '',
        size = 0,
        assetType = ReleaseAssetType.unknown,
        platform = null,
        architecture = null,
        contentType = null;

  final String name;
  final String downloadUrl;
  final int size;
  final ReleaseAssetType assetType;
  final AppUpdatePlatform? platform;
  final String? architecture;
  final String? contentType;

  bool get isEmpty => downloadUrl.isEmpty;
  bool get isNotEmpty => downloadUrl.isNotEmpty;

  factory ReleaseAsset.fromJson(Map<String, dynamic> json) {
    final name = json['name'] as String? ?? '';
    final downloadUrl = json['browser_download_url'] as String? ?? '';
    final size = json['size'] as int? ?? 0;
    final contentType = json['content_type'] as String?;
    final assetType = ReleaseAssetType.fromFilename(name);

    AppUpdatePlatform? platform;
    final lowerName = name.toLowerCase();
    if (lowerName.contains('win') ||
        assetType == ReleaseAssetType.msix ||
        assetType == ReleaseAssetType.exe) {
      platform = AppUpdatePlatform.windows;
    } else if (lowerName.contains('mac') ||
        lowerName.contains('darwin') ||
        assetType == ReleaseAssetType.dmg ||
        assetType == ReleaseAssetType.pkg) {
      platform = AppUpdatePlatform.macOS;
    } else if (lowerName.contains('linux') ||
        assetType == ReleaseAssetType.appImage ||
        assetType == ReleaseAssetType.deb ||
        assetType == ReleaseAssetType.rpm) {
      platform = AppUpdatePlatform.linux;
    } else if (lowerName.contains('android') ||
        assetType == ReleaseAssetType.apk) {
      platform = AppUpdatePlatform.android;
    } else if (lowerName.contains('ios') || lowerName.contains('iphone')) {
      platform = AppUpdatePlatform.iOS;
    }

    String? architecture;
    if (lowerName.contains('x64') ||
        lowerName.contains('x86_64') ||
        lowerName.contains('amd64')) {
      architecture = 'x64';
    } else if (lowerName.contains('arm64') || lowerName.contains('aarch64')) {
      architecture = 'arm64';
    } else if (lowerName.contains('x86') || lowerName.contains('i386')) {
      architecture = 'x86';
    }

    return ReleaseAsset(
      name: name,
      downloadUrl: downloadUrl,
      size: size,
      assetType: assetType,
      platform: platform,
      architecture: architecture,
      contentType: contentType,
    );
  }
}

class ReleaseAssetResolver {
  const ReleaseAssetResolver();

  ReleaseAsset? resolve({
    required List<ReleaseAsset> assets,
    AppUpdatePlatform? targetPlatform,
    String? targetArchitecture,
  }) {
    if (assets.isEmpty) return null;
    final platform = targetPlatform ?? AppUpdatePlatform.current();

    final platformAssets = assets.where((a) {
      if (a.platform == null) return false;
      return a.platform == platform;
    }).toList();

    if (platformAssets.isEmpty) {
      // If no platform match, check if any generic zip or tar.gz exists
      return null;
    }

    // Filter or sort by architecture if specified
    var candidates = platformAssets;
    if (targetArchitecture != null) {
      final archMatches = platformAssets
          .where((a) =>
              a.architecture == null || a.architecture == targetArchitecture)
          .toList();
      if (archMatches.isNotEmpty) {
        candidates = archMatches;
      }
    }

    // Sort candidates by asset type preference for the target platform
    candidates.sort((a, b) {
      final aPriority = _typePriority(platform, a.assetType);
      final bPriority = _typePriority(platform, b.assetType);
      return aPriority.compareTo(bPriority);
    });

    return candidates.first;
  }

  int _typePriority(AppUpdatePlatform platform, ReleaseAssetType type) {
    switch (platform) {
      case AppUpdatePlatform.windows:
        switch (type) {
          case ReleaseAssetType.msix:
            return 1;
          case ReleaseAssetType.exe:
            return 2;
          case ReleaseAssetType.zip:
            return 3;
          default:
            return 10;
        }
      case AppUpdatePlatform.macOS:
        switch (type) {
          case ReleaseAssetType.dmg:
            return 1;
          case ReleaseAssetType.pkg:
            return 2;
          case ReleaseAssetType.zip:
            return 3;
          default:
            return 10;
        }
      case AppUpdatePlatform.linux:
        switch (type) {
          case ReleaseAssetType.appImage:
            return 1;
          case ReleaseAssetType.deb:
            return 2;
          case ReleaseAssetType.rpm:
            return 3;
          case ReleaseAssetType.tarGz:
            return 4;
          case ReleaseAssetType.zip:
            return 5;
          default:
            return 10;
        }
      case AppUpdatePlatform.android:
        switch (type) {
          case ReleaseAssetType.apk:
            return 1;
          default:
            return 10;
        }
      case AppUpdatePlatform.iOS:
      case AppUpdatePlatform.unknown:
        return 10;
    }
  }
}
