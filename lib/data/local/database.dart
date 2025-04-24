
// lib/data/local/database.dart
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

part 'database.g.dart';

class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get job => text()();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();
}

@DriftDatabase(tables: [Users])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  Future<List<User>> getUnsyncedUsers() async {
    return await (select(users)..where((u) => u.synced.equals(false))).get();
  }

  Future<int> addUser(String name, String job) async {
    return await into(users).insert(
      UsersCompanion.insert(name: name, job: job, synced: const Value(false)),
    );
  }

  Future<void> markUserAsSynced(int id) async {
    await (update(users)..where(
      (u) => u.id.equals(id),
    )).write(const UsersCompanion(synced: Value(true)));
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}