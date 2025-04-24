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
      // Use the singleton instance within the isolate
      final database = AppDatabase(); 
      if (task == SyncService.syncTask) {
        await SyncService._syncUsers(database); // Pass the db instance
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
  // No longer need a static instance here, get it via factory or pass it
  // static final AppDatabase _database = AppDatabase(); 

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
      initialDelay: const Duration(seconds: 30), // Add initial delay
      constraints: Constraints(
        networkType: NetworkType.connected, // Only run when connected
      ),
    );
  }

  // Accept AppDatabase instance, required for background isolate
  static Future<void> _syncUsers(AppDatabase database) async { 
    final connectivityResults = await Connectivity().checkConnectivity();

    // No connectivity results or all are "none" type
    bool hasConnection = connectivityResults.isNotEmpty && 
                         connectivityResults.any((result) => result != ConnectivityResult.none);

    if (!hasConnection) {
      debugPrint("No connectivity, skipping sync");
      return;
    }
    
    // Use the passed database instance
    final unsyncedUsers = await database.getUnsyncedUsers(); 
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
             // Ensure correct parsing, handle potential String/int
             final idValue = response.data['id'];
             if (idValue is int) {
                remoteId = idValue;
             } else if (idValue is String) {
                remoteId = int.tryParse(idValue);
             }
          }
          
          // Use the passed database instance
          await database.markUserAsSynced(user.id, remoteId: remoteId); 
        } else {
          debugPrint("Failed to sync user ${user.id}: Status ${response.statusCode}");
        }
      } catch (e) {
         debugPrint("Error syncing user ${user.id}: $e");
         // Consider if retry logic is needed here or if periodic task is sufficient
      }
    }
  }

  static Future<void> triggerSync() async {
    // Check connectivity before scheduling
    final connectivityResults = await Connectivity().checkConnectivity();
    bool hasConnection = connectivityResults.isNotEmpty && 
                         connectivityResults.any((result) => result != ConnectivityResult.none);

    if (!hasConnection) {
      debugPrint("No connectivity, skipping manual sync trigger");
      return;
    }

    debugPrint("Triggering manual sync via WorkManager");
    // Only schedule the one-off task. Do NOT call _syncUsers directly.
    await Workmanager().registerOneOffTask(
      "manualSync-${DateTime.now().millisecondsSinceEpoch}", // Unique name
      syncTask,
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
      // Optional: Add a small delay to allow other startup tasks to complete
      initialDelay: const Duration(seconds: 5), 
    );

    // REMOVED: _syncUsers(); 
  }
}