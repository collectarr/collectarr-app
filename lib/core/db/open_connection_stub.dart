import 'package:drift/drift.dart';
import 'package:drift/native.dart';

QueryExecutor openConnection() {
  return NativeDatabase.memory();
}

