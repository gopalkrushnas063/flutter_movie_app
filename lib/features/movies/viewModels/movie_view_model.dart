
// lib/features/movies/viewModels/movie_view_model.dart
import 'package:movie_app/Utilities/enums.dart';
import 'package:movie_app/features/movies/models/movie_model.dart';

class MovieViewModel {
  final APIState status;
  final List<MovieModel>? movies;
  final int currentPage;
  final bool hasReachedMax;

  MovieViewModel({
    this.status = APIState.initial,
    this.movies,
    this.currentPage = 1,
    this.hasReachedMax = false,
  });

  MovieViewModel copyWith({
    APIState? status,
    List<MovieModel>? movies,
    int? currentPage,
    bool? hasReachedMax,
  }) {
    return MovieViewModel(
      status: status ?? this.status,
      movies: movies ?? this.movies,
      currentPage: currentPage ?? this.currentPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}
