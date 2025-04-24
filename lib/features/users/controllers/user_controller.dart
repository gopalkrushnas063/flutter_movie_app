import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_app/Utilities/enums.dart';
import 'package:movie_app/data/https.dart';
import 'package:movie_app/features/users/models/user_model.dart';
import 'package:movie_app/features/users/services/user_services.dart';
import 'package:movie_app/features/users/viewModels/user_view_model.dart';
import 'package:movie_app/main.dart'; // Import to access the connectivity provider

final userControllerProvider =
    StateNotifierProvider<UserController, UserViewModel>(
      (ref) {
        // Get the current connectivity and pass it to the controller
        final connectivity = ref.watch(connectivityProvider);
        return UserController(
          UserViewModel(isOnline: connectivity != ConnectivityResult.none),
          ref, // Pass the ref to access providers
        );
      },
    );

class UserController extends StateNotifier<UserViewModel> {
  final Ref _ref;

  UserController(UserViewModel state, this._ref) : super(state) {
    // Listen to connectivity changes and update the isOnline flag
    _ref.listen<ConnectivityResult>(
      connectivityProvider, 
      (previous, newConnectivity) {
        final wasOffline = previous == ConnectivityResult.none;
        final isNowOnline = newConnectivity != ConnectivityResult.none;
        
        // Update the online status in the state
        state = state.copyWith(
          isOnline: isNowOnline
        );
        
        // If we're transitioning from offline to online, refresh data
        if (wasOffline && isNowOnline) {
          debugPrint("🔄 Connectivity restored - refreshing data");
          
          // Reset loading state if needed
          if (state.status == APIState.loading) {
            state = state.copyWith(status: APIState.initial);
          }
          
          // Trigger a refresh
          getUsers(refresh: true);
        } else if (!wasOffline && !isNowOnline) {
          // Just went offline - try to load from cache
          debugPrint("📵 Just went offline - loading from cache");
          _loadCachedUsers();
        }
      }
    );
    
    // Check for cache initially
    _checkInitialCache();
  }
  
  // Check if we have cache on startup
  Future<void> _checkInitialCache() async {
    final hasCache = await UserServices.hasCachedData();
    if (hasCache) {
      debugPrint("Found cached data on startup");
      if (!state.isOnline) {
        // If we're starting offline, load from cache
        await _loadCachedUsers();
      }
    }
  }
  
  // Load users from cache
  Future<void> _loadCachedUsers() async {
    if (state.status == APIState.loading) return;
    
    state = state.copyWith(status: APIState.loading);
    
    final cachedUsers = await UserServices.getUsers(1, isOnline: false);
    
    if (cachedUsers != null && cachedUsers.isNotEmpty) {
      state = state.copyWith(
        status: APIState.success,
        users: cachedUsers,
        currentPage: 2, // Set to 2 so we'll fetch page 2 when back online
        hasReachedMax: true, // Prevent pagination while offline
      );
    } else {
      state = state.copyWith(
        status: APIState.error,
        error: "No cached data available"
      );
    }
  }

  // Updated getUsers method
  Future<void> getUsers({bool refresh = false}) async {
    // Don't load more if we've reached the max pages or already loading
    if (state.hasReachedMax && !refresh || state.status == APIState.loading) return;

    // If we're offline, load from cache
    if (!state.isOnline) {
      await _loadCachedUsers();
      return;
    }

    // If refreshing, reset the page count
    if (refresh) {
      state = state.copyWith(
        status: APIState.loading,
        currentPage: 1,
        hasReachedMax: false,
        users: [], // Clear existing users when refreshing
      );
    } else {
      state = state.copyWith(status: APIState.loading);
    }

    try {
      final users = await UserServices.getUsers(state.currentPage, isOnline: true);
      
      if (users != null) {
        final bool hasReachedMax = users.isEmpty || users.length < 6; // Assuming 6 per page
        
        state = state.copyWith(
          status: APIState.success,
          users: refresh ? users : [...state.users ?? [], ...users],
          currentPage: state.currentPage + 1,
          hasReachedMax: hasReachedMax,
        );
      } else {
        state = state.copyWith(status: APIState.error);
      }
    } catch (e) {
      state = state.copyWith(status: APIState.error);
    }
  }


  Future<bool> addUser(String name, String job) async {
    try {
      // This will handle both online/offline cases
      final success = await UserServices.addUser(name, job);
      return success;
    } catch (e) {
      debugPrint("Error adding user: $e");
      return false;
    }
  }
}