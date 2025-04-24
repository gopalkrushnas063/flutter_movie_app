
// lib/features/movies/viewModels/movie_detail_view_model.dart


import 'package:movie_app/Utilities/enums.dart';
import 'package:movie_app/features/movies/models/movie_detail_model.dart';

class MovieDetailViewModel {
  final APIState status;
  final MovieDetailModel? movie;
  final String? error;

  MovieDetailViewModel({
    this.status = APIState.initial,
    this.movie,
    this.error,
  });

  MovieDetailViewModel copyWith({
    APIState? status,
    MovieDetailModel? movie,
    String? error,
  }) {
    return MovieDetailViewModel(
      status: status ?? this.status,
      movie: movie ?? this.movie,
      error: error ?? this.error,
    );
  }
}
