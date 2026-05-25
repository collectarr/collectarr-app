import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Severity levels for app log entries.
enum AppLogLevel { info, warning, error }

/// A single log entry captured at runtime.
class AppLogEntry {
  const AppLogEntry({
    required this.timestamp,
    required this.level,
    required this.source,
    required this.message,
    this.detail,
  });

  final DateTime timestamp;
  final AppLogLevel level;

  /// Short tag identifying the subsystem (e.g. "sync", "api", "collection").
  final String source;
  final String message;

  /// Optional extra detail such as a stack trace or diagnostic context.
  final String? detail;
}

/// In-memory ring-buffer log that keeps the most recent entries.
class AppLogNotifier extends Notifier<List<AppLogEntry>> {
  static const _maxEntries = 200;

  @override
  List<AppLogEntry> build() => const [];

  void log(
    AppLogLevel level,
    String source,
    String message, {
    String? detail,
  }) {
    final entry = AppLogEntry(
      timestamp: DateTime.now(),
      level: level,
      source: source,
      message: message,
      detail: detail,
    );
    final next = [...state, entry];
    if (next.length > _maxEntries) {
      state = next.sublist(next.length - _maxEntries);
    } else {
      state = next;
    }
  }

  void info(String source, String message, {String? detail}) =>
      log(AppLogLevel.info, source, message, detail: detail);

  void warn(String source, String message, {String? detail}) =>
      log(AppLogLevel.warning, source, message, detail: detail);

  void error(String source, String message, {String? detail}) =>
      log(AppLogLevel.error, source, message, detail: detail);

  void clear() => state = const [];
}

final appLogProvider =
    NotifierProvider<AppLogNotifier, List<AppLogEntry>>(AppLogNotifier.new);
