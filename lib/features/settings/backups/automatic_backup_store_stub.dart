import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/settings/backups/automatic_backup.dart';

AutomaticBackupStore createAutomaticBackupStore() =>
    const UnsupportedAutomaticBackupStore();

/// The web build has no folder to keep backup files in; Settings says so and
/// the JSON backup remains available there.
final class UnsupportedAutomaticBackupStore implements AutomaticBackupStore {
  const UnsupportedAutomaticBackupStore();

  @override
  bool get isSupported => false;

  @override
  Future<String> folderPath() async => '';

  @override
  Future<List<AutomaticBackup>> list() async => const [];

  @override
  Future<AutomaticBackup> create(
    LocalDatabase db, {
    required AutomaticBackupReason reason,
    required DateTime now,
  }) =>
      throw UnsupportedError('Automatic backups need a file system.');

  @override
  Future<int> prune({required int keepDays, required DateTime now}) async => 0;

  @override
  Future<Map<String, dynamic>> read(AutomaticBackup backup) =>
      throw UnsupportedError('Automatic backups need a file system.');
}
