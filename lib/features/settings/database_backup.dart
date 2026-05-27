import 'dart:convert';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:drift/drift.dart';

/// Serializes all Drift tables to a JSON map and deserializes back.
class DatabaseBackup {
  const DatabaseBackup(this.db);

  final LocalDatabase db;

  /// Export every table as a JSON-encodable map keyed by table name.
  Future<Map<String, dynamic>> export() async {
    final result = <String, dynamic>{
      '_version': db.schemaVersion,
      '_exportedAt': DateTime.now().toUtc().toIso8601String(),
    };
    for (final table in db.allTables) {
      final rows = await db.customSelect(
        'SELECT * FROM ${table.actualTableName}',
      ).get();
      result[table.actualTableName] = [
        for (final row in rows) row.data,
      ];
    }
    return result;
  }

  /// Encode the full backup as a pretty-printed JSON string.
  Future<String> exportJson() async {
    final data = await export();
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  /// Import data from a previously exported JSON map.
  /// Clears all existing data first.
  Future<void> import(Map<String, dynamic> data) async {
    await db.customStatement('PRAGMA foreign_keys = OFF;');
    try {
    await db.transaction(() async {
      // Clear all tables first.
      for (final table in db.allTables) {
        await db.delete(table).go();
      }
      // Re-insert rows.
      for (final table in db.allTables) {
        final tableName = table.actualTableName;
        final rows = data[tableName];
        if (rows == null || rows is! List) continue;
        for (final row in rows) {
          if (row is! Map<String, dynamic>) continue;
          final columns = row.keys.toList();
          final placeholders = columns.map((_) => '?').join(', ');
          final columnNames = columns.join(', ');
          await db.customInsert(
            'INSERT INTO $tableName ($columnNames) VALUES ($placeholders)',
            variables: [
              for (final key in columns) Variable(row[key]),
            ],
          );
        }
      }
    });
    } finally {
      await db.customStatement('PRAGMA foreign_keys = ON;');
    }
  }

  /// Clear all rows from every table.
  Future<void> clearAll() async {
    await db.customStatement('PRAGMA foreign_keys = OFF;');
    try {
    await db.transaction(() async {
      for (final table in db.allTables) {
        await db.delete(table).go();
      }
    });
    } finally {
      await db.customStatement('PRAGMA foreign_keys = ON;');
    }
  }
}
