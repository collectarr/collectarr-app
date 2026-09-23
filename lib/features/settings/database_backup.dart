import 'dart:convert';
import 'dart:typed_data';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/sync/sync_cursor_store.dart';
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
      final rows = await db
          .customSelect(
            'SELECT * FROM ${_quoteIdentifier(table.actualTableName)}',
          )
          .get();
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
  /// Validates the entire backup before resetting sync state or touching rows.
  /// The queued changes table is part of the backup and is restored as-is.
  Future<void> import(Map<String, dynamic> data) async {
    final backup = await validate(data);
    // A restore has no trustworthy incremental-sync cursor. If the database
    // transaction later rolls back, a full pull is still the safe fallback.
    await SyncCursorStore().clear();
    await _replaceWith(backup);
  }

  /// Validates the backup header, complete table set, columns, nullability and
  /// SQLite value types without modifying the database.
  Future<ValidatedDatabaseBackup> validate(
    Map<String, dynamic> data,
  ) async {
    final version = data['_version'];
    if (version is! int || version != db.schemaVersion) {
      throw FormatException(
        'Unsupported database backup version: $version. '
        'Expected ${db.schemaVersion}.',
      );
    }
    final exportedAt = data['_exportedAt'];
    if (exportedAt is! String || DateTime.tryParse(exportedAt) == null) {
      throw const FormatException('Backup is missing a valid _exportedAt.');
    }

    final tables = db.allTables.toList(growable: false);
    final expectedKeys = <String>{
      '_version',
      '_exportedAt',
      for (final table in tables) table.actualTableName,
    };
    final actualKeys = data.keys.toSet();
    final missingKeys = expectedKeys.difference(actualKeys);
    final unexpectedKeys = actualKeys.difference(expectedKeys);
    if (missingKeys.isNotEmpty || unexpectedKeys.isNotEmpty) {
      throw FormatException(
        'Backup table set does not match this database schema. '
        'Missing: ${missingKeys.join(', ')}. '
        'Unexpected: ${unexpectedKeys.join(', ')}.',
      );
    }

    final validatedTables = <_ValidatedBackupTable>[];
    for (final table in tables) {
      final tableName = table.actualTableName;
      final rawRows = data[tableName];
      if (rawRows is! List) {
        throw FormatException('Backup table "$tableName" must be a list.');
      }
      final columns = await _readColumns(tableName);
      final columnNames = columns.map((column) => column.name).toSet();
      final rows = <Map<String, dynamic>>[];
      for (var index = 0; index < rawRows.length; index++) {
        final rawRow = rawRows[index];
        if (rawRow is! Map) {
          throw FormatException(
            'Backup table "$tableName" row $index must be an object.',
          );
        }
        final row = Map<String, dynamic>.from(rawRow);
        final rowNames = row.keys.toSet();
        final missingColumns = columnNames.difference(rowNames);
        final unexpectedColumns = rowNames.difference(columnNames);
        if (missingColumns.isNotEmpty || unexpectedColumns.isNotEmpty) {
          throw FormatException(
            'Backup table "$tableName" row $index has an invalid column set. '
            'Missing: ${missingColumns.join(', ')}. '
            'Unexpected: ${unexpectedColumns.join(', ')}.',
          );
        }
        rows.add({
          for (final column in columns)
            column.name: _validateValue(
              tableName: tableName,
              rowIndex: index,
              column: column,
              value: row[column.name],
            ),
        });
      }
      validatedTables.add(
        _ValidatedBackupTable(
          tableName: tableName,
          columns: columns,
          rows: rows,
        ),
      );
    }
    return ValidatedDatabaseBackup._(validatedTables);
  }

  Future<List<_BackupColumn>> _readColumns(String tableName) async {
    final rows = await db
        .customSelect('PRAGMA table_info(${_quoteIdentifier(tableName)})')
        .get();
    if (rows.isEmpty) {
      throw FormatException('Database table "$tableName" is unavailable.');
    }
    return [
      for (final row in rows)
        _BackupColumn(
          name: row.data['name'] as String,
          declaredType: (row.data['type'] as String? ?? '').toUpperCase(),
          isRequired: row.data['notnull'] == 1 || row.data['pk'] != 0,
        ),
    ];
  }

  Object? _validateValue({
    required String tableName,
    required int rowIndex,
    required _BackupColumn column,
    required Object? value,
  }) {
    if (value == null) {
      if (column.isRequired) {
        throw FormatException(
          'Backup table "$tableName" row $rowIndex is missing a value for '
          'required column "${column.name}".',
        );
      }
      return null;
    }

    final validValue = switch (column.declaredType) {
      final type when type.contains('INT') => value is int,
      final type
          when type.contains('CHAR') ||
              type.contains('CLOB') ||
              type.contains('TEXT') =>
        value is String,
      final type
          when type.contains('REAL') ||
              type.contains('FLOA') ||
              type.contains('DOUB') =>
        value is num,
      final type when type.contains('BLOB') || type.isEmpty =>
        value is Uint8List || _isByteList(value),
      _ => value is num || value is String,
    };
    if (!validValue) {
      throw FormatException(
        'Backup table "$tableName" row $rowIndex has an invalid value type '
        'for column "${column.name}".',
      );
    }
    if ((column.declaredType.contains('BLOB') || column.declaredType.isEmpty) &&
        value is List &&
        value is! Uint8List) {
      return Uint8List.fromList(value.cast<int>());
    }
    return value;
  }

  bool _isByteList(Object value) =>
      value is List &&
      value.every((entry) => entry is int && entry >= 0 && entry <= 255);

  Future<void> _replaceWith(ValidatedDatabaseBackup backup) async {
    await db.transaction(() async {
      // Clear all tables first.
      for (final table in backup.tables) {
        await db.customStatement(
          'DELETE FROM ${_quoteIdentifier(table.tableName)}',
        );
      }
      for (final table in backup.tables) {
        final quotedTableName = _quoteIdentifier(table.tableName);
        final columnNames = table.columns
            .map((column) => _quoteIdentifier(column.name))
            .join(', ');
        final placeholders = table.columns.map((_) => '?').join(', ');
        for (final row in table.rows) {
          await db.customInsert(
            'INSERT INTO $quotedTableName ($columnNames) VALUES ($placeholders)',
            variables: [
              for (final column in table.columns) Variable(row[column.name]),
            ],
          );
        }
      }
    });
  }

  /// Clear all rows from every table.
  Future<void> clearAll() async {
    // Clear removes the local queue with the rest of the tables. Resetting the
    // cursor makes the next sync pull a complete remote snapshot.
    await SyncCursorStore().clear();
    await db.transaction(() async {
      for (final table in db.allTables) {
        await db.customStatement(
          'DELETE FROM ${_quoteIdentifier(table.actualTableName)}',
        );
      }
    });
  }

  static String _quoteIdentifier(String value) =>
      '"${value.replaceAll('"', '""')}"';
}

final class ValidatedDatabaseBackup {
  const ValidatedDatabaseBackup._(this.tables);

  final List<_ValidatedBackupTable> tables;
}

final class _ValidatedBackupTable {
  const _ValidatedBackupTable({
    required this.tableName,
    required this.columns,
    required this.rows,
  });

  final String tableName;
  final List<_BackupColumn> columns;
  final List<Map<String, dynamic>> rows;
}

final class _BackupColumn {
  const _BackupColumn({
    required this.name,
    required this.declaredType,
    required this.isRequired,
  });

  final String name;
  final String declaredType;
  final bool isRequired;
}
