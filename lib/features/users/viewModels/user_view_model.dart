
// lib/features/users/viewModels/user_view_model.dart
import 'package:movie_app/Utilities/enums.dart';
import 'package:movie_app/features/users/models/user_model.dart';

class UserViewModel {
  final APIState status;
  final List<UserModel>? users;
  final int currentPage;
  final bool hasReachedMax;
  final String? error;
  final bool isOnline; // Add this line

  UserViewModel({
    this.status = APIState.initial,
    this.users,
    this.currentPage = 1,
    this.hasReachedMax = false,
    this.error,
    this.isOnline = true, // Add default value
  });

  UserViewModel copyWith({
    APIState? status,
    List<UserModel>? users,
    int? currentPage,
    bool? hasReachedMax,
    String? error,
    bool? isOnline, // Add this parameter
  }) {
    return UserViewModel(
      status: status ?? this.status,
      users: users ?? this.users,
      currentPage: currentPage ?? this.currentPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      error: error ?? this.error,
      isOnline: isOnline ?? this.isOnline, // Include in copy
    );
  }
}
