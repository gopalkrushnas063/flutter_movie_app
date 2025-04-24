import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:movie_app/data/https.dart';
import 'package:movie_app/data/local/database.dart';
import 'package:movie_app/features/users/models/user_model.dart';
import 'package:movie_app/services/sync_service.dart';

class UserServices {
  static final AppDatabase _database = AppDatabase();

  static Future<bool> addUser(String name, String job) async {
    final connectivity = await Connectivity().checkConnectivity();
    final isOnline = connectivity != ConnectivityResult.none;
    
    try {
      if (isOnline) {
        // Try to post to API first
        debugPrint("Online: Attempting to add user directly to API");
        final response = await Https.apiURL.post(
          "/users",
          data: {"name": name, "job": job},
        );
        
        if (response.statusCode == 201) {
          debugPrint("Success: User added to API");
          return true;
        }
        throw Exception('API request failed with status ${response.statusCode}');
      } else {
        // Offline - store locally
        debugPrint("Offline: Storing user locally");
        await _database.addUser(name, job);
        // No need to trigger sync here because we know we're offline
        return true;
      }
    } catch (e) {
      debugPrint("Error in addUser: $e");
      // Fallback to local storage if online attempt fails
      try {
        debugPrint("Fallback: Storing user locally after API failure");
        await _database.addUser(name, job);
        if (isOnline) {
          // Schedule sync if we were supposedly online
          await SyncService.triggerSync();
        }
        return true; // We successfully stored locally at least
      } catch (dbError) {
        debugPrint("Critical: Failed to store locally: $dbError");
        return false; // Complete failure
      }
    }
  }
  
  static Future<List<UserModel>?> getUsers(int page) async {
    try {
      var res = await Https.apiURL.get("/users?page=$page");
      if (res.data != null && res.data['data'] is List) {
        return (res.data['data'] as List)
            .map<UserModel>((e) => UserModel.fromJson(e))
            .toList();
      }
      return null;
    } catch (e) {
      debugPrint("Error fetching users: $e");
      return null;
    }
  }
}