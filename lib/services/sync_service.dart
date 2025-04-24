
// lib/services/sync_service.dart
import 'package:flutter/material.dart';
import 'package:movie_app/data/local/database.dart';
import 'package:movie_app/features/users/services/user_services.dart';
import 'package:workmanager/workmanager.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class SyncService {
  static const String syncTask = "syncUsersTask";
  static final AppDatabase _database = AppDatabase();

  static Future<void> initialize() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: true,
    );
    Workmanager().registerPeriodicTask(
      "1",
      syncTask,
      frequency: const Duration(minutes: 15),
    );
  }

  static void callbackDispatcher() {
    Workmanager().executeTask((task, inputData) async {
      if (task == syncTask) {
        await _syncUsers();
      }
      return Future.value(true);
    });
  }

  static Future<void> _syncUsers() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) return;

    final unsyncedUsers = await _database.getUnsyncedUsers();
    for (final user in unsyncedUsers) {
      try {
        final success = await UserServices.addUser(user.name, user.job);
        if (success) {
          await _database.markUserAsSynced(user.id);
        }
      } catch (e) {
        debugPrint("Error syncing user ${user.id}: $e");
      }
    }
  }

  static Future<void> triggerSync() async {
    await Workmanager().registerOneOffTask(
      "manualSync",
      syncTask,
    );
  }
}
