class MovieModel {
  final String imdbID;
  final String title;
  final String year;
  final String posterUrl;
  final String type;

  MovieModel({
    required this.imdbID,
    required this.title,
    required this.year,
    required this.posterUrl,
    required this.type,
  });

  factory MovieModel.fromJson(Map<String, dynamic> json) {
    return MovieModel(
      imdbID: json['imdbID'],
      title: json['Title'],
      year: json['Year'],
      posterUrl: json['Poster'] ?? '',
      type: json['Type'],
    );
  }
}


// // lib/features/movies/models/movie_model.dart
// class MovieModel {
//   final int id;
//   final String title;
//   final String overview;
//   final String posterPath;
//   final String releaseDate;
//   final double voteAverage;

//   MovieModel({
//     required this.id,
//     required this.title,
//     required this.overview,
//     required this.posterPath,
//     required this.releaseDate,
//     required this.voteAverage,
//   });

//   factory MovieModel.fromJson(Map<String, dynamic> json) {
//     return MovieModel(
//       id: json['id'],
//       title: json['title'],
//       overview: json['overview'],
//       posterPath: json['poster_path'] ?? '',
//       releaseDate: json['release_date'] ?? '',
//       voteAverage: (json['vote_average'] ?? 0).toDouble(),
//     );
//   }

//   String get posterUrl => posterPath.isNotEmpty 
//       ? "http://image.tmdb.org/t/p/w185/$posterPath"
//       : '';
// }
