import 'dart:convert';

import 'package:collectarr_app/core/logging/recoverable_error.dart';
import 'package:collectarr_app/core/sync/sync_change.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Keeps rejected changes until the user decides. The pull after a rejection
/// replaces the local row, so this is the only copy of the rejected version.
class SyncConflictStore {
  static const _key = 'collectarr.sync.conflicts';
  static const _maxStored = 200;

  Future<List<SyncRejectedChange>> read() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final value = prefs.getString(_key);
      if (value == null) return const [];
      return (jsonDecode(value) as List)
          .cast<Map<String, dynamic>>()
          .map(SyncRejectedChange.fromStoredJson)
          .toList(growable: false);
    } catch (error, stackTrace) {
      logRecoverableError(
        source: 'sync',
        message: 'Failed to read the stored sync conflicts.',
        error: error,
        stackTrace: stackTrace,
      );
      return const [];
    }
  }

  Future<void> write(List<SyncRejectedChange> conflicts) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (conflicts.isEmpty) {
        await prefs.remove(_key);
        return;
      }
      final newest = conflicts.length > _maxStored
          ? conflicts.sublist(conflicts.length - _maxStored)
          : conflicts;
      await prefs.setString(
        _key,
        jsonEncode([for (final change in newest) change.toStoredJson()]),
      );
    } catch (error, stackTrace) {
      logRecoverableError(
        source: 'sync',
        message: 'Failed to store the sync conflicts.',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> clear() => write(const []);
}
