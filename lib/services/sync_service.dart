import 'package:flutter/material.dart';
import 'package:movie_app/data/https.dart';
import 'package:movie_app/data/local/database.dart';
import 'package:workmanager/workmanager.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

// Make this a top-level function
@pragma('vm:entry-point') // Important for background execution
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    debugPrint("Background task $task started");
    try {
      if (task == SyncService.syncTask) {
        await SyncService._syncUsers();
      }
      return Future.value(true);
    } catch (e) {
      debugPrint("Background task failed: $e");
      return Future.value(false);
    }
  });
}

class SyncService {
  static const String syncTask = "syncUsersTask";
  static final AppDatabase _database = AppDatabase();

  static Future<void> initialize() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: true,
    );

    // Register periodic sync task
    await Workmanager().registerPeriodicTask(
      "periodicSync",
      syncTask,
      frequency: const Duration(minutes: 15),
      constraints: Constraints(
        networkType: NetworkType.connected, // Only run when connected
      ),
    );
  }

  static Future<void> _syncUsers() async {
    final connectivityResults = await Connectivity().checkConnectivity();

    // No connectivity results or all are "none" type
    bool hasConnection = connectivityResults.isNotEmpty && 
                         connectivityResults.any((result) => result != ConnectivityResult.none);

    if (!hasConnection) {
      debugPrint("No connectivity, skipping sync");
      return;
    }

    final unsyncedUsers = await _database.getUnsyncedUsers();
    debugPrint("Found ${unsyncedUsers.length} unsynced users to sync");

    for (final user in unsyncedUsers) {
      try {
        // Post to API
        final response = await Https.apiURL.post(
          "/users",
          data: {"name": user.name, "job": user.job},
        );

        if (response.statusCode == 201) {
          debugPrint("Successfully synced user ${user.id}");

          // If the API returns an ID, store it
          int? remoteId;
          if (response.data != null && response.data['id'] != null) {
            remoteId = int.tryParse(response.data['id'].toString());
          }

          await _database.markUserAsSynced(user.id, remoteId: remoteId);
        } else {
          debugPrint("Failed to sync user ${user.id}: ${response.statusCode}");
        }
      } catch (e) {
        debugPrint("Error syncing user ${user.id}: $e");
      }
    }
  }

  static Future<void> triggerSync() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      debugPrint("No connectivity, skipping manual sync");
      return;
    }

    debugPrint("Triggering manual sync");
    await Workmanager().registerOneOffTask(
      "manualSync-${DateTime.now().millisecondsSinceEpoch}",
      syncTask,
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
    );

    // Also attempt an immediate sync
    _syncUsers();
  }
}