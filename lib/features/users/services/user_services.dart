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
        throw Exception(
          'API request failed with status ${response.statusCode}',
        );
      } else {
        // Offline - store locally
        debugPrint("Offline: Storing user locally");
        await _database.addUser(name, job);
        return true;
      }
    } catch (e) {
      debugPrint("Error in addUser: $e");
      try {
        debugPrint("Fallback: Storing user locally after API failure");
        await _database.addUser(name, job);
        if (isOnline) {
          await SyncService.triggerSync();
        }
        return true;
      } catch (dbError) {
        debugPrint("Critical: Failed to store locally: $dbError");
        return false;
      }
    }
  }

  static Future<List<UserModel>?> getUsers(
    int page, {
    bool isOnline = true,
  }) async {
    if (isOnline) {
      try {
        var res = await Https.apiURL.get("/users?page=2");
        if (res.data != null && res.data['data'] is List) {
          final users =
              (res.data['data'] as List)
                  .map<UserModel>((e) => UserModel.fromJson(e))
                  .toList();

          if (page == 1) {
            await _database.cacheRemoteUsers(users);
          }
          return users;
        }
        return null;
      } catch (e) {
        debugPrint("Error fetching users: $e");
        return await _getCachedUsers();
      }
    } else {
      return await _getCachedUsers();
    }
  }

  static Future<List<UserModel>?> _getCachedUsers() async {
    try {
      final cachedUsers = await _database.getCachedRemoteUsers();
      if (cachedUsers.isNotEmpty) {
        debugPrint("Loaded ${cachedUsers.length} users from cache");
        return cachedUsers;
      }
      return null;
    } catch (e) {
      debugPrint("Error getting cached users: $e");
      return null;
    }
  }

  static Future<bool> hasCachedData() async {
    return await _database.hasCachedUsers();
  }
}
