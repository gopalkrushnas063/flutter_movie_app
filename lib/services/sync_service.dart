// import 'package:flutter/material.dart';
// import 'package:movie_app/data/https.dart';
// import 'package:movie_app/data/local/database.dart';
// import 'package:workmanager/workmanager.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';

// // Make this a top-level function
// @pragma('vm:entry-point') // Important for background execution
// void callbackDispatcher() {
//   Workmanager().executeTask((task, inputData) async {
//     debugPrint("Background task $task started");
//     try {
//       // Use the singleton instance within the isolate
//       final database = AppDatabase(); 
//       if (task == SyncService.syncTask) {
//         await SyncService._syncUsers(database); // Pass the db instance
//       }
//       return Future.value(true);
//     } catch (e) {
//       debugPrint("Background task failed: $e");
//       return Future.value(false);
//     }
//   });
// }

// class SyncService {
//   static const String syncTask = "syncUsersTask";
//   // No longer need a static instance here, get it via factory or pass it
//   // static final AppDatabase _database = AppDatabase(); 

//   static Future<void> initialize() async {
//     await Workmanager().initialize(
//       callbackDispatcher,
//       isInDebugMode: true,
//     );

//     // Register periodic sync task
//     await Workmanager().registerPeriodicTask(
//       "periodicSync",
//       syncTask,
//       frequency: const Duration(minutes: 15),
//       initialDelay: const Duration(seconds: 30), // Add initial delay
//       constraints: Constraints(
//         networkType: NetworkType.connected, // Only run when connected
//       ),
//     );
//   }

//   // Accept AppDatabase instance, required for background isolate
//   static Future<void> _syncUsers(AppDatabase database) async { 
//     final connectivityResults = await Connectivity().checkConnectivity();

//     // No connectivity results or all are "none" type
//     bool hasConnection = connectivityResults.isNotEmpty && 
//                          connectivityResults.any((result) => result != ConnectivityResult.none);

//     if (!hasConnection) {
//       debugPrint("No connectivity, skipping sync");
//       return;
//     }
    
//     // Use the passed database instance
//     final unsyncedUsers = await database.getUnsyncedUsers(); 
//     debugPrint("Found ${unsyncedUsers.length} unsynced users to sync");

//     for (final user in unsyncedUsers) {
//       try {
//         // Post to API
//         final response = await Https.apiURL.post(
//           "/users",
//           data: {"name": user.name, "job": user.job},
//         );

//         if (response.statusCode == 201) {
//           debugPrint("Successfully synced user ${user.id}");

//           // If the API returns an ID, store it
//           int? remoteId;
//           if (response.data != null && response.data['id'] != null) {
//              // Ensure correct parsing, handle potential String/int
//              final idValue = response.data['id'];
//              if (idValue is int) {
//                 remoteId = idValue;
//              } else if (idValue is String) {
//                 remoteId = int.tryParse(idValue);
//              }
//           }
          
//           // Use the passed database instance
//           await database.markUserAsSynced(user.id, remoteId: remoteId); 
//         } else {
//           debugPrint("Failed to sync user ${user.id}: Status ${response.statusCode}");
//         }
//       } catch (e) {
//          debugPrint("Error syncing user ${user.id}: $e");
//          // Consider if retry logic is needed here or if periodic task is sufficient
//       }
//     }
//   }

//   static Future<void> triggerSync() async {
//     // Check connectivity before scheduling
//     final connectivityResults = await Connectivity().checkConnectivity();
//     bool hasConnection = connectivityResults.isNotEmpty && 
//                          connectivityResults.any((result) => result != ConnectivityResult.none);

//     if (!hasConnection) {
//       debugPrint("No connectivity, skipping manual sync trigger");
//       return;
//     }

//     debugPrint("Triggering manual sync via WorkManager");
//     // Only schedule the one-off task. Do NOT call _syncUsers directly.
//     await Workmanager().registerOneOffTask(
//       "manualSync-${DateTime.now().millisecondsSinceEpoch}", // Unique name
//       syncTask,
//       constraints: Constraints(
//         networkType: NetworkType.connected,
//       ),
//       // Optional: Add a small delay to allow other startup tasks to complete
//       initialDelay: const Duration(seconds: 5), 
//     );

//     // REMOVED: _syncUsers(); 
//   }
// }


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
      // Create database instance within the isolate
      final database = AppDatabase();
      
      if (task == SyncService.syncTask) {
        await SyncService._syncUsers(database);
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
  static bool _isInitialized = false;
  
  // Prevent multiple initialization attempts
  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      debugPrint("Initializing SyncService...");
      
      await Workmanager().initialize(
        callbackDispatcher,
        isInDebugMode: false, // Set to false for release mode
      );

      // Register periodic sync task with longer initial delay
      await Workmanager().registerPeriodicTask(
        "periodicSync",
        syncTask,
        frequency: const Duration(minutes: 15),
        initialDelay: const Duration(minutes: 3), // Longer delay to let app fully start
        constraints: Constraints(
          networkType: NetworkType.connected, // Only run when connected
          requiresBatteryNotLow: true, // Only run when battery is not low
        ),
        existingWorkPolicy: ExistingWorkPolicy.replace,
      );
      
      _isInitialized = true;
      debugPrint("SyncService initialized successfully");
    } catch (e) {
      debugPrint("Failed to initialize SyncService: $e");
    }
  }

  // Accept AppDatabase instance, required for background isolate
  static Future<void> _syncUsers(AppDatabase database) async {
    // Check connectivity before starting sync
    final connectivityResults = await Connectivity().checkConnectivity();
    bool hasConnection = connectivityResults.isNotEmpty && 
                         connectivityResults.any((result) => result != ConnectivityResult.none);

    if (!hasConnection) {
      debugPrint("No connectivity, skipping sync");
      return;
    }
    
    // Use the passed database instance
    final unsyncedUsers = await database.getUnsyncedUsers();
    
    if (unsyncedUsers.isEmpty) {
      debugPrint("No unsynced users to sync");
      return;
    }
    
    debugPrint("Found ${unsyncedUsers.length} unsynced users to sync");

    // Process in batches to avoid overwhelming the network
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
          
          // Add a small delay between API calls to avoid rate limiting
          await Future.delayed(const Duration(milliseconds: 250));
        } else {
          debugPrint("Failed to sync user ${user.id}: Status ${response.statusCode}");
        }
      } catch (e) {
         debugPrint("Error syncing user ${user.id}: $e");
         // Add a longer delay after an error
         await Future.delayed(const Duration(milliseconds: 500));
      }
    }
  }

  static Future<void> triggerSync() async {
    // Avoid triggering sync if not initialized
    if (!_isInitialized) {
      debugPrint("SyncService not initialized yet, skipping sync trigger");
      return;
    }
    
    // Check connectivity before scheduling
    final connectivityResults = await Connectivity().checkConnectivity();
    bool hasConnection = connectivityResults.isNotEmpty && 
                         connectivityResults.any((result) => result != ConnectivityResult.none);

    if (!hasConnection) {
      debugPrint("No connectivity, skipping manual sync trigger");
      return;
    }

    debugPrint("Triggering manual sync via WorkManager");
    // Use a unique name for one-off task
    final uniqueName = "manualSync-${DateTime.now().millisecondsSinceEpoch}";
    
    try {
      await Workmanager().registerOneOffTask(
        uniqueName,
        syncTask,
        constraints: Constraints(
          networkType: NetworkType.connected,
          requiresBatteryNotLow: true,
        ),
        initialDelay: const Duration(seconds: 10), // Delay to avoid immediate execution
      );
      debugPrint("Manual sync scheduled: $uniqueName");
    } catch (e) {
      debugPrint("Failed to schedule manual sync: $e");
    }
  }
}