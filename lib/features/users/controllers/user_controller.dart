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
        }
      }
    );
  }

  // Add a refresh parameter to the getUsers method
  Future<void> getUsers({bool refresh = false}) async {
    // Don't load more if we've reached the max pages or already loading
    if (state.hasReachedMax && !refresh || state.status == APIState.loading) return;

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
      final response = await Https.apiURL.get(
        "/users?page=${state.currentPage}",
      );

      if (response.data != null) {
        final List<UserModel> users =
            (response.data['data'] as List)
                .map<UserModel>((e) => UserModel.fromJson(e))
                .toList();

        final int totalPages = response.data['total_pages'];
        final bool hasReachedMax = state.currentPage >= totalPages;

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