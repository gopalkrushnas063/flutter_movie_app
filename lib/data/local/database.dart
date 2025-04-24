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
  IntColumn get remoteId => integer().nullable()(); // For storing remote ID after sync
}

@DriftDatabase(tables: [Users])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // Get all unsynced users
  Future<List<User>> getUnsyncedUsers() async {
    return await (select(users)..where((u) => u.synced.equals(false))).get();
  }

  // Get all synced users
  Future<List<User>> getSyncedUsers() async {
    return await (select(users)..where((u) => u.synced.equals(true))).get();
  }

  // Add a new user locally
  Future<int> addUser(String name, String job) async {
    return await into(users).insert(
      UsersCompanion.insert(name: name, job: job, synced: const Value(false)),
    );
  }

  // Mark a user as synced and optionally update with remote ID
  Future<void> markUserAsSynced(int id, {int? remoteId}) async {
    await (update(users)..where(
      (u) => u.id.equals(id),
    )).write(UsersCompanion(
      synced: const Value(true),
      remoteId: remoteId != null ? Value(remoteId) : const Value.absent(),
    ));
  }
  
  // Get all users, sorted by sync status
  Future<List<User>> getAllUsers() async {
    return await (select(users)
      ..orderBy([
        (u) => OrderingTerm(expression: u.synced, mode: OrderingMode.desc),
        (u) => OrderingTerm(expression: u.id, mode: OrderingMode.desc),
      ])
    ).get();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}