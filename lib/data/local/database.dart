// import 'package:drift/drift.dart';
// import 'package:drift/native.dart';
// import 'package:flutter/material.dart' show debugPrint;
// import 'package:movie_app/features/users/models/user_model.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:path/path.dart' as p;
// import 'dart:io';

// part 'database.g.dart';

// class Users extends Table {
//   IntColumn get id => integer().autoIncrement()();
//   TextColumn get name => text()();
//   TextColumn get job => text()();
//   BoolColumn get synced => boolean().withDefault(const Constant(false))();
//   IntColumn get remoteId => integer().nullable()(); // For storing remote ID after sync
// }

// class RemoteUsers extends Table {
//   IntColumn get id => integer()();
//   TextColumn get email => text()();
//   TextColumn get firstName => text()();
//   TextColumn get lastName => text()();
//   TextColumn get avatar => text()();
//   DateTimeColumn get cachedAt => dateTime().withDefault(currentDateAndTime)();
// }

// @DriftDatabase(tables: [Users, RemoteUsers])
// class AppDatabase extends _$AppDatabase {
//   AppDatabase._internal() : super(_openConnection());

//   static final AppDatabase _instance = AppDatabase._internal();

//   factory AppDatabase() {
//     return _instance;
//   }

//   @override
//   int get schemaVersion => 2;

//   @override
//   MigrationStrategy get migration => MigrationStrategy(
//     onCreate: (Migrator m) {
//       return m.createAll();
//     },
//     onUpgrade: (Migrator m, int from, int to) async {
//       if (from < 2) {
//         await m.createTable(remoteUsers);
//       }
//     },
//     beforeOpen: (details) async {
//       await customStatement('PRAGMA foreign_keys = ON');
//       if (details.wasCreated) {
//         debugPrint("Database was created at version ${details.versionNow}");
//       } else if (details.hadUpgrade) {
//         debugPrint("Database was upgraded from version ${details.versionBefore} to ${details.versionNow}");
//       }
//     },
//   );

//   Future<List<User>> getUnsyncedUsers() async {
//     return await (select(users)..where((u) => u.synced.equals(false))).get();
//   }

//   Future<List<User>> getSyncedUsers() async {
//     return await (select(users)..where((u) => u.synced.equals(true))).get();
//   }

//   Future<int> addUser(String name, String job) async {
//     return await into(users).insert(
//       UsersCompanion.insert(name: name, job: job, synced: const Value(false)),
//     );
//   }

//   Future<void> markUserAsSynced(int id, {int? remoteId}) async {
//     await (update(users)..where(
//       (u) => u.id.equals(id),
//     )).write(UsersCompanion(
//       synced: const Value(true),
//       remoteId: remoteId != null ? Value(remoteId) : const Value.absent(),
//     ));
//   }
  
//   Future<List<User>> getAllUsers() async {
//     return await (select(users)
//       ..orderBy([
//         (u) => OrderingTerm(expression: u.synced, mode: OrderingMode.desc),
//         (u) => OrderingTerm(expression: u.id, mode: OrderingMode.desc),
//       ])
//     ).get();
//   }

//   Future<void> cacheRemoteUsers(List<UserModel> users) async {
//     try {
//       await batch((batch) {
//         batch.deleteAll(remoteUsers);
        
//         for (final user in users) {
//           batch.insert(
//             remoteUsers,
//             RemoteUsersCompanion.insert(
//               id: user.id,
//               email: user.email,
//               firstName: user.firstName,
//               lastName: user.lastName,
//               avatar: user.avatar,
//             ),
//           );
//         }
//       });
//       debugPrint("Cached ${users.length} remote users");
//     } catch (e) {
//       debugPrint("Error caching remote users: $e");
//       if (e.toString().contains('no such table')) {
//         debugPrint("Attempting to create RemoteUsers table manually");
//         try {
//           await transaction(() async {
//             await customStatement('''
//               CREATE TABLE IF NOT EXISTS remote_users (
//                 id INTEGER NOT NULL PRIMARY KEY,
//                 email TEXT NOT NULL,
//                 first_name TEXT NOT NULL,
//                 last_name TEXT NOT NULL,
//                 avatar TEXT NOT NULL,
//                 cached_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
//               )
//             ''');
//           });
//           await cacheRemoteUsers(users);
//         } catch (retryError) {
//           debugPrint("Failed to manually create table: $retryError");
//         }
//       }
//     }
//   }
  
//   Future<List<UserModel>> getCachedRemoteUsers() async {
//     try {
//       final cachedUsers = await select(remoteUsers).get();
      
//       return cachedUsers.map((user) => UserModel(
//         id: user.id,
//         email: user.email,
//         firstName: user.firstName,
//         lastName: user.lastName,
//         avatar: user.avatar,
//       )).toList();
//     } catch (e) {
//       debugPrint("Error getting cached users: $e");
//       return [];
//     }
//   }
  
//   Future<bool> hasCachedUsers() async {
//     try {
//       final count = await (select(remoteUsers)
//         ..limit(1))
//         .get()
//         .then((value) => value.length);
//       return count > 0;
//     } catch (e) {
//       debugPrint("Error checking cached users: $e");
//       return false;
//     }
//   }
  
//   Future<void> clearCachedUsers() async {
//     try {
//       await delete(remoteUsers).go();
//       debugPrint("Cleared all cached remote users");
//     } catch (e) {
//       debugPrint("Error clearing cached users: $e");
//     }
//   }
// }

// LazyDatabase _openConnection() {
//   return LazyDatabase(() async {
//     final dbFolder = await getApplicationDocumentsDirectory();
//     final file = File(p.join(dbFolder.path, 'db.sqlite'));
    
//     return NativeDatabase(file);
//   });
// }


import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart' show debugPrint;
import 'package:movie_app/features/users/models/user_model.dart';
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

class RemoteUsers extends Table {
  IntColumn get id => integer()();
  TextColumn get email => text()();
  TextColumn get firstName => text()();
  TextColumn get lastName => text()();
  TextColumn get avatar => text()();
  DateTimeColumn get cachedAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [Users, RemoteUsers])
class AppDatabase extends _$AppDatabase {
  // Private constructor with lazy initialization
  AppDatabase._internal() : super(_openConnection());
  
  // Singleton instance
  static AppDatabase? _instance;
  
  // Factory constructor that returns the singleton instance
  factory AppDatabase() {
    _instance ??= AppDatabase._internal();
    return _instance!;
  }

  // Flag to track if the database has been initialized
  bool _isInitialized = false;

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) {
      return m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        await m.createTable(remoteUsers);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      if (details.wasCreated) {
        debugPrint("Database was created at version ${details.versionNow}");
      } else if (details.hadUpgrade) {
        debugPrint("Database was upgraded from version ${details.versionBefore} to ${details.versionNow}");
      }
    },
  );

  // Method to perform heavy initialization tasks that can be deferred
  Future<void> initializeDatabase() async {
    if (_isInitialized) return;
    
    try {
      // Perform any additional initialization here
      // This could include creating indexes, validating data, etc.
      
      _isInitialized = true;
      debugPrint("Database fully initialized");
    } catch (e) {
      debugPrint("Error during database initialization: $e");
    }
  }

  Future<List<User>> getUnsyncedUsers() async {
    return await (select(users)..where((u) => u.synced.equals(false))).get();
  }

  Future<List<User>> getSyncedUsers() async {
    return await (select(users)..where((u) => u.synced.equals(true))).get();
  }

  Future<int> addUser(String name, String job) async {
    return await into(users).insert(
      UsersCompanion.insert(name: name, job: job, synced: const Value(false)),
    );
  }

  Future<void> markUserAsSynced(int id, {int? remoteId}) async {
    await (update(users)..where(
      (u) => u.id.equals(id),
    )).write(UsersCompanion(
      synced: const Value(true),
      remoteId: remoteId != null ? Value(remoteId) : const Value.absent(),
    ));
  }
  
  Future<List<User>> getAllUsers() async {
    return await (select(users)
      ..orderBy([
        (u) => OrderingTerm(expression: u.synced, mode: OrderingMode.desc),
        (u) => OrderingTerm(expression: u.id, mode: OrderingMode.desc),
      ])
    ).get();
  }

  Future<void> cacheRemoteUsers(List<UserModel> users) async {
    try {
      await batch((batch) {
        batch.deleteAll(remoteUsers);
        
        for (final user in users) {
          batch.insert(
            remoteUsers,
            RemoteUsersCompanion.insert(
              id: user.id,
              email: user.email,
              firstName: user.firstName,
              lastName: user.lastName,
              avatar: user.avatar,
            ),
          );
        }
      });
      debugPrint("Cached ${users.length} remote users");
    } catch (e) {
      debugPrint("Error caching remote users: $e");
      if (e.toString().contains('no such table')) {
        debugPrint("Attempting to create RemoteUsers table manually");
        try {
          await transaction(() async {
            await customStatement('''
              CREATE TABLE IF NOT EXISTS remote_users (
                id INTEGER NOT NULL PRIMARY KEY,
                email TEXT NOT NULL,
                first_name TEXT NOT NULL,
                last_name TEXT NOT NULL,
                avatar TEXT NOT NULL,
                cached_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
              )
            ''');
          });
          await cacheRemoteUsers(users);
        } catch (retryError) {
          debugPrint("Failed to manually create table: $retryError");
        }
      }
    }
  }
  
  Future<List<UserModel>> getCachedRemoteUsers() async {
    try {
      final cachedUsers = await select(remoteUsers).get();
      
      return cachedUsers.map((user) => UserModel(
        id: user.id,
        email: user.email,
        firstName: user.firstName,
        lastName: user.lastName,
        avatar: user.avatar,
      )).toList();
    } catch (e) {
      debugPrint("Error getting cached users: $e");
      return [];
    }
  }
  
  Future<bool> hasCachedUsers() async {
    try {
      final count = await (select(remoteUsers)
        ..limit(1))
        .get()
        .then((value) => value.length);
      return count > 0;
    } catch (e) {
      debugPrint("Error checking cached users: $e");
      return false;
    }
  }
  
  Future<void> clearCachedUsers() async {
    try {
      await delete(remoteUsers).go();
      debugPrint("Cleared all cached remote users");
    } catch (e) {
      debugPrint("Error clearing cached users: $e");
    }
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    
    return NativeDatabase(file);
  });
}