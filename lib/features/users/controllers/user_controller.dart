
// lib/features/users/controllers/user_controller.dart
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_app/Utilities/enums.dart';
import 'package:movie_app/data/https.dart';
import 'package:movie_app/features/users/models/user_model.dart';
import 'package:movie_app/features/users/services/user_services.dart';
import 'package:movie_app/features/users/viewModels/user_view_model.dart';

final userControllerProvider =
    StateNotifierProvider<UserController, UserViewModel>(
      (ref) => UserController(UserViewModel()),
    );

class UserController extends StateNotifier<UserViewModel> {
  UserController(super.state);

  Future<void> checkConnectivity() async {
    final connectivity = await Connectivity().checkConnectivity();
    state = state.copyWith(isOnline: connectivity != ConnectivityResult.none);
  }

  Future<void> getUsers() async {
    // Don't load more if we've reached the max pages or already loading
    if (state.hasReachedMax || state.status == APIState.loading) return;

    state = state.copyWith(status: APIState.loading);

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
          users: [...state.users ?? [], ...users],
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

  // Future<bool> addUser(String name, String job) async {
  //   try {
  //     bool success = await UserServices.addUser(name, job);
  //     if (success) {
  //       // Refresh the list
  //       state = UserViewModel();
  //       await getUsers();
  //       return true;
  //     }
  //     return false;
  //   } catch (e) {
  //     return false;
  //   }
  // }

  // In your UserController
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