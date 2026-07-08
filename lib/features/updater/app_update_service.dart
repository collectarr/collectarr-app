import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ---------------------------------------------------------------------------
// Configuration
// ---------------------------------------------------------------------------

const kGitHubOwner = 'collectarr';
const kGitHubRepo = 'collectarr-app';
const _kAutoCheckKey = 'collectarr.updater.auto_check';

class UpdateSettings {
  const UpdateSettings({this.autoCheck = true});

  final bool autoCheck;

  UpdateSettings copyWith({bool? autoCheck}) {
    return UpdateSettings(autoCheck: autoCheck ?? this.autoCheck);
  }

  static Future<UpdateSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    return UpdateSettings(
      autoCheck: prefs.getBool(_kAutoCheckKey) ?? true,
    );
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kAutoCheckKey, autoCheck);
  }
}

// ---------------------------------------------------------------------------
// Release info
// ---------------------------------------------------------------------------

class GitHubRelease {
  const GitHubRelease({
    required this.version,
    required this.tagName,
    required this.name,
    required this.body,
    required this.publishedAt,
    required this.msixDownloadUrl,
    required this.msixSize,
  });

  final String version; // e.g. "0.2.0-beta.1"
  final String tagName;
  final String name;
  final String body; // markdown release notes
  final DateTime publishedAt;
  final String msixDownloadUrl;
  final int msixSize; // bytes

  factory GitHubRelease.fromJson(Map<String, dynamic> json) {
    final assets = json['assets'] as List<dynamic>? ?? [];
    final msixAsset = assets.cast<Map<String, dynamic>>().firstWhere(
          (a) => (a['name'] as String? ?? '').endsWith('.msix'),
          orElse: () => <String, dynamic>{},
        );

    final tag = json['tag_name'] as String? ?? '';
    final version = tag.startsWith('v') ? tag.substring(1) : tag;

    return GitHubRelease(
      version: version,
      tagName: tag,
      name: json['name'] as String? ?? tag,
      body: json['body'] as String? ?? '',
      publishedAt: DateTime.tryParse(
            json['published_at'] as String? ?? '',
          ) ??
          DateTime.now(),
      msixDownloadUrl: msixAsset['browser_download_url'] as String? ?? '',
      msixSize: msixAsset['size'] as int? ?? 0,
    );
  }
}

// ---------------------------------------------------------------------------
// Version comparison
// ---------------------------------------------------------------------------

/// Returns true when [remote] is strictly newer than [local].
bool isNewerVersion(String local, String remote) {
  return _compareSemver(local, remote) > 0;
}

int _compareSemver(String local, String remote) {
  final l = _splitSemver(local);
  final r = _splitSemver(remote);

  for (var i = 0; i < 3; i++) {
    final cmp = r.core[i].compareTo(l.core[i]);
    if (cmp != 0) return cmp;
  }

  if (l.prerelease.isEmpty && r.prerelease.isEmpty) return 0;
  if (l.prerelease.isEmpty) return -1;
  if (r.prerelease.isEmpty) return 1;

  final length = l.prerelease.length < r.prerelease.length
      ? l.prerelease.length
      : r.prerelease.length;
  for (var i = 0; i < length; i++) {
    final left = l.prerelease[i];
    final right = r.prerelease[i];

    final leftNumber = int.tryParse(left);
    final rightNumber = int.tryParse(right);

    if (leftNumber != null && rightNumber != null) {
      final cmp = rightNumber.compareTo(leftNumber);
      if (cmp != 0) return cmp;
      continue;
    }

    if (leftNumber != null) return -1;
    if (rightNumber != null) return 1;

    final cmp = right.compareTo(left);
    if (cmp != 0) return cmp;
  }

  return r.prerelease.length.compareTo(l.prerelease.length);
}

({List<int> core, List<String> prerelease}) _splitSemver(String v) {
  final cleaned = v.startsWith('v') ? v.substring(1) : v;
  final withoutBuild = cleaned.split('+').first;
  final parts = withoutBuild.split('-');
  final coreParts = parts.first.split('.');
  return (
    core: [
      if (coreParts.isNotEmpty) int.tryParse(coreParts[0]) ?? 0 else 0,
      if (coreParts.length > 1) int.tryParse(coreParts[1]) ?? 0 else 0,
      if (coreParts.length > 2) int.tryParse(coreParts[2]) ?? 0 else 0,
    ],
    prerelease:
        parts.length > 1 ? parts.sublist(1).join('-').split('.') : const [],
  );
}

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

enum UpdateStatus {
  idle,
  checking,
  upToDate,
  updateAvailable,
  downloading,
  readyToInstall,
  installing,
  error,
}

class AppUpdateState {
  const AppUpdateState({
    this.status = UpdateStatus.idle,
    this.currentVersion = '',
    this.release,
    this.downloadProgress = 0.0,
    this.downloadedPath,
    this.errorMessage,
    this.settings = const UpdateSettings(),
  });

  final UpdateStatus status;
  final String currentVersion;
  final GitHubRelease? release;
  final double downloadProgress; // 0.0 – 1.0
  final String? downloadedPath;
  final String? errorMessage;
  final UpdateSettings settings;

  AppUpdateState copyWith({
    UpdateStatus? status,
    String? currentVersion,
    GitHubRelease? release,
    double? downloadProgress,
    String? downloadedPath,
    String? errorMessage,
    UpdateSettings? settings,
  }) {
    return AppUpdateState(
      status: status ?? this.status,
      currentVersion: currentVersion ?? this.currentVersion,
      release: release ?? this.release,
      downloadProgress: downloadProgress ?? this.downloadProgress,
      downloadedPath: downloadedPath ?? this.downloadedPath,
      errorMessage: errorMessage ?? this.errorMessage,
      settings: settings ?? this.settings,
    );
  }
}

// ---------------------------------------------------------------------------
// Controller
// ---------------------------------------------------------------------------

class AppUpdateController extends Notifier<AppUpdateState> {
  @override
  AppUpdateState build() {
    ref.onDispose(() {
      _cancelToken?.cancel();
      _dio.close();
    });
    init();
    return const AppUpdateState();
  }

  final _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
  ));

  CancelToken? _cancelToken;

  Future<void> init() async {
    final info = await PackageInfo.fromPlatform();
    final settings = await UpdateSettings.load();
    state = state.copyWith(
      currentVersion: info.version,
      settings: settings,
    );
    if (settings.autoCheck) {
      await checkForUpdate();
    }
  }

  Future<void> updateSettings(UpdateSettings settings) async {
    await settings.save();
    state = state.copyWith(settings: settings);
  }

  Future<void> checkForUpdate() async {
    if (state.status == UpdateStatus.checking ||
        state.status == UpdateStatus.downloading) {
      return;
    }
    state = state.copyWith(
      status: UpdateStatus.checking,
      errorMessage: null,
    );
    try {
      final url =
          'https://api.github.com/repos/$kGitHubOwner/$kGitHubRepo/releases?per_page=100';
      final response = await _dio.get<List<dynamic>>(url);
      if (response.data == null) {
        state = state.copyWith(
          status: UpdateStatus.error,
          errorMessage: 'Empty response from GitHub',
        );
        return;
      }
      GitHubRelease? release;
      for (final item in response.data!) {
        if (item is! Map<String, dynamic>) continue;
        if (item['draft'] as bool? ?? false) continue;
        final candidate = GitHubRelease.fromJson(item);
        if (candidate.msixDownloadUrl.isEmpty) continue;
        if (!isNewerVersion(state.currentVersion, candidate.version)) continue;
        release = candidate;
        break;
      }
      if (release == null) {
        state = state.copyWith(
          status: UpdateStatus.upToDate,
          release: null,
        );
        return;
      }
      state = state.copyWith(
        status: UpdateStatus.updateAvailable,
        release: release,
      );
    } on DioException catch (e) {
      state = state.copyWith(
        status: UpdateStatus.error,
        errorMessage: e.message ?? 'Network error while checking for updates',
      );
    } catch (e) {
      state = state.copyWith(
        status: UpdateStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> downloadUpdate() async {
    final release = state.release;
    if (release == null || release.msixDownloadUrl.isEmpty) return;

    _cancelToken = CancelToken();
    state = state.copyWith(
      status: UpdateStatus.downloading,
      downloadProgress: 0.0,
      errorMessage: null,
    );

    try {
      final tempDir = await getTemporaryDirectory();
      final fileName = 'collectarr-${release.version}.msix';
      final savePath = p.join(tempDir.path, fileName);

      await _dio.download(
        release.msixDownloadUrl,
        savePath,
        cancelToken: _cancelToken,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            state = state.copyWith(
              downloadProgress: received / total,
            );
          }
        },
      );

      state = state.copyWith(
        status: UpdateStatus.readyToInstall,
        downloadedPath: savePath,
        downloadProgress: 1.0,
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        state = state.copyWith(status: UpdateStatus.updateAvailable);
      } else {
        state = state.copyWith(
          status: UpdateStatus.error,
          errorMessage: e.message ?? 'Download failed',
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: UpdateStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  void cancelDownload() {
    _cancelToken?.cancel();
  }

  Future<void> installUpdate() async {
    final path = state.downloadedPath;
    if (path == null) return;

    state = state.copyWith(status: UpdateStatus.installing);
    try {
      // Launch the MSIX installer and exit the app.
      await Process.start(
        'powershell',
        ['-Command', 'Start-Process', '"$path"'],
        mode: ProcessStartMode.detached,
      );
      // The OS installer will handle the rest.
    } catch (e) {
      state = state.copyWith(
        status: UpdateStatus.error,
        errorMessage: 'Failed to launch installer: $e',
      );
    }
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final appUpdateProvider = NotifierProvider<AppUpdateController, AppUpdateState>(
  AppUpdateController.new,
);
