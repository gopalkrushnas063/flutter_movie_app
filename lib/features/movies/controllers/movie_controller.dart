
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_app/Utilities/enums.dart';
import 'package:movie_app/features/movies/models/movie_model.dart';
import 'package:movie_app/features/movies/services/movie_services.dart';
import 'package:movie_app/features/movies/viewModels/movie_view_model.dart';

final movieControllerProvider = StateNotifierProvider<MovieController, MovieViewModel>(
  (ref) => MovieController(MovieViewModel())..getMovies(),
);

// Update your MovieController to prevent duplicate loading
class MovieController extends StateNotifier<MovieViewModel> {
  MovieController(super.state);
  bool _isLoading = false;

  Future<void> getMovies({String? searchQuery}) async {
    if (state.hasReachedMax || _isLoading) return;
    
    _isLoading = true;
    state = state.copyWith(status: APIState.loading);
    
    try {
      List<MovieModel>? movies = await MovieServices.getMovies(
        state.currentPage,
        searchQuery: searchQuery ?? 'movie'
      );
      
      if (movies == null) {
        state = state.copyWith(status: APIState.error);
      } else if (movies.isEmpty) {
        state = state.copyWith(
          status: APIState.success,
          hasReachedMax: true,
        );
      } else {
        // Check for duplicates before adding
        final newMovies = movies.where((newMovie) => 
          !state.movies.any((existingMovie) => 
            existingMovie.imdbID == newMovie.imdbID)).toList();
            
        state = state.copyWith(
          status: APIState.success,
          movies: [...state.movies, ...newMovies],
          currentPage: newMovies.isEmpty ? state.currentPage : state.currentPage + 1,
          hasReachedMax: newMovies.isEmpty,
        );
      }
    } catch (e) {
      state = state.copyWith(status: APIState.error);
    } finally {
      _isLoading = false;
    }
  }
}
