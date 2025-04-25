
import 'package:flutter/material.dart';
import 'package:movie_app/data/https.dart';
import 'package:movie_app/features/movies/models/movie_model.dart';

class MovieServices {
  static Future<List<MovieModel>?> getMovies(int page, {String searchQuery = 'movie'}) async {
    try {
      var res = await Https.omdbApiURL.get("", queryParameters: {
        's': searchQuery,
        'type': 'movie',
        'page': page.toString(),
      });
      
      if (res.data['Response'] == 'True' && res.data['Search'] is List) {
        return (res.data['Search'] as List)
            .map<MovieModel>((e) => MovieModel.fromJson(e))
            .toList();
      }
      return null;
    } catch (e) {
      debugPrint("Error fetching movies: $e");
      return null;
    }
  }
}


// // lib/features/movies/services/movie_services.dart
// import 'package:flutter/material.dart';
// import 'package:movie_app/data/https.dart';
// import 'package:movie_app/features/movies/models/movie_model.dart';

// class MovieServices {
//   static Future<List<MovieModel>?> getMovies(int page) async {
//     try {
//       var res = await Https.movieApiURL.get("/discover/movie?page=$page");
//       if (res.data != null && res.data['results'] is List) {
//         return (res.data['results'] as List)
//             .map<MovieModel>((e) => MovieModel.fromJson(e))
//             .toList();
//       }
//       return null;
//     } catch (e) {
//       debugPrint("Error fetching movies: $e");
//       return null;
//     }
//   }
// }
