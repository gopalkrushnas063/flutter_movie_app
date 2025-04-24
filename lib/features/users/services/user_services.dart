
// lib/features/users/services/user_services.dart
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
        final response = await Https.apiURL.post(
          "/users",
          data: {"name": name, "job": job},
        );
        
        if (response.statusCode == 201) {
          return true;
        }
        throw Exception('API request failed');
      } else {
        // Offline - store locally
        await _database.addUser(name, job);
        await SyncService.triggerSync(); // Schedule sync for when online
        return true;
      }
    } catch (e) {
      // Fallback to local storage if online attempt fails
      await _database.addUser(name, job);
      if (isOnline) {
        await SyncService.triggerSync(); // Schedule sync if we were online
      }
      return false;
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