
// lib/features/movies/controllers/movie_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_app/Utilities/enums.dart';
import 'package:movie_app/features/movies/models/movie_model.dart';
import 'package:movie_app/features/movies/services/movie_services.dart';
import 'package:movie_app/features/movies/viewModels/movie_view_model.dart';


final movieControllerProvider = StateNotifierProvider<MovieController, MovieViewModel>(
  (ref) => MovieController(MovieViewModel()),
);

class MovieController extends StateNotifier<MovieViewModel> {
  MovieController(super.state);

  Future<void> getMovies() async {
    if (state.hasReachedMax) return;
    
    state = state.copyWith(status: APIState.loading);
    
    try {
      List<MovieModel>? movies = await MovieServices.getMovies(state.currentPage);
      
      if (movies == null || movies.isEmpty) {
        state = state.copyWith(
          status: APIState.success,
          hasReachedMax: true,
        );
      } else {
        state = state.copyWith(
          status: APIState.success,
          movies: [...state.movies ?? [], ...movies],
          currentPage: state.currentPage + 1,
          hasReachedMax: false,
        );
      }
    } catch (e) {
      state = state.copyWith(status: APIState.error);
    }
  }
}