
// lib/features/movies/services/movie_detail_services.dart
import 'package:movie_app/data/https.dart';
import 'package:movie_app/features/movies/models/movie_detail_model.dart';

class MovieDetailServices {
  static Future<MovieDetailModel> getMovieDetail(int movieId) async {
    final res = await Https.movieApiURL.get("/movie/$movieId");
    if (res.data == null) {
      throw Exception('Failed to load movie details');
    }
    return MovieDetailModel.fromJson(res.data);
  }
}
