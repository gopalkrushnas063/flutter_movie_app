import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_app/Utilities/enums.dart';
import 'package:movie_app/features/movies/models/movie_detail_model.dart';
import 'package:movie_app/features/movies/services/movie_detail_services.dart';
import 'package:movie_app/features/movies/viewModels/movie_detail_view_model.dart';

final movieDetailControllerProvider = 
    FutureProvider.family<MovieDetailModel, String>((ref, imdbId) async {
  return await MovieDetailServices.getMovieDetail(imdbId);
});

class MovieDetailController extends StateNotifier<MovieDetailViewModel> {
  final String imdbId;

  MovieDetailController(this.imdbId) : super(MovieDetailViewModel()) {
    getMovieDetail();
  }

  Future<void> getMovieDetail() async {
    state = state.copyWith(status: APIState.loading);
    try {
      final movie = await MovieDetailServices.getMovieDetail(imdbId);
      state = state.copyWith(
        status: APIState.success,
        movie: movie,
      );
    } catch (e) {
      state = state.copyWith(
        status: APIState.error,
        error: e.toString(),
      );
    }
  }
}


// // lib/features/movies/controllers/movie_detail_controller.dart
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:movie_app/Utilities/enums.dart';
// import 'package:movie_app/features/movies/models/movie_detail_model.dart';
// import 'package:movie_app/features/movies/services/movie_detail_services.dart';
// import 'package:movie_app/features/movies/viewModels/movie_detail_view_model.dart';


// final movieDetailControllerProvider = 
//     FutureProvider.family<MovieDetailModel, int>((ref, movieId) async {
//   return await MovieDetailServices.getMovieDetail(movieId);
// });

// class MovieDetailController extends StateNotifier<MovieDetailViewModel> {
//   final int movieId;

//   MovieDetailController(this.movieId) : super(MovieDetailViewModel()) {
//     getMovieDetail();
//   }

//   Future<void> getMovieDetail() async {
//     state = state.copyWith(status: APIState.loading);
//     try {
//       final movie = await MovieDetailServices.getMovieDetail(movieId);
//       if (movie != null) {
//         state = state.copyWith(
//           status: APIState.success,
//           movie: movie,
//         );
//       } else {
//         state = state.copyWith(
//           status: APIState.error,
//           error: 'Failed to load movie details',
//         );
//       }
//     } catch (e) {
//       state = state.copyWith(
//         status: APIState.error,
//         error: e.toString(),
//       );
//     }
//   }
// }
